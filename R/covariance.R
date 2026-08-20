#' Analytic GLS standard error under an arbitrary within-subject
#' covariance structure
#'
#' Generalizes [analytic_gls_se()] to accept any k x k within-subject
#' covariance matrix, so the treatment-by-time interaction can be
#' compared across covariance structures (random-slope, compound
#' symmetry, AR(1) plus error) without re-deriving the information
#' matrix each time. Added for the analytic scenario extension in
#' `analysis/scripts/run_scenario_grid.R` (2026-08-16 review, issue
#' 2.4).
#'
#' @param times Numeric vector of visit times.
#' @param n_per_group Integer, subjects per arm.
#' @param v_mat A k x k within-subject covariance matrix, where
#'   `k = length(times)`.
#'
#' @return Numeric scalar, the GLS standard error of the
#'   treatment-by-time interaction coefficient.
#' @export
analytic_gls_se_general <- function(times, n_per_group, v_mat) {
  v_inv <- solve(v_mat)

  x_ctrl <- cbind(1, times, 0, 0)
  x_trt <- cbind(1, times, 1, times)

  info <- n_per_group * (t(x_ctrl) %*% v_inv %*% x_ctrl) +
    n_per_group * (t(x_trt) %*% v_inv %*% x_trt)

  info_inv <- solve(info)
  sqrt(info_inv[4, 4])
}

#' Within-subject covariance matrix for the random-intercept,
#' random-slope structure
#'
#' @inheritParams simulate_trial
#' @param times Numeric vector of visit times.
#' @return A k x k covariance matrix.
#' @export
cov_random_slope <- function(times, tau_0, tau_1, tau_01, sigma) {
  z_mat <- cbind(1, times)
  d_mat <- matrix(c(tau_0^2, tau_01, tau_01, tau_1^2), 2, 2)
  z_mat %*% d_mat %*% t(z_mat) + sigma^2 * diag(length(times))
}

#' Within-subject covariance matrix for compound symmetry
#'
#' A random-intercept-only special case: constant correlation
#' between any two visits for the same subject.
#'
#' @param times Numeric vector of visit times.
#' @param tau_0 Numeric, SD of the random intercept.
#' @param sigma Numeric, residual SD.
#' @return A k x k covariance matrix.
#' @export
cov_compound_symmetry <- function(times, tau_0, sigma) {
  k <- length(times)
  matrix(tau_0^2, k, k) + sigma^2 * diag(k)
}

#' Within-subject covariance matrix for AR(1) plus measurement error
#'
#' @param times Numeric vector of visit times.
#' @param sigma Numeric, residual (white-noise) SD.
#' @param rho Numeric in (0, 1), AR(1) correlation per unit time.
#' @param sigma_ar Numeric, SD of the AR(1) process itself.
#' @return A k x k covariance matrix.
#' @export
cov_ar1_error <- function(times, sigma, rho, sigma_ar) {
  k <- length(times)
  time_dist <- abs(outer(times, times, "-"))
  sigma_ar^2 * rho^time_dist + sigma^2 * diag(k)
}
