# R/plot_pace.r
utils::globalVariables(c("Type", "Value", "Time"))

#' Plot PACE Forecast vs Actuals
#' @param forecast_df Data frame from pace_forecast()
#' @param actual_df Original historical data (optional)
#' @return ggplot object
#' @export
#' @importFrom ggplot2 ggplot aes geom_line geom_point scale_color_manual theme_minimal theme labs element_text element_blank
#' @importFrom dplyr bind_rows mutate select
#' @examples
#' df <- data.frame(Time = seq(as.Date("2020-01-01"), by="quarter", length.out=12),
#'                  Value = c(80,95,100,92,105,110,90,78,70,85,98,110))
#' fc <- pace_forecast(df, 4)
#' plot_pace(fc, df)
plot_pace <- function(forecast_df, actual_df = NULL) {
  if (!all(c("Time", "Forecast") %in% names(forecast_df))) {
    stop("forecast_df must contain 'Time' and 'Forecast'")
  }

  plot_data <- forecast_df %>%
    mutate(Value = Forecast, Type = "Forecast") %>%
    select(Time, Value, Type)

  if (!is.null(actual_df)) {
    if (!all(c("Time", "Value") %in% names(actual_df))) {
      stop("actual_df must contain 'Time' and 'Value'")
    }
    actual_data <- actual_df %>%
      mutate(Type = "Actual") %>%
      select(Time, Value, Type)
    plot_data <- bind_rows(actual_data, plot_data)
  }

  plot_data <- plot_data %>%
    mutate(Type = factor(Type, levels = c("Actual", "Forecast")))

  ggplot(plot_data, aes(x = Time, y = Value, color = Type)) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 2.5) +
    scale_color_manual(values = c("Actual" = "#2c7bb6", "Forecast" = "#d7191c")) +
    theme_minimal(base_size = 12) +
    theme(
      legend.position = "bottom",
      legend.title = element_blank(),
      plot.title = element_text(hjust = 0.5, face = "bold"),
      axis.title = element_text(face = "bold")
    ) +
    labs(
      title = "PACE Forecast",
      subtitle = if (!is.null(actual_df)) "Actual vs Forecast" else "Forecast",
      x = "Date",
      y = "Value"  # ← THIS QUOTE WAS MISSING!
    )
}
