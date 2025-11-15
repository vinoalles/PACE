
# PACE

> **P**redictive **A**djusted **C**apped **E**stimator:  
> A transparent forecasting method combining growth signals with
> volatility controls.

The **PACE** R package provides a simple, deterministic forecasting
approach that blends year-over-year, quarter-over-quarter, and
prior-quarter growth indicators while applying fixed caps to prevent
unstable jumps. The method is fully transparent and requires no model
fitting.

PACE is designed for users who need fast, explainable, and stable
short-term forecasts across many domains, including economics, finance,
operations, and general time-series analysis.

------------------------------------------------------------------------

## ✨ Features

| Capability                       | Description |
|----------------------------------|-------------|
| Quarterly forecasting            | ✔️          |
| Growth-rate blending             | ✔️          |
| Volatility/outlier caps          | ✔️          |
| Optional seasonal scaling        | ✔️          |
| Plot helper                      | ✔️          |
| Deterministic (no model fitting) | ✔️          |

------------------------------------------------------------------------

## 📦 Installation

\`\`\`r \# Development version
devtools::install_github(“vinoalles/PACE”)
