# Full-factorial Monte Carlo grid over covariance structure and
# visit schedule for the visit-placement comparison reported in
# analysis/report/report.Rmd (2026-08-16 review, issue 2.4).
#
# This extends the earlier analytic-only scenario grid
# (run_scenario_grid.R) to a genuine Monte Carlo comparison: for
# each (covariance structure, visit schedule) cell, n_sims replicate
# trials are simulated and fit with REML (nlme::lme() for the
# random-slope structures, nlme::gls() with a matched correlation
# structure for compound symmetry and AR(1) plus error), so
# finite-sample REML/inference behavior is assessed, not just the
# closed-form asymptotic relative efficiency.
#
# Scope note: this grid deliberately excludes dropout. Adding a
# dropout mechanism requires a design decision (MCAR/MAR, rate,
# whether attrition is tied to visit timing) that only the author
# should make; see docs/pub_review_remediation_2026-08-20.md,
# "Deferred". This script factorizes over covariance structure and
# visit schedule only, all under complete data.
#
# Usage:
#   Rscript analysis/scripts/run_full_factorial.R [n_sims]
#
# Default n_sims is 1000 per cell (reduced from the main study's
# 2000 to keep the 5-structure x 4-schedule x 1000-replication grid
# inside a practical single-core runtime; each cell's MCSE is
# reported so this reduction is transparent, not hidden).

pkgload::load_all(".", quiet = TRUE)

args <- commandArgs(trailingOnly = TRUE)
n_sims <- if (length(args) >= 1) as.integer(args[[1]]) else 1000L

n_per_group <- 50
beta_0 <- 50
beta_1 <- -1.0
beta_2 <- 0
beta_3 <- 0.19
sigma <- 3.0
tau_0 <- 5.0
base_seed <- 20260820

schedules <- list(
  list(label = "Equal", times = c(0, 6, 12, 18, 24)),
  list(label = "Mild-clustered", times = c(0, 4, 8, 20, 24)),
  list(label = "Boundary-clustered", times = c(0, 2, 4, 20, 24)),
  list(label = "Extreme-clustered", times = c(0, 1, 2, 23, 24))
)

structures <- list(
  list(label = "Random slope", parameter = "tau_1 = 0.10",
       family = "random_slope", tau_1 = 0.10),
  list(label = "Random slope", parameter = "tau_1 = 0.30",
       family = "random_slope", tau_1 = 0.30),
  list(label = "Random slope", parameter = "tau_1 = 0.50",
       family = "random_slope", tau_1 = 0.50),
  list(label = "Compound symmetry", parameter = "tau_0 = 5.0",
       family = "compound_symmetry"),
  list(label = "AR(1) + error", parameter = "rho = 0.8",
       family = "ar1_error", rho = 0.8, sigma_ar = 4.0)
)

summarise_cell <- function(res, n_sims, beta_3) {
  res <- res[!is.na(res$est), ]
  n_conv <- nrow(res)
  if (n_conv < 2) {
    return(data.frame(
      n_converged = n_conv, n_sims = n_sims,
      bias = NA_real_, mcse_bias = NA_real_,
      empirical_se = NA_real_, mcse_empirical_se = NA_real_,
      mean_model_se = NA_real_, power = NA_real_,
      mcse_power = NA_real_
    ))
  }
  emp_se <- stats::sd(res$est)
  mcse_emp_se <- emp_se / sqrt(2 * (n_conv - 1))
  bias <- mean(res$est) - beta_3
  mcse_bias <- emp_se / sqrt(n_conv)
  power <- mean(res$pval < 0.05)
  mcse_power <- sqrt(power * (1 - power) / n_conv)
  data.frame(
    n_converged = n_conv, n_sims = n_sims,
    bias = bias, mcse_bias = mcse_bias,
    empirical_se = emp_se, mcse_empirical_se = mcse_emp_se,
    mean_model_se = mean(res$se), power = power,
    mcse_power = mcse_power
  )
}

