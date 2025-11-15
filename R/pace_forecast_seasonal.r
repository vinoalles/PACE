# R/pace_forecast_seasonal.r
utils::globalVariables(c("season_mean", "season_factor", "Time", "Value", "year", "quart", "Ysum", "Qsum", "Yearyoy", "QoQyoy", "PQoQ"))

#' PACE Forecast with Seasonal Adjustment
#'
#' @description Extends PACE with quarterly seasonal normalization.
#' @inheritParams pace_forecast
#' @return Data frame with Time and Forecast
#' @export
#' @importFrom dplyr %>% arrange group_by summarise mutate lag
#' @importFrom lubridate year quarter
#' @importFrom utils tail
#' @examples
#' df <- data.frame(Time = seq(as.Date("2020-01-01"), by = "quarter", length.out = 16),
#'                  Value = c(80,95,110,90, 85,100,115,95, 82,97,112,92, 87,102,118,96))
#' pace_forecast_seasonal(df, 4)
pace_forecast_seasonal <- function(df, periods = 12) {
  if (!all(c("Time", "Value") %in% names(df))) stop("df must have Time and Value")

  df$Time <- as.Date(df$Time)
  df <- df %>% arrange(Time)
  df$year <- year(df$Time)
  df$quart <- quarter(df$Time)

  ydf <- df %>% group_by(year) %>% summarise(Ysum = sum(Value), .groups = "drop") %>%
    mutate(Yearyoy = (Ysum / lag(Ysum, 1)) - 1)

  qdf <- df %>% group_by(year, quart) %>% summarise(Qsum = sum(Value), .groups = "drop") %>%
    mutate(QoQyoy = (Qsum / lag(Qsum, 4)) - 1, PQoQ = (Qsum / lag(Qsum, 1)) - 1)

  season_idx <- df %>% group_by(quart) %>%
    summarise(season_mean = mean(Value), .groups = "drop") %>%
    mutate(season_factor = season_mean / mean(season_mean))

  forecasts <- data.frame()
  last_date <- max(df$Time)
  add_q <- function(start, n) seq.Date(start, by = "quarter", length.out = n + 1)[n + 1]
  cap <- function(x) pmin(pmax(x, -0.25), 0.50)

  for (i in seq_len(periods)) {
    future_date <- add_q(last_date, i)
    yoy <- cap(tail(ydf$Yearyoy, 1))
    qyoy <- cap(mean(tail(qdf$QoQyoy, 4), na.rm = TRUE))
    pq <- cap(tail(qdf$PQoQ, 1))
    last_val <- tail(df$Value, 1)
    growth <- mean(c(yoy, qyoy, pq), na.rm = TRUE)
    base_val <- last_val * (1 + growth)
    q <- quarter(future_date)
    season_adj <- season_idx$season_factor[season_idx$quart == q]
    forecast_val <- base_val * season_adj

    forecasts <- rbind(forecasts, data.frame(Time = future_date, Forecast = forecast_val))

    df <- rbind(df, data.frame(Time = future_date, Value = forecast_val,
                               year = year(future_date), quart = quarter(future_date)))
  }
  forecasts
}
