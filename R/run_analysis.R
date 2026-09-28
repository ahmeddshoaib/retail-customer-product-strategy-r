suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(scales)
  library(tidyr)
})

dir.create("outputs", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

transactions <- read_csv("data/demo/transactions.csv", show_col_types = FALSE) %>%
  mutate(TransactionDate = as.Date(TransactionDate))
conjoint <- read_csv("data/demo/conjoint_responses.csv", show_col_types = FALSE)
products <- read_csv("data/demo/product_profiles.csv", show_col_types = FALSE)

analysis_date <- max(transactions$TransactionDate) + 1
rfm <- transactions %>%
  group_by(CustomerID) %>%
  summarise(
    Recency = as.integer(analysis_date - max(TransactionDate)),
    Frequency = n(),
    Monetary = sum(Revenue),
    CoffeeRevenue = sum(Revenue[Category == "Coffee"]),
    CoffeeShare = CoffeeRevenue / Monetary,
    .groups = "drop"
  )

cluster_input <- rfm %>%
  transmute(
    Recency = scale(log1p(Recency))[, 1],
    Frequency = scale(log1p(Frequency))[, 1],
    Monetary = scale(log1p(Monetary))[, 1],
    CoffeeShare = scale(CoffeeShare)[, 1]
  )
set.seed(42)
cluster <- kmeans(cluster_input, centers = 4, nstart = 50)
rfm$Segment <- paste("Segment", cluster$cluster)

segment_summary <- rfm %>%
  group_by(Segment) %>%
  summarise(
    Customers = n(),
    MedianRecency = median(Recency),
    MeanFrequency = mean(Frequency),
    MeanRevenue = mean(Monetary),
    MeanCoffeeShare = mean(CoffeeShare),
    .groups = "drop"
  ) %>%
  arrange(desc(MeanRevenue))

conjoint_model <- lm(
  Rating ~ factor(Format) + Price + factor(Origin) + factor(Strength) + factor(Sustainability),
  data = conjoint
)
coefficients <- tibble(
  term = names(coef(conjoint_model)),
  estimate = unname(coef(conjoint_model))
)

attribute_ranges <- tibble(
  Attribute = c("Format", "Price", "Origin", "Strength", "Sustainability"),
  UtilityRange = c(
    diff(range(c(0, coefficients$estimate[grepl("Format", coefficients$term)]))),
    abs(coef(conjoint_model)["Price"]) * diff(range(conjoint$Price)),
    diff(range(c(0, coefficients$estimate[grepl("Origin", coefficients$term)]))),
    diff(range(c(0, coefficients$estimate[grepl("Strength", coefficients$term)]))),
    diff(range(c(0, coefficients$estimate[grepl("Sustainability", coefficients$term)])))
  )
) %>%
  mutate(Importance = UtilityRange / sum(UtilityRange))

product_model <- prcomp(products %>% select(Convenience, Premium, SustainabilityScore), scale. = TRUE)
product_scores <- bind_cols(
  products %>% select(Product, Format, Price, Sustainability),
  as_tibble(product_model$x[, 1:2])
)

write_csv(rfm %>% mutate(data_label = "synthetic_demo", .before = 1), "outputs/customer_rfm_segments.csv")
write_csv(segment_summary %>% mutate(data_label = "synthetic_demo", .before = 1), "outputs/segment_summary.csv")
write_csv(coefficients %>% mutate(data_label = "synthetic_demo", .before = 1), "outputs/conjoint_coefficients.csv")
write_csv(attribute_ranges %>% mutate(data_label = "synthetic_demo", .before = 1), "outputs/conjoint_importance.csv")
write_csv(product_scores %>% mutate(data_label = "synthetic_demo", .before = 1), "outputs/product_positioning.csv")

segment_plot <- ggplot(segment_summary, aes(reorder(Segment, MeanRevenue), MeanRevenue, fill = MeanCoffeeShare)) +
  geom_col() +
  coord_flip() +
  scale_fill_viridis_c(labels = percent_format(accuracy = 1)) +
  labs(title = "Synthetic validation only: segment value profile", x = NULL, y = "Mean customer revenue", fill = "Coffee share") +
  theme_minimal(base_size = 12)
ggsave("figures/rfm_segment_profile.png", segment_plot, width = 9, height = 5.2, dpi = 180)

importance_plot <- ggplot(attribute_ranges, aes(reorder(Attribute, Importance), Importance)) +
  geom_col(fill = "#7c3aed") +
  coord_flip() +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Synthetic validation only: conjoint attribute importance", x = NULL, y = "Relative importance") +
  theme_minimal(base_size = 12)
ggsave("figures/conjoint_importance.png", importance_plot, width = 9, height = 5.2, dpi = 180)

pca_plot <- ggplot(product_scores, aes(PC1, PC2, label = Product, colour = Format)) +
  geom_point(size = 3) +
  geom_text(nudge_y = 0.12, size = 3.5) +
  labs(title = "Synthetic validation only: product positioning", x = "Principal component 1", y = "Principal component 2", colour = NULL) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")
ggsave("figures/product_positioning.png", pca_plot, width = 9, height = 5.2, dpi = 180)

message("RETAIL CUSTOMER AND PRODUCT ANALYSIS COMPLETED")

