# rk.survey.design: Survey Analysis Tools for RKWard

![Version](https://img.shields.io/badge/Version-0.7.0-blue.svg)
![License](https://img.shields.io/badge/License-GPL--3-green.svg)
![R Version](https://img.shields.io/badge/R-%3E%3D%203.0.0-lightgrey.svg)

This package provides a suite of RKWard plugins that create a graphical user interface for the powerful `survey` R package. It is designed to simplify the workflow for complex survey analysis by providing dialogs for creating survey design objects and performing a wide range of common statistical analyses.

## Features / Included Plugins

This package installs a new top-level menu in RKWard: **Survey**, which contains the following nine plugins:

*   **Create Survey Design:**
    *   The cornerstone of the package. This plugin uses `survey::svydesign()` to create a `svydesign` object.
    *   Allows specification of weights, strata, cluster IDs (PSUs), and Finite Population Correction (FPC).
    *   Includes an option for nested designs.

*   **Survey Mean or Total:**
    *   Calculates the survey-weighted mean (`svymean`) or total (`svytotal`) for one or more variables.
    *   Includes options to subset the design and adjust for lonely PSUs.

*   **Grouped Survey Analysis (by):**
    *   Performs grouped analysis using `survey::svyby()`.
    *   Calculates means or totals of analysis variables for each subgroup defined by grouping variables.
    *   Includes options to subset the design and adjust for lonely PSUs.

*   **Survey Quantiles:**
    *   Calculates survey-weighted quantiles (e.g., quartiles, deciles) for a variable using `survey::svyquantile()`.
    *   Includes options to subset the design and adjust for lonely PSUs.

*   **Survey Ratio:**
    *   Calculates the ratio of two survey-weighted totals using `survey::svyratio()`.
    *   Includes options to subset the design and adjust for lonely PSUs.

*   **Survey GLM:**
    *   Fits a generalized linear model to survey data using `survey::svyglm()`.
    *   Supports specifying response and predictor variables and the `quasibinomial` family.
    *   Includes options to subset the design and adjust for lonely PSUs.

*   **Survey Table:**
    *   Creates survey-weighted one-way or two-way contingency tables using `survey::svytable()`.
    *   Includes options to subset the design and adjust for lonely PSUs.

*   **Survey Chi-squared Test:**
    *   Performs a survey-weighted chi-squared test of independence for two variables using `survey::svychisq()`.
    *   Includes options to subset the design and adjust for lonely PSUs.

*   **Subset Survey Object:**
    *   Filters a design based on a logical condition to create a new, smaller `svydesign` object.

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

1.  Open RKWard.
2.  Run the following commands in the R console:

```R
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

3.  Restart RKWard to ensure the new menu items appear correctly.

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
4.  The "Analysis variables" and "Grouping variables (by)" slots will now be populated with the columns from inside the survey object.
5.  For **"Analysis variables"**, select `api00` and `api99`.
6.  For **"Grouping variables (by)"**, select `stype`.
7.  Ensure the **"Function (FUN)"** dropdown is set to "Mean".
8.  Click **Submit**.

The RKWard output window will display a formatted table showing the mean `api00` and `api99` scores for each school type (`E`, `H`, `M`), correctly weighted according to the survey design.

## Author

Alfonso Cano (alfonso.cano@correo.buap.mx)
Assisted by Gemini, a large language model from Google.
