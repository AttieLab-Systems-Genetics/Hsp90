library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(openxlsx)

# Load raw files
b6_file <- "data/B6 NDNB25 in vivo data.xlsx"
nzo_file <- "data/NZO NDNB-25.xlsx"
out_file <- "data/NDNB-25 B6 and NZO Masterdate sheet v2 R.xlsx"

cat("Reading raw files...\n")

# Process NZO Data ---
nzo_raw <- read_excel(nzo_file, sheet = "Sheet1")
nzo_gtt <- read_excel(nzo_file, sheet = "GTTs")

# Rename columns to standardized names
nzo_processed <- nzo_raw %>%
  mutate(
    Strain_ID = str_replace(`mouse #`, "-", "_"),
    Birth_date = as.numeric(as.Date(birthdate)),
    sex = sex,
    diet = diet,
    age_wk_start_on_diet = NA_real_,
    Date_on_diet = as.numeric(as.Date(`date on diet`)),
    age_wk_Today = age,
    `6_7wk_weight` = as.numeric(`6-7 wk weight`),
    `6_7wk_glucose` = as.numeric(`6-7 wk glucose`),
    `6_7wk_insulin` = as.numeric(`6-7 wk insulin`),
    treatment_injetion = treatment,
    date_of_treatment = as.numeric(as.Date(`date of first injection`)),
    weight_g_pretreatment = `weight...12`,
    glucose_pretreatment = glucose,
    age_wk_GTT_posttreatment = NA_real_,
    GTT_date = as.numeric(as.Date(`GTT date`)),
    weight_g_posttreatment = `weight...15`
  ) %>%
  # Fill age_wk_start_on_diet if Date_on_diet and Birth_date are present
  mutate(
    age_wk_start_on_diet = if_else(!is.na(Date_on_diet) & !is.na(Birth_date), (Date_on_diet - Birth_date) / 7, NA_real_),
    age_wk_GTT_posttreatment = if_else(!is.na(GTT_date) & !is.na(Birth_date), (GTT_date - Birth_date) / 7, NA_real_)
  ) %>%
  select(
    Strain_ID, Birth_date, sex, diet, age_wk_start_on_diet, Date_on_diet,
    age_wk_Today, `6_7wk_weight`, `6_7wk_glucose`, `6_7wk_insulin`,
    treatment_injetion, date_of_treatment, weight_g_pretreatment,
    glucose_pretreatment, age_wk_GTT_posttreatment, GTT_date,
    weight_g_posttreatment
  )

# Process NZO GTT data
nzo_gtt_clean <- nzo_gtt %>%
  rename(
    mouse = `...1`,
    time = `...2`,
    glucose = `...3`,
    insulin = `...4`,
    c_pep = `...5`
  ) %>%
  select(mouse, time, glucose, insulin, c_pep) %>%
  # Fill down the mouse ID since it spans 4 rows
  fill(mouse, .direction = "down") %>%
  # Remove rows where time is NA or mouse is NA
  filter(!is.na(mouse) & !is.na(time)) %>%
  # Convert "off curve high" to NA in insulin
  mutate(
    insulin = if_else(insulin == "off curve high", NA_character_, as.character(insulin)),
    insulin = as.numeric(insulin),
    glucose = as.numeric(glucose),
    c_pep = as.numeric(c_pep),
    Strain_ID = str_replace(mouse, "-", "_")
  )

# Pivot NZO GTT to wide
nzo_gtt_wide <- nzo_gtt_clean %>%
  select(-mouse) %>%
  pivot_wider(
    names_from = time,
    values_from = c(glucose, insulin, c_pep),
    names_glue = "{.value}_{time}"
  ) %>%
  rename(
    Glucose_0_GTT_posttreatment = glucose_0,
    Glucose_15_GTT_posttreatment = glucose_15,
    Glucose_30_GTT_posttreatment = glucose_30,
    Glucose_120_GTT_posttreatment = glucose_120,
    Insulin_0_GTT_posttreatment = insulin_0,
    Insulin_15_GTT_postinjection = insulin_15,
    Insulin_30_GTT_postinjection = insulin_30,
    Insulin_120_GTT_postinjection = insulin_120,
    C_peptide_0_GTT_postinjection = c_pep_0,
    C_peptide_15_GTT_postinjection = c_pep_15,
    C_peptide_30_GTT_postinjection = c_pep_30,
    C_peptide_120_GTT_postinjection = c_pep_120
  )

# Join NZO Data
nzo_final <- nzo_processed %>% left_join(nzo_gtt_wide, by = "Strain_ID")


# --- Process B6 Data ---
b6_raw <- read_excel(b6_file, sheet = "NDNB-25 ")
b6_gtt <- read_excel(b6_file, sheet = "NDNB-25 GTT")

