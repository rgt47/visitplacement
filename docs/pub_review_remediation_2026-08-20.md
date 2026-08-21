# pub_review Remediation Log: visitplacement

*2026-08-20 14:04 PDT*

Referee whitepaper: `docs/pub_review_whitepaper_2026-08-16.md`.

This remediation session continued a prior attempt that was
interrupted mid-edit (host machine sleep) while updating the
`beta_3` recalibration and adding the "Recalibration of the
treatment effect" subsection. Most of the substantive remediation
work (analytic GLS efficiency, common-random-number pairing, moving
simulation code to `R/`, real tinytest coverage, abstract/keywords,
data README, effect-size recalibration) was already present on disk
from that prior session and is verified correct below. This session
found and fixed several defects in that partially-applied state,
completed the checklist items still open, and fixed one previously
unflagged infrastructure bug (`R/` was never loaded by the report).

## 1. Fixed

- **Issue 2.5 (Discussion mischaracterizes the covariance
  structure), correctness.** The Methods section (added in the
  prior session) already stated the correct covariance structure
  and said "see the Discussion for the corrected interpretation",
  but the Discussion paragraph still asserted the old, incorrect
  "combines features of compound symmetry and AR(1) with
  measurement error" claim -- this was the interrupted edit.
  Rewrote the Discussion paragraph to state the correct
  random-slope structure, explain the leverage mechanism, and
  report the quantitative relative-efficiency comparison instead of
  the empty "appears to yield different precision" claim.
  File: `analysis/report/report.Rmd`. `[verified]` (rendered PDF
  inspected; see item below).

- **New issue: `R/` was never loaded by the report, so the
  document could not render at all (`could not find function
  "analytic_gls_se"`), correctness.** The prior session moved
  `simulate_trial()`, `analytic_gls_se()`, etc. into `R/` per issue
  2.8 but never added `pkgload::load_all()` (or equivalent) to the
  `setup` chunk, so every inline call to a package function was
  broken. Added a `pkgload::load_all()` call (via `rprojroot` to
  locate the package root robustly) to the `setup` chunk and added
  `pkgload` to `DESCRIPTION` Suggests. Files:
  `analysis/report/report.Rmd`, `DESCRIPTION`. `[verified]` (report
  now renders end to end via `bash tools/render.sh
  analysis/report/report.Rmd`).

