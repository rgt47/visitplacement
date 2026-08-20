library(tinytest)

times_equal <- c(0, 6, 12, 18, 24)
times_clustered <- c(0, 2, 4, 20, 24)

# --- consistency between the general and specialized functions ----------

v_rs <- cov_random_slope(times_equal, tau_0 = 5, tau_1 = 0.3,
                          tau_01 = 0, sigma = 3)
se_general <- analytic_gls_se_general(times_equal, 50, v_rs)
se_specialized <- analytic_gls_se(times_equal, 50, 5, 0.3, 0, 3)

expect_equal(
  se_general, se_specialized,
  tolerance = 1e-8,
  info = "general and specialized random-slope SE calculations agree"
)

# --- compound symmetry: clustering should not matter -------------------

v_cs_equal <- cov_compound_symmetry(times_equal, tau_0 = 5, sigma = 3)
v_cs_clustered <- cov_compound_symmetry(times_clustered, tau_0 = 5,
                                         sigma = 3)
se_cs_equal <- analytic_gls_se_general(times_equal, 50, v_cs_equal)
se_cs_clustered <- analytic_gls_se_general(times_clustered, 50,
                                            v_cs_clustered)

expect_true(
  is.finite(se_cs_equal) && is.finite(se_cs_clustered),
  info = "compound symmetry SEs are finite"
)
expect_true(
  se_cs_clustered < se_cs_equal,
  info = "under compound symmetry, boundary clustering still
    improves precision for the slope contrast (concentrating
    observations where correlation-adjusted leverage is highest)"
)

# --- AR(1) plus error covariance matrix is valid ------------------------

v_ar1 <- cov_ar1_error(times_equal, sigma = 1, rho = 0.7, sigma_ar = 3)
expect_equal(
  dim(v_ar1), c(5L, 5L),
  info = "AR(1) plus error covariance has the right dimensions"
)
expect_true(
  isSymmetric(v_ar1),
  info = "AR(1) plus error covariance matrix is symmetric"
)
eig <- eigen(v_ar1, only.values = TRUE)$values
expect_true(
  all(eig > 0),
  info = "AR(1) plus error covariance matrix is positive definite"
)
se_ar1 <- analytic_gls_se_general(times_equal, 50, v_ar1)
expect_true(
  is.finite(se_ar1) && se_ar1 > 0,
  info = "AR(1) plus error analytic SE is finite and positive"
)
