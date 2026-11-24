# Referee report: 'Efficiency Consequences of Visit Schedule Choice in Longitudinal Trials'
*2026-11-18 15:59 PST*

Manuscript: `analysis/report/report.Rmd` (visitplacement compendium,
HEAD `git show HEAD:analysis/report/report.Rmd`). No supplement.
Comments are anchored to section names and quoted phrases rather than
line numbers, because the prose is being revised in a separate pass.

## 1. Summary of the manuscript

The manuscript compares two five-visit schedules for a two-arm,
24-month trial with a linearly divergent treatment effect: equal
spacing (months 0, 6, 12, 18, 24) and boundary clustering (months 0,
2, 4, 20, 24). The data-generating model is a random-intercept,
random-slope linear mixed model with 50 subjects per arm. The authors
compute the exact GLS standard error of the treatment-by-time
interaction for each schedule (relative efficiency 1.063), then run a
2000-replication common-random-number (CRN) Monte Carlo study fitted
by REML with `nlme::lme()`. The empirical relative efficiency is 1.07
(paired bootstrap 95% interval 1.06 to 1.09). An analytic grid over
the random-slope SD, compound symmetry (CS), and AR(1) plus error, and
a 20-cell Monte Carlo grid crossing five covariance structures with
four schedules, are offered as robustness evidence. The stated
contribution is a 'worked, fully reproducible demonstration of how
much efficiency is at stake for one realistic configuration' plus a
reusable code template. The authors explicitly disclaim optimality.

## 2. Overall assessment and recommendation

**Recommendation: major revision (and, in its present form, not
suitable for a top-tier statistics journal).**

The computational work is careful and reproducible. The saved
artifacts match the reported numbers, the CRN design and MCSE
reporting follow Morris, White and Crowther (2019), and the authors
are candid about scope. However, the central quantity has a one-line
closed form that the manuscript does not state. Under the simulated
model, Var(beta_3-hat) = (4/n)(sigma^2/S_tt + tau_1^2), where n is the
total sample size and S_tt = sum_j (t_j - t-bar)^2. This formula
reduces the entire design comparison to a ratio of S_tt values. It
makes the 2000-replication simulation largely confirmatory, it shows
the optimal design is trivially computable (contrary to the stated
limitation), and it contradicts several mechanistic statements in the
text. The compound-symmetry and AR(1) narratives contain claims that
the authors' own closed-form code refutes. The Monte Carlo grid is
not CRN-paired and is underpowered for the efficiency contrasts it is
used to support, so the '14 of 15 cells' corroboration is weaker than
stated. With the closed form placed at the center, the mechanism
claims corrected, and the grid either paired or replaced by analytic
values, the paper could be a useful short communication or tutorial
in an applied venue (for example *Statistics in Medicine* tutorial
section, *Contemporary Clinical Trials*, or *Pharmaceutical
Statistics*). It does not, in my judgment, contain a methodological
advance sufficient for JASA, JRSS-B, or Biometrika.

## 3. Significance and novelty

The question of time-point allocation for linearly divergent
treatment effects is settled at the level of theory for the models
considered here. Winkens et al. (2005, 2006, 2007) computed optimal
time-points under CS, AR(1), and AR(1) plus error. Ouwens, Tan and
Berger (2002) and Tekle, Tan and Berger (2008) gave (maximin)
D-optimal designs for random-intercept, random-slope models.
Mentré, Mallet and Baccar (1997) gave the general Fisher-information
framework for random-effects regression designs, which underlies the
PFIM and PopED software. Raudenbush and Liu (2001) and Galbraith and
Marschner (2002) gave closed-form power for group differences in
slopes as a function of study duration, frequency, and dropout, and
to my recollection both work with a slope-variance decomposition
of the same sigma^2/S_tt + tau_1^2 form used implicitly here
(checked against abstracts and secondary summaries only).

