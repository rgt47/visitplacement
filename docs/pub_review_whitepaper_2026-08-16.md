# Publication Review White Paper: visitplacement

*Review date: 2026-08-16 10:10 PDT*

Workspace: `~/prj/res/05-optimal-visit-placement/visitplacement`
Reviewer role: statistical journal referee (Statistics in Medicine,
Biometrics, Contemporary Clinical Trials standard).

Epistemic labels used throughout: **verified** (I ran code and
observed the result), **inspected** (I read the source), **inferred**
(consistent with surrounding evidence), **unverified**.

## 1. Summary of the work under review

One manuscript exists: `analysis/report/report.Rmd` ("Optimal Visit
Placement in Longitudinal Trials", ~630 lines; rendered `report.tex`
and `report.pdf` present, staged copy in `analysis/report/share/`).
The document combines a literature review of optimal observation-time
placement in longitudinal trials (Winkens et al. 2005, 2006, 2007;
Ouwens et al. 2002; Tekle et al. 2008, 2011; Vickers 2003; and
related work) with a Monte Carlo study comparing two five-visit
schedules for a 100-subject, two-arm, 24-month trial with a linearly
divergent treatment effect: equal spacing (0, 6, 12, 18, 24 months)
versus boundary-clustered spacing (0, 2, 4, 20, 24 months). Data are
generated from a random-intercept, random-slope linear mixed model
and analyzed with `nlme::lme()` under REML across 2000 replications.
Reported metrics are bias, empirical SE, mean model-based SE, power,
and 95% CI coverage for the treatment-by-time interaction. All
simulation code is inline in the Rmd (inspected); `R/`,
`analysis/scripts/`, `vignettes/`, and `man/` are empty (verified by
directory listing). No other manuscript, vignette, or paper draft
exists, so no cross-report coherence assessment applies.

## 2. Major issues

### 2.1 The power comparison is at ceiling and therefore vacuous

Location: `report.Rmd`, parameter block (lines 213-224) and Results
(rendered `report.tex`, summary table and following paragraph).

Both designs attain 100.0% empirical power (verified from the
rendered `report.tex`: "an empirical power of 100.0%, compared with
100.0%"). With beta_3 = 0.5, tau_1 = 0.3, sigma = 3, and n = 100,
the analytic power is 1 to machine precision (verified: I computed
the exact GLS standard error, 0.0678 for equal spacing, giving
z = 0.5/0.0678, approximately 7.4). A power column in which every
entry is 1 cannot discriminate designs and signals that the effect
size was not calibrated. A referee will read this as a fundamental
design flaw in the simulation study. Remediation: calibrate beta_3
(or n) so the equal-spacing design sits near 80-90% power, or drop
power as a metric and report relative efficiency; preferably vary
effect size as a factor.

### 2.2 The headline precision difference is not separated from Monte Carlo noise

Location: Results, summary table and prose; Discussion paragraph 2.

The empirical SEs are 0.0671 (equal) vs 0.0650 (clustered), a
difference of 0.0021. No Monte Carlo standard errors are reported
anywhere in the manuscript (inspected). With 2000 replications, the
MCSE of each empirical SD is approximately
SD/sqrt(2(R-1)) = 0.00106, so the MCSE of the difference between
two independent (unpaired) simulation arms is roughly 0.0015; the
observed difference is about 1.4 MCSEs and is not, on the evidence
presented, distinguishable from simulation noise (inferred from
standard MCSE formulas; the designs are simulated from one shared
seed stream sequentially, not paired, inspected at lines 38 and
404-421). The Discussion accordingly retreats to the empty claim
that the clustered design "appears to yield different precision"
(line 597), which asserts nothing. Remediation: (a) report MCSE for
every metric per Morris, White, and Crowther (2019, Statistics in
Medicine); (b) use common random numbers (pair the designs within
replication) so the efficiency contrast is estimated with far
smaller error; (c) increase replications; (d) state the estimated
relative efficiency with an uncertainty interval and interpret it
directionally.

### 2.3 The simulated quantity has a closed-form answer, and the paper neither computes it nor explains what simulation adds

Location: Methods and Results, entire simulation design.

Under the stated generating model, Var(beta_3-hat) for GLS is
available exactly: with V = Z D Z' + sigma^2 I per subject, the
information matrix gives SE = 0.0678 (equal) and 0.0658
(clustered), relative efficiency 1.063 (verified: I ran this
computation; it reproduces the simulated model-based SEs 0.0676 and
0.0655 to within Monte Carlo error). The manuscript presents 2000
REML fits to estimate numbers obtainable from a ten-line linear
algebra calculation. A referee at any of the target journals will
ask what the simulation contributes beyond the analytic value:
finite-sample REML behavior, convergence failures, CI coverage with
estimated degrees of freedom, robustness to misspecification. None
of these is currently the object of study. Remediation: present the
analytic (asymptotic) relative efficiencies as the primary result,
possibly over a continuum of designs and covariance parameters, and
reserve simulation for questions the asymptotics cannot answer
(small samples, dropout, misspecified covariance, nonlinear
trajectories).

### 2.4 Single-scenario design: no factors are varied

Location: Methods, "Parameter values" and "Design specifications".

The study examines one parameter vector, one covariance structure
(random intercept and slope with iid error), one sample size, one
effect size, and exactly two candidate schedules (inspected). The
literature the paper itself reviews shows that the optimal
placement depends critically on the covariance structure (CS vs
AR(1) vs AR(1) plus error). A simulation paper that claims to
provide "simulation-based evidence on how different visit schedules
perform ... under realistic data-generating mechanisms" (lines
162-165) must vary at least: covariance structure (including serial
correlation), strength of random slope variance relative to
residual error, number of candidate designs (including the
theoretically optimal and a mid-loaded schedule), dropout, and
effect size. As it stands the empirical evidence cannot support any
general conclusion. Remediation: a factorial scenario grid with the
designs as one factor, reported as relative efficiency versus equal
spacing.

