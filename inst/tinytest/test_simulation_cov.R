library(tinytest)

times_equal <- c(0, 6, 12, 18, 24)

# --- simulate_trial_cov() -------------------------------------------------

v_cs <- cov_compound_symmetry(times_equal, tau_0 = 5, sigma = 3)

set.seed(1)
dat <- simulate_trial_cov(
  times = times_equal, n_per_group = 20, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, v_mat = v_cs
)

expect_equal(
  nrow(dat), 40 * length(times_equal),
  info = "one row per subject-visit"
)
expect_true(
  all(c("id", "time", "group", "y") %in% names(dat)),
  info = "simulate_trial_cov returns the expected columns"
)
expect_true(
  all(!is.na(dat$y)),
  info = "no missing outcomes generated"
)

# --- run_one_sim_cov(): compound symmetry ---------------------------------

set.seed(2)
one_cs <- run_one_sim_cov(
  times = times_equal, n_per_group = 25, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, v_mat = v_cs, structure = "compound_symmetry"
)

expect_true(
  all(c("est", "se", "pval", "ci_lo", "ci_hi") %in% names(one_cs)),
  info = "run_one_sim_cov returns the expected columns"
)
expect_true(
  !is.na(one_cs$est) && !is.na(one_cs$se) && one_cs$se > 0,
  info = "run_one_sim_cov converges under compound symmetry"
)

# --- run_one_sim_cov(): AR(1) plus error ----------------------------------

v_ar1 <- cov_ar1_error(times_equal, sigma = 1, rho = 0.7, sigma_ar = 3)

set.seed(3)
one_ar1 <- run_one_sim_cov(
  times = times_equal, n_per_group = 25, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, v_mat = v_ar1, structure = "ar1_error"
)

expect_true(
  !is.na(one_ar1$est) && !is.na(one_ar1$se) && one_ar1$se > 0,
  info = "run_one_sim_cov converges under AR(1) plus error"
)

# a passed-in `dat` is used as-is rather than regenerated
set.seed(4)
dat2 <- simulate_trial_cov(
  times = times_equal, n_per_group = 25, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, v_mat = v_cs
)
fit_a <- run_one_sim_cov(
  times = times_equal, n_per_group = 25, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, v_mat = v_cs, structure = "compound_symmetry",
  dat = dat2
)
fit_b <- run_one_sim_cov(
  times = times_equal, n_per_group = 25, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, v_mat = v_cs, structure = "compound_symmetry",
  dat = dat2
)
expect_equal(
  fit_a$est, fit_b$est,
  info = "passing the same dat gives identical fits (CRN support)"
)