Against this literature, the manuscript's new material is (a) one
numerical worked example of the efficiency gap between two specific
schedules and (b) a finite-sample REML simulation confirming that
asymptotic GLS calculations are accurate at n = 100. Point (b) is
expected: for balanced complete data with time-invariant design
within subject, the GLS estimator of the fixed slope contrast does not
depend on the variance components at all (verified below: on one
simulated clustered-design dataset, the `lme` REML estimate, a CS
`gls` estimate, and the difference in arm means of per-subject OLS
slopes all equal 0.3162342), so REML
estimation error in V cannot affect the point estimate and affects
only the model-based SE. The manuscript does not engage with dropout,
which is the feature that most plausibly changes the practical
recommendation, nor with post-2015 work on optimal designs under
missing data (for example the Lee, Biedermann and Mitra optimal
cohort-design framework with MAR dropout; see Section 6). The work
reads as a careful teaching example rather than a contribution to
design theory.

## 4. Major comments

**M1. The design comparison has a closed form that should replace
most of the narrative (Methods, 'Analytic relative efficiency' and
'Covariance structure and theoretical prediction'). Verified.**

With Z_i = [1, t] and X_i spanned by the columns of Z_i in each arm,
the GLS estimator of beta_3 equals the difference in arm means of
per-subject OLS slopes. Hence

  Var(beta_3-hat) = (2/n_per_group) (sigma^2 / S_tt + tau_1^2).

I checked this against `analytic_gls_se()`: it reproduces 0.06782
(equal) and 0.06577 (clustered) to all printed digits, and the
function's output is unchanged when tau_0 is set to 1 or 20 or
tau_01 to 1 (executed; scratch script `check.R`). Consequences:

- The relative efficiency is (sigma^2/S_e + tau_1^2) /
  (sigma^2/S_c + tau_1^2), with S_e = 360 and S_c = 496. Every number
  in the random-slope rows of the scenario table follows from this.
- The relative efficiency exceeds 1 for every finite tau_1 whenever
  S_c > S_e. The advantage shrinks toward 1 as tau_1^2 S_tt / sigma^2
  grows but cannot reverse. The Monte Carlo section's statement that
  'the clustering advantage is not guaranteed to hold once the
  random-slope variance is large' is therefore false under this
  model; the reversal at tau_1 = 0.50 is Monte Carlo noise (see M4).
- tau_0 and tau_01 are irrelevant to the comparison. The Discussion
  caveat about 'independent random effects' does not apply to the
  efficiency result.
- The REML simulation cannot change the point estimate's variance;
  it can only assess the model-based SE and Wald coverage. The
  manuscript should state this, and the 2000-replication study should
  be framed as a check on inference, not on efficiency.

Remedy: state the formula and its derivation in the Methods, derive
the scenario table from it, and reduce the simulation to the
inference-quality question.

**M2. The 'optimal design is not computed here' limitation is
unnecessary, and the clustered schedule captures only about half the
available gain (Abstract; Introduction, 'Present study'; Discussion).
Verified.**

Because the variance depends on the schedule only through S_tt, the
optimal five-visit schedule on [0, 24] places visits at the two
endpoints in a 3/2 or 2/3 split (S_tt = 691.2). Its relative
efficiency versus equal spacing is 1.116 (executed), versus 1.063 for
the clustered schedule and 1.098 for the 'extreme' schedule. Under CS
the corresponding optimum gives relative efficiency 1.92 (SE 0.0228
vs 0.0316; executed). Replicated visits at the same time are
unrealistic, so the practically relevant result is a constrained
optimum (for example, a minimum gap between visits). The paper
should report the unconstrained bound and at least one constrained
optimum. The Abstract's phrase 'how much efficiency is at stake'
cannot be answered without this bound.

**M3. The compound-symmetry 'mechanism' narrative contradicts the
paper's own model and code (Introduction, 'Present study';
Methods, 'Covariance structure and theoretical prediction'; Methods,
'Scenario extension (analytic only)'; Discussion). Verified for the
paper's mean model; suspected with respect to Winkens et al.**

The text says that under CS clustering helps 'because the treatment
effect (and hence the signal) is largest there', that this is
'distinct from' the random-slope leverage mechanism, and that the
clustered design wins under CS and AR(1) 'by a different mechanism in
each case'. Under CS with the paper's mean model (free baseline group
effect beta_2), Var(beta_3-hat) = (4/n) sigma^2 / S_tt exactly, so the
CS relative efficiency is 496/360 = 1.3778. That is the value in the
scenario table (1.3778; executed). CS is the tau_1 = 0 limit of the
random-slope result, and its mechanism is the same leverage argument.
'The signal is largest there' is not a variance argument: the
variance of an estimator does not depend on the size of the effect.

