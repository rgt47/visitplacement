#' Simulate one trial dataset under a random-intercept, random-slope
#' linear mixed model
#'
#' @param times Numeric vector of visit times (months).
#' @param n_per_group Integer, number of subjects per arm.
#' @param beta_0 Numeric, fixed intercept.
#' @param beta_1 Numeric, fixed time slope (control arm).
#' @param beta_2 Numeric, baseline group effect.
#' @param beta_3 Numeric, treatment-by-time interaction.
#' @param tau_0 Numeric, SD of the random intercept.
#' @param tau_1 Numeric, SD of the random slope.
#' @param tau_01 Numeric, covariance between random intercept and slope.
#' @param sigma Numeric, residual SD.
#'
#' @return A data frame with one row per subject-visit, columns
#'   `id`, `visit`, `time`, `group`, `b0`, `b1`, `y`.
#' @export
simulate_trial <- function(times, n_per_group, beta_0,
                            beta_1, beta_2, beta_3,
                            tau_0, tau_1, tau_01, sigma) {
  n <- 2 * n_per_group
  k <- length(times)

  group <- rep(c(0, 1), each = n_per_group)
  id <- seq_len(n)

  re_cov <- matrix(c(tau_0^2, tau_01, tau_01, tau_1^2), 2, 2)
  re <- mvtnorm_re(n, re_cov)
  b0 <- re[, 1]
  b1 <- re[, 2]

  dat <- expand.grid(visit = seq_len(k), id = id)
  dat$time <- times[dat$visit]
  dat$group <- group[dat$id]
  dat$b0 <- b0[dat$id]
  dat$b1 <- b1[dat$id]
  dat$y <- (beta_0 + dat$b0) +
    (beta_1 + dat$b1) * dat$time +
    beta_2 * dat$group +
    beta_3 * dat$group * dat$time +
    stats::rnorm(nrow(dat), 0, sigma)

  dat$id <- factor(dat$id)
  dat
}

#' Draw correlated random-intercept, random-slope pairs
#'
#' Avoids a dependency on `mvtnorm` by drawing from the bivariate
#' normal via a Cholesky factorization, so that `tau_01 != 0` is
#' supported without an extra package dependency.
#'
#' @param n Integer, number of draws.
#' @param sigma_mat 2x2 covariance matrix.
#' @return An n x 2 matrix of draws.
#' @noRd
mvtnorm_re <- function(n, sigma_mat) {
  if (all(sigma_mat[upper.tri(sigma_mat)] == 0) &&
        sigma_mat[1, 1] >= 0 && sigma_mat[2, 2] >= 0) {
    z0 <- stats::rnorm(n, 0, sqrt(sigma_mat[1, 1]))
    z1 <- stats::rnorm(n, 0, sqrt(sigma_mat[2, 2]))
    return(cbind(z0, z1))
  }
  ch <- chol(sigma_mat)
  z <- matrix(stats::rnorm(n * 2), n, 2)
  z %*% ch
}

#' Fit one simulated trial and extract the treatment-by-time
#' interaction estimate
#'
#' @inheritParams simulate_trial
#' @param dat Optional pre-generated data frame from
#'   [simulate_trial()]; if `NULL` (the default) a new dataset is
#'   generated internally. Passing `dat` explicitly allows common
#'   random numbers to be reused across designs.
#'
#' @return A one-row data frame with columns `est`, `se`, `pval`,
#'   `ci_lo`, `ci_hi`. All are `NA` if the mixed model fit failed to
#'   converge.
#' @export
run_one_sim <- function(times, n_per_group, beta_0, beta_1, beta_2,
                         beta_3, tau_0, tau_1, tau_01, sigma,
                         dat = NULL) {
  if (is.null(dat)) {
    dat <- simulate_trial(
      times, n_per_group, beta_0, beta_1, beta_2, beta_3,
      tau_0, tau_1, tau_01, sigma
    )
  }

  fit <- tryCatch(
    nlme::lme(
      y ~ time * group,
      random = ~ time | id,
      data = dat,
      method = "REML",
      control = nlme::lmeControl(
        opt = "optim",
        maxIter = 200,
        msMaxIter = 200
      )
    ),
    error = function(e) NULL,
    warning = function(w) NULL
  )

  if (is.null(fit)) {
    return(
      data.frame(est = NA_real_, se = NA_real_, pval = NA_real_,
                 ci_lo = NA_real_, ci_hi = NA_real_)
    )
  }

  s <- summary(fit)
  coefs <- s$tTable
  row <- which(rownames(coefs) == "time:group")

  est <- coefs[row, "Value"]
  se <- coefs[row, "Std.Error"]
  pval <- coefs[row, "p-value"]
  df_res <- coefs[row, "DF"]
  ci_lo <- est - stats::qt(0.975, df_res) * se
  ci_hi <- est + stats::qt(0.975, df_res) * se

  data.frame(est = est, se = se, pval = pval, ci_lo = ci_lo,
             ci_hi = ci_hi)
}

