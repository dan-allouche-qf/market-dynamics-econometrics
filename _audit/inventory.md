# Phase 1 — Inventory

## Repo overview

- **Type**: R Markdown analysis project (R-only repo, no .R scripts)
- **Topic**: Time series econometrics — interactions between S&P 500, VIX, and 10-Year US Treasury Yield
- **Period covered**: weekly 2005-01-01 → 2024-12-31, 1044 observations
- **Branch audit**: `audit-2026-05`, tag baseline `pre-audit-2026-05/main` = 633abd1

## Tracked files (6)

| Path | Size | Purpose |
|---|---|---|
| `.gitignore` | 230 B | R history / output exclusions; whitelists CSV at root by gitignoring `data/*.csv` only |
| `README.md` | 3 278 B | Project overview, methodology summary, R packages list |
| `data/` | empty dir | Intended for raw/processed data (currently empty — data file lives at repo root) |
| `market_dynamics_analysis.Rmd` | 110 264 B (1 745 lines) | Full econometric pipeline (univariate ADF/KPSS, ARMA, VAR, Granger, IRF Cholesky + LP, Johansen, VECM), code + interpretations |
| `market_dynamics_analysis.pdf` | 358 KB | Compiled PDF report (xelatex output of the Rmd) |
| `weekly_raw_values_SP500_VIX_US10Y_2005_2024.csv` | 63 374 B (1 045 lines incl. header) | Exported snapshot from Yahoo Finance (`^GSPC`, `^VIX`, `^TNX`) |

## Git history

- 3 commits total:
  - `de0869e` — Initial commit: Market Dynamics Econometrics project
  - `633abd1` — Add PDF report and update .gitignore (tag baseline)
  - `27eab61` — audit phase 0: init audit infrastructure

Authors: `Dan Allouche <dan.allouche@icloud.com>` only. No foreign authors.

## R packages required (extracted from Rmd `library()` calls)

- `tidyquant`, `dplyr`, `knitr`, `kableExtra`, `purrr`, `ggplot2`, `scales`
- `urca` (ADF, KPSS), `forecast` (Arima), `vars` (VAR, ca.jo, causality, irf, vec2var)
- `tidyr`, `lpirfs` (local projections)
- + `rmarkdown` for rendering, `xelatex` for PDF compilation

Status local: all 12 R packages + rmarkdown **installed** (R 4.5.3 aarch64-darwin).

## Reproducibility artifacts

- No `renv.lock`, no `DESCRIPTION`, no `sessionInfo.txt` shipped with the repo → reproducibility currently relies on `install.packages(...)` instructions in README.
- The Rmd performs `tq_get(...)` to pull live data from Yahoo Finance — but a static snapshot is committed at `weekly_raw_values_SP500_VIX_US10Y_2005_2024.csv` via `write.csv` in the data_import chunk. Live re-pull can produce small data revisions (Yahoo back-adjustments) but the snapshot is the canonical input.

## Identity (Phase 7)

- Rmd YAML: `author: "Dan Allouche"` (already correctly normalized — Cas B no-op)
- README.md: no author field present (Cas A — could be enriched, optional)
- LICENSE: absent
- CITATION.cff: absent
- No AI mentions (Claude, GPT, etc.) detected anywhere
- No foreign human names detected

## Secrets / abs paths

- `_audit/secrets_trufflehog.txt`: empty (no leaks)
- `_audit/abs_paths.txt`: empty (no non-portable absolute paths)

## Classification preview

- Theme: financial econometrics (PUBLIC_QUANT).
- Maturity: complete reproducible report (Rmd + compiled PDF + snapshot CSV).
- Suggested classification: **PUBLIC_QUANT** — Tier provisional: A (clean methodology, complete code-to-report pipeline, light gaps on reproducibility metadata).
