# Phase 3 verification: re-compute every numerical claim from the Rmd
# Run with: Rscript _audit/verify_numbers.R

# Use the snapshot CSV (canonical input — same as the Rmd's write.csv output)
suppressPackageStartupMessages({
  library(dplyr)
  library(urca)
  library(forecast)
  library(vars)
  library(tidyr)
  library(purrr)
})

set.seed(0)  # IRF / LP don't depend on seeds but be safe

csv_path <- "weekly_raw_values_SP500_VIX_US10Y_2005_2024.csv"
data_weekly_raw <- read.csv(csv_path, stringsAsFactors = FALSE) |>
  mutate(date = as.Date(date)) |>
  arrange(date)

# Sanity: dimensions
cat("=== SANITY ===\n")
cat("n_obs:", nrow(data_weekly_raw), "\n")
cat("start:", format(min(data_weekly_raw$date)), " end:", format(max(data_weekly_raw$date)), "\n")
cat("n_NA total:", sum(is.na(data_weekly_raw)), "\n")
cat("obs SP500:", sum(!is.na(data_weekly_raw$SP500)),
    "  VIX:", sum(!is.na(data_weekly_raw$VIX)),
    "  US10Y:", sum(!is.na(data_weekly_raw$US10Y)), "\n\n")

y_sp  <- data_weekly_raw$SP500
y_vix <- data_weekly_raw$VIX
y_us  <- data_weekly_raw$US10Y

# Min / max for descriptive references
cat("SP500 min:", min(y_sp), " (date:", format(data_weekly_raw$date[which.min(y_sp)]), ")\n")
cat("VIX max:",  max(y_vix), " (date:", format(data_weekly_raw$date[which.max(y_vix)]), ")\n")
cat("US10Y min:", min(y_us), "  US10Y max:", max(y_us), "\n\n")

# =====================
# ADF tests (Rmd claims)
# =====================
cat("=== ADF SP500 ===\n")
t3 <- ur.df(y_sp, type = "trend", lags = 6, selectlags = "AIC")
cat("M3 ADF tstat (claim -0.856) ->", round(t3@teststat[1], 3),
    " | trend b tstat (claim 1.727) ->", round(coefficients(t3@testreg)["tt","t value"], 3), "\n")
t2 <- ur.df(y_sp, type = "drift", lags = 6, selectlags = "AIC")
cat("M2 ADF tstat (claim 1.749) ->", round(t2@teststat[1], 3),
    " | const c tstat (claim 0.293) ->", round(coefficients(t2@testreg)["(Intercept)","t value"], 3), "\n")
t1 <- ur.df(y_sp, type = "none", lags = 6, selectlags = "AIC")
cat("M1 ADF tstat (claim 3.131) ->", round(t1@teststat[1], 3), "\n")

cat("\n=== ADF VIX ===\n")
t3v <- ur.df(y_vix, type = "trend", lags = 6, selectlags = "AIC")
cat("M3 ADF tstat (claim -5.715) ->", round(t3v@teststat[1], 3), "\n")

cat("\n=== ADF US10Y ===\n")
t3u <- ur.df(y_us, type = "trend", lags = 6, selectlags = "AIC")
cat("M3 ADF tstat (claim -1.453) ->", round(t3u@teststat[1], 3),
    " | trend b tstat (claim 0.545) ->", round(coefficients(t3u@testreg)["tt","t value"], 3), "\n")
t2u <- ur.df(y_us, type = "drift", lags = 6, selectlags = "AIC")
cat("M2 ADF tstat (claim -1.831) ->", round(t2u@teststat[1], 3),
    " | const c tstat (claim 1.734) ->", round(coefficients(t2u@testreg)["(Intercept)","t value"], 3), "\n")
t1u <- ur.df(y_us, type = "none", lags = 6, selectlags = "AIC")
cat("M1 ADF tstat (claim -0.592) ->", round(t1u@teststat[1], 3), "\n")