The Winkens et al. (2005) finding that end-loading helps under CS may
reflect a different mean model, for example one that constrains group
means to be equal at baseline, as is common for randomized trials.
I could not confirm this from the abstract (suspected). The authors
should check the model in Winkens et al. and state explicitly whether
it matches theirs. If it does not, the manuscript's comparison with
that paper must be rewritten.

**M4. The Monte Carlo grid does not support '14 of 15 cells
corroborate the direction' at the stated strength (Methods,
'Scenario extension (Monte Carlo)'; Abstract; Discussion).
Inspected (code) and verified (arithmetic).**

The grid draws each cell from its own seed (`base_seed + cell_id`
in `run_full_factorial.R`). It does not use CRN across schedules.
The text nevertheless says the replications are fitted 'exactly as in
the main comparison', which used CRN. For a ratio of two independent
variance estimates with R = 1000, SE(log RE) is about
sqrt(4/(R-1)) = 0.063. Seven of the fifteen non-baseline cells lie
within about 1.2 such standard errors of 1: all six random-slope
cells at tau_1 = 0.30 and 0.50 (RE 1.018 to 1.047, and 0.930) and
the AR(1)
mild-clustered cell (1.062). The 0.930 reversal is about 1.2 such
standard errors below 1 on the log scale. The direction of these
seven cells is not established by
the simulation; it is established by the closed form. The extreme
versus boundary 'non-monotonic' AR(1) pattern is contradicted by the
paper's own analytic SEs, which are monotone across the four schedules
(0.0554, 0.0538, 0.0528, 0.0522; analytic RE 1.13 for extreme vs 1.10
for boundary; executed). The explanation offered ('packing visits very
close together adds little independent information') therefore
explains noise.

Remedy: (a) rerun the grid with CRN across schedules within each
structure, as in the main comparison; or (b) report, per cell, the
analytic RE beside the empirical RE with an interval, and use the
simulation only to check agreement and coverage. Remove the AR(1)
mechanistic explanation unless the closed form supports it.

**M5. Dropout and practical constraints are the substantive issues,
and they are deferred (Discussion; Methods, 'Scenario extension
(Monte Carlo)'). Design facts verified by arithmetic; dropout
consequences suspected, not computed.**

The clustered schedule leaves a 16-month gap (months 4 to 20) and
puts 60% of its S_tt (296 of 496) in the last two visits (verified).
Monotone dropout in cognitive-decline trials is often substantial by
24 months (general experience; no figure was computed here). Under
such dropout I suspect the clustered schedule loses more slope
information per dropout than equal spacing, and it provides no
information about subjects lost in the gap. A 16-month gap is also
unlikely to be acceptable for safety monitoring and retention.
Because the efficiency gain under the base case is only 6%, I
suspect plausible dropout could erase or reverse it; this was not
computed. The closed form extends directly: under MCAR monotone
dropout with known visit-retention probabilities, the expected
information is a retention-weighted sum of per-pattern S_tt terms
(Galbraith and Marschner 2002). This calculation needs no new
simulation and should be in the paper. Without it, the Discussion's
first conclusion ('a design decision with real consequences') is not
supported for practice.

**M6. Overstated or inaccurate inferential statements. Inspected
and verified as marked.**

(a) Monte Carlo grid: 'REML estimation ... is not detectably biased
by covariance misspecification'. Every cell is fitted with the
matched correlation structure (`run_one_sim()` or
`run_one_sim_cov()` with the generating family), so no
misspecification is examined (inspected). (b) 'Recalibration of the
treatment effect': power at beta_3 = 0.5 is described as '1 to
machine precision'; it is 1 - 3.1e-8 (verified). The point stands but
the phrase is wrong. (c) The GLS variance is described as
'asymptotic' and 'large-sample'. Given V, it is the exact variance of
the GLS estimator; only its use with estimated V is asymptotic. (d)
Results of both grids are reported inside the Methods section. (e)
Discussion: the clustered design's advantage 'became
indistinguishable from Monte Carlo noise in one of 15 non-baseline
cells' understates the issue in M4: seven cells are within about one
standard error of no difference.

**M7. The manuscript contains internal revision history (throughout).
Inspected.**

Phrases such as '2026-08-16 review, issue 2.4', 'issue 2.8(e)', 'An
earlier draft of this report described the simulated structure as
...; that characterization is incorrect and has been removed', and
the setup chunk comment are process notes for the authors, not
content for readers or referees. They should be removed from the
submission. The correct characterization of the covariance should be
stated once, without reference to the earlier error.

## 5. Minor comments

1. Methods, 'Parameter values': Table 1 gives n = 50 (subjects per
   group), while 'Analytic relative efficiency' uses 'n = 100'.
   Define n once.
2. Methods, 'Covariance structure': 'does not grow with tau_1
   boundary leverage' is not grammatical and its meaning is unclear.
3. Methods, 'Covariance structure': 'the marginal variance increases
   with t_j^2' holds for t_j >= 0 whenever tau_01 >= 0, but can fail
   at small t_j when tau_01 < 0. State the condition, since the
   general formula is given with tau_01 free.
4. Methods, 'Recalibration': the power calculation uses normal
   quantiles; the analysis uses t with lme denominator degrees of
   freedom. The difference is negligible here but should be stated.
5. Monte Carlo grid table: power is 0.999 to 1.000 in the
   tau_1 = 0.10 and CS cells. The recalibration argument used to
   justify beta_3 = 0.19 applies equally to these cells, where power
   is again at ceiling and uninformative.
6. Results, 'Summary statistics': report the CRN paired difference in
   squared error or the correlation between designs' estimates; it
   documents how much the pairing reduced Monte Carlo error.
7. Figure 'Distribution of model-based standard errors': a boxplot of
   model SEs is less informative than a plot of model SE against
   empirical SE per design, or of coverage.
8. Introduction, 'Practical guidance': the Vickers (2003) summary
   'four post-treatment assessments (or seven total including
   baseline)' may misread the source (suspected). The abstract, as
   retrieved through a summarizing fetch of PMC280679, says there is
   little value in more than four baseline or post-treatment
   assessments, 'or seven where baseline assessments are taken'. That
   wording is ambiguous. Please check the full text and state the
   threshold exactly as Vickers gives it.
9. Introduction, 'Design criteria': the Tekle et al. (2008) claim
   that the 'most efficient number of repeated measurements equals
   the sum of the number of cohorts and the degree of the polynomial'
   was not confirmed from available abstracts (unverified).
10. Discussion: 'In this study, we have endeavored to illustrate' is
    filler; the paragraph should open with the finding.
11. The abstract's '1.06-1.09' uses a hyphen for a range; use 'to' or
    an en dash consistently with the body.
12. Bibliography: `candel2008empirical` lists year 2008 with volume
    18(4); the print issue is 2009 (suspected, from recall).
    `abebe2014bayesian` lists 2014 with volume 24(5); the print issue
    is 2015 (suspected). `iddi2022longpower` lacks volume and pages
    (The R Journal 14(1), suspected from recall). `jones1991unequally`
    lacks a DOI. `donohue2010power` carries an unverified author list
    flagged in the .bib comment; replace it or verify it before
    submission.
13. Setup chunk: `set.seed(20260305)` in the report has no effect on
    the reported results, which are read from saved artifacts. Remove
    it or explain it, to avoid an implied reproducibility claim.

## 6. Missing and questionable references

| Claim location | Issue | Suggested source |
|---|---|---|
| Methods, slope variance and design comparison | The sigma^2/S_tt + tau_1^2 decomposition and its dependence on duration and frequency are established | Raudenbush SW, Liu X. Effects of study duration, frequency of observation, and sample size on power in studies of group differences in polynomial change. *Psychological Methods* 2001;6(4):387-401. |
| Discussion, dropout | Closed-form power for slope comparisons with dropout exists | Galbraith S, Marschner IC. Guidelines for the design of clinical trials with longitudinal outcomes. *Controlled Clinical Trials* 2002;23(3):257-273. |
| Introduction, design theory | General random-effects design framework missing | Mentré F, Mallet A, Baccar D. Optimal design in random-effects regression models. *Biometrika* 1997;84(2):429-442. |
| Introduction, design theory | Standard textbook reference for longitudinal optimal design | Berger MPF, Wong WK. *An Introduction to Optimal Designs for Social and Biomedical Research*. Wiley; 2009. |
| Discussion, dropout | Optimal time-point designs under MAR dropout (post-2015) | Lee KM, Biedermann S, Mitra R. Optimal design for longitudinal studies with MAR dropout (Southampton ePrints 407748; verify final venue and year). |
| Introduction, power tools | Power for random-slope models with dropout | Zhao Y, Edland SD. Power formulas for mixed effects models with random slope and intercept comparing rate of change across groups (PMID 33581000, 2021; verify). |
| Introduction, 'Present study' | Winkens et al. (2005) CS mechanism | Verify the mean model (baseline constraint) in the full text before contrasting mechanisms (see M3). |
| Introduction, Vickers | Threshold paraphrase possibly inaccurate (suspected) | Check against the Vickers (2003) full text (Minor 8). |

## 7. Suggestions for strengthening the paper

1. Lead with the closed form and present the design comparison as a
   function of S_tt and the ratio tau_1^2/sigma^2, with a single
   figure of relative efficiency against that ratio for the candidate
   schedules and the unconstrained optimum.
2. Add a constrained-optimal schedule (for example, minimum spacing of
   2 or 3 months, or a required interim visit for safety) and report
   its efficiency.
3. Add the retention-weighted information calculation under MCAR
   monotone dropout for a few dropout rates, and identify the dropout
   rate at which equal spacing becomes preferable.
4. Rerun the factorial grid with CRN across schedules, or replace its
   efficiency column with analytic values and keep the simulation for
   coverage and model-SE accuracy.
5. Add a misspecification arm, for example fitting the
   random-intercept-only or the AR(1) model to random-slope data, if
   the robustness claim is to be retained.
6. Consider sensitivity to nonlinear decline (for example, a
   quadratic control trajectory) since boundary-clustered designs
   cannot detect curvature in the gap.

## 8. Scope of this review

Verified (executed in R, scratch script
`/private/tmp/claude-501/-Users-zenn-prj-res-01-fisher-exact-rx2-fisherexacttestrx2-analysis-report/be4b228f-9df5-41a4-9039-7499d4f23926/scratchpad/05-visit/check.R`,
under 1 minute):

- The saved `sim_results.rds`, `factorial_grid.rds`, and
  `scenario_grid.rds` match the numbers quoted in the prose and
  abstract (analytic RE 1.063; bootstrap RE 1.072, interval 1.056 to
  1.087; power 78.7% and 81.4%; all cells 1000/1000 converged; max
  |bias| 0.0037).
- The closed form for Var(beta_3-hat), its invariance to tau_0 and
  tau_01, the CS relative efficiency 496/360, the optimal-design bound
  1.116, the analytic power values 80.0% and 82.4%, the ratio 2.80,
  and the 1 - 3.1e-8 power at beta_3 = 0.5.
- Analytic SEs for all four schedules under CS, AR(1) plus error, and
  tau_1 = 0.10 and 0.50.
- On one simulated clustered-design dataset, the `lme` REML estimate
  of beta_3, a CS `gls` estimate, and the arm difference in mean
  per-subject OLS slopes are identical (0.3162342; scratch script
  `check2.R`). This is a single-dataset check of the general
  algebraic result, not a proof.

Inspected (read, not executed): `R/simulation.R`, `R/covariance.R`,
the three driver scripts, `references.bib`, and every code chunk in
the report.

Not checked: the simulations were not rerun; the rendered PDF was not
inspected; the full texts of Winkens et al. (2005, 2006, 2007),
Tekle et al. (2008, 2011), Candel (2009), Abebe et al. (2015), and
Ouwens et al. (2002) were not read, so the attributed claims are
checked against abstracts at best; the unit tests were not run.
The suggested references in Section 6 are partly from recall:
Berger and Wong (2009) was not searched, the Lee, Biedermann and
Mitra title and venue are unconfirmed, and the Raudenbush and Liu
and Galbraith and Marschner descriptions rest on abstracts and
secondary summaries. The prior review and remediation logs the
manuscript refers to (`docs/pub_review_*.md`) were not read. The
dropout consequences in M5 were not computed.

Literature searches run (WebSearch): Winkens et al. 2005 abstract and
CS findings; Vickers 2003 abstract (full abstract read at PMC);
Raudenbush and Liu 2001 and Galbraith and Marschner 2002; Mentré,
Mallet and Baccar 1997 and PFIM/PopED; post-2015 work on optimal visit
schedules with dropout for slope models.
