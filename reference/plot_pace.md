# Plot PACE Forecast

Visualizes PACE forecasts against actual historical data. Displays
Actual values (blue) vs Forecast values (red).

## Usage

``` r
plot_pace(forecast_df, actual_df = NULL)
```

## Arguments

- forecast_df:

  A data frame returned by pace_forecast or pace_forecast_seasonal
  containing columns Time and Forecast.

- actual_df:

  (optional) A data frame with historical Time and Value columns.

## Value

A ggplot object

## Examples

``` r
df <- data.frame(Time = seq(as.Date("2020-01-01"), by="quarter", length.out=12),
                 Value = rnorm(12, 100, 10))
result <- pace_forecast(df, periods = 4)
plot_pace(result, df)

```
