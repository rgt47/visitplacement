# Voice and humanizer revision log: report.Rmd
*2026-11-18 16:12 PST*

Manuscript: `analysis/report/report.Rmd` (no supplement). Baseline:
`git show HEAD:analysis/report/report.Rmd` (working tree was clean
before this pass). Nothing was staged, committed, rendered, or pushed.

## Procedure

Pass 2 (use_rgtvoice) and Pass 3 (humanizer, File mode) were applied
together, paragraph by paragraph, in 21 paragraph-level Edit calls.
The two passes are therefore not separable in the diff. A grep-based
re-scan followed, covering 'rather than', 'not just', 'not only',
'genuine', 'underscore', 'crucial', 'robust', 'pivotal', 'key',
semicolons, and the subordinators ', which', 'whose', 'that depends',
'so that', 'although', 'while', and the dash and curly-quote checks
in the script. It led to 7 corrective edits:

- 'agrees with' was restored to 'is consistent with' in two places.
  The original wording is in the Monte Carlo extension and the
  Discussion.
- An added sentence ('The random-slope structure simulated here
  works differently.') was folded back into one sentence that
  carries the original 'instead'.
- The Candel (2008) finding regained its attribution ('They showed
  that ...').
- 'a correlation that depends only on' became 'Its correlation
  depends only on'.
- ', which respects the CRN pairing' became a separate sentence.
- One 26-word sentence was shortened to 25 words. 'the random-slope
  structure simulated here' became 'the simulated random-slope
  structure'.

Total: 28 Edit calls on the manuscript. The prose was not re-read
in full after the corrective edits. The re-scan was by grep and
script, so it was not a complete human-style read.

## Kinds of changes

1. Sentence splitting. The baseline had 58 sentences over 25 words.
   Long sentences were split at subordinate clauses, semicolons, and
   colons. Plain connectives head the second sentence ('However,',
   'As a result,', 'That is,', 'Nevertheless,', 'In turn,').
2. Participial riders removed. Examples are 'computing optimal
   allocations', 'showing that', 'finding that', 'demonstrating the
   practical impact', and 'formally accounting for'. Each became a
   separate sentence with its own subject.
3. Long math sentence restructured ('Analytic relative efficiency').
   The 79-word sentence defining Z_i, D, V, and M is now a sequence of
   'Let ... be ...' and 'The information matrix is ...' sentences.
   Every math token is unchanged.
4. Lists inside parentheses unpacked. This applies to the four
   schedules in the Monte Carlo extension, the quantities examined in
   'Present study', and the MCAR/MAR design decision (twice). Each
   now has its own sentence. 'MCAR/MAR' became 'MCAR versus MAR'.
5. Word choice. 'pragmatic' became 'practical', 'approximately'
   became 'about', 'demonstrated' became 'showed', 'additionally'
   became 'also', and 'exists to answer' became 'answers'.
   'underscores' (a humanizer stock word) became 'is a reminder
   that', which keeps the claim at the same strength. 'genuine' was
   dropped from 'a genuine Monte Carlo grid' and 'a genuine Monte
   Carlo assessment'.
6. Not-X-but-Y and contrast constructions. 'This is a genuine Monte
   Carlo assessment, not a re-derivation ...' became a direct
   statement. 'but not through the mechanism ...' (Discussion) became
   a 'However,' sentence. 'not just its estimation error' became 'in
   addition to its estimation error'. 'rather than redrawn' became
   'and is not redrawn'. 'close to, but not at, the ceiling' became
   'close to the ceiling but not at it'. 'informative rather than at
   ceiling' became 'informative and below the ceiling'.
7. Decorative bold removed. The two 'Present study' list labels
   ('Equal spacing:', 'Clustered spacing:') lost their bold. The list
   itself and its two items are unchanged.
8. The Discussion sentence about the earlier draft was reordered.
   It now reads 'An earlier draft of this report incorrectly described
   it as a structure that ...'. The quoted phrase is unchanged, and
   the correction is kept.

## Passages deliberately left alone

- YAML header and abstract (hard constraint). The abstract has a
  'rather than at ceiling' contrast and a hyphenated range; neither
  was touched.
- All code chunks, chunk options, kable captions, and `fig.cap`
  strings (code, not prose).
- Headings. They were already sentence case, so no change was made.
- The numbered four-item list in 'Simulation procedure' keeps four
  items. Only the prose inside items 1 and 2 was split.
- Internal revision notes ('2026-08-16 review, issue 2.4', 'issue
  2.8', 'issue 2.8(e)', 'An earlier draft ...'). The referee report
  (M7) asks for their removal. Removing them would change the number
  multiset and delete information, which this pass forbids. They are
  deferred to the remediation step.
- Claims the referee report flags as wrong or overstated were
  reworded only, never strengthened or corrected. These include the
  CS 'signal largest at the end' mechanism, 'different mechanism in
  each case', '14 of 15 cells corroborates', 'exactly as in the main
  comparison', 'not guaranteed to hold', the AR(1) 'packing visits'
  explanation, 'covariance misspecification', '1 to machine
  precision', and the Vickers 'seven total including baseline'
  paraphrase.
- The garbled phrase 'does not grow with $\tau_1$ boundary leverage'
  (referee minor 2) was kept verbatim. Its intended meaning is
  unclear, and guessing would change the claim.
- 'rather than' contrasts in which both halves carry information
  were kept. These are 'administrative convenience rather than
  statistical efficiency', 'random effects rather than fixed
  effects', and 'excluded ... rather than imputed or retried'.
- Sentences over 25 words that remain. Inline math counts as several
  whitespace tokens, and the rule was applied to prose words.
  - The 'Marginalizing over the random effects' sentence has about
    11 prose words plus one long display-style inline formula.
  - 'For each design we compute ...' has about 24 prose words plus
    two inline math expressions.
  - The other two scanner hits are false positives. One is two list
    items read as one sentence. The other is a sentence ending in
    `.'`, which the splitter does not break.
- Some conditional and purpose clauses were kept because they carry
  the condition or the purpose. These are the 'when', 'as', and
  'once' clauses and two 'so that' clauses. The 'so that' clauses
  are 'recalibrated $\beta_3$ so that ...' and 'resamples
  replication indices so that ...'.
- Signature hedges and RGT words ('endeavored', 'warrant mention',
  'merit emphasis', 'plausible', 'broadly', 'largely') were kept.

## Verification result

Script:
`/private/tmp/claude-501/-Users-zenn-prj-res-01-fisher-exact-rx2-fisherexacttestrx2-analysis-report/be4b228f-9df5-41a4-9039-7499d4f23926/scratchpad/05-visit/verify.py`,
run against `git show HEAD:analysis/report/report.Rmd`. Tokens were
stripped of a trailing period, comma, colon, or semicolon. The script
was first run on the untouched file to confirm a clean baseline.

| Check | Result |
|---|---|
| YAML header, including abstract, byte-identical | IDENTICAL |
| Code-chunk lines (fences, options, bodies) | IDENTICAL |
| Heading lines | IDENTICAL |
| Inline R expressions (multiset, exact bytes) | IDENTICAL |
| Inline and display math (multiset) | IDENTICAL |
| `\@ref()` cross-references (multiset) | IDENTICAL |
| `@` citation keys (multiset) | IDENTICAL |
| Numbers (multiset) | IDENTICAL |
| Em dashes, en dashes, curly quotes | 0, 0, 0 |
| Sentences over 25 whitespace tokens | 58 before, 4 after (explained above) |

Overall: PASS. The script was rerun after the corrective edits with
the same result. All changed lines are prose; no information-bearing
sentence was deleted and no literal repeats were merged.
