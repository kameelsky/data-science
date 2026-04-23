library(FrF2)
library(unrepx)
library(car)
library(dplyr)
library(stringr)
library(ggplot2)
library(ggrepel)
library(DT)


# Design --------------------------------------------------------------------------------------


design <- FrF2(
  nfactors = 6,
  nruns = 2^(6 - 1),
  factor.names = list(
    Temperature = c(20, 30),
    Time = c("30 min", "6 hours"),
    Concentration = c(5, 20),
    Ratio = c("1:1", "1:5"),
    NaCl = c(50, 500),
    pH = c(6, 8)
  ),
  randomize = FALSE
)

# Factors
factors <- colnames(design)

# Standard order for Yates analysis
design$std.order <- seq_len(nrow(design))

# Aliases
aliasprint(design)


# Response ------------------------------------------------------------------------------------


Decrease <- c(
  9.5563, 23.7753, 28.1728, 40.9096, 22.3398, 7.0571, 12.0645, 42.5196,
  12.9399, 11.4177, 37.9469, 42.7592, 20.9732, 17.2356, 9.6189, 38.8151,
  4.6307, 2.3525, 26.6300, 40.6680, 43.5146, -0.9522, 11.1147, 24.7521,
  5.1247, 4.0604, 31.0278, 35.0870, 23.0103, 16.1543, 6.7222, 36.1924
)
design <- add.response(design, response = Decrease)
design



# Analysis ------------------------------------------------------------------------------------

# Data frame of effects
effects_alpha <- 0.05
method <- "Lenth"
pdf(file = NULL)

# Sort by std.order for yates analysis
design <- design[order(design$std.order), ]
df1 <- DanielPlot(design)
invisible(dev.off())
df1 <- df1[order(abs(df1$x), decreasing = TRUE), ]
df2 <- eff.test(yates(design$Decrease), method = method)
if (all.equal(df1$x, df2$effect)) {
  message("Yates effects are equal in data frames.")
} else {
  stop("Yates effects are not equal")
}
effects <- cbind(df1, df2)
effects <- effects[, c(1, 2, 8, 9, 10)]

effects_me <- ME(effects$x, method = method, alpha = effects_alpha)
effects <- effects |>
  as_tibble(rownames = NA) |>
  tibble::rownames_to_column(var = "factor") |>
  mutate(
    significance = case_when(
      simult.pval <= effects_alpha ~ "SME",
      p.value <= effects_alpha ~ "ME",
      .default = "ns"
    )
  ) |>
  rename(effect = x, normal_score = y, t_score = t.ratio, p_value = p.value, adj_p_value = simult.pval)

# Datatable -----------------------------------------------------------------------------------

datatable(
  effects,
  rownames = FALSE,
  options = list(
    buttons = c("copy", "csv")
  )
) |>
  formatRound(
    columns = c(
      "effect",
      "normal_score",
      "t_score",
      "p_value",
      "adj_p_value"
    ),
    digits = 4
  ) |>
  formatStyle(
    "significance",
    target = "row",
    backgroundColor = styleEqual(
      c("SME", "ME", "ns"),
      c("#90a955", "#ecf39e", "#f5f5f5")
    ),
    fontWeight = styleEqual(
      c("SME", "ME", "ns"),
      c("bold", "bold", "normal")
    )
  )


# Plots ---------------------------------------------------------------------------------------


main_effects <- MEPlot(design)
interactions <- IAPlot(design)
effects |>
  mutate(
    label = ifelse(significance != "ns", factor, NA),
  ) |>
  ggplot(aes(x = effect, y = normal_score, color = significance, size = significance)) +
  geom_point() +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_label_repel(
    data = ~ filter(.x, effect >= 0),
    aes(label = label),
    na.rm = TRUE,
    arrow = arrow(length = unit(0.02, "npc"), type = "open", ends = "first"),
    show.legend = FALSE,
    xlim = c(NA, 0),
    direction = "both",
    force_pull = 0,
    size = 3.5,
  ) +
  geom_label_repel(
    data = ~ filter(.x, effect < 0),
    aes(label = label),
    na.rm = TRUE,
    arrow = arrow(length = unit(0.02, "npc"), type = "open", ends = "first"),
    show.legend = FALSE,
    xlim = c(0, NA),
    direction = "both",
    force_pull = 0,
    size = 3.5,
  ) +
  coord_cartesian(clip = "off") +
  scale_color_manual(
    name = "Significance",
    values = c("SME" = "#c1121f", "ME" = "#003049", "ns" = "#8b8c89"),
    breaks = c("SME", "ME", "ns")
  ) +
  scale_size_manual(
    name = "Significance",
    values = c("SME" = 3.5, "ME" = 3.5, "ns" = 1),
    breaks = c("SME", "ME", "ns")
  ) +
  scale_x_continuous(
    breaks = scales::pretty_breaks(n = 10), minor_breaks = NULL
  ) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10), minor_breaks = NULL) +
  labs(
    title = "Effects plot",
    subtitle = paste0(
      "Lenth's pseudo-standard error method for unreplicated factorial designs ",
      sprintf("(\u03B1 = %.2f). ", effects_alpha),
      "\nLabeled effects exceed the SME or ME threshold; ",
      "unlabeled effects (gray) are consistent with noise."
    ), x = "Yates effect",
    y = "Normal score",
    color = "Significance",
    caption = paste0("\nLenth, R.V. (1989) Quick and easy analysis of unreplicated factorials. Technometrics 31, 469–473.")
  )


