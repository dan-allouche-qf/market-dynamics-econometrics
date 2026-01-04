# Market Dynamics Econometrics: Interactions Between Implied Volatility, Interest Rates, and Stock Markets

## Overview

This project provides an in-depth econometric analysis of the dynamic interactions between three key financial indicators: the S&P 500 Index, the CBOE Volatility Index (VIX), and the 10-Year US Treasury Yield. Covering two decades of weekly data (2005–2024), the study explores how market sentiment, interest rate regimes, and equity performance co-evolve and influence each other.

The analysis follows a rigorous time series framework, transitioning from univariate ARMA modeling to multivariate VAR and VECM specifications to capture both short-term spillover effects and long-term equilibrium relationships.

## Research Objectives

The primary goal of this research is to answer:
- How do implied volatility and long-term interest rates interact with equity market levels over time?
- Which variables act as the primary drivers (Granger-causal factors) within the financial system?
- Does a long-run equilibrium (cointegration) exist between these historically linked variables?

## Methodology

### 1. Univariate Analysis
- **Stationarity Testing**: Comprehensive unit root testing using Augmented Dickey-Fuller (ADF) and KPSS tests.
- **ARMA Modeling**: Identification and estimation of an ARMA(1,0) model for S&P 500 log-returns based on the Bayesian Information Criterion (BIC).
- **Forecasting**: Short-term forecasting (1-3 weeks) with associated prediction intervals.

### 2. Multivariate Analysis
- **Vector Autoregression (VAR)**: Estimation of a VAR(1) model to capture dynamic interdependencies.
- **Granger Causality**: Formal testing of predictive relationships, revealing the S&P 500 as a central information hub.
- **Impulse-Response Functions (IRF)**: Analysis of shock transmission using both Cholesky decomposition and Local Projections.
- **Cointegration (Johansen Test)**: Identification of a stable long-run relationship between indices and yields.
- **Vector Error Correction Model (VECM)**: Estimation of a VECM to account for both short-run dynamics and long-run equilibrium adjustment.

## Key Findings

- **Information Hierarchy**: Equity markets (S&P 500) act as the primary driver of information flow, Granger-causing both volatility (VIX) and interest rate (US10Y) movements.
- **Volatility Dynamics**: The VIX behaves as a reactive "fear gauge," responding strongly and asymmetrically to equity declines but showing limited predictive power for future returns.
- **Long-Run Equilibrium**: A significant cointegrating relationship exists, confirming that equity values, risk expectations, and the cost of capital are fundamentally bound together over long horizons.

## Project Structure

- `market_dynamics_analysis.Rmd`: The primary R Markdown file containing the full econometric pipeline, code, and interpretations.
- `data/`: Directory intended for housing the raw and processed datasets (weekly time series).

## Requirements

The analysis is performed in R. To replicate the results, the following packages are required:

```r
install.packages(c("tidyquant", "dplyr", "knitr", "kableExtra", "purrr", 
                   "ggplot2", "scales", "urca", "forecast", "vars", 
                   "tidyr", "lpirfs"))
```

