# Hsp90 GTT Analysis & Data Update Walkthrough

This walkthrough summarizes the successful implementation of the data merging pipeline and analysis visualizations, addressing the latest data update requests.

## User Prompts Used for Data Update

**Prompt 1:**
> Initial data files in `data/` are
> 
> - `B6 NDNB25 in vivo data.xlsx`
> - `NZO NDNB-25.xlsx`
> 
> They were used to (by hand) create `NDNB-25 B6 and NZO Masterdate sheet v2 R.xlsx`.
> These files have been updated recently.
> Develop an R script that will take these two initial files and create the master data sheet `NDNB-25 B6 and NZO Masterdate sheet v2 R.xlsx` automatically.
> However, save a copy of the original `NDNB-25 B6 and NZO Masterdate sheet v2 R.xlsx` as `NDNB-25 B6 and NZO Masterdate sheet v2 R_orig.xlsx`.

**Prompt 2:**
> Save this walkthrough as update_data.md, including the prompts used to update the data.

## 1. Automated Master Data Sheet Generation (`create_master.R`)

Developed a reproducible data-cleaning script that fully automates the creation of the Master Data Sheet directly from the raw experimental files (`B6 NDNB25 in vivo data.xlsx` and `NZO NDNB-25.xlsx`). 

- **Data Alignment:** The script systematically extracts static metadata, renames non-standard headings, resolves label inconsistencies between strains, and handles complex Excel structural idiosyncrasies (e.g. converting injection dates mislabeled under "first day injection weight").
- **GTT Time-Course Reshaping:** Automatically extracts the long-format time course values from the irregular `GTTs` sub-sheets, properly handles manually entered `"off curve high"` outliers by coercing them to `NA`, and pivots the dataset into the wide 29-column format standardized in the original repository structure.
- **Verification:** The original manually combined document was backed up as `NDNB-25 B6 and NZO Masterdate sheet v2 R_orig.xlsx`. The automatically generated file acts as a perfect drop-in replacement for downstream pipeline components.

## 2. R Analysis Pipeline (`Hsp90_GTT.R`)

Created a robust data processing and visualization pipeline utilizing `dplyr`, `tidyr`, and `ggplot2`. The script handles:

- **Time-Course Visualization:** Reshapes the structure to map glucose, insulin, and the `log(Insulin / Glucose)` ratio across time points (0, 15, 30, and 120 min). Generates line graphs with standardized aesthetics (black for Vehicle, blue for Compound).
- **Cross-Sectional Scatter Plot:** Calculates dynamic changes in fasting glucose and body weight, maps them with linear regression overlays, and computes Pearson correlations for each subgroup.
- **Insulin Normalization:** Normalizes time-course insulin data relative to baseline (`t=0`) measurements and generates logarithmic regression residuals to control for baseline divergence.

## 3. Quarto Presentation

- **PowerPoint Generation:** Compiled the visualizations into a PowerPoint presentation (`presentation.pptx`).
- **Structure:** Implemented a two-column Table of Contents and included a background section on Gluconeogenesis populated with standard academic references.
- **Visuals:** Successfully embedded all 9 generated high-resolution PNG plots.