# Model ---------------------------------------------------------------------------------------


df <- as_tibble(design)

# Full
full_model <- lm(Decrease ~ (Temperature + Time + Concentration + Ratio + NaCl + pH)^3, data = df)
message("Aliases")
aliases(full_model)

# 1
model1 <- lm(Decrease ~ Time + Temperature:Time + Time:Concentration, data = df)
summary(model1)
anova(model1)

# 2
model2 <- lm(Decrease ~ Time + Temperature:Time + Time:Concentration + Temperature:Time:Concentration, data = df)
summary(model2)
anova(model2)

anova(model1, model2)

# 3
model3 <- lm(Decrease ~ Time + Temperature:Time + Time:Concentration + Temperature:Time:Concentration + Temperature:Ratio:Concentration, data = df)
summary(model3)
anova(model3)

anova(model2, model3)

# Final
final_model <- lm(Decrease ~ Time + Temperature:Time + Time:Concentration + Temperature:Time:Concentration, data = df)
summary(final_model)
anova(final_model)


# Diagnostics ---------------------------------------------------------------------------------


# Residuals
df <- df |>
  mutate(
    Fitted = fitted(final_model),
    Residuals = residuals(final_model),
    ResidualAbs = abs(Residuals)
  )
df

# Normality
qqPlot(final_model, main = "Q-Q Plot")
shapiro.test(residuals(final_model))

# Homoscedasticity
ncvTest(final_model)

plot(
  fitted(final_model), residuals(final_model),
  main = "Residual vs. Fitted value",
  xlab = "Fitted values",
  ylab = "Residuals"
)
abline(h = 0, lty = 2)

# Independence
durbinWatsonTest(final_model)

# Residual influence
influencePlot(final_model)


# WLS -----------------------------------------------------------------------------------------

# # Plots
# par(mfrow = c(2, 2))
# plot(df$Fitted, df$Residuals, xlab = "Fitted")
# plot(df$Time, df$Residuals, xlab = "Time")
# plot(df$Temperature, df$Residuals, xlab = "Temperature")
# plot(df$Concentration, df$Residuals, xlab = "Concentration")
#
# # Model variance in respect to the variable for which is is decreasing, e.g.: Fitted
# varianceModel <- lm(ResidualAbs ~ Fitted, data = df)
# summary(varianceModel)
# weights <- 1 / fitted(varianceModel)^2
# weights
#
# # Modeling
# final_model_wls <- lm(Decrease ~ Time + Temperature:Time + Time:Concentration + Temperature:Time:Concentration, data = df, weights = weights)
# summary(final_model_wls)
# anova(final_model_wls)
#
#
# df <- df |>
#   mutate(
#     Fitted_WLS = fitted(final_model_wls),
#     Residuals_WLS = residuals(final_model_wls),
#     ResidualAbs_WLS = abs(Residuals_WLS)
#   )
# df
#
# ggplot(df, aes(x = Fitted, y = Residuals)) +
#   geom_point(size = 3, stroke = 1, fill = NA, color = "red", shape = 21) +
#   geom_smooth(se = TRUE) +
#   labs(
#     title = "Residual vs. Fitted value",
#     x = "Fitted values",
#     y = "Residuals"
#   )


# Predictions ---------------------------------------------------------------------------------


new_data <- expand.grid(
  Time          = levels(df$Time),
  Temperature   = levels(df$Temperature),
  Concentration = levels(df$Concentration)
)

predictions <- predict(final_model, newdata = new_data, interval = "confidence")
result <- cbind(new_data, as.data.frame(predictions)) %>%
  as_tibble() %>%
  arrange(desc(fit))
result





find_aliases <- function(model, term) {
  als <- aliases(model)$aliases
  # Znajdź grupy gdzie term występuje
  matches <- Filter(function(x) any(str_detect(x, fixed(term))), als)
  # Pokaż tylko grupy z więcej niż 1 elementem (prawdziwe aliasy)
  aliased <- Filter(function(x) length(x) > 1, matches)
  if (length(aliased) == 0) {
    message(term, " nie ma aliasów (efekt czysty)")
  } else {
    aliased
  }
}