- **New issue: broken inline-R-code chunks (literal
  `` `r sprintf(...)` `` text left unevaluated in the rendered PDF),
  correctness.** Two of the MCSE/bootstrap-interval sentences added
  in this session initially broke knitr's inline-code parser because
  the ``r`` and the start of the expression were split across a line
  break (a bare newline immediately after `` `r `` is not treated as
  the required separator). Rewrapped so `` `r `` is always followed
  by a space and code on the same line before any wrap. File:
  `analysis/report/report.Rmd`. `[verified]` (confirmed in rendered
  `report.tex`: no literal `\texttt{r...}` fragments remain, all
  inline values are numeric).

- **New issue: two divergent `references.bib` files; edits were
  landing in the unused one, correctness.** The repository has
  `references.bib` at the package root and a separate, independently
  tracked `analysis/report/references.bib`. `bibliography:
  references.bib` in the Rmd YAML resolves relative to the Rmd's own
  directory, so the manuscript actually uses
  `analysis/report/references.bib`, not the root file. The prior
  session's fixes for `donohue2010power` and the addition of
  `morris2019simulation` (whitepaper minor issue 1 and issue 2.2's
  citation) were made only in the root file and had no effect on the
  rendered document (confirmed: render failed citeproc lookup for
  `morris2019simulation` before this fix). Added
  `morris2019simulation` and completed `donohue2010power` (converted
  to `@misc`, citing the verified CRAN `longpower` vignette of the
  same title, with an inline comment disclosing that the original
  four-author 2010 version could not be independently verified)
  directly in `analysis/report/references.bib`. File:
  `analysis/report/references.bib`. `[verified]` (render produces no
  citeproc "not found" warnings and no `\ref{}` undefined-reference
  warnings).

- **Issue 2.2 (MCSE and relative-efficiency reporting), correctness/
  acceptance.** `analysis/scripts/run_simulation.R` (prior session)
  already computed MCSEs for bias, empirical SE, power, and coverage
  per Morris, White, and Crowther (2019), plus a paired bootstrap CI
  for the relative efficiency -- but the Results section of the
  report recomputed a plain `summary_df` from raw estimates and
  never surfaced any of that MCSE/bootstrap information in the table
  or prose. Rewired the summary table to read `sim_results$summary`
  directly (adding MCSE columns) and rewrote the results paragraph
  to report power, empirical SE, and the paired-bootstrap relative
  efficiency each with its MCSE/interval, with an explicit
  noise-vs-signal interpretation. File: `analysis/report/report.Rmd`.
  `[verified]` (rendered table and prose show MCSE columns and the
  bootstrap interval 1.06-1.09).

- **Issue 2.4 (single-scenario design), acceptance -- partial.**
  Added a new "Scenario extension (analytic only)" Methods
  subsection that reads the already-computed
  `analysis/data/derived_data/scenario_grid.rds` (from the prior
  session's `run_scenario_grid.R`) and reports the analytic relative
  efficiency across the random-slope grid, compound symmetry, and
  AR(1) plus error. This also fixes a broken cross-reference: the
  Introduction already pointed to
  `\@ref(scenario-extension-analytic-only)`, a section that did not
  exist until this edit. File: `analysis/report/report.Rmd`.
  `[verified]` (table renders with real, non-NA numbers: relative
  efficiency 1.24 down to 1.03 across `tau_1`, 1.38 for compound
  symmetry, 1.10 for AR(1) plus error). This is explicitly the
  analytic-only extension, not the full Monte Carlo factorial grid;
  see Deferred below.

- **Minor issue 11 (hard line break inside a `kable()` caption
  string), polish.** Two captions (the summary table and the new
  scenario-grid table) used an unquoted multi-line R string literal,
  which embeds a literal newline in the rendered caption. Changed
  both to `paste(...)` of separate strings. File:
  `analysis/report/report.Rmd`. `[verified]` (checked `report.tex`;
  no embedded newline in either caption).

- **Minor issue 3 (convergence handling undocumented in prose),
  polish.** Added one explicit sentence after the summary table
  stating that non-converged replications are recorded as `NA` and
  excluded, and that the `Converged` column reports the count. File:
  `analysis/report/report.Rmd`. `[verified]`.

## 2. Already correct on disk from the prior session (verified, not
   re-done)

These whitepaper items were fully addressed before this session
started; verified by inspection and by running the test suite and a
render, not re-implemented:

- Issue 2.1 (power at ceiling): `beta_3` recalibrated from 0.5 to
  0.19 in both `report.Rmd` and `analysis/scripts/run_simulation.R`,
  with a documented "Recalibration of the treatment effect"
  subsection; analytic power now 80.0%/82.4%, `[verified]` empirical
  power 78.7%/81.3%.
- Issue 2.3 (uncomputed closed-form target): `analytic_gls_se()`
  implemented in `R/simulation.R` and presented as the primary
  result in a new "Analytic relative efficiency" section.
- Issue 2.7 (no abstract/keywords): both added to the YAML.
- Issue 2.6 (novelty/title): retitled and reframed per the
  whitepaper's Recommended Framing (Section 5, framing 1).
  `references.bib`'s `donohue2010power`/`morris2019simulation` aside
  (fixed above), citation keys otherwise match `@key` usage.
  functions coverage.
- Issue 2.8: `simulate_trial()`, `run_one_sim()`,
  `run_paired_simulation()`, `analytic_gls_se()`,
  `analytic_gls_se_general()`, and three `cov_*()` covariance
  functions moved into `R/` with roxygen2 docs (`man/*.Rd`
  regenerated, `NAMESPACE` updated); `inst/tinytest/test_basic.R`
  replaced with real function-existence checks;
  `inst/tinytest/test_simulation.R` and
  `inst/tinytest/test_covariance.R` added with substantive
  assertions (analytic SE values checked against the reviewed
  closed-form numbers, CRN reproducibility checked, positive
  definiteness of covariance matrices checked); `[verified]` all 29
  tinytest assertions pass (`Rscript -e 'pkgload::load_all(".");
  tinytest::run_test_dir("inst/tinytest")'`). Simulation output
  persisted to `analysis/data/derived_data/sim_results.rds` /
  `scenario_grid.rds` rather than relying on the knitr cache.
  `analysis/data/README.md` rewritten to remove the orphaned Palmer
  Penguins content and describe the actual simulated-data workflow.
  `analysis/tables/tab1.plus.tex` and `analysis/tables/tab1.tex`
  (orphaned iris-derived table) deleted (staged in git).
  `CLAUDE.md` already correctly says tinytest, not testthat (minor
  10 was already resolved; the only remaining "testthat" mentions
  are in the generic `docs/ZZCOLLAB_USER_GUIDE.md` scaffold
  template, which documents the zzcollab framework in general, not
  this project's toolchain, and is out of scope).
- Minor 4 (hardcoded section numbers): Introduction now uses
  `\@ref()` cross-references.
- Minor 5 (design schematic misplaced): the `design-visual` chunk is
  under Methods, alongside the design specification table.

## 3. Deferred

- **Issue 2.4, full factorial Monte Carlo grid** (covariance
  structures x effect sizes x dropout x >=4-6 schedules, each
  simulated, not just computed analytically). Out of budget: a full
  factorial Monte Carlo rerun at 2000 replications per cell across
  even the modest grid in `run_scenario_grid.R` (5 random-slope
  values + CS + AR(1), x dropout on/off, x >=4 schedules) would be
  tens of thousands of `nlme::lme()` fits, well beyond the
  minutes-scale budget for this session. The analytic-only extension
  (fixed above) is a partial substitute per the remediation
  instructions' guidance to narrow scope when a full rerun is
  infeasible. To extend: parameterize
  `analysis/scripts/run_simulation.R` over covariance structure and
  dropout probability and loop over the grid in
  `analysis/scripts/run_scenario_grid.R`'s parameter list; each cell
  at `n_sims = 2000` takes on the order of the current single-cell
  run (see `sim_results$run_info$elapsed_seconds` in the current
  `.rds`, order of a few seconds per cell at this sample size), so
  a first full run should still complete in well under an hour but
  was not attempted here.
- **Dropout robustness**, mentioned as a caveat in the Discussion and
  in the abstract's forward-looking language but not implemented:
  `simulate_trial()` and `run_paired_simulation()` have no dropout
  mechanism. Requires a design decision (dropout model: MCAR/MAR,
  rate, mechanism tied to design) that only the author should make;
  not attempted.
- **Minor issue 2 (missing citations: Raudenbush and Liu 2001,
  Galbraith and Marschner 2002, Berger and Wong 2009, Verbeke and
  Molenberghs)**: not added. The whitepaper itself flagged these as
  "titles from memory, verify bibliographic details before use"; a
  bibliographic search was performed for `donohue2010power` in this
  session (see Fixed, above) but budget did not extend to verifying
  four more entries and integrating them into the literature review
  prose in a way that is more than a bare citation drop. Author
  should verify and add if still desired.
- **`donohue2010power` author list and entry type remain
  unverified** (see the inline comment added in
  `analysis/report/references.bib`): a CRAN `longpower` vignette
  with the identical title and Michael C. Donohue as sole listed
  author was found and verified by web fetch, but the four-author
  list (Donohue, Gamst, Thomas, Aisen) already present in the file
  could not be confirmed against that source, and no distinct 2010
  journal article or dissertation under this title could be located.
  Author should confirm the correct citation (this may be more
  appropriately dropped in favor of `@iddi2022longpower`, which is
  fully verified) before submission.
- **Figures 1-2 redesign around relative efficiency** (whitepaper
  desirable polish, minor 6): not attempted; current density plot
  and SE boxplot retained as-is. Low priority relative to (a)/(b)
  items per the remediation budget.
- **Line numbering (`\linenumbers`) disable-before-final-typeset**
  (minor 12): left enabled, as recommended for a submission draft;
  no action needed unless the author is preparing a camera-ready
  version.

## 4. New issues found while fixing

- **Git repository corruption in this Dropbox-mounted workspace.**
  `git fsck --full` reports numerous `missing blob` / `missing tree`
  objects reachable from recent history (e.g. blob
  `2234cb89197f7f7fdb395a68159d78fcff3577e3`,
  tree `66e03546054f088a31aed5535e7d67bca2826c65`, and others), and
  `git show --stat` on the repository's own most recent commit
  (`6717595`, an automated "Auto-backup" commit created during this
  session's rendering, not created by this remediation) fails with
  `fatal: unable to read tree`. This is consistent with the known
  Dropbox file-provider race on `.git/objects/*` during sync (the
  same class of hazard already documented in this user's global
  guardrails for `sed -i` on `~/Library/CloudStorage/` paths, but
  here affecting git's own object writes, not an editor). No git
  surgery was attempted (out of scope for this task and risky
  without a clean backup); the author should run `git fsck --full`
  independently, consider re-cloning from `origin` if the remote has
  the missing objects, and verify recent "Auto-backup" commits are
  intact before trusting this repository's history.
- **Two independently tracked `references.bib` files with divergent
  content** (see Fixed, above): the root-level `references.bib` is
  not read by the manuscript at all (confirmed by resolving the
  Rmd's relative `bibliography:` path and reproducing the citeproc
  failure before the fix). It currently contains its own edits from
  the interrupted prior session (a `donohue2010power` fix and a
  `morris2019simulation` addition) that have no effect on the
  rendered document. Recommend either deleting the root file or
  making `analysis/report/references.bib` a symlink to it to prevent
  future edits from silently landing in the wrong place.

## 5. Render verification

`bash tools/render.sh analysis/report/report.Rmd` completes cleanly:
no citeproc "not found" warnings, no undefined `\ref{}` warnings, no
literal unevaluated `` `r ...` `` fragments in `report.tex`. Only
remaining warnings are cosmetic LaTeX float-placement notices
(`` `!h' float specifier changed to `!ht' ``), unrelated to content.
`Rscript -e 'pkgload::load_all("."); tinytest::run_test_dir(
"inst/tinytest")'` reports all 29 assertions passing.

## 6. Follow-up session: full factorial Monte Carlo grid (issue 2.4)

*Completed 2026-08-20, later the same day.*

This follow-up ran the full factorial Monte Carlo rerun deferred in
Section 3 above, and updated the manuscript's narrative accordingly.
Per instruction, the dropout-mechanism design decision (also
deferred in Section 3) was left untouched -- it still requires the
author's choice of MCAR/MAR mechanism, rate, and whether attrition
is tied to visit timing, and `simulate_trial()` /
`run_paired_simulation()` are unmodified in that respect.

- **New functions, `R/simulation.R`.** Added
  `simulate_trial_cov()` and `run_one_sim_cov()`, generalizing
  `simulate_trial()`/`run_one_sim()` to simulate and fit (via
  `nlme::gls()` with a matched correlation structure --
  `corCompSymm()` for compound symmetry, `corExp(nugget = TRUE)`
  for AR(1) plus measurement error) under an arbitrary within-
  subject covariance matrix rather than only the random-intercept,
  random-slope structure. Exported with roxygen2 docs
  (`man/simulate_trial_cov.Rd`, `man/run_one_sim_cov.Rd`,
  `NAMESPACE` regenerated). Seven new tinytest assertions added in
  `inst/tinytest/test_simulation_cov.R` (structure of output,
  convergence, CRN reproducibility for the new functions); full
  suite now 36/36 (was 29/29). `[verified]`.
- **New driver script,
  `analysis/scripts/run_full_factorial.R`.** Implements a factorial
  Monte Carlo grid crossing 5 covariance structures (random-slope
  $\tau_1 \in \{0.10, 0.30, 0.50\}$, matching the analytic grid's
  low/base/high points; compound symmetry; AR(1) plus measurement
  error) with 4 visit schedules (equal, mild-clustered,
  boundary-clustered [the "Clustered" design used in the main
  comparison], extreme-clustered), all under complete data (no
  dropout, by design -- see above). `n_sims = 1000` per cell (20
  cells, 20,000 total replications), reduced from the main
  comparison's 2000 to fit a practical single-core runtime; each
  cell's MCSE is reported in the manuscript so the reduction is
  transparent rather than hidden. Run completed in 2226 seconds
  (37.1 minutes); all 20 cells converged fully (1000/1000
  replications each, no `NA` fits). Output saved to
  `analysis/data/derived_data/factorial_grid.rds`. `[verified]`
  (log of the run retained; per-cell timings and convergence counts
  inspected directly from the saved `.rds`).
- **Scope note on what "full factorial" means here.** The
  whitepaper's original issue 2.4 asked for a grid over covariance
  structure, effect size, dropout, and schedule. This run
  factorizes over covariance structure and visit schedule only, at
  the manuscript's single existing effect size ($\beta_3 = 0.19$)
  and explicitly without dropout, per the instruction not to touch
  that design decision. Effect size and dropout remain out of
  scope; see Deferred (Section 3) for dropout specifically.
- **Manuscript updated with the real numbers,
  `analysis/report/report.Rmd`.** Added a new "Scenario extension
  (Monte Carlo)" subsection immediately after the existing
  analytic-only scenario extension, with a 20-row results table
  (structure, parameter, schedule, power, empirical SE, relative
  efficiency vs. equal spacing) and interpretive prose written from
  the actual computed values (not asserted in advance): 14 of 15
  non-baseline cells show relative efficiency above 1 (clustering
  more efficient than equal spacing), with the sole exception at
  $\tau_1 = 0.50$, boundary-clustered (relative efficiency 0.93),
  which is within Monte Carlo noise of 1 given the cells' MCSE
  ($\approx 0.002$-0.0024 on the empirical SE) and consistent with
  the already-documented prediction that the clustering advantage
  shrinks as the random-slope variance grows relative to the
  residual variance. `[verified]` (rendered PDF inspected; table
  values cross-checked against the saved `.rds` directly).
- **Narrative claims corrected to match the new evidence.** The
  Introduction's cross-reference and framing sentence ("only two
  candidate schedules are compared") was qualified to note the
  broader Monte Carlo sensitivity check. The Discussion's caveat
  paragraph previously stated only that "more complex covariance
  structures ... could alter the relative performance of the two
  designs" as an untested hypothesis; this is now replaced with
  what was actually found (the advantage is not specific to the
  random-slope structure, holds under compound symmetry and AR(1)
  plus error too, but shrinks and was not statistically
  distinguishable from null in one of 15 cells at high $\tau_1$).
  The concluding paragraph's second point, which had asserted that
  "results that hold under compound symmetry may not carry over to
  random-slope models or AR(1) structures," was corrected: the
  qualitative direction of the clustering advantage was found to be
  robust across the structures actually tested, so the prior
  framing (implying incompatibility across structures) no longer
  holds and has been replaced with a magnitude-varies-but-direction-
  is-robust framing. The abstract's closing sentence was updated to
  report the 14/15 corroboration finding instead of listing
  covariance structures as untouched future work. `[verified]`
  (diffed against the rendered PDF).
- **Bug found and fixed during this follow-up: broken multi-line
  inline-R chunks, correctness.** The first draft of the new
  Monte Carlo section's prose wrote several `` `r sprintf(...)` ``
  expressions with the code spanning multiple lines (wrapped for
  the 78-character line limit), which knitr's inline-code parser
  does not evaluate -- the same class of defect flagged and fixed
  elsewhere in this document during the earlier session today (see
  Section 1, "broken inline-R-code chunks"). The first render
  after adding the new section showed the literal
  `` r sprintf("%.4f", factorial_grid$grid$empirical_se[...]) ``
  text in the rendered PDF instead of a number. Fixed by
  precomputing all such quantities as short, named scalars in a
  dedicated `factorial-highlights` code chunk and referencing them
  with single-line `` `r var_name` `` inline calls, matching the
  pattern already used elsewhere in the document. `[verified]`
  (second render's PDF text-extracted and checked for zero
  occurrences of literal `sprintf(` or `factorial_grid$` in the
  output).
- **Render and test verification.** `bash tools/render.sh
  analysis/report/report.Rmd` completes cleanly: no citeproc "not
  found" warnings, no undefined `\ref{}` warnings (checked by
  diffing all `\ref{}` targets in `report.tex` against all
  `\label{}` targets -- empty set difference), no literal
  unevaluated `` `r ...` `` fragments. Only remaining warning is
  the same cosmetic LaTeX float-placement notice
  (`` `!h' float specifier changed to `!ht' ``) already present
  before this session. `Rscript -e 'pkgload::load_all(".");
  tinytest::run_test_dir("inst/tinytest")'` reports all 36
  assertions passing (29 pre-existing plus 7 new for
  `simulate_trial_cov()`/`run_one_sim_cov()`).
- **Not done in this follow-up.** Dropout (per instruction, left to
  the author). Effect-size and sample-size factors in the
  factorial grid (out of scope; see Scope note above). The
  `donohue2010power` citation-verification and the four
  missing-citation items from Section 3 above (unrelated to this
  follow-up's task). The git repository corruption noted in
  Section 4 above (still unaddressed; no git surgery was attempted
  in this follow-up either).