### 2.5 The Discussion mischaracterizes the generating covariance structure

Location: Discussion, second paragraph (lines 590-598).

The text asserts the generating mechanism "combines features of
compound symmetry and AR(1) with measurement error". This is
incorrect (inspected). A random-intercept plus random-slope model
with iid residuals induces a covariance with variance increasing in
t and correlations determined by the times, but it contains no
autoregressive component whatsoever; it is the standard
random-coefficients structure, distinct from both CS (which is the
random-intercept-only special case) and AR(1). Because the paper's
theoretical anchor (Winkens et al. 2005) makes structure-specific
predictions, mislabeling the simulated structure undermines the
claim that results are "broadly consistent with" that theory. For
the random-slope structure, boundary-loaded designs are efficient
for slope contrasts for the classical leverage reason, not for the
CS reason cited in the Introduction (lines 172-175). Remediation:
state the induced covariance correctly, derive or cite the correct
theoretical prediction for this structure, and align the
Introduction's motivation for the clustered design with it.

### 2.6 Novelty and contribution are insufficient for any research journal in the current form

Location: Introduction, "Present study" (lines 160-179); title.

The stated gap, "limited simulation-based evidence exists on how
different visit schedules perform in finite samples", is thin, and
what follows (two ad hoc designs, one scenario, metrics at ceiling)
does not fill it. The title promises "Optimal Visit Placement" but
no optimization is performed anywhere; no design in the paper is
shown to be optimal, and the theoretically optimal designs from the
cited literature are never computed or included as comparators
(inspected). The literature review is competent but the empirical
section is currently a teaching example, not a contribution.
Remediation: either (a) broaden into a genuine methodological
comparison (analytic efficiencies plus targeted simulation, scenario
grid, optimal designs as comparators, dropout robustness), or
(b) reframe explicitly as a tutorial or case study (see Section 5).
Retitle to match what is actually delivered.

### 2.7 No abstract, and required end matter is missing

Location: `report.Rmd` YAML and document structure.

The manuscript has no abstract (inspected; the YAML has no abstract
field and no abstract section exists). There is no data and code
availability statement, no funding or conflict statement, no
keywords, and no acknowledgment of computational environment
(hardware, package versions, run time) as expected for simulation
studies. Remediation: add all of the above; the zzcollab compendium
(Dockerfile, renv.lock) is a genuine asset that the availability
statement should exploit.

### 2.8 Reproducibility gaps between compendium claims and repository contents

Location: repository root; `CLAUDE.md`; `analysis/`.

