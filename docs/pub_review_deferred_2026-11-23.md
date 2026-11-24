# pub_review Deferred-Item Pass: visitplacement
*2026-11-23 12:48 PST*

Sources read: `docs/pub_review_whitepaper_2026-08-16.md`,
`docs/pub_review_remediation_2026-08-20.md` (sections 3, 4, 6), and
the later, uncommitted referee pass in `analysis/report/`
(`referee-report-2026-11-18.md`,
`referee-remediation-log-2026-11-18.md`). Git history since
2026-08-20 was checked (`53ef2c0`, `0c2fc05`, `d3db1ea`, `7422861`,
`40e5a22`, `0ae0fa5`, `cddef1c`). Most later work is uncommitted in
the working tree (`R/design.R`, `inst/tinytest/test_design.R`, five
new `man/*.Rd`, and the 2026-11-18 manuscript revision), so several
items below are resolved by working-tree files, not commits.

Nothing was staged or committed.

## 1. Inventory

| # | Source log | Item | Class |
|---|---|---|---|
| A1 | 2026-08-20 s.3 | Issue 2.4: full factorial Monte Carlo grid | RESOLVED-SINCE |
| A2 | 2026-08-20 s.3 | Dropout robustness not modeled | RESOLVED-SINCE |
| A3a | 2026-08-20 s.3 | Minor 2: Raudenbush and Liu, Galbraith and Marschner, Berger and Wong citations | RESOLVED-SINCE |
| A3b | 2026-08-20 s.3 | Minor 2: Verbeke and Molenberghs citation | AUTHOR-DECISION |
| A4 | 2026-08-20 s.3 | `donohue2010power` author list and type unverified | RESOLVED-SINCE |
| A5 | 2026-08-20 s.3 | Minor 6: redesign Figures 1-2 around relative efficiency | DO-NOW (done) |
| A6 | 2026-08-20 s.3 | Minor 12: `\linenumbers` enabled | AUTHOR-DECISION |
| A7 | 2026-08-20 s.4 | Git object corruption (`git fsck` missing objects) | RESOLVED-SINCE |
| A8 | 2026-08-20 s.4 | Two divergent `references.bib` files | AUTHOR-DECISION |
| B1 | 2026-11-18 Deferred | Mentre, Mallet and Baccar (1997) coauthors unconfirmed | AUTHOR-DECISION |
| B2 | 2026-11-18 Deferred | Lee, Biedermann and Mitra (MAR dropout) not located | AUTHOR-DECISION |
| B3 | 2026-11-18 Deferred | Winkens et al. (2005) mean model: full text not read | AUTHOR-DECISION |
| B4 | 2026-11-18 Deferred | M4 remedy (a): rerun grid with common random numbers | AUTHOR-DECISION |
| B5 | 2026-11-18 Deferred | Minor 7: SE boxplot less informative than model vs empirical SE | DO-NOW (done) |
| B6 | 2026-11-18 Deferred | Section 7 items 5, 6: misspecification arm, nonlinear trajectories | AUTHOR-DECISION |
| B7 | 2026-11-18 Deferred | Raudenbush and Liu, Galbraith and Marschner full texts unchecked | AUTHOR-DECISION |
| B8 | 2026-11-18 Deferred | Render not run | RESOLVED-SINCE |
| B9 | 2026-11-18 New issues | Code comments cite '2026-08-16 review' issue numbers | DO-NOW (done) |
| B10 | 2026-11-18 New issues | 2026-08-20 log called the advantage 'robust across structures' | NO-LONGER-APPLIES |
| B11 | 2026-11-18 New issues | Months 0, 2, 4, 22, 24 beat the clustered design | RESOLVED-SINCE |

Totals: 20 items; 7 resolved-since; 1 no-longer-applies; 3 done
now; 0 long-run; 9 author-decision.

Evidence for the RESOLVED-SINCE and NO-LONGER-APPLIES rows
(inspected unless marked otherwise):

- A1: the covariance-by-schedule grid was run in the 2026-08-20
  follow-up (commit `53ef2c0`, `analysis/scripts/run_full_factorial.R`)
  and rerun on 2026-11-19 (working-tree
  `factorial_grid.rds`, R 4.6.0, 415 s). The effect-size and
  sample-size factors no longer need simulation: the closed form now
  in Methods, $\text{Var}(\hat\beta_3) = (2/n_g)(\sigma^2/S_{tt} +
  \tau_1^2)$, shows relative efficiency does not depend on
  $\beta_3$ or $n_g$. The dropout factor is A2.
- A2: `analytic_gls_se_dropout()` and `retention_constant_hazard()`
  in `R/design.R` (untracked) and the Results subsection 'Monotone
  dropout (analytic)'. Only MCAR monotone dropout is covered; see B2
  and section 4.
