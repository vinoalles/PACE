# Declare variables used in dplyr pipelines (silences CRAN notes)
utils::globalVariables(c(
  "Time", "Value", "year", "quart", "Ysum", "Qsum",
  "Yearyoy", "QoQyoy", "PQoQ"
))

#' PACE Forecasting Algorithm
#'
#' @description
#' PACE (Predictive Adjusted Capped Estimator) is a robust hybrid forecasting method
#' that blends Year-over-Year (YoY), Quarter-over-Quarter (QoQ), and Prior-Quarter
#' growth rates. It applies volatility caps (-25% to +50%) and dynamically updates
#' historical data with forecasts for stable, interpretable business forecasts.
#'
#' @param df A data frame with columns:
#'   - `Time`: Date (will be coerced to Date)
#'   - `Value`: Numeric values to forecast
#' @param periods Number of future quarters to forecast (default: 12)
#'
#' @return A data frame with columns `Time` (Date) and `Forecast` (numeric)
#'
#' @export
#'
#' @importFrom dplyr %>% arrange group_by summarise mutate lag
#' @importFrom lubridate year quarter
#' @importFrom utils tail
#'
#' @examples
#' df <- data.frame(
#'   Time = seq(as.Date("2020-01-01"), by = "quarter", length.out = 12),
#'   Value = c(80, 95, 100, 92, 105, 110, 90, 78, 70, 85, 98, 110)
#' )
#' pace_forecast(df, periods = 4)
#'
pace_forecast <- function(df, periods = 12) {

  # Input validation
  if (!all(c("Time", "Value") %in% names(df))) {
    stop("df must contain columns 'Time' and 'Value'")
  }

  df$Time <- as.Date(df$Time)
  df <- df %>% arrange(Time)
  df$year <- year(df$Time)
  df$quart <- quarter(df$Time)

  # Annual YoY growth
  ydf <- df %>%
    group_by(year) %>%
    summarise(Ysum = sum(Value), .groups = "drop") %>%
    mutate(Yearyoy = (Ysum / lag(Ysum, 1)) - 1)

  # Quarterly metrics
  qdf <- df %>%
    group_by(year, quart) %>%
    summarise(Qsum = sum(Value), .groups = "drop") %>%
    mutate(
      QoQyoy = (Qsum / lag(Qsum, 4)) - 1,
      PQoQ   = (Qsum / lag(Qsum, 1)) - 1
    )

  forecasts <- data.frame()
  last_date <- max(df$Time)

  # Helper: add quarters
  add_q <- function(start, n) {
    seq.Date(start, by = "quarter", length.out = n + 1)[n + 1]
  }

  # Cap extreme growth
  cap <- function(x) pmin(pmax(x, -0.25), 0.50)

  for (i in seq_len(periods)) {
    future_date <- add_q(last_date, i)

    yoy  <- cap(tail(ydf$Yearyoy, 1))
    qyoy <- cap(mean(tail(qdf$QoQyoy, 4), na.rm = TRUE))
    pq   <- cap(tail(qdf$PQoQ, 1))
    last_val <- tail(df$Value, 1)

    growth <- mean(c(yoy, qyoy, pq), na.rm = TRUE)
    forecast_val <- last_val * (1 + growth)

    forecasts <- rbind(forecasts, data.frame(
      Time = future_date,
      Forecast = forecast_val
    ))

    # Append forecast to history for next iteration
    df <- rbind(df, data.frame(
      Time = future_date,
      Value = forecast_val,
      year = year(future_date),
      quart = quarter(future_date)
    ))
  }

  return(forecasts)
}