Verified by inspection: (a) `R/` contains no functions, so nothing
is unit-tested; the only test is `expect_true(TRUE)` in
`inst/tinytest/test_basic.R`; (b) `analysis/scripts/` is empty even
though the project documentation (`CLAUDE.md`) describes
"standalone simulation scripts"; (c) `analysis/tables/tab1.tex` is
an orphaned iris-derived table with no generating script and no
connection to the project; (d) `analysis/data/README.md` documents a
Palmer Penguins dataset that does not exist in the repository and is
unrelated to the project; (e) simulation results are baked into a
committed knitr cache (`report_cache/`), so a fresh render may or
may not regenerate the reported numbers depending on cache
invalidation. Every figure and table in the manuscript itself does
have generating code inline in the Rmd (inspected). Remediation:
move `simulate_trial()`/`run_one_sim()` into `R/` with roxygen2
documentation and real tinytest coverage; delete or replace the
orphaned iris table and penguins data README; save simulation
output as a versioned artifact (e.g., `analysis/data/derived_data/`
RDS) rather than relying on the knitr cache.

## 3. Minor issues

1. `references.bib` entry `donohue2010power` lacks journal, volume,
   and pages (inspected); as rendered it produces an incomplete
   reference. Complete it or cite the published version.
2. Missing relevant citations: Morris, White, and Crowther (2019)
   on simulation study reporting; Raudenbush and Liu (2001,
   Psychological Methods) on duration and frequency of observation;
   Galbraith and Marschner (2002, Controlled Clinical Trials) on
   design of trials with longitudinal outcomes; Berger and Wong
   (2009, Applied Optimal Designs) as a modern companion to
   Atkinson and Donev (1992). Verbeke and Molenberghs would anchor
   the LMM notation. (Inferred relevance; titles from memory,
   verify bibliographic details before use.)
3. Convergence handling: rows with failed fits are silently dropped
   (`results[!is.na(results$est), ]`, line 424) and the per-design
   convergence count appears only in a table column. All 2000
   converged here (verified from `report.tex`), but the protocol
   should state how nonconvergence would be handled and report it
   explicitly in prose.
4. The Introduction refers to "Sections 2 and 3" and "Section 1.1"
   (lines 63-65); with `bookdown` numbering these cross-references
   should use `\@ref()` rather than hard-coded numbers (inspected).
5. Figure 3 (design schematic) is placed in Results but is purely
   descriptive of the designs; it belongs in Methods alongside
   Table 2, and the arbitrary vertical offsets of the visit markers
   (lines 547-551) should be explained in the caption or replaced
   with a dedicated timeline panel.
6. The density plot (Figure 1) and SE boxplot (Figure 2) convey
   little beyond the summary table when both designs are at ceiling
   power; after recalibration (issue 2.1) they may earn their
   place, but consider a single figure of relative efficiency
   across scenarios instead.
7. Reporting style: "power of 100.0%, compared with 100.0%" should
   never survive proofreading; also give the relative efficiency
   (ratio of variances), which is the quantity of design interest,
   not raw SEs to four decimals.
8. `beta_2 = 0` (no baseline group difference) is appropriate for a
   randomized trial but deserves one sentence of justification;
   likewise `tau_01 = 0` (independent intercepts and slopes) is a
   substantive restriction that should be flagged as a scenario
   limitation.
9. The seed is set once globally (line 38); with `cache=TRUE` on
   the simulation chunk, reproducibility depends on chunk execution
   order. State the seed policy in Methods and consider per-design
   seed streams to enable pairing (see issue 2.2).
10. `CLAUDE.md` says the test framework is "testthat (3e)" while
    the repository uses tinytest (inspected); align documentation.
11. The kable caption string "Simulation results for the
    treatment-by-time
    interaction." contains a hard line break that renders with
    irregular spacing in the caption (inspected in `report.tex`).
12. Line numbers (`lineno`) are enabled, which is appropriate for
    submission drafts; remember to disable for a final typeset
    version depending on journal requirements.

## 4. What remains to be done

Ordered by importance for submission readiness.

(a) Required for correctness

- Fix the covariance-structure mischaracterization in the
  Discussion and the CS-based motivation of the clustered design in
  the Introduction (issue 2.5).
- Add Monte Carlo standard errors to every reported metric and stop
  interpreting differences within MC noise (issue 2.2).
- Recalibrate the effect size or sample size so power is off the
  ceiling, or remove power as a comparison metric (issue 2.1).
- Complete the `donohue2010power` reference (minor 1).

(b) Required for acceptance

- Compute analytic GLS variances and relative efficiencies as the
  primary results; position the simulation as finite-sample
  validation and extension (issue 2.3).
