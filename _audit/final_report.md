# Final report — `market-dynamics-econometrics`

Branch: `audit-2026-05`. Baseline: `pre-audit-2026-05/main` = 633abd1.

## Scope and method

R-only repo with a single 1745-line Rmd ("market_dynamics_analysis.Rmd"), a PDF report, a bundled CSV snapshot (weekly SP500/VIX/US10Y 2005-2024, 1044 observations, no missing values), and a README. Audit covered Phases 1–7 and 10 of the v6 protocol. Phase 2 was executed in full dynamic mode (R 4.5.3, all 12 required R packages installed, xelatex via TinyTeX); the corrected Rmd was re-rendered end-to-end and the resulting PDF was committed.

## Findings summary

| Priority | Found | Confirmed | Fixed | Rejected |
|---|---|---|---|---|
| P0 | 1 | 1 | 1 | 0 |
| P1 | 2 | 2 | 2 | 0 |
| P2 | 0 | 0 | 0 | 0 |
| P3 | 6 | 3 | 3 | 3 |

### Confirmed and fixed

- **C-01 (P0)**: Mislabeled Johansen trace output (`vecm_estimation` chunk). Pre-fix PDF printed `r = 0: 2`, `r <= 2: 61.14`, contradicting the narrative text that correctly stated `r = 0: 61.14`. Cause: `map_dfr` double-permutation of labels vs values. Fixed by rebuilding the data.frame with `teststat[n_vars:1]` ordering and matching labels.
- **C-02 (P1)**: Granger causality table claimed 6 bilateral tests but `causality(model, cause=X)` returns the joint test "X → rest of system". Same F-values were duplicated and the narrative attributed `F = 893.56` to two distinct bilateral directions. Fixed by reducing the test list to 3 properly-labelled joint tests and rewriting the two interpretation paragraphs to derive the bilateral conclusions from the (correctly bilateral) VAR coefficients.
- **C-03 (P1)**: Stale "Question 3/4/6" cross-references inherited from an academic homework numbering — the document has no question structure. Replaced with descriptive references to the actual section names (9 hits, all fixed).
- **C-04 (P3)**: `shapiro.test(residuals_arma[1:5000])` with comment "computational constraints" — slice was a no-op (residual series has ~1043 obs). Now passes the full vector with a corrected note.
- **C-05 (P3)**: `data_import` chunk pulled from Yahoo Finance and `data_export` unconditionally overwrote the canonical CSV on every render. Now reads the snapshot first and only falls back to a live pull if the snapshot is missing; export only writes if file does not exist.
- **C-06 (P3)**: README had no author. Added `Author: Dan Allouche` plus Project Structure / Data and Reproducibility / Render instructions sections.

### Rejected (see findings_rejected.md)

- R-01 Decorative arrows → are substantive (Granger directions)
- R-02 LaTeX header packages cosmetic redundancy — kept (safe to keep)
- R-03 "Limitations and Future Research" — substantive content, not a stub

## Reproducibility

Status: **YES — fully reproducible end-to-end**.

- All 12 R packages from the README install instructions present locally (R 4.5.3 aarch64-darwin).
- xelatex available (TinyTeX r78301).
- Re-ran `rmarkdown::render("market_dynamics_analysis.Rmd")` after fixes: success, ~30 s runtime, PDF regenerated (commit 20e7564).
- Bundled CSV snapshot is the canonical input (1044 obs, 0 NAs); the chunk fallback only re-pulls Yahoo Finance if the snapshot is absent. This makes the report deterministic offline.

Recommendation (not blocking): generate and commit a `sessionInfo.txt` for pinning, and consider `renv::init()` later. Not added now to avoid creating a new file beyond audit infrastructure without the user's input (DECISIONS_REQUIRED if implemented systematically across the portfolio).

## Numeric verification (Phase 3)

68 distinct numeric claims extracted from the Rmd and recomputed by `_audit/verify_numbers.R` against the canonical CSV. Every recomputation matched at the precision claimed (typically 3-6 decimals). Full log: `_audit/verify_numbers.log`. Notably, the ARMA(1,0) coefficients, the VAR(1) coefficient matrix, the Granger F-statistics, the Johansen trace statistics, the cointegrating vector coefficients (410.59, 327.12), the adjustment coefficients (4.47e-4, 1.17e-4, 1.43e-6), and the 3-week forecast levels (5921.39, 5930.12, 5939.29) all reproduce exactly.

## Identity (Phase 7)

- Rmd YAML: `author: "Dan Allouche"` (pre-existing, correct — Cas B no-op).
- README: added explicit `Author: Dan Allouche`.
- Git history: single author `Dan Allouche <dan.allouche@icloud.com>`. No foreign names.
- No AI mentions (Claude / GPT / Anthropic / Copilot / Sonnet / Opus / "AI") anywhere in code, narrative, or PDF.
- Cas applied: **B** for Rmd YAML (already normalized), **A** for README (no name present → added).

## Classification

- **PUBLIC_QUANT** — financial econometrics on public Yahoo Finance series; no proprietary data; standard methodology (ADF/KPSS, ARMA, VAR, Granger, IRF Cholesky + LP, Johansen, VECM).
- **Tier: A**
  - Strengths: rigorous time-series pipeline, full coverage of theory → estimation → diagnostics → forecast → multivariate → cointegration → VECM. 20-year sample. Complete reproducibility chain (R + xelatex + bundled snapshot). All 68 numeric claims recomputed and match.
  - Limitations: no `renv.lock` / `DESCRIPTION` for pinned versions; linear modeling only (acknowledged in the Rmd's "Limitations and Future Research" section); no out-of-sample backtesting of the ARMA forecasts.

## Bloqueurs / DECISIONS_REQUIRED

None. The audit was conducted entirely with conservative defaults; no item required user input.

## Phase 2 status

**Executed (dynamic).** R + all required packages + xelatex available locally; rendered the Rmd to PDF end-to-end successfully after fixes. Pre-render and post-render numerics match exactly except for the targeted corrections (Johansen output, Granger labels, removed "Question N", shapiro comment).

## Commits

- 27eab61 — audit(market-dynamics-econometrics): phase 0 — init audit infrastructure (pre-existing)
- c7ae634 — audit(market-dynamics-econometrics): phase 1-7 — fix VECM label swap, clarify Granger interpretation, add data snapshot fallback
- 20e7564 — audit(market-dynamics-econometrics): phase 2 — regenerate PDF from corrected Rmd

## Diff vs baseline

Will be produced at the end via `git diff pre-audit-2026-05/main..HEAD --stat > _audit/diff_summary.txt`.
