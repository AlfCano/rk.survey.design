## Golden Rules (Definitive Instructions for `rkwarddev` v0.10-3)

### 1. The R Script is the Single Source of Truth
(Unchanged) Your sole output will be a single R script that defines all plugin components as R objects and uses `rk.plugin.skeleton()` to write the final files. This script **must** be wrapped in `local({})` to avoid polluting the user's global environment when sourced.

### 2. The Sacred Structure of the Help File (`.rkh`)
(Unchanged) This is a critical and error-prone section.

*   The user will provide help text in a simple R list. Your script **must** translate this into `rkwarddev` objects.
*   **The Translation Pattern is Fixed:** `plugin_help$summary` becomes `rk.rkh.summary()`, `plugin_help$usage` becomes `rk.rkh.usage()`, etc.
*   **CRITICAL:** The help document's main title **must** be created with `rk.rkh.title()`. A plain string will cause an error.
*   This final `rk.rkh.doc` object **must** be passed to `rk.plugin.skeleton` inside a named list: `rkh = list(help = ...)`.

### 3. The Inflexible One-`varselector`-to-Many-`varslot`s UI Pattern
(Unchanged) This pattern is mandatory for selecting an object and then selecting items *from* that object.

*   **Step 1: The Shared Source (`rk.XML.varselector`):** Create **one** `rk.XML.varselector` object with a hard-coded `id.name`.
*   **Step 2: The Destination Boxes (`rk.XML.varslot`):** Create all `varslot`s that depend on this selection.
*   **Step 3: The Link:** The `source` argument of **every single one** of these `varslot`s **must** be the same `id.name` from the `varselector`.
*   **Step 4: Filtering:** Apply class filters to the **`varslot`** using `attr(my_varslot, "classes") <- "my_class"`.
*   **Step 5: Nested Data (`source_property`):** To select variables from a data frame *inside* another object, you **must** use `attr(my_column_varslot, "source_property") <- "name_of_the_dataframe_inside"`.

### 4. The `calculate`/`printout` Content Pattern (Revised and Extended)
This pattern dictates the precise responsibilities of the JavaScript blocks.

*   **The `calculate` Block:**
    *   This block generates the R code for the **entire computation sequence**.
    *   It **must** assign the final result to a hard-coded object name (e.g., `svyby_result <- ...`), which should match the `initial` argument of its `rk.XML.saveobj`.
    *   **Intermediate Objects:** For multi-step calculations (like subsetting then analyzing), you **must** create intermediate R objects (e.g., `svy_subset <- subset(...)`).
    *   **State Tracking:** You **must** use a JavaScript variable to track which R object should be used in the next step of the calculation (e.g., `var final_svy_obj = svy_obj; if(use_subset) { final_svy_obj = "svy_subset"; }`).
*   **The `printout` Block (Revised):**
    *   This block's only purpose is to display the final result object. It must be minimalist and should **not** contain conditional `if` logic.
    *   The **best practice** is to pipe all final transformations and the print command together: `echo("svyby_result |> as.data.frame() |> rk.results(print.rownames=FALSE)\\n");`. This keeps the saved object clean while formatting the output perfectly.
    *   This block should **not** contain `rk.header()` calls. Set `results.header` in the `rk.plugin.component` or `rk.plugin.skeleton` `js` argument list instead.

### 5. Strict Adherence to Legacy `rkwarddev` Syntax
(Unchanged) The target version `0.10-3` has specific function signatures that must be followed.

*   **`rk.XML.cbox` vs. `rk.XML.checkbox`:** You **must** use `rk.XML.cbox(..., value="1")`.
*   **`rk.plugin.skeleton` Arguments:** A proven, working set of arguments is: `about`, `path`, `xml`, `js`, `rkh`, `pluginmap`, `components`, `create`, `load`, `overwrite`, and `show = FALSE`.

### 6. The Immutable Raw JavaScript String Paradigm (Extended)
You **must avoid programmatic JavaScript generation** (`rk.paste.JS`, `rk.JS.vars`). You will write a self-contained, multi-line R character string for the `calculate` logic.

*   **Master `getValue()`:** Begin the script by declaring a JavaScript variable for every UI component.
*   **The `getColumnName` Helper is Mandatory:** For any UI that selects variables from an object, you **must** include the following robust helper function inside your JavaScript string:
    ```javascript
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
    ```
*   **Handle Multi-Step Logic:** Use JavaScript `if` statements and variables to conditionally generate intermediate R commands (like `subset`) and to determine which R object to use as input for subsequent commands.
*   **`echo()` is Mandatory:** All R code to be executed **must** be wrapped in `echo()`.

### 7. Correct Component Architecture for Multi-Plugin Packages
(Unchanged) To create a single R package that contains multiple plugins, you **must** use the following syntax.

*   **The "Main" Component:** Its full definition is passed directly to `rk.plugin.skeleton()`. Its menu location is defined in the `pluginmap` argument of this main call.
*   **"Additional" Components:** Every other plugin **must** be defined using `rk.plugin.component("Plugin Name", xml=..., js=..., hierarchy=list("Top Menu", "Plugin Label"))`. These component objects are then passed as a `list` to the `components` argument of the main `rk.plugin.skeleton()` call.

### 8. (Unchanged) Avoid `<logic>` Sections for Maximum Compatibility
The `<logic>` section and `rk.XML.connect()` are fragile and must not be used. All conditional behavior **must** be handled inside the `calculate` JavaScript string.

### 9. (Unchanged) Separation of Concerns
The generated `make_plugin.R` script **only generates files**. It **must not** contain calls to `rk.updatePluginMessages` or `devtools::install()`. It will, however, print a final message instructing the user to perform these steps.
