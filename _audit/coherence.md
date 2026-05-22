# Phase 4 — Code ↔ Description coherence

## Methodology described in README and Rmd

| Method | README claim | Rmd implementation | Match |
|--------|--------------|--------------------|-------|
| ADF + KPSS unit root tests | yes | `urca::ur.df` + `urca::ur.kpss` with sequential M3 → M2 → M1 | Y |
| ARMA model BIC selection | "ARMA(1,0) based on BIC" | grid search p,q in {0..4}, BIC-min = ARMA(1,0) | Y |
| Short-term forecasting 1-3 weeks with PIs | yes | `forecast(arma, h=3, level=c(80,95))` | Y |
| VAR(1) | yes | `vars::VAR(var_ts, p=1, type="const")` | Y |
| Granger causality | yes | `vars::causality(var_model, cause=X)` — joint per cause (3 tests, originally claimed as 6 bilateral; corrected) | Y after fix |
| IRF Cholesky | yes | `irf(var_model, n.ahead=12, ortho=TRUE)` | Y |
| IRF Local Projections | yes | `lpirfs::lp_lin(...)` BIC lag selection, h=12 | Y |
| Johansen cointegration trace test | yes | `urca::ca.jo(coint_data, type="trace", K=4)` | Y |
| VECM | yes | `vars::vec2var(johansen_test, r=1)` | Y |

## Coherence issues found and resolved

- **Joint vs bilateral Granger**: README does not specify which form; the Rmd was internally incoherent (labels said bilateral, computation was joint). Resolved (C-02 — see findings_confirmed.md).
- **Stale "Question N" references**: C-03; resolved.
- **Mislabeled Johansen output**: C-01; printed values now match the interpretation text. Resolved.

## Coherence between Rmd interpretations and recomputed numerics

All 68 quantitative claims cross-listed in `claims.csv` recomputed in `verify_numbers.R` — every match=Y. Recompute precision: down to 4 to 6 decimals (verify_numbers.log).