#' Analytic (generalized least squares) standard error of the
#' treatment-by-time interaction
#'
#' Computes the exact large-sample GLS standard error of
#' \eqn{\hat\beta_3} under the random-intercept, random-slope data
#' generating model of [simulate_trial()], for a balanced two-arm
#' design with the given visit times. This is the closed-form
#' target that the Monte Carlo simulation estimates; see the
#' Reproducibility notes in `analysis/report/report.Rmd` (issue 2.3
#' of the 2026-08-16 review) for the derivation.
#'
#' @param times Numeric vector of visit times.
#' @param n_per_group Integer, subjects per arm.
#' @param tau_0 Numeric, SD of the random intercept.
#' @param tau_1 Numeric, SD of the random slope.
#' @param tau_01 Numeric, covariance between random intercept and
#'   slope.
#' @param sigma Numeric, residual SD.
#'
#' @return Numeric scalar, the GLS standard error of the
#'   treatment-by-time interaction coefficient.
#' @export
analytic_gls_se <- function(times, n_per_group, tau_0, tau_1,
                             tau_01, sigma) {
  k <- length(times)
  z_mat <- cbind(1, times)
  d_mat <- matrix(c(tau_0^2, tau_01, tau_01, tau_1^2), 2, 2)
  v_mat <- z_mat %*% d_mat %*% t(z_mat) + sigma^2 * diag(k)
  v_inv <- solve(v_mat)

  x_ctrl <- cbind(1, times, 0, 0)
  x_trt <- cbind(1, times, 1, times)

  info <- n_per_group * (t(x_ctrl) %*% v_inv %*% x_ctrl) +
    n_per_group * (t(x_trt) %*% v_inv %*% x_trt)

  info_inv <- solve(info)
  sqrt(info_inv[4, 4])
}

#' Run a paired Monte Carlo comparison of two visit designs
#'
#' Uses common random numbers: for each replication, the same
#' subject-level random effects and residual errors are reused for
#' both designs (matched on subject and visit index), so that the
#' Monte Carlo comparison of the two designs is a paired comparison
#' with much smaller Monte Carlo error than two independent
#' simulation arms (review issue 2.2).
#'
#' @param times_a,times_b Numeric vectors of visit times for the two
#'   designs, of equal length `k`.
#' @param n_sims Integer, number of Monte Carlo replications.
#' @inheritParams simulate_trial
#' @param seed Integer, RNG seed (set once before the loop).
#'
#' @return A list with elements `results_a`, `results_b` (data
#'   frames as returned by [run_one_sim()], with a `rep` column
#'   added) and `paired_diff`, the per-replication difference in
#'   `est` between design A and design B computed only for
#'   replications where both designs converged.
#' @export
run_paired_simulation <- function(times_a, times_b, n_per_group,
                                   beta_0, beta_1, beta_2, beta_3,
                                   tau_0, tau_1, tau_01, sigma,
                                   n_sims, seed = NULL) {
  stopifnot(length(times_a) == length(times_b))
  if (!is.null(seed)) set.seed(seed)

  n <- 2 * n_per_group
  k <- length(times_a)
  re_cov <- matrix(c(tau_0^2, tau_01, tau_01, tau_1^2), 2, 2)

  out_a <- vector("list", n_sims)
  out_b <- vector("list", n_sims)

  for (rep_i in seq_len(n_sims)) {
    group <- rep(c(0, 1), each = n_per_group)
    re <- mvtnorm_re(n, re_cov)
    b0 <- re[, 1]
    b1 <- re[, 2]
    eps <- matrix(stats::rnorm(n * k, 0, sigma), nrow = n, ncol = k)

    dat_a <- build_replicate(times_a, group, b0, b1, eps, beta_0,
                              beta_1, beta_2, beta_3)
    dat_b <- build_replicate(times_b, group, b0, b1, eps, beta_0,
                              beta_1, beta_2, beta_3)

    res_a <- run_one_sim(times_a, n_per_group, beta_0, beta_1,
                          beta_2, beta_3, tau_0, tau_1, tau_01,
                          sigma, dat = dat_a)
    res_b <- run_one_sim(times_b, n_per_group, beta_0, beta_1,
                          beta_2, beta_3, tau_0, tau_1, tau_01,
                          sigma, dat = dat_b)
    res_a$rep <- rep_i
    res_b$rep <- rep_i
    out_a[[rep_i]] <- res_a
    out_b[[rep_i]] <- res_b
  }

  results_a <- do.call(rbind, out_a)
  results_b <- do.call(rbind, out_b)

  both_ok <- !is.na(results_a$est) & !is.na(results_b$est)
  paired_diff <- results_a$est[both_ok] - results_b$est[both_ok]

  list(results_a = results_a, results_b = results_b,
       paired_diff = paired_diff)
}

#' Build one simulated replicate for a given design from shared
#' random draws
#'
#' @inheritParams run_paired_simulation
#' @param group Integer vector of group indicators, length `n`.
#' @param b0,b1 Numeric vectors of subject-level random effects,
#'   length `n`.
#' @param eps Numeric matrix of residual errors, `n` by `k`, shared
#'   across designs of matching `k` so the same random draw is used
#'   for the j-th visit regardless of when it occurs.
#' @return A data frame as produced by [simulate_trial()].
#' @noRd
build_replicate <- function(times, group, b0, b1, eps, beta_0,
                             beta_1, beta_2, beta_3) {
  n <- length(group)
  k <- length(times)
  id <- seq_len(n)

  dat <- expand.grid(visit = seq_len(k), id = id)
  dat$time <- times[dat$visit]
  dat$group <- group[dat$id]
  dat$b0 <- b0[dat$id]
  dat$b1 <- b1[dat$id]
  dat$eps <- eps[cbind(dat$id, dat$visit)]
  dat$y <- (beta_0 + dat$b0) +
    (beta_1 + dat$b1) * dat$time +
    beta_2 * dat$group +
    beta_3 * dat$group * dat$time +
    dat$eps

  dat$id <- factor(dat$id)
  dat
}
