suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

rfm <- read_csv("outputs/customer_rfm_segments.csv", show_col_types = FALSE)
segments <- read_csv("outputs/segment_summary.csv", show_col_types = FALSE)
importance <- read_csv("outputs/conjoint_importance.csv", show_col_types = FALSE)

stopifnot(nrow(rfm) == 925)
stopifnot(n_distinct(rfm$CustomerID) == 925)
stopifnot(n_distinct(rfm$Segment) == 4)
stopifnot(sum(segments$Customers) == 925)
stopifnot(abs(sum(importance$Importance) - 1) < 1e-8)
stopifnot(all(rfm$data_label == "synthetic_demo"))
message("ALL RETAIL STRATEGY VALIDATION CHECKS PASSED")

