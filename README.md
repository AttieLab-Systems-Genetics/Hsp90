# Hsp90 GTT Analysis

This repository contains prompts and code to generate plots from the Hsp90 GTT analysis.
The prompts are key--they were used to generate the code, figures and powerpoint.
Data and results (qmd and pptx) are not stored in GitHub.

- [Prompts to Create PowerPoint](prompt.md)
- [R script to Create Plots and PowerPoint](Hsp90_GTT.R)
- [Prompts to Update Data](update_prompts.md)
- [R script to Update Data](create_master.R)

The [prompt.md](prompt.md) file has the history of its construction,
starting with a set of prompts developed by Alan Attie and Diana Esparza on
a Monday, which were updated on that Wednesday by Brian Yandell and Diana Esparza. You can look at the `blame` or `history` of that document to learn more.

The data were updated in their source files, which means the `master` file
would need to be updated.
This is a tedious and error-prone process.
To address this, the
[update_data.md](update_data.md) prompt was used to create
[create_master.R](create_master.R) and the updated "master" file.
