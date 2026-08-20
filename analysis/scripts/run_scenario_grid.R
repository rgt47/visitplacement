# Analytic-only scenario extension for the visit-placement
# comparison in analysis/report/report.Rmd.
#
# The main study (run_simulation.R) fixes one covariance structure
# (random intercept and slope) and two designs. This script computes
# the exact GLS relative efficiency of equal vs. clustered spacing
# across a small grid of covariance structures and random-slope
# variances, using the closed-form calculation in
# R/covariance.R -- no Monte Carlo simulation is needed because the
# quantity of interest (asymptotic relative efficiency) has a known
# closed form (2026-08-16 review, issue 2.3).
#
# This is explicitly NOT the full factorial simulation grid called
# for by the review (issue 2.4), which would additionally vary
# sample size, dropout, and simulate finite-sample REML behavior
# for each cell. That remains a documented TODO; see
# docs/pub_review_remediation_*.md.
#
# Usage: Rscript analysis/scripts/run_scenario_grid.R

pkgload::load_all(".", quiet = TRUE)

times_equal <- c(0, 6, 12, 18, 24)
times_clustered <- c(0, 2, 4, 20, 24)
n_per_group <- 50
sigma <- 3.0
tau_0 <- 5.0

# Random-slope structure: vary the random-slope SD relative to the
# base case (tau_1 = 0.3).
tau_1_grid <- c(0.10, 0.20, 0.30, 0.40, 0.50)

rs_rows <- lapply(tau_1_grid, function(tau_1) {
  se_eq <- analytic_gls_se(times_equal, n_per_group, tau_0, tau_1,
                            0, sigma)
  se_cl <- analytic_gls_se(times_clustered, n_per_group, tau_0,
                            tau_1, 0, sigma)
  data.frame(
    structure = "Random slope",
    parameter = sprintf("tau_1 = %.2f", tau_1),
    se_equal = se_eq,
    se_clustered = se_cl,
    relative_efficiency = (se_eq / se_cl)^2
  )
})

# Compound symmetry (random intercept only, tau_1 = 0): the
# theoretical anchor cited in the Introduction for the clustered
# design's motivation, included so the manuscript's structures are
# not limited to the one actually simulated.
v_cs_equal <- cov_compound_symmetry(times_equal, tau_0, sigma)
v_cs_clustered <- cov_compound_symmetry(times_clustered, tau_0, sigma)
se_cs_eq <- analytic_gls_se_general(times_equal, n_per_group,
                                     v_cs_equal)
se_cs_cl <- analytic_gls_se_general(times_clustered, n_per_group,
                                     v_cs_clustered)
cs_row <- data.frame(
  structure = "Compound symmetry",
  parameter = sprintf("tau_0 = %.1f", tau_0),
  se_equal = se_cs_eq,
  se_clustered = se_cs_cl,
  relative_efficiency = (se_cs_eq / se_cs_cl)^2
)

# AR(1) plus measurement error, at a moderate serial correlation.
rho <- 0.8
sigma_ar <- 4.0
v_ar1_equal <- cov_ar1_error(times_equal, sigma, rho, sigma_ar)
v_ar1_clustered <- cov_ar1_error(times_clustered, sigma, rho,
                                  sigma_ar)
se_ar1_eq <- analytic_gls_se_general(times_equal, n_per_group,
                                      v_ar1_equal)
se_ar1_cl <- analytic_gls_se_general(times_clustered, n_per_group,
                                      v_ar1_clustered)
ar1_row <- data.frame(
  structure = "AR(1) + error",
  parameter = sprintf("rho = %.1f", rho),
  se_equal = se_ar1_eq,
  se_clustered = se_ar1_cl,
  relative_efficiency = (se_ar1_eq / se_ar1_cl)^2
)

scenario_grid <- do.call(rbind, c(rs_rows, list(cs_row, ar1_row)))
rownames(scenario_grid) <- NULL

out_dir <- "analysis/data/derived_data"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
out_path <- file.path(out_dir, "scenario_grid.rds")
saveRDS(scenario_grid, out_path)
message(sprintf("Saved: %s", out_path))
print(scenario_grid)
