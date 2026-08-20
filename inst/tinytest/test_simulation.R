library(tinytest)

times_equal <- c(0, 6, 12, 18, 24)
times_clustered <- c(0, 2, 4, 20, 24)

# --- simulate_trial() -------------------------------------------------

set.seed(1)
dat <- simulate_trial(
  times = times_equal, n_per_group = 20, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, tau_0 = 5, tau_1 = 0.3, tau_01 = 0,
  sigma = 3
)

expect_equal(
  nrow(dat), 40 * length(times_equal),
  info = "one row per subject-visit"
)
expect_true(
  all(c("id", "time", "group", "y") %in% names(dat)),
  info = "simulate_trial returns the expected columns"
)
expect_true(
  all(dat$time %in% times_equal),
  info = "visit times match the requested schedule"
)
expect_equal(
  length(unique(dat$id)), 40,
  info = "subject count matches 2 * n_per_group"
)
expect_true(
  all(!is.na(dat$y)),
  info = "no missing outcomes generated"
)

# --- run_one_sim() ------------------------------------------------------

set.seed(2)
one <- run_one_sim(
  times = times_equal, n_per_group = 25, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, tau_0 = 5, tau_1 = 0.3, tau_01 = 0,
  sigma = 3
)

expect_true(
  all(c("est", "se", "pval", "ci_lo", "ci_hi") %in% names(one)),
  info = "run_one_sim returns the expected columns"
)
expect_true(
  !is.na(one$est) && !is.na(one$se),
  info = "run_one_sim converges on a well-specified design"
)
expect_true(
  one$se > 0,
  info = "standard error is positive"
)
expect_true(
  one$ci_lo < one$est && one$est < one$ci_hi,
  info = "point estimate lies inside its own confidence interval"
)

# a passed-in `dat` is used as-is rather than regenerated
set.seed(3)
dat2 <- simulate_trial(
  times = times_equal, n_per_group = 25, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, tau_0 = 5, tau_1 = 0.3, tau_01 = 0,
  sigma = 3
)
fit_a <- run_one_sim(
  times = times_equal, n_per_group = 25, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, tau_0 = 5, tau_1 = 0.3, tau_01 = 0,
  sigma = 3, dat = dat2
)
fit_b <- run_one_sim(
  times = times_equal, n_per_group = 25, beta_0 = 50, beta_1 = -1,
  beta_2 = 0, beta_3 = 0.5, tau_0 = 5, tau_1 = 0.3, tau_01 = 0,
  sigma = 3, dat = dat2
)
expect_equal(
  fit_a$est, fit_b$est,
  info = "passing the same dat gives identical fits (CRN support)"
)

# --- analytic_gls_se() ---------------------------------------------------

se_equal <- analytic_gls_se(
  times = times_equal, n_per_group = 50, tau_0 = 5.0, tau_1 = 0.3,
  tau_01 = 0.0, sigma = 3.0
)
se_clustered <- analytic_gls_se(
  times = times_clustered, n_per_group = 50, tau_0 = 5.0,
  tau_1 = 0.3, tau_01 = 0.0, sigma = 3.0
)

expect_equal(
  se_equal, 0.0678233,
  tolerance = 1e-5,
  info = "analytic GLS SE for equal spacing matches the reviewed
    closed-form value"
)
expect_equal(
  se_clustered, 0.06577086,
  tolerance = 1e-5,
  info = "analytic GLS SE for clustered spacing matches the
    reviewed closed-form value"
)
expect_true(
  se_clustered < se_equal,
  info = "boundary-clustered spacing is more efficient for the
    slope contrast under this random-slope structure"
)

# degenerate one-visit-time-value case still returns a finite,
# positive SE (a design should never silently produce NA or Inf)
se_two_visits <- analytic_gls_se(
  times = c(0, 24), n_per_group = 50, tau_0 = 5.0, tau_1 = 0.3,
  tau_01 = 0.0, sigma = 3.0
)
expect_true(
  is.finite(se_two_visits) && se_two_visits > 0,
  info = "two-visit design yields a finite positive analytic SE"
)

# --- run_paired_simulation() ---------------------------------------------

set.seed(4)
paired <- run_paired_simulation(
  times_a = times_equal, times_b = times_clustered,
  n_per_group = 20, beta_0 = 50, beta_1 = -1, beta_2 = 0,
  beta_3 = 0.5, tau_0 = 5, tau_1 = 0.3, tau_01 = 0, sigma = 3,
  n_sims = 20, seed = 4
)

expect_equal(
  nrow(paired$results_a), 20,
  info = "run_paired_simulation runs the requested number of reps"
)
expect_true(
  length(paired$paired_diff) > 0,
  info = "at least some replications converge for both designs"
)
expect_true(
  mean(paired$results_a$est, na.rm = TRUE) > 0,
  info = "average estimate is on the correct side of zero for a
    positive treatment-by-time effect"
)

# common random numbers: with beta_3 = 0 and n_sims = 1, both
# designs share the same subject-level random effects, so the
# fixed-effect estimate under a common intercept/slope difference
# should be strongly correlated, not independent
set.seed(5)
paired_null <- run_paired_simulation(
  times_a = times_equal, times_b = times_equal,
  n_per_group = 15, beta_0 = 50, beta_1 = -1, beta_2 = 0,
  beta_3 = 0.5, tau_0 = 5, tau_1 = 0.3, tau_01 = 0, sigma = 3,
  n_sims = 10, seed = 5
)
expect_equal(
  paired_null$results_a$est, paired_null$results_b$est,
  tolerance = 1e-8,
  info = "identical designs under CRN reproduce identical fits
    (verifies shared random draws, not independent redraws)"
)
