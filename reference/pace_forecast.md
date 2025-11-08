# PACE Forecasting Algorithm

PACE (Predictive Adjusted Capped Estimator) is a time-series forecasting
method that blends Year-over-Year, Quarter-over-Quarter, and
Prior-Quarter growth rates, applies volatility capping, and generates
forward projections suitable for business, economic, and operational
forecasting.

## Usage

``` r
pace_forecast(df, periods = 12)
```

## Arguments

- df:

  A data frame with two columns: Time (Date) and Value (numeric).

- periods:

  Number of future periods to forecast (default = 12).

## Value

A data frame with forecasted values.

## Examples

``` r
df <- data.frame(Time = seq(as.Date("2020-01-01"), by="quarter", length.out=12),
                 Value = rnorm(12, 100, 10))
pace_forecast(df, periods = 4)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
#> 
#> Attaching package: ‘lubridate’
#> The following objects are masked from ‘package:base’:
#> 
#>     date, intersect, setdiff, union
#>         Time Forecast
#> 1 2023-01-01 81.42319
#> 2 2023-04-01 79.21768
#> 3 2023-07-01 77.07190
#> 4 2023-10-01 74.98425
```
