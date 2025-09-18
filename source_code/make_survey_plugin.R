local({
  # =========================================================================================
  # Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  package_about <- rk.XML.about(
    name = "rk.survey.design",
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "A plugin package to create and analyze complex survey designs using the 'survey' package.",
      version = "0.7.1",
      url = "https://github.com/AlfCano/rk.survey.design",
      license = "GPL (>= 3)"
    )
  )


  # =========================================================================================
  # Main Plugin: Create Survey Design
  # =========================================================================================
  help_main <- rk.rkh.doc(
    title = rk.rkh.title(text = "Create Survey Design"),
    summary = rk.rkh.summary(text = "Creates a survey design object using svydesign() from the 'survey' package."),
    usage = rk.rkh.usage(text = "Select the data.frame, specify the design variables, and assign a name for the resulting survey design object.")
  )

  js_calc_main <- "
    // Get values from UI
    var dataframe = getValue(\"dataframe_object\");
    var id_var_full = getValue(\"id_var\");
    var probs_var_full = getValue(\"probs_var\");
    var strata_var_full = getValue(\"strata_var\");
    var fpc_var_full = getValue(\"fpc_var\");
    var weight_var_full = getValue(\"weight_var\");
    var nest_option = getValue(\"nest_cbox\");
    var check_strata_option = getValue(\"check_strata_cbox\");
    var pps_option = getValue(\"pps_input\");
    var variance_option = getValue(\"variance_pps\");
    var calibrate_formula = getValue(\"calibrate_formula_input\");
    var dbtype_val = getValue(\"dbtype_input\");
    var dbname_val = getValue(\"dbname_input\");

    // Helper function to extract column name from full object path
    function getColumnName(fullName) {
        if (!fullName) return \"\";
        if (fullName.indexOf(\"[[\") > -1) { return fullName.match(/\\[\\[\\\"(.*?)\\\"\\]\\]/)[1]; }
        else if (fullName.indexOf(\"$\") > -1) { return fullName.substring(fullName.lastIndexOf(\"$\") + 1); }
        else { return fullName; }
    }

    // Clean the column names
    var id_col = getColumnName(id_var_full);
    var probs_col = getColumnName(probs_var_full);
    var strata_col = getColumnName(strata_var_full);
    var fpc_col = getColumnName(fpc_var_full);
    var weight_col = getColumnName(weight_var_full);

    // Build the options array for the svydesign call
    var options = new Array();

    if (id_col) { options.push(\"ids = ~\" + id_col); } else { options.push(\"ids = ~1\"); }
    if (probs_col) { options.push(\"probs = ~\" + probs_col); }
    if (strata_col) { options.push(\"strata = ~\" + strata_col); }
    if (fpc_col) { options.push(\"fpc = ~\" + fpc_col); }
    if (weight_col) { options.push(\"weights = ~\" + weight_col); }
    if (calibrate_formula) { options.push(\"calibrate.formula = \" + calibrate_formula); }

    options.push(\"data = \" + dataframe);

    if (nest_option == \"1\"){ options.push(\"nest=TRUE\"); }
    if (check_strata_option == \"1\"){ options.push(\"check.strata=TRUE\"); }

    if (pps_option) {
        options.push(\"pps = \" + pps_option);
    }
    if (variance_option) {
        options.push(\"variance = \\\"\" + variance_option + \"\\\"\");
    }

    if (dbtype_val) { options.push(\"dbtype = \\\"\" + dbtype_val + \"\\\"\"); }
    if (dbname_val) { options.push(\"dbname = \\\"\" + dbname_val + \"\\\"\"); }

    echo('survey.design <- svydesign(' + options.join(', ') + ')\\n');
  "

  js_print_main <- '{
        var save_name = getValue("save_survey.objectname");
        var header_cmd = "rk.header(\\"Survey design object saved as: " + save_name + "\\");\\n";
        echo(header_cmd);
    }
  '
  # UI Elements
  dataframe_selector <- rk.XML.varselector(id.name = "dataframe_selector", label="Select data object")
  dataframe_object_slot <- rk.XML.varslot(label = "Survey data (data.frame)", source = "dataframe_selector", classes = "data.frame", required = TRUE, id.name = "dataframe_object")
  id_varslot <- rk.XML.varslot(id.name = "id_var", label = "ID/Cluster variable (~1 for no cluster)", source = "dataframe_selector")
  strata_varslot <- rk.XML.varslot(id.name = "strata_var", label = "Strata variable (optional)", source = "dataframe_selector")
  weight_varslot <- rk.XML.varslot(id.name = "weight_var", label = "Weight variable (or use probs)", source = "dataframe_selector")
  probs_varslot <- rk.XML.varslot(id.name = "probs_var", label = "Sampling probabilities (optional)", source = "dataframe_selector")
  fpc_varslot <- rk.XML.varslot(id.name = "fpc_var", label = "Finite Population Correction (optional)", source = "dataframe_selector")

  # Tab 1: Basic Options
  basic_tab_content <- rk.XML.col(
    dataframe_object_slot,
    id_varslot,
    strata_varslot,
    weight_varslot,
    probs_varslot,
    fpc_varslot,
    rk.XML.cbox(label="Nest clusters within strata (nest=TRUE)", id.name="nest_cbox", value="1")
  )

  # Tab 2: Advanced Options
  advanced_tab_content <- rk.XML.col(
    rk.XML.cbox(label="Check nesting of clusters in strata (check.strata=TRUE)", id.name="check_strata_cbox", value="1"),
    rk.XML.input(label = "PPS method (e.g., 'brewer') or object", id.name = "pps_input"),
    rk.XML.dropdown(label="PPS variance estimator", options=list("Horvitz-Thompson (default)"=list(val=""), "Yates-Grundy"=list(val="YG")), id.name="variance_pps"),
    rk.XML.input(label = "Calibration formula (e.g., ~var1+var2)", id.name = "calibrate_formula_input"),
    rk.XML.frame(
      rk.XML.input(label = "Database type (e.g., 'SQLite')", id.name = "dbtype_input"),
      rk.XML.input(label = "Database name (e.g., 'survey.db')", id.name = "dbname_input"),
      label = "Database Options (optional)"
    )
  )

  # Assemble Dialog
  save_survey_object <- rk.XML.saveobj(label = "Save survey design object as", chk = TRUE, initial = "survey.design", id.name = "save_survey")
  main_dialog_content <- rk.XML.dialog(
    label = "Create Complex Survey Design",
    child = rk.XML.row(
      dataframe_selector,
      rk.XML.col(
        rk.XML.tabbook(
          tabs = list(
            "Basic Design" = basic_tab_content,
            "Advanced Options" = advanced_tab_content
          )
        ),
        save_survey_object
      )
    )
  )

  # =========================================================================================
  # Helper for all component JS blocks
  # =========================================================================================
  js_helpers <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
  '

  # =========================================================================================
  # Component 1: svymean / svytotal
  # =========================================================================================
  svydesign_selector1 <- rk.XML.varselector(label = "Workspace objects", id.name = "svydesign_selector1")
  svydesign_object_slot1 <- rk.XML.varslot(label = "Survey design object", source = "svydesign_selector1", required = TRUE, id.name = "svydesign_object1")
  attr(svydesign_object_slot1, "classes") <- "svydesign"
  analysis_vars_slot1 <- rk.XML.varslot(label = "Analysis variables", source = "svydesign_selector1", multi = TRUE, required = TRUE, id.name = "analysis_vars1")
  attr(analysis_vars_slot1, "source_property") <- "variables"
  subset_cbox1 <- rk.XML.cbox(label="Subset the survey design", value="1", id.name="subset_cbox1")
  subset_input1 <- rk.XML.input(label="Subset expression", id.name="subset_input1")
  subset_frame1 <- rk.XML.frame(subset_cbox1, subset_input1, label="Subset Option")
  mean_total_dropdown <- rk.XML.dropdown(label="Function", options=list("Mean"=list(val="svymean", chk=TRUE), "Total"=list(val="svytotal")), id.name="mean_total_func")
  lonely_psu_cbox1 <- rk.XML.cbox(label="Adjust for lonely PSUs (single-cluster strata)", value="1", id.name="lonely_psu_cbox1")
  save_mean_total <- rk.XML.saveobj(label = "Save result as", initial = "svystat_result", chk = TRUE, id.name = "save_mean_total")
  mean_total_dialog <- rk.XML.dialog(
    label = "Survey Mean or Total",
    child = rk.XML.row(
        svydesign_selector1,
        rk.XML.col(svydesign_object_slot1, analysis_vars_slot1, subset_frame1, mean_total_dropdown, lonely_psu_cbox1, save_mean_total)
    )
  )
  js_calc_mean_total <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
    var lonely_psu = getValue("lonely_psu_cbox1");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\\"adjust\\")\\n\\n");
    }
    var use_subset = getValue("subset_cbox1");
    var subset_expr = getValue("subset_input1");
    var svy_obj = getValue("svydesign_object1");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\\n");
        final_svy_obj = "svy_subset";
    }
    var analysis_vars_str = getValue("analysis_vars1");
    var func = getValue("mean_total_func");
    var vars_array = analysis_vars_str.split(/\\s+/).filter(function(n){ return n != "" });
    var clean_vars_array = vars_array.map(getColumnName);
    var formula = "~" + clean_vars_array.join(" + ");
    echo("svystat_result <- " + func + "(" + formula + ", " + final_svy_obj + ")\\n");
  '
  js_print_mean_total <- '{
        var save_name = getValue("save_mean_total.objectname");
        var header_cmd = "rk.header(\\"Survey Stat saved as: " + save_name + "\\",level=3);\\n";
        echo(header_cmd);
      echo("svystat_result |> as.data.frame() |> rk.results()\\n");
    }
  '
  mean_total_component <- rk.plugin.component(
    "Survey Mean or Total",
    xml = list(dialog = mean_total_dialog),
    js = list(require = "survey",calculate = js_calc_mean_total, printout = js_print_mean_total, results.header="Survey svystat results"),
    hierarchy = list("Survey", "Survey Mean or Total")
  )

  # =========================================================================================
  # Component 2: svyby
  # =========================================================================================
  svydesign_selector2 <- rk.XML.varselector(label = "Workspace objects", id.name = "svydesign_selector2")
  svydesign_object_slot2 <- rk.XML.varslot(label = "Survey design object", source = "svydesign_selector2", required = TRUE, id.name = "svydesign_object2")
  attr(svydesign_object_slot2, "classes") <- "svydesign"
  analysis_vars_slot2 <- rk.XML.varslot(label = "Analysis variables", source = "svydesign_selector2", multi = TRUE, required = TRUE, id.name = "analysis_vars2")
  attr(analysis_vars_slot2, "source_property") <- "variables"
  by_vars_slot <- rk.XML.varslot(label = "Grouping variables (by)", source = "svydesign_selector2", multi = TRUE, required = TRUE, id.name = "by_vars")
  attr(by_vars_slot, "source_property") <- "variables"
  subset_cbox2 <- rk.XML.cbox(label="Subset the survey design", value="1", id.name="subset_cbox2")
  subset_input2 <- rk.XML.input(label="Subset expression", id.name="subset_input2")
  subset_frame2 <- rk.XML.frame(subset_cbox2, subset_input2, label="Subset Option")
  by_func_dropdown <- rk.XML.dropdown(label="Function (FUN)", options=list("Mean"=list(val="svymean", chk=TRUE), "Total"=list(val="svytotal")), id.name="by_func")
  lonely_psu_cbox2 <- rk.XML.cbox(label="Adjust for lonely PSUs (single-cluster strata)", value="1", id.name="lonely_psu_cbox2")
  save_by <- rk.XML.saveobj(label = "Save result as", initial = "svyby_result", chk = TRUE, id.name = "save_by")
  by_dialog <- rk.XML.dialog(
      label = "Grouped Survey Analysis (by)",
      child = rk.XML.row(
          svydesign_selector2,
          rk.XML.col(svydesign_object_slot2, analysis_vars_slot2, by_vars_slot, subset_frame2, by_func_dropdown, lonely_psu_cbox2, save_by)
      )
  )
  js_calc_by <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
    var lonely_psu = getValue("lonely_psu_cbox2");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\\"adjust\\")\\n\\n");
    }
    var use_subset = getValue("subset_cbox2");
    var subset_expr = getValue("subset_input2");
    var svy_obj = getValue("svydesign_object2");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\\n");
        final_svy_obj = "svy_subset";
    }
    var analysis_vars_str = getValue("analysis_vars2");
    var by_vars_str = getValue("by_vars");
    var func = getValue("by_func");
    var analysis_vars_array = analysis_vars_str.split(/\\s+/).filter(function(n){ return n != "" });
    var clean_analysis_vars = analysis_vars_array.map(getColumnName);
    var formula = "~" + clean_analysis_vars.join(" + ");
    var by_vars_array = by_vars_str.split(/\\s+/).filter(function(n){ return n != "" });
    var clean_by_vars = by_vars_array.map(getColumnName);
    var by_formula = "~" + clean_by_vars.join(" + ");
    echo("svyby_result <- svyby(" + formula + ", " + by_formula + ", " + final_svy_obj + ", " + func + ")\\n");
  '
  js_print_by <- '{
        var save_name = getValue("save_by.objectname");
        var header_cmd = "rk.header(\\"Survey by saved as: " + save_name + "\\",level=3);\\n";
        echo(header_cmd);
        echo("svyby_result |> as.data.frame() |> rk.results(print.rownames=FALSE)\\n");
    }
  '
  by_component <- rk.plugin.component(
      "Grouped Survey Analysis",
      xml = list(dialog = by_dialog),
      js = list(require = "survey",calculate = js_calc_by, printout = js_print_by, results.header="Survey by results"),
      hierarchy = list("Survey", "Grouped Survey Analysis (by)")
  )

  # =========================================================================================
  # Component 3: svyquantile
  # =========================================================================================
  svydesign_selector3 <- rk.XML.varselector(label = "Workspace objects", id.name = "svydesign_selector3")
  svydesign_object_slot3 <- rk.XML.varslot(label = "Survey design object", source = "svydesign_selector3", required = TRUE, id.name = "svydesign_object3")
  attr(svydesign_object_slot3, "classes") <- "svydesign"
  analysis_var_slot3 <- rk.XML.varslot(label = "Analysis variable", source = "svydesign_selector3", required = TRUE, id.name = "analysis_var3")
  attr(analysis_var_slot3, "source_property") <- "variables"
  quantiles_input <- rk.XML.input(label = "Quantiles (comma-separated)", initial = "0.25, 0.5, 0.75", id.name = "quantiles_input")
  subset_cbox3 <- rk.XML.cbox(label="Subset the survey design", value="1", id.name="subset_cbox3")
  subset_input3 <- rk.XML.input(label="Subset expression", id.name="subset_input3")
  subset_frame3 <- rk.XML.frame(subset_cbox3, subset_input3, label="Subset Option")
  lonely_psu_cbox3 <- rk.XML.cbox(label="Adjust for lonely PSUs (single-cluster strata)", value="1", id.name="lonely_psu_cbox3")
  save_quantile <- rk.XML.saveobj(label = "Save result as", initial = "svyquantile_result", chk = TRUE, id.name = "save_quantile")
  quantile_dialog <- rk.XML.dialog(
    label = "Survey Quantiles",
    child = rk.XML.row(
        svydesign_selector3,
        rk.XML.col(svydesign_object_slot3, analysis_var_slot3, quantiles_input, subset_frame3, lonely_psu_cbox3, save_quantile)
    )
  )
  js_calc_quantile <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
    var lonely_psu = getValue("lonely_psu_cbox3");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\\"adjust\\")\\n\\n");
    }
    var use_subset = getValue("subset_cbox3");
    var subset_expr = getValue("subset_input3");
    var svy_obj = getValue("svydesign_object3");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\\n");
        final_svy_obj = "svy_subset";
    }
    var analysis_var_str = getValue("analysis_var3");
    var quantiles_str = getValue("quantiles_input");
    var save_name = getValue("save_quantile.objectname");
    var clean_var = getColumnName(analysis_var_str);
    var formula = "~" + clean_var;
    echo("svyquantile_result <- svyquantile(" + formula + ", " + final_svy_obj + ", quantiles=c(" + quantiles_str + "))\\n");
  '
  js_print_quantile <- '{
      echo("result_name <- names(svyquantile_result)\\n");
      echo("for(e in result_name){\\n");
      echo("rk.header(paste0(\\"Quantiles for variable: \\", e), level=3)\\n");
      echo("svyquantile_result[[e]] |> as.data.frame () |> rk.results()\\n");
      echo("}\\n");
    }
  '
  quantile_component <- rk.plugin.component(
    "Survey Quantiles",
    xml = list(dialog = quantile_dialog),
    js = list(require = "survey", calculate = js_calc_quantile, printout = js_print_quantile, results.header="Survey Quantiles"),
    hierarchy = list("Survey", "Survey Quantiles")
  )

  # =========================================================================================
  # Component 4: svyratio
  # =========================================================================================
  svydesign_selector4 <- rk.XML.varselector(label = "Workspace objects", id.name = "svydesign_selector4")
  svydesign_object_slot4 <- rk.XML.varslot(label = "Survey design object", source = "svydesign_selector4", required = TRUE, id.name = "svydesign_object4")
  attr(svydesign_object_slot4, "classes") <- "svydesign"
  numerator_var_slot <- rk.XML.varslot(label = "Numerator variable", source = "svydesign_selector4", required = TRUE, id.name = "numerator_var")
  attr(numerator_var_slot, "source_property") <- "variables"
  denominator_var_slot <- rk.XML.varslot(label = "Denominator variable", source = "svydesign_selector4", required = TRUE, id.name = "denominator_var")
  attr(denominator_var_slot, "source_property") <- "variables"
  subset_cbox4 <- rk.XML.cbox(label="Subset the survey design", value="1", id.name="subset_cbox4")
  subset_input4 <- rk.XML.input(label="Subset expression", id.name="subset_input4")
  subset_frame4 <- rk.XML.frame(subset_cbox4, subset_input4, label="Subset Option")
  lonely_psu_cbox4 <- rk.XML.cbox(label="Adjust for lonely PSUs (single-cluster strata)", value="1", id.name="lonely_psu_cbox4")
  save_ratio <- rk.XML.saveobj(label = "Save result as", initial = "svyratio_result", chk = TRUE, id.name = "save_ratio")
  ratio_dialog <- rk.XML.dialog(
    label = "Survey Ratio",
    child = rk.XML.row(
        svydesign_selector4,
        rk.XML.col(svydesign_object_slot4, numerator_var_slot, denominator_var_slot, subset_frame4, lonely_psu_cbox4, save_ratio)
    )
  )
  js_calc_ratio <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
    var lonely_psu = getValue("lonely_psu_cbox4");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\\"adjust\\")\\n\\n");
    }
    var use_subset = getValue("subset_cbox4");
    var subset_expr = getValue("subset_input4");
    var svy_obj = getValue("svydesign_object4");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\\n");
        final_svy_obj = "svy_subset";
    }
    var numerator_str = getValue("numerator_var");
    var denominator_str = getValue("denominator_var");
    var save_name = getValue("save_ratio.objectname");
    var clean_num = getColumnName(numerator_str);
    var clean_den = getColumnName(denominator_str);
    var num_formula = "~" + clean_num;
    var den_formula = "~" + clean_den;
    echo("svyratio_result <- svyratio(" + num_formula + ", " + den_formula + ", " + final_svy_obj + ")\\n");
  '
  js_print_ratio <- '{
      var save_name = getValue("save_ratio.objectname");
      echo("result_name <- names(svyratio_result)\\n");
      echo("for(e in result_name){\\n");
      echo("rk.header(paste0(\\"Result: \\", e), level=3)\\n");
      echo("svyratio_result[[e]] |> as.data.frame () |> rk.results()\\n");
      echo("}\\n");
    }
  '
  ratio_component <- rk.plugin.component(
    "Survey Ratio",
    xml = list(dialog = ratio_dialog),
    js = list(require = "survey", calculate = js_calc_ratio, printout = js_print_ratio, results.header="Survey Ratio"),
    hierarchy = list("Survey", "Survey Ratio")
  )

  # =========================================================================================
  # Component 5: svyglm
  # =========================================================================================
  svydesign_selector5 <- rk.XML.varselector(label = "Workspace objects", id.name = "svydesign_selector5")
  svydesign_object_slot5 <- rk.XML.varslot(label = "Survey design object", source = "svydesign_selector5", required = TRUE, id.name = "svydesign_object5")
  attr(svydesign_object_slot5, "classes") <- "svydesign"
  response_var_slot <- rk.XML.varslot(label = "Response variable", source = "svydesign_selector5", required = TRUE, id.name = "response_var")
  attr(response_var_slot, "source_property") <- "variables"
  predictor_vars_slot <- rk.XML.varslot(label = "Predictor variables", source = "svydesign_selector5", multi = TRUE, required = TRUE, id.name = "predictor_vars")
  attr(predictor_vars_slot, "source_property") <- "variables"
  quasibinomial_cbox <- rk.XML.cbox(label="Use quasibinomial family", value="1", id.name="quasibinomial_cbox")
  subset_cbox5 <- rk.XML.cbox(label="Subset the survey design", value="1", id.name="subset_cbox5")
  subset_input5 <- rk.XML.input(label="Subset expression", id.name="subset_input5")
  subset_frame5 <- rk.XML.frame(subset_cbox5, subset_input5, label="Subset Option")
  lonely_psu_cbox5 <- rk.XML.cbox(label="Adjust for lonely PSUs (single-cluster strata)", value="1", id.name="lonely_psu_cbox5")
  save_glm <- rk.XML.saveobj(label = "Save result as", initial = "svyglm_result", chk = TRUE, id.name = "save_glm")
  glm_dialog <- rk.XML.dialog(
    label = "Survey GLM",
    child = rk.XML.row(
        svydesign_selector5,
        rk.XML.col(svydesign_object_slot5, response_var_slot, predictor_vars_slot, quasibinomial_cbox, subset_frame5, lonely_psu_cbox5, save_glm)
    )
  )
  js_calc_glm <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
    var lonely_psu = getValue("lonely_psu_cbox5");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\\"adjust\\")\\n\\n");
    }
    var use_subset = getValue("subset_cbox5");
    var subset_expr = getValue("subset_input5");
    var svy_obj = getValue("svydesign_object5");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\\n");
        final_svy_obj = "svy_subset";
    }
    var response_str = getValue("response_var");
    var predictors_str = getValue("predictor_vars");
    var save_name = getValue("save_glm.objectname");
    var clean_response = getColumnName(response_str);
    var predictors_array = predictors_str.split(/\\s+/).filter(function(n){ return n != "" });
    var clean_predictors = predictors_array.map(getColumnName);
    var formula = clean_response + " ~ " + clean_predictors.join(" + ");
    var family_str = "";
    if (getValue("quasibinomial_cbox") == "1") {
        family_str = ", family=quasibinomial()";
    }
    echo("svyglm_result <- svyglm(" + formula + ", " + final_svy_obj + family_str + ")\\n");
  '
  js_print_glm <- '{
      echo("rk.print(summary(svyglm_result))\\n");
    }
  '
  glm_component <- rk.plugin.component(
    "Survey GLM",
    xml = list(dialog = glm_dialog),
    js = list(require = "survey", calculate = js_calc_glm, printout = js_print_glm, results.header="Survey GLM Results"),
    hierarchy = list("Survey", "Survey GLM")
  )

  # =========================================================================================
  # Component 6: Subset Survey Object
  # =========================================================================================
  svydesign_selector6 <- rk.XML.varselector(label = "Workspace objects", id.name = "svydesign_selector6")
  svydesign_object_slot6 <- rk.XML.varslot(label = "Survey design object", source = "svydesign_selector6", required = TRUE, id.name = "svydesign_object6")
  attr(svydesign_object_slot6, "classes") <- "svydesign"
  subset_input6 <- rk.XML.input(label="Subset expression", required=TRUE, id.name="subset_input6")
  save_subset <- rk.XML.saveobj(label = "Save subsetted object as", initial = "svy_subset", chk = TRUE, id.name = "save_subset")
  subset_dialog <- rk.XML.dialog(
    label = "Subset Survey Object",
    child = rk.XML.row(
        svydesign_selector6,
        rk.XML.col(svydesign_object_slot6, subset_input6, save_subset)
    )
  )
  js_calc_subset <- '
    var subset_expr = getValue("subset_input6");
    var svy_obj = getValue("svydesign_object6");
    var save_name = getValue("save_subset.objectname");
    echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\\n");
  '
  js_print_subset <- '
    if(getValue("save_subset") == "1"){
        var save_name = getValue("save_subset.objectname");
        var header_cmd = "rk.header(\\"Survey subset object saved as: " + save_name + "\\");\\n";
        echo(header_cmd);
    }
  '
  subset_component <- rk.plugin.component(
    "Subset Survey Object",
    xml = list(dialog = subset_dialog),
    js = list(require = "survey", calculate = js_calc_subset, printout = js_print_subset),
    hierarchy = list("Survey", "Subset Survey Object")
  )

  # =========================================================================================
  # Component 7: svytable
  # =========================================================================================
  svydesign_selector7 <- rk.XML.varselector(label = "Workspace objects", id.name = "svydesign_selector7")
  svydesign_object_slot7 <- rk.XML.varslot(label = "Survey design object", source = "svydesign_selector7", required = TRUE, id.name = "svydesign_object7")
  attr(svydesign_object_slot7, "classes") <- "svydesign"
  row_var_slot <- rk.XML.varslot(label = "Row variable", source = "svydesign_selector7", required = TRUE, id.name = "row_var")
  attr(row_var_slot, "source_property") <- "variables"
  col_var_slot <- rk.XML.varslot(label = "Column variable (optional)", source = "svydesign_selector7", id.name = "col_var")
  attr(col_var_slot, "source_property") <- "variables"
  subset_cbox7 <- rk.XML.cbox(label="Subset the survey design", value="1", id.name="subset_cbox7")
  subset_input7 <- rk.XML.input(label="Subset expression", id.name="subset_input7")
  subset_frame7 <- rk.XML.frame(subset_cbox7, subset_input7, label="Subset Option")
  lonely_psu_cbox7 <- rk.XML.cbox(label="Adjust for lonely PSUs (single-cluster strata)", value="1", id.name="lonely_psu_cbox7")
  save_table <- rk.XML.saveobj(label = "Save table as", initial = "svytable_result", chk = TRUE, id.name = "save_table")
  table_dialog <- rk.XML.dialog(
    label = "Survey Table",
    child = rk.XML.row(
        svydesign_selector7,
        rk.XML.col(svydesign_object_slot7, row_var_slot, col_var_slot, subset_frame7, lonely_psu_cbox7, save_table)
    )
  )
  js_calc_table <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
    var lonely_psu = getValue("lonely_psu_cbox7");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\\"adjust\\")\\n\\n");
    }
    var use_subset = getValue("subset_cbox7");
    var subset_expr = getValue("subset_input7");
    var svy_obj = getValue("svydesign_object7");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\\n");
        final_svy_obj = "svy_subset";
    }
    var row_str = getValue("row_var");
    var col_str = getValue("col_var");
    var save_name = getValue("save_table.objectname");
    var clean_row = getColumnName(row_str);
    var clean_col = getColumnName(col_str);
    var formula = "~" + clean_row;
    if (clean_col) {
        formula += " + " + clean_col;
    }
    echo("svytable_result <- svytable(" + formula + ", " + final_svy_obj + ")\\n");
  '
  js_print_table <- '{
      echo("rk.results(svytable_result)\\n");
    }
  '
  table_component <- rk.plugin.component(
    "Survey Table",
    xml = list(dialog = table_dialog),
    js = list(require = "survey", calculate = js_calc_table, printout = js_print_table, results.header="Survey Table"),
    hierarchy = list("Survey", "Survey Table")
  )

  # =========================================================================================
  # Component 8: svychisq
  # =========================================================================================
  svydesign_selector8 <- rk.XML.varselector(label = "Workspace objects", id.name = "svydesign_selector8")
  svydesign_object_slot8 <- rk.XML.varslot(label = "Survey design object", source = "svydesign_selector8", required = TRUE, id.name = "svydesign_object8")
  attr(svydesign_object_slot8, "classes") <- "svydesign"
  var1_chisq_slot <- rk.XML.varslot(label = "Variable 1", source = "svydesign_selector8", required = TRUE, id.name = "var1_chisq")
  attr(var1_chisq_slot, "source_property") <- "variables"
  var2_chisq_slot <- rk.XML.varslot(label = "Variable 2", source = "svydesign_selector8", required = TRUE, id.name = "var2_chisq")
  attr(var2_chisq_slot, "source_property") <- "variables"
  subset_cbox8 <- rk.XML.cbox(label="Subset the survey design", value="1", id.name="subset_cbox8")
  subset_input8 <- rk.XML.input(label="Subset expression", id.name="subset_input8")
  subset_frame8 <- rk.XML.frame(subset_cbox8, subset_input8, label="Subset Option")
  lonely_psu_cbox8 <- rk.XML.cbox(label="Adjust for lonely PSUs (single-cluster strata)", value="1", id.name="lonely_psu_cbox8")
  save_chisq <- rk.XML.saveobj(label = "Save result as", initial = "svychisq_result", chk = TRUE, id.name = "save_chisq")
  chisq_dialog <- rk.XML.dialog(
    label = "Survey Chi-squared Test",
    child = rk.XML.row(
        svydesign_selector8,
        rk.XML.col(svydesign_object_slot8, var1_chisq_slot, var2_chisq_slot, subset_frame8, lonely_psu_cbox8, save_chisq)
    )
  )
  js_calc_chisq <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            return lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
    var lonely_psu = getValue("lonely_psu_cbox8");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\\"adjust\\")\\n\\n");
    }
    var use_subset = getValue("subset_cbox8");
    var subset_expr = getValue("subset_input8");
    var svy_obj = getValue("svydesign_object8");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\\n");
        final_svy_obj = "svy_subset";
    }
    var var1_str = getValue("var1_chisq");
    var var2_str = getValue("var2_chisq");
    var save_name = getValue("save_chisq.objectname");
    var clean_var1 = getColumnName(var1_str);
    var clean_var2 = getColumnName(var2_str);
    var formula = "~" + clean_var1 + " + " + clean_var2;
    echo("svychisq_result <- svychisq(" + formula + ", " + final_svy_obj + ")\\n");
  '
  js_print_chisq <- '{
      echo("rk.print(svychisq_result)\\n");
      echo("rk.print(summary(svychisq_result))\\n");
      echo("rk.header(paste0(\\"Expected: \\"), level=3)\\n");
      echo("rk.results(svychisq_result$expected)\\n");
      echo("rk.header(paste0(\\"Observed: \\"), level=3)\\n");
      echo("rk.results(svychisq_result$observed)\\n");
      echo("rk.header(paste0(\\"Residuals: \\"), level=3)\\n");
      echo("rk.results(svychisq_result$residuals)\\n");
      echo("rk.header(paste0(\\"Standar residuals: \\"), level=3)\\n");
      echo("rk.results(svychisq_result$stdres)\\n");
    }
  '
  chisq_component <- rk.plugin.component(
    "Survey Chi-squared Test",
    xml = list(dialog = chisq_dialog),
    js = list(require = "survey", calculate = js_calc_chisq, printout = js_print_chisq, results.header="Survey Chi-squared Test"),
    hierarchy = list("Survey", "Survey Chi-squared Test")
  )

  # =========================================================================================
  # Final Plugin Skeleton Call
  # =========================================================================================
  all_components <- list(
    mean_total_component,
    by_component,
    quantile_component,
    ratio_component,
    glm_component,
    subset_component,
    table_component,
    chisq_component
  )

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = main_dialog_content),
    js = list(
      require = "survey",
      calculate = js_calc_main,
      printout = js_print_main
    ),
    rkh = list(help = help_main),
    components = all_components,
    pluginmap = list(
        name = "Create Survey Design",
        hierarchy = list("Survey", "Create Survey Design")
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  cat("\nPlugin package 'rk.survey.design' with 9 plugins generated.\n\nTo complete installation:\n\n")
  cat("  rk.updatePluginMessages(plugin.dir=\"rk.survey.design\")\n\n")
  cat("  devtools::install(\"rk.survey.design\")\n")
})