run_cell <- function(structure, sched, seed) {
  set.seed(seed)
  times <- sched$times

  if (structure$family == "random_slope") {
    reps <- lapply(seq_len(n_sims), function(i) {
      run_one_sim(
        times = times, n_per_group = n_per_group, beta_0 = beta_0,
        beta_1 = beta_1, beta_2 = beta_2, beta_3 = beta_3,
        tau_0 = tau_0, tau_1 = structure$tau_1, tau_01 = 0,
        sigma = sigma
      )
    })
  } else {
    v_mat <- if (structure$family == "compound_symmetry") {
      cov_compound_symmetry(times, tau_0, sigma)
    } else {
      cov_ar1_error(times, sigma, structure$rho, structure$sigma_ar)
    }
    fit_structure <- if (structure$family == "compound_symmetry") {
      "compound_symmetry"
    } else {
      "ar1_error"
    }
    reps <- lapply(seq_len(n_sims), function(i) {
      run_one_sim_cov(
        times = times, n_per_group = n_per_group, beta_0 = beta_0,
        beta_1 = beta_1, beta_2 = beta_2, beta_3 = beta_3,
        v_mat = v_mat, structure = fit_structure
      )
    })
  }
  do.call(rbind, reps)
}

message(sprintf(
  "Running full factorial: %d structures x %d schedules x %d sims",
  length(structures), length(schedules), n_sims
))
t0 <- Sys.time()

cell_id <- 0L
rows <- list()
for (structure in structures) {
  for (sched in schedules) {
    cell_id <- cell_id + 1L
    seed <- base_seed + cell_id
    t_cell <- Sys.time()
    res <- run_cell(structure, sched, seed)
    cell_elapsed <- as.numeric(Sys.time() - t_cell, units = "secs")
    cell_summary <- summarise_cell(res, n_sims, beta_3)
    row <- cbind(
      data.frame(
        structure = structure$label,
        parameter = structure$parameter,
        schedule = sched$label,
        elapsed_seconds = cell_elapsed
      ),
      cell_summary
    )
    rows[[cell_id]] <- row
    message(sprintf(
      "  [%d/%d] %s (%s) x %s: power=%.3f, empirical_se=%.4f (%.1fs)",
      cell_id, length(structures) * length(schedules),
      structure$label, structure$parameter, sched$label,
      cell_summary$power, cell_summary$empirical_se, cell_elapsed
    ))
  }
}

factorial_grid <- do.call(rbind, rows)
rownames(factorial_grid) <- NULL

# Relative efficiency of each non-baseline schedule vs. Equal
# spacing, within structure, computed from the empirical variances
# of this same run (not a paired CRN comparison across schedules,
# since the covariance matrix itself changes with the schedule for
# the AR(1) and random-slope structures; see report.Rmd for
# discussion of this limitation relative to the CRN-paired primary
# comparison in run_simulation.R).
factorial_grid$relative_efficiency_vs_equal <- NA_real_
for (s in unique(factorial_grid$structure)) {
  for (p in unique(factorial_grid$parameter[factorial_grid$structure == s])) {
    idx <- which(factorial_grid$structure == s &
                   factorial_grid$parameter == p)
    eq_idx <- idx[factorial_grid$schedule[idx] == "Equal"]
    if (length(eq_idx) == 1 &&
          is.finite(factorial_grid$empirical_se[eq_idx])) {
      eq_se <- factorial_grid$empirical_se[eq_idx]
      factorial_grid$relative_efficiency_vs_equal[idx] <-
        (eq_se / factorial_grid$empirical_se[idx])^2
    }
  }
}

elapsed <- as.numeric(Sys.time() - t0, units = "secs")
message(sprintf("Full factorial finished in %.1f seconds", elapsed))

out <- list(
  grid = factorial_grid,
  params = list(
    n_per_group = n_per_group, beta_0 = beta_0, beta_1 = beta_1,
    beta_2 = beta_2, beta_3 = beta_3, sigma = sigma, tau_0 = tau_0,
    n_sims = n_sims, base_seed = base_seed
  ),
  schedules = schedules,
  structures = structures,
  run_info = list(
    elapsed_seconds = elapsed,
    r_version = R.version.string,
    nlme_version = as.character(utils::packageVersion("nlme")),
    generated_at = as.character(Sys.time())
  )
)

out_dir <- "analysis/data/derived_data"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
out_path <- file.path(out_dir, "factorial_grid.rds")
saveRDS(out, out_path)
message(sprintf("Saved: %s", out_path))
print(factorial_grid)
