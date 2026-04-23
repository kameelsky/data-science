library(rsm)
library(ggplot2)
library(metR)
library(plotly)
library(dplyr)

# Design --------------------------------------------------------------------------------------


design <- ccd(
  ~ x1 + x2,
  n0 = c(3, 0),
  alpha = "face",
  coding = list(
    x1 ~ (Cond - 10) / 5,
    x2 ~ (pH - 6) / 1
  ),
  randomize = FALSE
)

data <- design |>
  decode.data() |>
  as.data.frame()

# Experiment ----------------------------------------------------------------------------------


data$Capacity <- c(96, 102, 137, 4, 121, 137, 127, 139, 54, 119, 84)

data |>
  mutate(
    Cond = as.factor(Cond),
    pH   = as.factor(pH)
  ) |>
  ggplot(aes(x = Cond, y = Capacity, color = pH, group = pH)) +
  geom_point(size = 2) +
  stat_summary(fun = mean, geom = "crossbar", linewidth = 0.4, width = 0.1) +
  stat_summary(fun = mean, geom = "line") +
  stat_summary(fun.data = \(x) mean_sdl(x, mult = 1), geom = "errorbar", width = 0.1) +
  scale_y_continuous(breaks = seq(0, max(data$Capacity) + 20, by = 20)) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.ticks.x = element_blank()
  )

# Model ---------------------------------------------------------------------------------------

rsm_model <- rsm(Capacity ~ SO(Cond, pH), data = data)
summary(rsm_model)

# Extract metrics
adj_r2 <- summary(rsm_model)$adj.r.squared
rmse <- summary(rsm_model)$sigma


# Plot 2D -------------------------------------------------------------------------------------


# Generate data
cond_seq <- seq(5, 15, length.out = 100)
ph_seq <- seq(5, 7, length.out = 100)
grid <- expand.grid(Cond = cond_seq, pH = ph_seq)
grid$Capacity <- predict(rsm_model, newdata = grid)

grid |>
  ggplot(aes(x = Cond, y = pH, z = Capacity)) +
  metR::geom_contour_fill(
    breaks = scales::pretty_breaks(15)(grid$Capacity)
  ) +
  metR::geom_contour2(
    breaks = scales::pretty_breaks(15)(grid$Capacity),
    color = "black",
    linewidth = 0.4
  ) +
  metR::geom_text_contour(
    breaks = scales::pretty_breaks(30)(grid$Capacity),
    stroke = 0.3,
    size = 3,
    color = "black",
    label.placer = label_placer_fraction(frac = 0.4)
  ) +
  scale_fill_gradientn(
    colours = c("#e63946", "#f1faee", "#a8dadc", "#457b9d", "#1d3557")
  ) +
  scale_x_continuous(
    breaks = seq(5, 15, 1),
    expand = c(0, 0)
  ) +
  scale_y_continuous(
    breaks = seq(5, 7, 0.25),
    expand = c(0, 0)
  ) +
  labs(
    title = "Response surface model",
    subtitle = latex2exp::TeX("$Capacity \\sim Cond \\cdot pH + Cond^{2} + pH^{2}$"),
    caption = latex2exp::TeX(sprintf("Adjusted $R^{2}$ = %.3f, RMSE = %.3f", adj_r2, rmse)),
    x = "Capacity [mS/cm]",
    y = "pH",
    fill = "Capacity"
  ) +
  theme(
    panel.border = element_rect(color = "black", linewidth = 1.5),
    axis.title.x = element_text(face = "bold"),
    axis.title.y = element_text(face = "bold")
  )

# Plot 3D -------------------------------------------------------------------------------------


grid_3d <- matrix(
  grid$Capacity,
  nrow = length(ph_seq),
  ncol = length(cond_seq),
  byrow = TRUE
)

plot_ly() |>
  add_surface(
    x = cond_seq,
    y = ph_seq,
    z = grid_3d,
    colorscale = list(
      c(0, "#e63946"),
      c(0.25, "#f1faee"),
      c(0.5, "#a8dadc"),
      c(0.75, "#457b9d"),
      c(1, "#1d3557")
    ),
    opacity = 0.85,
    contours = list(
      z = list(
        show = TRUE, usecolormap = TRUE, highlightcolor = "#fff",
        project = list(z = TRUE, usecolormap = TRUE)
      )
    ),
    colorbar = list(title = list(text = "Capacity")),
    hovertemplate =
      "Cond: %{x}<br>pH: %{y}<br>Capacity: %{z}<extra>RSM</extra>"
  ) |>
  add_markers(
    x = data$Cond,
    y = data$pH,
    z = data$Capacity,
    marker = list(
      size = 5,
      color = "#ff6b35",
      line = list(color = "white", width = 1)
    ),
    name = "Observed",
    hovertemplate =
      "Cond: %{x}<br>pH: %{y}<br>Capacity: %{z}<extra>Observed</extra>"
  ) |>
  layout(
    scene = list(
      xaxis = list(title = "Cond", range = c(5, 15)),
      yaxis = list(title = "pH", range = c(5, 7)),
      zaxis = list(title = "Capacity"),
      camera = list(eye = list(x = 1.6, y = -1.6, z = 1.0))
    )
  )


# Calculations --------------------------------------------------------------------------------

message("Optimum")
print(summary(rsm_model)$canonical$xs)
message("Coefficient matrix eigenvalues")
cat(summary(rsm_model)$canonical$eigen$values)

# Function
function_x <- function(x) {
  predict(rsm_model, newdata = data.frame(Cond = 5, pH = x))
}

# Optimization
opt <- optimize(
  function_x,
  interval = c(5, 7),
  maximum = TRUE
)
opt_df <- data.frame(
  pH = opt$maximum,
  Capacity = opt$objective
)
opt_df

# Plot
x_domain <- seq(5, 7, length.out = 100)
data.frame(
  pH = x_domain,
  Capacity = function_x(x_domain)
) |>
  ggplot(aes(x = pH, y = Capacity)) +
  geom_line(aes(color = "Model"), linewidth = 0.8) +
  geom_point(
    data = data[data$Cond == 5, ],
    aes(x = pH, y = Capacity, color = "Observed"),
    size = 3
  ) +
  geom_point(
    data = opt_df,
    aes(x = pH, y = Capacity, color = "Optimum"),
    size = 4,
    shape = 4,
    stroke = 1.2
  ) +
  ggrepel::geom_text_repel(
    data = opt_df,
    aes(
      x = pH, y = Capacity,
      label = paste0(
        "pH = ", round(pH, 2),
        "\nCapacity = ", round(Capacity, 1)
      )
    ),
    size = 3.5,
    color = "#2a9d8f",
    box.padding = 0.4,
    point.padding = 0.3,
    segment.color = "grey50",
    show.legend = FALSE
  ) +
  scale_color_manual(
    name = "Legend",
    values = c(
      "Model" = "#457b9d",
      "Observed" = "#e63946",
      "Optimum" = "#2a9d8f"
    )
  ) +
  labs(
    title = expression("Capacity(pH, Cond = 5)"),
    x = "pH",
    y = "Capacity"
  ) +
  scale_x_continuous(
    breaks = seq(5, 7, 0.25),
    minor_breaks = seq(5, 7, 0.125)
  )