- A3a: all three keys are in `analysis/report/references.bib` and
  cited in the Introduction (`raudenbush2001effects`,
  `galbraith2002guidelines`, `berger2009introduction`).
- A4: entry is now `@misc`, single author, longpower vignette
  1.0.27 (2024); the unverified four-author list is gone.
- A7: `git fsck --full` run today reports no missing or corrupt
  objects [verified].
- B8: `share/MANIFEST.md` records renders on 2026-11-19 12:54 and
  18:45, after the last `report.Rmd` edit (2026-11-18 23:56); two
  further renders were made today (section 2).
- B10: the 2026-08-20 log is a record and is not edited; the
  current Discussion makes no such claim and states that dropout
  reverses the comparison at about 27%.
- B11: the Results table 'constrained-optimum' and the abstract
  already report the two-month-gap optimum (RE 1.08).

## 2. Done now

- **A5. Relative efficiency figure (whitepaper minor 6; 2026-11-18
  report, section 7 item 1).** Added figure `re-ratio` to Results,
  'Optimal and constrained schedules': closed-form relative
  efficiency against equal spacing as a function of
  $\tau_1^2/\sigma^2$ for the mild, clustered, best two-month-gap,
  best one-month-gap, and unconstrained schedules, with the base
  case and $\tau_1 = 0.5$ marked. All values come from
  `schedule_stt()`, `best_schedule()` output already in the chunk,
  and the closed form; no new number appears in the prose. One
  sentence added referring to the figure ('ordered by $S_{tt}$ and
  all decline toward 1'), which follows from the closed form. The
  density plot is retained. File: `analysis/report/report.Rmd`.
  `[verified]`: rendered; figure inspected; at ratio 0 the curves
  equal the CS values in Table 'constrained-optimum' (1.92 bound).
- **B5. SE figure (2026-11-18 minor 7).** The `se-boxplot` figure
  now overlays, per design, the empirical SD of the estimates with
  $\pm 2$ MCSE bars and the exact GLS SE beside the box of
  model-based SEs, all from objects already computed in the
  `power-diff` and `analytic-efficiency` chunks. Caption rewritten.
  Both new captions are built with `paste()` in earlier chunks to
  keep source lines under 78 characters. File:
  `analysis/report/report.Rmd`. `[verified]`: rendered and
  inspected.
- **B9. Review-issue references in code.** Removed '2026-08-16
  review, issue N' and 'review issue N' references from roxygen and
  script comments, and corrected three stale statements found at the
  same places: `run_full_factorial.R` said dropout was left to the
  author (it is now handled analytically in `R/design.R`) and now
  also states that schedules use independent seeds (confirmed:
  `seed <- base_seed + cell_id`); `run_scenario_grid.R` called the
  Monte Carlo grid a 'documented TODO'; `run_simulation.R` pointed
  to a renamed section ('Recalibration of the treatment effect',
  now 'Choice of the treatment effect'). The `analytic_gls_se()`
  roxygen said 'exact large-sample' and pointed to 'Reproducibility
  notes'; it now says 'exact for known variance components' and
  points to Methods and `closed_form_se()`. `man/*.Rd` regenerated
  with `roxygen2::roxygenise()` (a dry run on a scratch copy first
  confirmed that `man/` and `NAMESPACE` were otherwise in sync).
  Files: `R/simulation.R`, `R/covariance.R`,
  `analysis/scripts/run_simulation.R`,
  `analysis/scripts/run_full_factorial.R`,
  `analysis/scripts/run_scenario_grid.R`,
  `man/analytic_gls_se.Rd`, `man/analytic_gls_se_general.Rd`,
  `man/run_paired_simulation.Rd`, `man/simulate_trial_cov.Rd`,
  `man/run_one_sim_cov.Rd`. `[verified]`: comment and
  documentation text only; tests pass. The tinytest `info=`
  strings that say 'reviewed closed-form value' were left as they
  are.

Checks run:

- `pkgload::load_all('.'); tinytest::run_test_dir('inst/tinytest')`:
  59 of 59 pass, before and after the edits [verified].
- `bash tools/render.sh analysis/report/report.Rmd`, run twice
  (second run after a linetype adjustment): completes; only the
  existing cosmetic `!h` float warnings; `fig:re-ratio` and
  `fig:se-boxplot` labels resolve in `report.tex` [verified].
- Every number hardcoded in the abstract and body was recomputed by
  purling `report.Rmd` and evaluating it in a scratch session:
  analytic SEs 0.0678 and 0.0658, RE 1.06, analytic power 80.0% and
  82.4%, unconstrained RE 1.12, two-month-gap RE 1.08, CS RE 1.38,
  bootstrap RE 1.07 (1.06 to 1.09), dropout crossover 27.4%, grid
  counts 15/15 covering, 8/15 above 1, 6/6 random-slope cells at
  $\tau_1 \geq 0.30$ including 1, the eight cells listed in prose,
  and AR(1) analytic SEs monotone. All match the text [verified].

## 3. Long runs

None remain over the 10-minute cap. The only simulation rerun
still open (B4) now takes about 7 minutes (415 s logged on
2026-11-19, against 2226 s in August), so it is listed under author
decisions, not here.

## 4. Author decisions

- **A3b. Verbeke and Molenberghs.** Options: add the textbook as
  the reference for LMM notation, or leave it out. No claim in the
  current text needs it. Recommendation: add only if a journal style
  expects a notation reference; verify the edition first.
- **A6. Line numbers.** Keep `\usepackage[mathlines]{lineno}` and
  `\linenumbers` for submission and referee rounds; remove both lines
  from the YAML for the camera-ready version.
- **A8. Two `references.bib` files.** The root `references.bib`
  (last modified 2026-08-20) is not read by the manuscript and has
  diverged: it lacks `galbraith2002guidelines`,
  `raudenbush2001effects`, `zhao2022power`, `berger2009introduction`
  and the renamed Winkens keys, and holds unused entries
  (`coffey2003internal`, `gosho2015mmrm`, and others) plus a stale
  `@phdthesis{donohue2010power}`. Options: delete it, replace it with
  a symlink to `analysis/report/references.bib`, or keep it as a
  general library. Recommendation: delete it (or symlink), since
  edits have already landed in the wrong file once.
- **B1, B2, B7. Citation verification needing source access.**
  Mentre et al. (1997) coauthors, the Lee, Biedermann and Mitra MAR
  dropout paper, and the full texts of Raudenbush and Liu and
  Galbraith and Marschner. This pass made no external lookups.
  Recommendation: check in Zotero or the publisher pages; Lee et al.
  matters most, since the paper's dropout result is MCAR-only and a
  MAR design reference would anchor the limitation.
- **B3. Winkens et al. (2005) mean model.** The manuscript now says
  explicitly that it was not checked. Options: read the full text and
  either reconcile the CS result or keep the disclaimer.
  Recommendation: read it before submission; the disclaimer is
  honest but a referee will ask.
- **B4. Common random numbers in the grid.** The current text uses
  remedy (b) (independent samples, F-based intervals) correctly.
  Remedy (a) would narrow the intervals so that the direction is
  resolved in more cells, but requires changing
  `run_full_factorial.R` to share draws across schedules within a
  structure, rerunning (`Rscript analysis/scripts/run_full_factorial.R
  1000`, about 7 minutes single-core), and replacing the F-interval
  and the hardcoded list of cells above 1 in 'Monte Carlo scenario
  grid' with paired-bootstrap intervals. Recommendation: optional;
  the closed form already settles direction, so the gain is
  presentational.
- **B6. Misspecification and nonlinear trajectories.** Both are
  scope extensions (fit a random-slope model to AR(1) data, or add a
  quadratic term). The Discussion lists both as unexamined.
  Recommendation: leave as stated limitations unless the target
  journal expects a robustness section; a misspecification arm at
  1000 replications per cell would be of the same order as the
  current grid (minutes).
- **Outcome-dependent (MAR/MNAR) dropout** (residual of A2). The
  current calculation is MCAR with a constant hazard, stated as such.
  Recommendation: keep the scope statement; extend only with B2's
  reference in hand.

## 5. New issues found

- **Large uncommitted working tree.** The 2026-11-18 referee and
  voice revision, `R/design.R`, `inst/tinytest/test_design.R`, five
  `man/*.Rd` files, and the regenerated `factorial_grid.rds` are not
  committed, and four of those files are untracked. The 2026-08-20
  log recorded git object loss in this repository. Recommendation:
  commit soon.
- **`factorial_grid.rds` was regenerated on 2026-11-19** (R 4.6.0,
  415 s). Compared with the committed version, only `elapsed_seconds`,
  `r_version`, `generated_at`, and `bias` (mean relative difference
  about 1e-7) differ [verified with `all.equal()`]. Reported numbers
  are unaffected.
- **Hardcoded numbers remain in the YAML abstract and in
  'Choice of the treatment effect'** (for example 1.06, 1.12, 1.08,
  1.38, 1.07, 27%, 80.0%, 82.4%, 0.0678). All match today's
  computation (section 2), but they will not update if inputs change.
  Two same-minute renders also wrote a duplicate row to
  `analysis/report/share/MANIFEST.md`
  (`report-2026-11-23-1247-cddef1c-wip.pdf`, file overwritten); this
  is wrapper behavior and was left as is.
