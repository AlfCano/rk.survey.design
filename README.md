# rk.survey.design: Survey Analysis Tools for RKWard

![Version](https://img.shields.io/badge/Version-0.5.2-blue.svg)
![License](https://img.shields.io/badge/License-GPL--3-green.svg)
![R Version](https://img.shields.io/badge/R-%3E%3D%203.0.0-lightgrey.svg)

This package provides a suite of RKWard plugins that create a graphical user interface for the powerful `survey` R package. It is designed to simplify the workflow for complex survey analysis by providing dialogs for creating survey design objects and performing basic statistical analyses like calculating means, totals, and grouped statistics.

## Features / Included Plugins

This package installs a new top-level menu in RKWard: **Survey**, which contains the following three plugins:

*   **Create Survey Design:**
    *   The cornerstone of the package. This plugin uses `survey::svydesign()` to create a `svydesign` object from a standard data frame.
    *   Allows specification of weights, strata, and cluster IDs (PSUs).
    *   Includes an option for nested designs.

*   **Survey Mean or Total:**
    *   Takes a `svydesign` object as input.
    *   Calculates the survey-weighted mean (`svymean`) or total (`svytotal`) for one or more variables.
    *   Includes an option to adjust for strata with single clusters ("lonely PSUs").

*   **Grouped Survey Analysis (by):**
    *   Takes a `svydesign` object as input.
    *   Performs grouped analysis using `survey::svyby()`.
    *   Calculates survey-weighted means or totals of analysis variables for each subgroup defined by one or more grouping variables.
    *   Includes an option to adjust for lonely PSUs.

## Requirements

1.  A working installation of **RKWard**.
2.  The R package **`survey`**. If you do not have it, install it from the R console:
    ```R
    install.packages("survey")
    ```
3.  The R package **`devtools`** is required for installation from the source code.
    ```R
    install.packages("devtools")
    ```

## Installation

To install the `rk.survey.design` plugin package, you need the source code (e.g., by downloading it from GitHub).

1.  Open R in RKWard.
2.  Set your R working directory to the folder that *contains* the `rk.survey.design` plugin directory. For example, if your code is in `/home/user/R/rk.survey.design`, set your working directory to `/home/user/R`.
3.  Run the following commands in the R console:

```
local({
## Preparar
require(devtools)
## Computar
  install_github(
    repo="AlfCano/rk.survey.design"
  )
## Imprimir el resultado
rk.header ("Resultados de Instalar desde git")
})

```

4.  Restart RKWard to ensure the new menu items appear correctly.

## Usage Workflow Example

The intended workflow is to first create a design object and then use that object for analysis.

### Step 1: Create the Survey Design Object

1.  Load a sample dataset from the `survey` package into your R workspace:
    ```R
    library(survey)
    data(api)
    ```
2.  Navigate to **Survey > Create Survey Design**.
3.  In the RKWard dialog, drag the `apiclus1` data frame from the workspace browser into the "Survey data (data.frame)" slot.
4.  The other slots will now be populated with the columns from `apiclus1`.
    *   Select `pw` for the "Weight variable".
    *   Select `stype` for the "Strata variable".
    *   Select `dnum` for the "ID/Cluster variable".
5.  In the "Save survey design object as" field, keep the default name `survey.design`.
6.  Click **Submit**.

A new object named `survey.design` of class `svydesign` will be created in your workspace.

### Step 2: Perform a Grouped Analysis

1.  Navigate to **Survey > Grouped Survey Analysis (by)**.
2.  In the RKWard dialog, the object browser on the left will now show the `survey.design` object.
3.  Drag `survey.design` into the "Survey design object" slot.
4.  The "Analysis variables" and "Grouping variables (by)" slots will now be populated with the columns from *inside* the survey object (e.g., `api00`, `stype`, etc.).
5.  For **"Analysis variables"**, select `api00` and `api99`.
6.  For **"Grouping variables (by)"**, select `stype`.
7.  Ensure the **"Function (FUN)"** dropdown is set to "Mean".
8.  In the "Save result as" field, keep the default name `svyby_result`.
9.  Click **Submit**.

The RKWard output window will display a formatted table showing the mean `api00` and `api99` scores for each school type (`E`, `H`, `M`), correctly weighted according to the survey design. A new data frame `svyby_result` will also be available in your workspace.

## Author

Alfonso Cano Robles (alfonso.cano@correo.buap.mx)

Assisted by Gemini, a large language model from Google.