- Expand to a factorial scenario grid: covariance structures
  (random slope, CS, AR(1), AR(1) plus error), effect sizes,
  dropout mechanisms, and at least four to six candidate schedules
  including a theoretically optimal design (issue 2.4).
- Use common random numbers to pair designs within replication
  (issue 2.2).
- Write an abstract; add data and code availability, computational
  environment disclosure, and keywords (issue 2.7).
- Sharpen the stated contribution and retitle to match the actual
  content (issue 2.6).
- Move simulation functions into `R/` with documentation and real
  tests; persist simulation output as versioned data (issue 2.8).

(c) Desirable polish

- Remove orphaned template artifacts (`tab1.tex`, penguins data
  README); align `CLAUDE.md` with the actual toolchain.
- Replace hard-coded section cross-references with `\@ref()`.
- Move the design schematic to Methods; redesign Figures 1-2 around
  relative efficiency.
- Add the missing design-literature citations (minor 2).

## 5. Recommended framing

Plausible framings for this material:

1. **Methodological comparison paper** (analytic efficiencies plus
   simulation across covariance structures and dropout), target
   Contemporary Clinical Trials, Pharmaceutical Statistics, or
   Statistics in Medicine (as a shorter piece).
2. **Pedagogical exposition / tutorial** ("visit placement matters:
   a worked example"), target The American Statistician (Teacher's
   Corner) or a clinical-audience journal.
3. **Software plus methods paper**, if the empty `visitplacement`
   package were developed into a design-evaluation tool (analytic
   efficiency calculator for arbitrary schedules and covariance
   structures), target R Journal or JSS; this would complement, and
   must be positioned against, `longpower` (Iddi and Donohue 2022),
   which already covers power for LMMs but not schedule
   optimization.

Recommendation: framing 1, executed as an analytic-first
design-comparison study. Reasoning: the theory literature (Winkens,
Ouwens, Tekle, Abebe) already owns the optimality results, so a
purely theoretical framing has no room; a purely pedagogical piece
would waste the compendium's reproducibility machinery and the
author's practical trial-design credibility (ADCS/Alzheimer's trial
context, Donohue et al. 2010); and current practice, as embodied in
`longpower` and standard protocol templates, evaluates power for a
given schedule but offers practitioners no guidance or tooling on
schedule choice. The genuine gap is translational: how much
efficiency is at stake for realistic trial configurations, when
does clustering help or hurt (dropout, serial correlation,
nonlinear trajectories), and a quantitative answer practitioners
can apply. What is already standard and must not be claimed as new:
the optimality of boundary-loaded designs for slope estimation, the
dependence on covariance structure, and closed-form LMM power.

Implications of framing 1: the title should promise a comparison
and practical guidance, not optimality (e.g., on the efficiency
consequences of visit schedule choice in longitudinal trials); the
abstract should lead with the relative-efficiency numbers across
scenarios and the dropout robustness finding; the introduction
keeps the current literature review largely intact but replaces the
"limited simulation-based evidence" gap claim with the translational
gap above; comparators must include the equally spaced design, two
or more clustered variants, and the analytically optimal design per
structure; target journal Contemporary Clinical Trials (natural fit
with Winkens et al. 2006) or Pharmaceutical Statistics. Under this
framing, the current single-scenario simulation becomes one cell of
the scenario grid; the design schematic moves to Methods; the
density and boxplot figures move to supplementary material; and the
analytic efficiency surface plus a dropout-robustness figure become
the main exhibits. Framing 3 is a reasonable follow-on paper if the
package is built, but should not be attempted simultaneously.

## 6. Assessment

Verdict: **reject in current form; encourage resubmission after
major revision** (equivalently, not yet submittable). The
manuscript is an early-stage draft: the literature review is
serviceable and the reproducibility scaffolding is genuinely good,
but the empirical core consists of a single uncalibrated scenario
whose headline metric is at ceiling, whose precision contrast is
within Monte Carlo noise, whose target quantity has an uncomputed
closed-form answer, and whose discussion mischaracterizes the
simulated covariance structure. No referee at the target journals
would send this out for minor revision. The path to a publishable
paper is clear and is enumerated in Section 4; the decisive steps
are the analytic-first reframing, the scenario grid, and MCSE-
disciplined reporting.

## 7. Revision history

- 2026-08-16: Initial review. No prior white paper existed. Eight
  major issues and twelve minor issues identified; verdict: reject
  in current form / major revision required before submission.
