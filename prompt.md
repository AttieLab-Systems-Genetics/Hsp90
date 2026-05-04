# R Analysis Prompt History
*Date: 2026-03-19* (Updated: 2026-03-25)

**Execution Prompt Used:** "Run the prompt and do all the steps listed in promptsAlan.md". Make sure all software needed is installed.

Here is a consolidated record of the instructions used to build the `Hsp90_GTT.R` data analysis pipeline. They have been refined and grouped to reduce duplication while accurately capturing the complete workflow requirements.

### 1. Data Initialization
> We will be analyzing Glucose Tolerance Test (GTT) data from this master spreadsheet: `'NDNB-25 B6 and NZO Masterdate sheet v2 R.xlsx'`.

### 2. Time-Course Line Graphs (Glucose, Insulin, & Log Ratio)
> Generate time-course line graphs for the GTT data at 0, 15, 30, and 120 minutes vs. time. Create separate plots for:
> - **Glucose levels**
> - **Insulin levels**
> - **log(Insulin / Glucose) ratio**
> 
> Output individual figures for both the **NZO** strain and **B6** strain across each of the three metrics (yielding 6 plots total). Format the aesthetics such that the Vehicle treated group maps to black dots and lines, and the Compound treated group maps to blue dots and lines. Include standard error bars.

### 3. Cross-Sectional Scatter Plot 
> Create a cross-sectional scatter plot mapping the **change in fasting glucose** (Glucose at 0 GTT minus glucose preinjection) on the Y-axis against the **change in body weight** (weight postinjection minus weight preinjection) on the X-axis for all mice.
> 
> Format the scatter plot with the following aesthetics:
> - Color the NZO strain blue and the B6 strain black. 
> - The drug-treated (compound) mice should be circles and vehicle-treated mice should be squares. 
> - Add linear regression lines for each of the 4 individual subgroups.
> - Calculate and display the Pearson correlation coefficients (`r`) and associated `p-values` as explicit text directly on the graph.

### 4. File Management
> Rename the script file formatting spaces to underscores (`Hsp90_GTT`), and explicitly add the `.R` file extension to properly follow standard naming conventions.

### 5. Documentation
> Add the current date to this tracking file.

### 6. Presentation Generation
> Use Quarto to automatically generate a PowerPoint deck (`.pptx`) embedding all of the outputted PNG figures.
> Ensure the presentation includes:
> - A two-column Table of Contents slide with functional intra-document hyperlinks.
> - A background section on Gluconeogenesis, split across multiple clean slides with academic references.

### 7. Insulin Baseline Normalization
> Process the time 0 insulin baseline measurements by removing them from the time-course mapping and calculate two new subgroup metrics: the `Insulin / Insulin_0` ratio and the extracted log-regression residuals (`log(Insulin) ~ log(Insulin_0)`). Plot both the Insulin Ratio and Insulin Residuals over time, splitting the NZO and B6 strains side-by-side using `facet_wrap`. Add these newest plots to the Quarto presentation deck.
