suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})

set.seed(42)
dir.create("data/demo", recursive = TRUE, showWarnings = FALSE)

n_customers <- 925
customers <- tibble(
  CustomerID = sprintf("C%04d", 1:n_customers),
  CoffeeAffinity = rbeta(n_customers, 2.2, 4.2),
  ValueSensitivity = rbeta(n_customers, 2.5, 2.8),
  BaseSpend = rgamma(n_customers, shape = 3.2, scale = 7)
)

transactions <- lapply(seq_len(n_customers), function(index) {
  n <- max(1, rpois(1, lambda = 5 + 7 * customers$CoffeeAffinity[index]))
  coffee <- rbinom(n, 1, prob = 0.08 + 0.65 * customers$CoffeeAffinity[index])
  tibble(
    CustomerID = customers$CustomerID[index],
    TransactionDate = as.Date("2026-08-31") - sample(0:364, n, replace = TRUE),
    Category = if_else(coffee == 1, "Coffee", sample(c("Tea", "Bakery", "Snacks", "Accessories"), n, replace = TRUE)),
    Revenue = round(pmax(1.5, customers$BaseSpend[index] * runif(n, 0.35, 1.35) * if_else(coffee == 1, 0.85, 1)), 2)
  )
}) %>% bind_rows()

formats <- c("Whole bean", "Ground", "Pods")
prices <- c(6.5, 8.0, 9.5)
origins <- c("Blend", "Colombia", "Ethiopia")
strengths <- c("Medium", "Strong")
sustainability <- c("Standard", "Certified")

conjoint <- crossing(
  Respondent = 1:180,
  Task = 1:8
) %>%
  mutate(
    Format = sample(formats, n(), replace = TRUE),
    Price = sample(prices, n(), replace = TRUE),
    Origin = sample(origins, n(), replace = TRUE),
    Strength = sample(strengths, n(), replace = TRUE),
    Sustainability = sample(sustainability, n(), replace = TRUE),
    Rating = 6.2
      + if_else(Format == "Pods", 1.4, if_else(Format == "Ground", 0.7, 0))
      - 0.55 * Price
      + if_else(Sustainability == "Certified", 0.55, 0)
      + if_else(Strength == "Strong", 0.30, 0)
      + if_else(Origin == "Colombia", 0.25, if_else(Origin == "Ethiopia", 0.15, 0))
      + rnorm(n(), 0, 0.8)
  )

products <- crossing(
  Format = formats,
  Price = prices,
  Sustainability = sustainability
) %>%
  slice_sample(n = 12) %>%
  mutate(
    Product = paste("Concept", row_number()),
    Convenience = case_when(Format == "Pods" ~ 5, Format == "Ground" ~ 3.5, TRUE ~ 2.5),
    Premium = scales::rescale(Price, to = c(2, 5)),
    SustainabilityScore = if_else(Sustainability == "Certified", 5, 2.5)
  )

write_csv(transactions, "data/demo/transactions.csv")
write_csv(conjoint, "data/demo/conjoint_responses.csv")
write_csv(products, "data/demo/product_profiles.csv")
message("SYNTHETIC RETAIL DATA GENERATED")

