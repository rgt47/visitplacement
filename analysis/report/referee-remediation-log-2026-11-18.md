# Referee remediation log: report.Rmd
*2026-11-18 23:52 PST*

Referee report: `referee-report-2026-11-18.md`. Built on the
2026-11-18 voice pass. Nothing was staged, committed, rendered, or
pushed. No simulation was rerun; every new number is computed in
report chunks from closed-form functions or from the existing
`.rds` artifacts. Scratch: `/private/tmp/claude-501/rem-05/`.

## Fixed

- **M1 (closed form).** New `R/design.R`: `schedule_stt()`,
  `closed_form_se()`. Methods now derive
  Var(beta_3-hat) = (2/n_g)(sigma^2/S_tt + tau_1^2), state that RE
  cannot reverse, that tau_0 and tau_01 do not enter, and that the
  simulation checks inference only. Tests: closed form equals
  `analytic_gls_se()` across tau_1 and schedules, invariance to
  tau_0/tau_01, and the `lme` REML estimate equals the arm
  difference in per-subject OLS slopes on three datasets.
  [verified]
- **M2 (optimum).** New `best_schedule()`; new Results subsection
  and table: unconstrained bound S_tt = 691.2 (RE 1.116; CS 1.92),
  best schedules with minimum gap 1, 2, 3 months (RE 1.098, 1.078,
  1.057). The 'not computed here' limitation was removed. [verified]
- **M3 (CS mechanism).** Removed every 'signal largest there' and
  'different mechanism' statement (Introduction, Present study,
  Methods twice, scenario text, Discussion). CS is now stated as the
  tau_1 = 0 limit (RE = 496/360). Winkens et al. (2005) is restated
  from its abstract (retrieved via Europe PMC), and the text says
  their mean model was not checked. [applied; abstract verified]
- **M4 (MC grid).** Remedy (b): table now shows analytic RE,
  empirical RE, and an F-based 95% interval (independent samples).
  Prose uses inline counts: intervals contain the analytic RE in
  15/15 cells; 8/15 lie above 1; all six tau_1 = 0.30/0.50 cells
  include 1. Removed 'exactly as in the main comparison', '14 of
  15', 'not guaranteed to hold', and the AR(1) 'packing visits'
  explanation; the analytic AR(1) SEs are stated as monotone.
  [verified by purl run]
- **M5 (dropout).** New `analytic_gls_se_dropout()` and
  `retention_constant_hazard()`: expected GLS information under MCAR
  monotone dropout. Under constant-hazard dropout RE falls 1.063,
  1.042, 1.019, 0.993, 0.963 (0 to 40%); crossover at about 27%.
  Scope (MCAR, retention curve, base-case variance components) is
  stated. Tests: no dropout reproduces the complete-data SE;
  non-monotone retention errors. [verified]
- **M6.** (a) 'not detectably biased by misspecification' replaced
  by a statement that no misspecification was examined. (b) power
  at beta_3 = 0.5 now computed inline (1 - 3.1e-8). (c)
  'asymptotic/large-sample' replaced by 'exact for known V'. (d)
  grid results, optimum, and dropout moved into Results; Methods
  keeps only the designs. (e) Discussion rewritten. [verified]
- **M7.** Removed all review/issue references, 'earlier draft'
  passages (Methods, Recalibration, Discussion), 'left to the
  author', and the setup-chunk history comment. The 'Recalibration'
  heading became 'Choice of the treatment effect'. [verified by grep]
- **Minor 1, 2, 3, 4, 5, 6, 10, 11, 13.** n_g defined once
  (table symbol and text); garbled 'boundary leverage' phrase
  rewritten; marginal-variance condition on tau_01 stated; normal
  vs t note added; power-ceiling cells noted (8 cells); CRN
  correlation 0.985, coverage and model/empirical SE gap (1.4%)
  reported; the Discussion grid claim is limited to model SEs, since
  the grid stores no coverage;
  Discussion opens with the finding; ranges use 'to'; inert
  `set.seed(20260305)` removed and the driver's seed stated.
- **Minor 8 (Vickers).** Replaced paraphrase with the verbatim
  abstract sentence (Europe PMC). [verified]
- **Minor 9 (Tekle 2008).** Claim confirmed verbatim in the
  abstract (Europe PMC); text unchanged. [verified]
- **Minor 12 / Section 6 (bibliography,
  `analysis/report/references.bib`, a regular file).** Crossref-
  verified: Candel year 2009; Abebe year 2015; Iddi 14(1):264-282;
  Jones DOI 10.2307/2532504. `donohue2010power` now has the single
  author shown on the CRAN vignette (2024, longpower 1.0.27); the
  unverified four-author list was removed. Added and cited
  (Crossref-verified): Raudenbush and Liu 2001, Galbraith and
  Marschner 2002, Berger and Wong 2009, Zhao and Edland 2022.
  Galbraith and Marschner is cited for design guidelines only
  (title-level support). [verified]

## Deferred

- Mentré, Mallet and Baccar (1997): Crossref and OpenAlex list
  only Mentré as author; coauthors unconfirmed, so not added.
- Lee, Biedermann and Mitra: no Crossref record matched the
  referee's description (candidates: Stat Sinica 2018 x2, SiM 2019
  multiarm). Not added.
- Winkens et al. (2005) mean model (M3): full text not read.
- Grid rerun with CRN (M4 remedy a): about 37 minutes, over the cap.
  Command after adding CRN to `run_full_factorial.R`:
  `Rscript analysis/scripts/run_full_factorial.R 1000`.
- Minor 7 (SE figure) and section 7 items 5 and 6
  (misspecification arm, nonlinear trajectories): not done.
- Raudenbush and Liu, Galbraith and Marschner: cited for power vs
  duration and frequency only; their full texts were not checked
  against our derivation (stated in text).
- Render not run (by instruction). `bash tools/render.sh
  analysis/report/report.Rmd` is needed to check table layout.

## New issues found while fixing

- With a two-month minimum gap, months 0, 2, 4, 22, 24 beat the
  paper's clustered design (RE 1.078 vs 1.063).
- `run_full_factorial.R` and `R/simulation.R` comments still cite
  '2026-08-16 review' issue numbers (code comments, not manuscript).
- `docs/pub_review_remediation_2026-08-20.md` (line 355) called
  the advantage 'robust across the structures actually tested'; the
  dropout calculation shows this holds only for complete data.

## Abstract voice pass

Words: 223 -> 219. Sentences: 16, all 8 to 21 words, none over 25.
Block scalar and indentation kept; `yaml::yaml.load()` parses it.

Factual changes:

1. Added the closed form and its dependence on S_tt only (M1).
2. Added the unconstrained bound 1.12 and two-month-gap best 1.08
   (M2).
3. Added CS relative efficiency 1.38 (scenario table).
4. 'shrinks as random-slope variance grows' now adds 'cannot
   reverse' (M1).
5. Removed '14 of 15 cells corroborate' (M4).
6. Removed 'appears real and not simulation noise'; the simulation
   is described as a check on coverage (M1, M6).
7. Removed 'theoretically optimal design is not computed here' and
   'We do not claim optimality' (M2).
8. Added the MCAR dropout crossover near 27% (M5).
9. Removed 'fully reproducible demonstration' and the
   `R/simulation.R` template claim; replaced by a plain compendium
   statement.
10. Range '1.06-1.09' became '1.06 to 1.09' (minor 11); the
    'recalibrate the effect size' clause was dropped.
