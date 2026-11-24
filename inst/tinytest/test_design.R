library(tinytest)

times_equal <- c(0, 6, 12, 18, 24)
times_clustered <- c(0, 2, 4, 20, 24)

# --- schedule_stt() and closed_form_se() -----------------------------

expect_equal(schedule_stt(times_equal), 360,
             info = "S_tt of equal spacing")
expect_equal(schedule_stt(times_clustered), 496,
             info = "S_tt of boundary-clustered spacing")

for (tau_1 in c(0.1, 0.3, 0.5)) {
  for (sched in list(times_equal, times_clustered)) {
    expect_equal(
      closed_form_se(sched, 50, tau_1, 3),
      analytic_gls_se(sched, 50, 5, tau_1, 0, 3),
      tolerance = 1e-10,
      info = "closed form matches the GLS information-matrix SE"
    )
  }
}

expect_equal(
  analytic_gls_se(times_clustered, 50, 20, 0.3, 1, 3),
  closed_form_se(times_clustered, 50, 0.3, 3),
  tolerance = 1e-10,
  info = "GLS SE does not depend on tau_0 or tau_01"
)

expect_equal(
  closed_form_se(times_equal, 50, 0, 3),
  analytic_gls_se_general(
    times_equal, 50, cov_compound_symmetry(times_equal, 5, 3)
  ),
  tolerance = 1e-10,
  info = "tau_1 = 0 reproduces the compound-symmetry SE"
)

# --- GLS estimate equals arm difference in per-subject OLS slopes ----

for (seed in 1:3) {
  set.seed(seed)
  dat <- simulate_trial(
    times_clustered, 30, 50, -1, 0, 0.19, 5, 0.3, 0, 3
  )
  fit <- nlme::lme(y ~ time * group, random = ~ time | id, data = dat,
                   method = "REML")
  slopes <- vapply(split(dat, dat$id), function(d) {
    stats::coef(stats::lm(y ~ time, data = d))[[2]]
  }, numeric(1))
  grp <- vapply(split(dat$group, dat$id), `[`, numeric(1), 1)
  ols_diff <- mean(slopes[grp == 1]) - mean(slopes[grp == 0])
  expect_equal(
    unname(nlme::fixef(fit)[["time:group"]]), ols_diff,
    tolerance = 1e-6,
    info = "REML estimate of beta_3 equals OLS-slope difference"
  )
}

# --- best_schedule() -------------------------------------------------

b1 <- best_schedule(5, 24, 1)
expect_equal(b1$stt, 610, info = "distinct-month optimum S_tt")
expect_equal(b1$times, c(0, 1, 2, 23, 24),
             info = "distinct-month optimum schedule")
b2 <- best_schedule(5, 24, 2)
expect_equal(b2$stt, 539.2, info = "two-month-gap optimum S_tt")
expect_true(all(diff(b2$times) >= 2), info = "gap constraint holds")
expect_error(best_schedule(5, 8, 3), info = "infeasible gap errors")

# --- analytic_gls_se_dropout() ---------------------------------------

expect_equal(
  analytic_gls_se_dropout(times_equal, 50, 5, 0.3, 0, 3, rep(1, 5)),
  analytic_gls_se(times_equal, 50, 5, 0.3, 0, 3),
  tolerance = 1e-10,
  info = "no dropout reproduces the complete-data SE"
)

ret <- retention_constant_hazard(times_clustered, 0.3, 24)
expect_equal(ret[1], 1, info = "full retention at baseline")
expect_equal(ret[5], 0.7, info = "retention at study end")
expect_true(
  analytic_gls_se_dropout(times_clustered, 50, 5, 0.3, 0, 3, ret) >
    analytic_gls_se(times_clustered, 50, 5, 0.3, 0, 3),
  info = "dropout increases the SE"
)
expect_error(
  analytic_gls_se_dropout(times_equal, 50, 5, 0.3, 0, 3,
                          c(1, 0.9, 0.95, 0.8, 0.7)),
  info = "non-monotone retention is rejected"
)
