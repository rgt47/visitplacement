# Simulation driver for the visit-placement Monte Carlo study
# reported in analysis/report/report.Rmd.
#
# Generates common-random-number (CRN) paired simulation results
# comparing the equal-spacing and boundary-clustered five-visit
# designs, plus a small analytic scenario grid over the random-slope
# variance. Output is saved as versioned .rds artifacts under
# analysis/data/derived_data/ so the manuscript can read real
# numbers via inline `r` expressions instead of hardcoded prose
# (2026-08-16 review, issue 2.8).
#
# Usage:
#   Rscript analysis/scripts/run_simulation.R [n_sims]
#
# Default n_sims is 2000, matching the original manuscript design.
# A reduced value (e.g. 200) is useful for a fast development check.

pkgload::load_all(".", quiet = TRUE)

args <- commandArgs(trailingOnly = TRUE)
n_sims <- if (length(args) >= 1) as.integer(args[[1]]) else 2000L

n_per_group <- 50
beta_0 <- 50
beta_1 <- -1.0
beta_2 <- 0
# Recalibrated from 0.5 to 0.19 so the equal-spacing design sits
# near 80% power instead of the ceiling (review issue 2.1); see
# report.Rmd, "Recalibration of the treatment effect" for the power
# calculation that motivates this value.
beta_3 <- 0.19
tau_0 <- 5.0
tau_1 <- 0.3
tau_01 <- 0.0
sigma <- 3.0
study_end <- 24
times_equal <- c(0, 6, 12, 18, 24)
times_clustered <- c(0, 2, 4, 20, 24)
seed <- 20260305

message(sprintf("Running paired simulation: n_sims = %d", n_sims))
t0 <- Sys.time()

paired <- run_paired_simulation(
  times_a = times_equal, times_b = times_clustered,
  n_per_group = n_per_group, beta_0 = beta_0, beta_1 = beta_1,
  beta_2 = beta_2, beta_3 = beta_3, tau_0 = tau_0, tau_1 = tau_1,
  tau_01 = tau_01, sigma = sigma, n_sims = n_sims, seed = seed
)

elapsed <- as.numeric(Sys.time() - t0, units = "secs")
message(sprintf("Simulation finished in %.1f seconds", elapsed))

summarise_design <- function(res, label) {
  res <- res[!is.na(res$est), ]
  n_conv <- nrow(res)
  emp_se <- stats::sd(res$est)
  # Monte Carlo SE of an empirical SD, per Morris, White, and
  # Crowther (2019, Statistics in Medicine), eq. for MCSE(SE-hat):
  # SE / sqrt(2 * (n_conv - 1)).
  mcse_emp_se <- emp_se / sqrt(2 * (n_conv - 1))
  bias <- mean(res$est) - beta_3
  mcse_bias <- emp_se / sqrt(n_conv)
  power <- mean(res$pval < 0.05)
  mcse_power <- sqrt(power * (1 - power) / n_conv)
  coverage <- mean(res$ci_lo <= beta_3 & beta_3 <= res$ci_hi)
  mcse_coverage <- sqrt(coverage * (1 - coverage) / n_conv)

  data.frame(
    design = label,
    n_converged = n_conv,
    n_sims = n_sims,
    mean_est = mean(res$est),
    bias = bias,
    mcse_bias = mcse_bias,
    empirical_se = emp_se,
    mcse_empirical_se = mcse_emp_se,
    mean_model_se = mean(res$se),
    power = power,
    mcse_power = mcse_power,
    coverage = coverage,
    mcse_coverage = mcse_coverage
  )
}

summary_df <- rbind(
  summarise_design(paired$results_a, "Equal"),
  summarise_design(paired$results_b, "Clustered")
)

paired_diff_mean <- mean(paired$paired_diff)
paired_diff_se <- stats::sd(paired$paired_diff) /
  sqrt(length(paired$paired_diff))

analytic_se_equal <- analytic_gls_se(
  times_equal, n_per_group, tau_0, tau_1, tau_01, sigma
)
analytic_se_clustered <- analytic_gls_se(
  times_clustered, n_per_group, tau_0, tau_1, tau_01, sigma
)

# Paired bootstrap for the relative efficiency (ratio of empirical
# variances). Resampling is over replication index (not individual
# estimates), which respects the CRN pairing and gives a Monte
# Carlo-error-aware interval for the efficiency contrast (review
# issue 2.2).
both_ok <- !is.na(paired$results_a$est) & !is.na(paired$results_b$est)
eq_est <- paired$results_a$est[both_ok]
cl_est <- paired$results_b$est[both_ok]
n_boot <- 2000L
boot_re <- numeric(n_boot)
for (i in seq_len(n_boot)) {
  idx <- sample(seq_along(eq_est), length(eq_est), replace = TRUE)
  boot_re[i] <- stats::var(eq_est[idx]) / stats::var(cl_est[idx])
}
relative_efficiency_boot <- list(
  point = stats::var(eq_est) / stats::var(cl_est),
  boot_se = stats::sd(boot_re),
  ci = stats::quantile(boot_re, c(0.025, 0.975))
)

sim_results <- list(
  params = list(
    n_per_group = n_per_group, beta_0 = beta_0, beta_1 = beta_1,
    beta_2 = beta_2, beta_3 = beta_3, tau_0 = tau_0, tau_1 = tau_1,
    tau_01 = tau_01, sigma = sigma, study_end = study_end,
    times_equal = times_equal, times_clustered = times_clustered,
    n_sims = n_sims, seed = seed
  ),
  summary = summary_df,
  paired_diff = list(
    n_pairs = length(paired$paired_diff),
    mean = paired_diff_mean,
    se = paired_diff_se
  ),
  analytic = data.frame(
    design = c("Equal", "Clustered"),
    analytic_se = c(analytic_se_equal, analytic_se_clustered)
  ),
  relative_efficiency = (analytic_se_equal / analytic_se_clustered)^2,
  relative_efficiency_boot = relative_efficiency_boot,
  raw = list(equal = paired$results_a, clustered = paired$results_b),
  run_info = list(
    elapsed_seconds = elapsed,
    r_version = R.version.string,
    nlme_version = as.character(utils::packageVersion("nlme")),
    generated_at = as.character(Sys.time())
  )
)

out_dir <- "analysis/data/derived_data"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
out_path <- file.path(out_dir, "sim_results.rds")
saveRDS(sim_results, out_path)
message(sprintf("Saved: %s", out_path))

print(summary_df)
