# PACE Forecast with Seasonality

PACE (Predictive Adjusted Capped Estimator) with seasonal adjustment.
Combines Year-over-Year, Quarter-over-Quarter, and Prior-Quarter growth
rates, applies volatility caps, and multiplies by quarterly seasonality
factors normalized to mean = 1.

## Usage

``` r
pace_forecast_seasonal(df, periods = 12)
```

## Arguments

- df:

  A data frame with two columns: Time (Date) and Value (numeric).

- periods:

  Number of future periods to forecast (default = 12).

## Value

A data frame containing future Time and Forecast values.

## Examples

``` r
df <- data.frame(Time = seq(as.Date("2020-01-01"), by = "quarter", length.out = 12),
                 Value = rnorm(12, 100, 10))
pace_forecast_seasonal(df, periods = 4)
#>         Time  Forecast
#> 1 2023-01-01  87.72517
#> 2 2023-04-01  96.66592
#> 3 2023-07-01 101.09158
#> 4 2023-10-01  99.03541
```
