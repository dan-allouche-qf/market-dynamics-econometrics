# Pass 1 — actions

## Pre-pass state
- Branch: `audit-2026-05`, baseline tag `pre-audit-2026-05/main` = 633abd1
- Phase 0 commit: 27eab61 (audit infrastructure)

## Phases run

| Phase | Status | Notes |
|-------|--------|-------|
| 1 — Inventory | done | `_audit/inventory.md` |
| 2 — Reproducibility | **dynamic, OK** | R 4.5.3 + all 12 R packages + xelatex (TinyTeX) available. Full `rmarkdown::render()` succeeded end-to-end. |
| 3 — Claims (P0) | done | `verify_numbers.R` recomputed all 68 numeric claims against the bundled CSV; all match. See `claims.csv`. |
| 4 — Code ↔ desc | done | `coherence.md`. Two P1 fixes (Granger labels, Question N refs). |
| 5 — Dead code | n/a | Single-Rmd repo, no `.R` scripts. Inline chunks all referenced by sections. |
| 6 — Anti-AI-slop | done | No emojis, no AI mentions, no "Voici"/"Let me explain" patterns. One P3 docstring/comment fixed (shapiro slice comment). |
| 7 — Identity | done | YAML already "Dan Allouche". Added explicit author in README. No foreign names in git log. |
| 10 — Classification | done | See final_report.md |

## Findings P0/P1/P2 status after this pass
- P0: 1 confirmed → fixed (Johansen output relabeling)
- P1: 2 confirmed → fixed (Granger joint vs bilateral, Question N refs)
- P2: 0 (no dead code)
- P3: 3 confirmed → fixed (shapiro comment, data import snapshot fallback, README author)

## Commits this pass
- c7ae634 — phase 1-7 fixes (Rmd + README + audit infra)
- 20e7564 — phase 2 regenerated PDF

## Convergence check
- P0+P1+P2 confirmed but unfixed: 0 → CONVERGED on pass 1.
