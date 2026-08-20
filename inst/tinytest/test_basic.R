library(tinytest)

expect_true(
  is.function(simulate_trial),
  info = "simulate_trial is exported and loadable"
)
expect_true(
  is.function(run_one_sim),
  info = "run_one_sim is exported and loadable"
)
expect_true(
  is.function(analytic_gls_se),
  info = "analytic_gls_se is exported and loadable"
)
expect_true(
  is.function(run_paired_simulation),
  info = "run_paired_simulation is exported and loadable"
)