b6_processed <- b6_raw %>%
  mutate(
    Strain_ID = str_replace(`mouse #`, "-", "_"),
    Birth_date = as.numeric(as.Date(birthdate)),
    sex = NA_character_, # Not provided for B6
    diet = NA_character_,
    age_wk_start_on_diet = NA_real_,
    Date_on_diet = NA_real_,
    age_wk_Today = NA_real_,
    `6_7wk_weight` = NA_real_,
    `6_7wk_glucose` = NA_real_,
    `6_7wk_insulin` = NA_real_,
    treatment_injetion = if_else(`control/compound` == "control", "vehicle", "compound"),
    date_of_treatment = as.numeric(as.Date(`first day injection weight`)),
    weight_g_pretreatment = weight,
    glucose_pretreatment = NA_real_,
    age_wk_GTT_posttreatment = `age at GTT`,
    GTT_date = NA_real_,
    weight_g_posttreatment = `GTT weight`
  ) %>%
  select(
    Strain_ID, Birth_date, sex, diet, age_wk_start_on_diet, Date_on_diet,
    age_wk_Today, `6_7wk_weight`, `6_7wk_glucose`, `6_7wk_insulin`,
    treatment_injetion, date_of_treatment, weight_g_pretreatment,
    glucose_pretreatment, age_wk_GTT_posttreatment, GTT_date,
    weight_g_posttreatment
  ) %>%
  filter(!is.na(Strain_ID))

# Process B6 GTT data
b6_gtt_clean <- b6_gtt %>%
  rename(
    mouse = `...1`,
    time = `...2`,
    glucose = glucose,
    insulin = insulin,
    c_pep = `c pep`
  ) %>%
  select(mouse, time, glucose, insulin, c_pep) %>%
  fill(mouse, .direction = "down") %>%
  filter(!is.na(mouse) & !is.na(time)) %>%
  mutate(
    insulin = as.numeric(insulin),
    glucose = as.numeric(glucose),
    c_pep = as.numeric(c_pep),
    Strain_ID = str_replace(mouse, "-", "_")
  )

b6_gtt_wide <- b6_gtt_clean %>%
  select(-mouse) %>%
  pivot_wider(
    names_from = time,
    values_from = c(glucose, insulin, c_pep),
    names_glue = "{.value}_{time}"
  ) %>%
  rename(
    Glucose_0_GTT_posttreatment = glucose_0,
    Glucose_15_GTT_posttreatment = glucose_15,
    Glucose_30_GTT_posttreatment = glucose_30,
    Glucose_120_GTT_posttreatment = glucose_120,
    Insulin_0_GTT_posttreatment = insulin_0,
    Insulin_15_GTT_postinjection = insulin_15,
    Insulin_30_GTT_postinjection = insulin_30,
    Insulin_120_GTT_postinjection = insulin_120,
    C_peptide_0_GTT_postinjection = c_pep_0,
    C_peptide_15_GTT_postinjection = c_pep_15,
    C_peptide_30_GTT_postinjection = c_pep_30,
    C_peptide_120_GTT_postinjection = c_pep_120
  )

# Join B6 Data
b6_final <- b6_processed %>% left_join(b6_gtt_wide, by = "Strain_ID")


# --- Merge and Output ---
master_combined <- bind_rows(nzo_final, b6_final)

# Ensure correct column order explicitly as per the original file
master_cols <- c(
  "Strain_ID", "Birth_date", "sex", "diet", "age_wk_start_on_diet", "Date_on_diet",
  "age_wk_Today", "6_7wk_weight", "6_7wk_glucose", "6_7wk_insulin", "treatment_injetion",
  "date_of_treatment", "weight_g_pretreatment", "glucose_pretreatment", "age_wk_GTT_posttreatment",
  "GTT_date", "weight_g_posttreatment", "Glucose_0_GTT_posttreatment", "Glucose_15_GTT_posttreatment",
  "Glucose_30_GTT_posttreatment", "Glucose_120_GTT_posttreatment", "Insulin_0_GTT_posttreatment",
  "Insulin_15_GTT_postinjection", "Insulin_30_GTT_postinjection", "Insulin_120_GTT_postinjection",
  "C_peptide_0_GTT_postinjection", "C_peptide_15_GTT_postinjection", "C_peptide_30_GTT_postinjection",
  "C_peptide_120_GTT_postinjection"
)

master_combined <- master_combined %>% select(all_of(master_cols))

cat("Writing combined Master Sheet to:", out_file, "\n")
write.xlsx(master_combined, out_file, asTable = FALSE)
cat("Done.\n")
