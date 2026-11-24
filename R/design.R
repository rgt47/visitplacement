#' Corrected sum of squares of a visit schedule
#'
#' @param times Numeric vector of visit times.
#' @return Numeric scalar, \eqn{S_{tt} = \sum_j (t_j - \bar t)^2}.
#' @export
schedule_stt <- function(times) {
  sum((times - mean(times))^2)
}

#' Closed-form standard error of the treatment-by-time interaction
#'
#' Under the random-intercept, random-slope model of
#' [simulate_trial()] with complete, balanced data, the GLS
#' estimator of \eqn{\beta_3} equals the difference in arm means of
#' per-subject OLS slopes. Its variance is therefore
#' \eqn{(2 / n_g)(\sigma^2 / S_{tt} + \tau_1^2)}, where \eqn{n_g} is
#' the number of subjects per arm. The result does not depend on the
#' random-intercept variance or the intercept-slope covariance.
#' Setting `tau_1 = 0` gives the compound-symmetry case.
#'
#' @param times Numeric vector of visit times.
#' @param n_per_group Integer, subjects per arm.
#' @param tau_1 Numeric, SD of the random slope.
#' @param sigma Numeric, residual SD.
#' @return Numeric scalar, the standard error of \eqn{\hat\beta_3}.
#' @export
closed_form_se <- function(times, n_per_group, tau_1, sigma) {
  sqrt((2 / n_per_group) * (sigma^2 / schedule_stt(times) + tau_1^2))
}

#' Best schedule under a minimum spacing constraint
#'
#' Searches all schedules of `k` integer visit months on
#' `[0, study_end]` that include baseline and the final month and
#' whose consecutive visits are at least `min_gap` months apart. It
#' returns the schedule with the largest corrected sum of squares,
#' which minimizes the variance of \eqn{\hat\beta_3} for any
#' \eqn{\tau_1} under the model of [simulate_trial()].
#'
#' @param k Integer, number of visits (at least 3).
#' @param study_end Integer, final visit month.
#' @param min_gap Integer, minimum months between visits.
#' @return A list with elements `times` and `stt`.
#' @export
best_schedule <- function(k, study_end, min_gap) {
  stopifnot(k >= 3, min_gap >= 1)
  interior <- utils::combn(seq_len(study_end - 1), k - 2)
  keep <- apply(interior, 2, function(x) {
    all(diff(c(0, x, study_end)) >= min_gap)
  })
  if (!any(keep)) stop("no schedule satisfies min_gap")
  interior <- interior[, keep, drop = FALSE]
  stt <- apply(interior, 2, function(x) {
    schedule_stt(c(0, x, study_end))
  })
  i <- which.max(stt)
  list(times = c(0, interior[, i], study_end), stt = stt[i])
}

#' Expected-information GLS standard error under monotone dropout
#'
#' Computes the GLS standard error of \eqn{\hat\beta_3} under the
#' random-intercept, random-slope model when subjects drop out
#' monotonically, independently of their outcomes (MCAR). Each
#' dropout pattern contributes its own information matrix, weighted
#' by its expected frequency. The calculation is asymptotic and
#' assumes the variance components are known.
#'
#' @inheritParams analytic_gls_se
#' @param retention Numeric vector, the same length as `times`, of
#'   the probability that a subject is still observed at each visit.
#'   It must start at 1 and be non-increasing.
#' @return Numeric scalar, the standard error of \eqn{\hat\beta_3}.
#' @export
analytic_gls_se_dropout <- function(times, n_per_group, tau_0, tau_1,
                                    tau_01, sigma, retention) {
  k <- length(times)
  stopifnot(
    length(retention) == k,
    isTRUE(all.equal(retention[1], 1)),
    all(diff(retention) <= 0)
  )
  last_visit_prob <- c(-diff(retention), retention[k])
  info <- matrix(0, 4, 4)
  for (m in seq_len(k)) {
    if (last_visit_prob[m] <= 0) next
    tt <- times[seq_len(m)]
    v_inv <- solve(cov_random_slope(tt, tau_0, tau_1, tau_01, sigma))
    x_ctrl <- cbind(1, tt, 0, 0)
    x_trt <- cbind(1, tt, 1, tt)
    info <- info + n_per_group * last_visit_prob[m] *
      (t(x_ctrl) %*% v_inv %*% x_ctrl + t(x_trt) %*% v_inv %*% x_trt)
  }
  sqrt(solve(info)[4, 4])
}

#' Visit retention under a constant dropout hazard
#'
#' @param times Numeric vector of visit times.
#' @param cum_dropout Numeric in `[0, 1)`, the probability of having
#'   dropped out by `study_end`.
#' @param study_end Numeric, final study month.
#' @return Numeric vector of retention probabilities at `times`.
#' @export
retention_constant_hazard <- function(times, cum_dropout, study_end) {
  (1 - cum_dropout)^(times / study_end)
}
