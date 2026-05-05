library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)

# 1. Data Initialization
dir.create("plots", showWarnings = FALSE)

data_file <- "data/NDNB-25 B6 and NZO Masterdate sheet v2 R.xlsx"
df <- read_excel(data_file)

# Extract strain and standardize treatment
df <- df %>%
  mutate(
    Strain = if_else(str_detect(Strain_ID, "NZO"), "NZO", "B6"),
    Treatment = str_to_title(treatment_injetion) # Compound, Vehicle
  ) %>%
  filter(!is.na(Treatment))

# 2. Time-Course Line Graphs (Glucose, Insulin, & Log Ratio)

# Pivot glucose data
glucose_long <- df %>%
  select(Strain_ID, Strain, Treatment, 
         `0` = Glucose_0_GTT_posttreatment,
         `15` = Glucose_15_GTT_posttreatment,
         `30` = Glucose_30_GTT_posttreatment,
         `120` = Glucose_120_GTT_posttreatment) %>%
  mutate(across(c(`0`, `15`, `30`, `120`), as.numeric)) %>%
  pivot_longer(cols = c(`0`, `15`, `30`, `120`), names_to = "Time", values_to = "Glucose") %>%
  mutate(Time = as.numeric(Time))

# Pivot insulin data
insulin_long <- df %>%
  select(Strain_ID, Strain, Treatment, 
         `0` = Insulin_0_GTT_posttreatment,
         `15` = Insulin_15_GTT_postinjection,
         `30` = Insulin_30_GTT_postinjection,
         `120` = Insulin_120_GTT_postinjection) %>%
  mutate(across(c(`0`, `15`, `30`, `120`), as.numeric)) %>%
  pivot_longer(cols = c(`0`, `15`, `30`, `120`), names_to = "Time", values_to = "Insulin") %>%
  mutate(Time = as.numeric(Time))

# Combine and calculate log ratio
tc_data <- glucose_long %>%
  left_join(insulin_long, by = c("Strain_ID", "Strain", "Treatment", "Time")) %>%
  mutate(Log_Ratio = log(Insulin / Glucose))

# Summary statistics for plotting
tc_summary <- tc_data %>%
  pivot_longer(cols = c(Glucose, Insulin, Log_Ratio), names_to = "Metric", values_to = "Value") %>%
  group_by(Strain, Treatment, Metric, Time) %>%
  summarize(
    Mean = mean(Value, na.rm = TRUE),
    SE = sd(Value, na.rm = TRUE) / sqrt(sum(!is.na(Value))),
    .groups = "drop"
  )

# Function to generate time course plots
plot_time_course <- function(data, strain, metric, ylab) {
  p <- data %>%
    filter(Strain == strain, Metric == metric) %>%
    ggplot(aes(x = Time, y = Mean, color = Treatment, group = Treatment)) +
    geom_line(linewidth = 1) +
    geom_point(size = 3) +
    geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE), width = 5, linewidth = 0.8) +
    scale_color_manual(values = c("Vehicle" = "black", "Compound" = "blue")) +
    theme_classic() +
    labs(
      title = paste(strain, "-", metric, "Time Course"),
      x = "Time (minutes)",
      y = ylab
    ) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      legend.title = element_blank()
    )
  
  ggsave(paste0("plots/TC_", strain, "_", metric, ".png"), plot = p, width = 6, height = 4)
  return(p)
}

# Generate 6 plots
for (strain in c("B6", "NZO")) {
  plot_time_course(tc_summary, strain, "Glucose", "Glucose levels")
  plot_time_course(tc_summary, strain, "Insulin", "Insulin levels")
  plot_time_course(tc_summary, strain, "Log_Ratio", "log(Insulin / Glucose)")
}

# 3. Cross-Sectional Scatter Plot
cs_data <- df %>%
  mutate(
    Glucose_0 = as.numeric(Glucose_0_GTT_posttreatment),
    Glucose_pre = as.numeric(glucose_pretreatment),
    Weight_post = as.numeric(weight_g_posttreatment),
    Weight_pre = as.numeric(weight_g_pretreatment)
  ) %>%
  mutate(
    dGlucose = Glucose_0 - Glucose_pre,
    dWeight = Weight_post - Weight_pre
  ) %>%
  filter(!is.na(dGlucose) & !is.na(dWeight))