cat("\n=== KPSS ===\n")
k_sp  <- ur.kpss(y_sp,  type = "mu", lags = "long")
cat("KPSS SP500 (claim 4.235) ->",  round(k_sp@teststat,  3), "\n")
k_vix <- ur.kpss(y_vix, type = "mu", lags = "long")
cat("KPSS VIX (claim 0.244) ->",   round(k_vix@teststat, 3), "\n")
k_us  <- ur.kpss(y_us,  type = "mu", lags = "long")
cat("KPSS US10Y (claim 1.454) ->", round(k_us@teststat,  3), "\n\n")

# =====================
# ARMA(1,0) on log returns
# =====================
sp500_ret <- data_weekly_raw |>
  transmute(date, return_SP500 = log(SP500) - lag(log(SP500))) |>
  tidyr::drop_na()

arma_final <- Arima(sp500_ret$return_SP500, order = c(1,0,0), include.mean = TRUE)
cat("=== ARMA(1,0) ===\n")
cat("phi1 (claim -0.0734) ->", round(coef(arma_final)["ar1"], 4), "\n")
cat("mu   (claim 0.0015)  ->", round(coef(arma_final)["intercept"], 4), "\n")
se <- sqrt(diag(arma_final$var.coef))
p_phi <- 2*(1 - pnorm(abs(coef(arma_final)["ar1"]/se["ar1"])))
p_mu  <- 2*(1 - pnorm(abs(coef(arma_final)["intercept"]/se["intercept"])))
cat("p(ar1) (claim 0.0174) ->", round(p_phi, 4), "\n")
cat("p(mu)  (claim 0.0289) ->", round(p_mu, 4), "\n")
cat("AIC (claim -4778.19) ->", round(AIC(arma_final), 2), "\n")
cat("BIC (claim -4763.34) ->", round(BIC(arma_final), 2), "\n")
cat("sigma2 (claim 0.0005974) ->", signif(arma_final$sigma2, 4), "\n")

ar_roots <- polyroot(c(1, -coef(arma_final)["ar1"]))
cat("AR root modulus (claim 13.62) ->", round(Mod(ar_roots), 2), "\n\n")

# ARMA(0,3) candidate AIC (claim -4779.91)
arma_03 <- Arima(sp500_ret$return_SP500, order = c(0,0,3), include.mean = TRUE)
cat("ARMA(0,3) AIC (claim -4779.91) ->", round(AIC(arma_03), 2), "\n\n")

# =====================
# Forecasting
# =====================
fcst <- forecast(arma_final, h = 3, level = c(80, 95))
cat("=== Forecasts (log-returns) ===\n")
cat("h=1 (claim 0.002443) ->", round(fcst$mean[1], 6), "\n")
cat("h=2 (claim 0.001474) ->", round(fcst$mean[2], 6), "\n")
cat("h=3 (claim 0.001545) ->", round(fcst$mean[3], 6), "\n")
cat("last observed return (claim -0.01076) ->", round(tail(sp500_ret$return_SP500, 1), 5), "\n")

last_sp500 <- tail(data_weekly_raw$SP500, 1)
cat("last observed SP500 (claim 5906.94) ->", round(last_sp500, 2), "\n")
cum_ret <- cumsum(fcst$mean)
fc_lvl <- last_sp500 * exp(cum_ret)
cat("forecast level h=1 (claim 5921.39) ->", round(fc_lvl[1], 2), "\n")
cat("forecast level h=2 (claim 5930.12) ->", round(fc_lvl[2], 2), "\n")
cat("forecast level h=3 (claim 5939.29) ->", round(fc_lvl[3], 2), "\n\n")

# =====================
# VAR(1) — coefficients claimed
# =====================
vix_level  <- data_weekly_raw$VIX
us10y_diff <- diff(data_weekly_raw$US10Y)
n_obs <- min(length(sp500_ret$return_SP500), length(vix_level), length(us10y_diff))
var_data <- data.frame(
  date       = sp500_ret$date[2:(n_obs+1)],
  SP500_ret  = sp500_ret$return_SP500[2:(n_obs+1)],
  VIX        = vix_level[2:(n_obs+1)],
  US10Y_diff = us10y_diff[1:n_obs]
)
var_data <- var_data[complete.cases(var_data), ]
var_ts <- ts(var_data[c("SP500_ret","VIX","US10Y_diff")], start = c(2005,1), frequency = 52)

