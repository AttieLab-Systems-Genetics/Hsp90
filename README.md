# Hsp90 GTT Analysis

This repository contains prompts and code to generate plots from the Hsp90 GTT analysis.
The prompts are key--they were used to generate the code, figures and powerpoint.
Data and results (qmd and pptx) are not stored in GitHub.

- [power_point.md](power_point.md): Prompts for PowerPoint
  - [R/Hsp90_GTT.R](R/Hsp90_GTT.R): R script to Create Plots and PowerPoint
- [update_data.md](update_data.md): Prompts to Update Data
  - [R/create_master.R](R/create_master.R): R script to Update Data

## Power Point

The `power_point.md` file has the history of its construction,
starting with a set of prompts developed
by Alan Attie and Diana Esparza on a Monday,
which were updated on that Wednesday
by Brian Yandell and Diana Esparza.
Later, Brian updated this file.
You can look at the `blame` or `history` of that document to learn more.

## Data Update

The data were updated in their source files, which means the `master` file
would need to be updated.
This is a tedious and error-prone process.
To address this, the
`update_data.md` prompt was used to create
`create_master.R` and the updated "master" file.

## This Repo

This repo was created to track the development of the
`power_point.md` and `update_data.md` files.
It started as a simple folder with
`power_point.md` (originally `prompt.md`)
and `the`data/` folder
and has grown since.

Folder organization (local copies not stored in GitHub):

- `data/` - Input data (local copy)
  - `B6 NDNB25 in vivo data.xlsx`
  - `NZO NDNB-25.xlsx`
  - `NDNB-25 B6 and NZO Masterdate sheet v2 R.xlsx` (and backups)
- `R/` - R scripts
  - `Hsp90_GTT.R`
  - `create_master.R`
- `previous/` - Previous plots, `.qmd` and `.pptx` files (saved before updates)
- `plots/` - Generated plots (local copy)
- `presentation.qmd` and `.pptx` files (local copies)
- `README.md` (this file)

Some other files are present but are not used in the pipeline.

The public part of this folder was saved to GitHub as
<https://github.com/AttieLab-Systems-Genetics/Hsp90>
using help from
[Documentation/github.md](https://github.com/byandell/Documentation/blob/main/github.md),
in particular
[Get started with GitHub (Happy Git with R)](https://happygitwithr.com/usage-intro).