# Calculate correlations
cor_data <- cs_data %>%
  group_by(Strain, Treatment) %>%
  summarize(
    r = cor(dWeight, dGlucose, use = "complete.obs"),
    p = cor.test(dWeight, dGlucose)$p.value,
    .groups = "drop"
  ) %>%
  mutate(
    label = sprintf("r = %.2f\np = %.3f", r, p)
  )

# Join for label positioning
cor_data <- cor_data %>%
  left_join(
    cs_data %>% group_by(Strain, Treatment) %>% 
      summarize(x = max(dWeight, na.rm=TRUE)*0.8, y = max(dGlucose, na.rm=TRUE)*0.8, .groups="drop"),
    by = c("Strain", "Treatment")
  )

p_scatter <- ggplot(cs_data, aes(x = dWeight, y = dGlucose, color = Strain, shape = Treatment)) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE, aes(linetype = Treatment)) +
  scale_color_manual(values = c("NZO" = "blue", "B6" = "black")) +
  scale_shape_manual(values = c("Compound" = 16, "Vehicle" = 15)) + # 16=circle, 15=square
  theme_classic() +
  labs(
    title = "Cross-Sectional Scatter Plot",
    x = "Change in Body Weight (g)",
    y = "Change in Fasting Glucose"
  ) +
  facet_wrap(~ Strain + Treatment, scales = "free") +
  geom_text(data = cor_data, aes(x = x, y = y, label = label), size = 3, inherit.aes = FALSE)

ggsave("plots/Scatter_dGlucose_vs_dWeight.png", plot = p_scatter, width = 8, height = 6)


# 4. Insulin Baseline Normalization
baseline_insulin <- df %>%
  select(Strain_ID, Strain, Treatment, Insulin_0 = Insulin_0_GTT_posttreatment) %>%
  mutate(Insulin_0 = as.numeric(Insulin_0))

insulin_norm <- insulin_long %>%
  filter(Time > 0) %>%
  left_join(baseline_insulin, by = c("Strain_ID", "Strain", "Treatment")) %>%
  filter(!is.na(Insulin) & !is.na(Insulin_0) & Insulin_0 > 0) %>%
  mutate(
    Insulin_Ratio = Insulin / Insulin_0,
    Log_Insulin = log(Insulin),
    Log_Insulin_0 = log(Insulin_0)
  )

# Calculate residuals for log(Insulin) ~ log(Insulin_0) for each timepoint
insulin_norm <- insulin_norm %>%
  group_by(Time) %>%
  mutate(
    Residual = if (n() > 2) residuals(lm(Log_Insulin ~ Log_Insulin_0, na.action = na.exclude)) else rep(NA_real_, n())
  ) %>%
  ungroup()

# Summarize for plotting
norm_summary <- insulin_norm %>%
  group_by(Strain, Treatment, Time) %>%
  summarize(
    Mean_Ratio = mean(Insulin_Ratio, na.rm = TRUE),
    SE_Ratio = sd(Insulin_Ratio, na.rm = TRUE) / sqrt(sum(!is.na(Insulin_Ratio))),
    Mean_Resid = mean(Residual, na.rm = TRUE),
    SE_Resid = sd(Residual, na.rm = TRUE) / sqrt(sum(!is.na(Residual))),
    .groups = "drop"
  )

p_ratio <- ggplot(norm_summary, aes(x = Time, y = Mean_Ratio, color = Treatment, group = Treatment)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = Mean_Ratio - SE_Ratio, ymax = Mean_Ratio + SE_Ratio), width = 5) +
  scale_color_manual(values = c("Vehicle" = "black", "Compound" = "blue")) +
  facet_wrap(~ Strain) +
  theme_classic() +
  labs(
    title = "Insulin Ratio (Insulin_t / Insulin_0) Over Time",
    x = "Time (minutes)",
    y = "Insulin Ratio"
  )

ggsave("plots/Insulin_Ratio.png", plot = p_ratio, width = 8, height = 4)

p_resid <- ggplot(norm_summary, aes(x = Time, y = Mean_Resid, color = Treatment, group = Treatment)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = Mean_Resid - SE_Resid, ymax = Mean_Resid + SE_Resid), width = 5) +
  scale_color_manual(values = c("Vehicle" = "black", "Compound" = "blue")) +
  facet_wrap(~ Strain) +
  theme_classic() +
  labs(
    title = "Insulin Residuals over Time",
    x = "Time (minutes)",
    y = "Residuals (log(Insulin) ~ log(Insulin_0))"
  )

ggsave("plots/Insulin_Residuals.png", plot = p_resid, width = 8, height = 4)

cat("Analysis complete. Plots saved to plots/ directory.\n")