cat("VAR data nrow (claim ~1042):", nrow(var_data), "\n")
lsel <- VARselect(var_ts, lag.max = 6, type = "const")
cat("VARselect SC (claim 1):", lsel$selection["SC(n)"], "\n")
cat("VARselect AIC (claim 4):", lsel$selection["AIC(n)"], "\n")
cat("VARselect HQ (claim 2):", lsel$selection["HQ(n)"], "\n")
cat("VARselect FPE (claim 4):", lsel$selection["FPE(n)"], "\n")

var_model <- vars::VAR(var_ts, p = 1, type = "const")
s <- summary(var_model)
cat("\n=== VAR(1) SP500_ret eq ===\n")
sp_eq <- s$varresult$SP500_ret$coefficients
print(round(sp_eq, 6))
cat("R2 (claim 0.0057):", round(s$varresult$SP500_ret$r.squared, 4), "\n")
cat("=== VAR(1) VIX eq ===\n")
vix_eq <- s$varresult$VIX$coefficients
print(round(vix_eq, 4))
cat("R2 (claim 0.947):", round(s$varresult$VIX$r.squared, 4), "\n")
cat("=== VAR(1) US10Y_diff eq ===\n")
us_eq <- s$varresult$US10Y_diff$coefficients
print(round(us_eq, 6))
cat("R2 (claim 0.060):", round(s$varresult$US10Y_diff$r.squared, 4), "\n")

# VAR stability roots
cat("VAR roots (claim 0.928, 0.102, 0.019):", round(roots(var_model), 3), "\n")
# Residual correlations
rescor <- cor(residuals(var_model))
cat("\nResid cor SP500-VIX (claim -0.059):", round(rescor["SP500_ret","VIX"], 3),
    " SP500-Yield (claim -0.061):", round(rescor["SP500_ret","US10Y_diff"], 3),
    " VIX-Yield (claim -0.124):", round(rescor["VIX","US10Y_diff"], 3), "\n\n")

# =====================
# Granger causality
# =====================
cat("=== Granger ===\n")
for (cause in c("SP500_ret","VIX","US10Y_diff")) {
  g <- causality(var_model, cause = cause)$Granger
  cat(cause, "-> others : F =", round(g$statistic, 3), ", p =", signif(g$p.value, 4), "\n")
}

# =====================
# Johansen
# =====================
coint_data <- ts(data_weekly_raw[, c("SP500","VIX","US10Y")], start=c(2005,1), frequency=52)
lsl <- VARselect(coint_data, lag.max=6, type="const")
opt <- max(as.numeric(lsl$selection["AIC(n)"]), 2)
cat("\nJohansen K (claim 4):", opt, "\n")
jo <- ca.jo(coint_data, type="trace", ecdet="none", K=opt, spec="transitory")
cat("trace r=0 (claim 61.14):",  round(jo@teststat[3], 2), "\n")
cat("trace r<=1 (claim 9.12):",  round(jo@teststat[2], 2), "\n")
cat("trace r<=2 (claim 2.00):",  round(jo@teststat[1], 2), "\n")

# Normalized cointegrating vector with SP500 -> 1
beta1 <- jo@V[, 1]
beta_norm <- beta1 / beta1["SP500.l2"]
cat("Beta normalized (SP500=1): VIX (claim -410.59) ->", round(beta_norm["VIX.l2"], 2),
    ", US10Y (claim -327.12) ->", round(beta_norm["US10Y.l2"], 2), "\n")

alpha <- jo@W[, 1]
cat("alpha SP500 (claim 4.47e-4):",  signif(alpha[1], 3),
    " VIX (claim 1.17e-4):",  signif(alpha[2], 3),
    " US10Y (claim 1.43e-6):", signif(alpha[3], 3), "\n")
