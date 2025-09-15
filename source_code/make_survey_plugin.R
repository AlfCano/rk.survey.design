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
      version = "0.6.0", # Version bumped for subset feature
      url = "https://github.com/AlfCano/rk.survey.design",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # Main Plugin: Create Survey Design (Unchanged)
  # =========================================================================================

  help_main <- rk.rkh.doc(
    title = rk.rkh.title(text = "Create Survey Design"),
    summary = rk.rkh.summary(text = "Creates a survey design object using svydesign() from the 'survey' package."),
    usage = rk.rkh.usage(text = "Select the data.frame, specify the design variables, and assign a name for the resulting survey design object.")
  )

  js_calc_main <- "
    var weight_var_full = getValue(\"weight_var\");
    var strata_var_full = getValue(\"strata_var\");
    var id_var_full = getValue(\"id_var\");
    var dataframe = getValue(\"dataframe_object\");
    var nest_option = getValue(\"nest_cbox\");
    function getColumnName(fullName) {
        if (!fullName) return \"\";
        if (fullName.indexOf(\"[[\") > -1) { return fullName.match(/\\[\\[\\\"(.*?)\\\"\\]\\]/)[1]; }
        else if (fullName.indexOf(\"$\") > -1) { return fullName.substring(fullName.lastIndexOf(\"$\") + 1); }
        else { return fullName; }
    }
    var weight_col = getColumnName(weight_var_full);
    var strata_col = getColumnName(strata_var_full);
    var id_col = getColumnName(id_var_full);
    var options = new Array();
    if (id_col) { options.push(\"ids = ~\" + id_col); } else { options.push(\"ids = ~1\"); }
    if (strata_col) { options.push(\"strata = ~\" + strata_col); }
    if (weight_col) { options.push(\"weights = ~\" + weight_col); }
    options.push(\"data = \" + dataframe);
    if(nest_option == \"1\"){ options.push(\"nest=TRUE\"); }
    echo('survey.design <- svydesign(' + options.join(', ') + ')\\n');
  "
  js_print_main <- '
    if(getValue("save_survey") == "1"){
        var save_name = getValue("save_survey.objectname");
        var header_cmd = "rk.header(\\"Survey design object saved as: " + save_name + "\\");\\n";
        echo(header_cmd);
    }
  '

  dataframe_selector <- rk.XML.varselector(id.name = "dataframe_selector")
  dataframe_object_slot <- rk.XML.varslot(label = "Survey data (data.frame)", source = "dataframe_selector", classes = "data.frame", required = TRUE, id.name = "dataframe_object")
  weight_varslot <- rk.XML.varslot(id.name = "weight_var", label = "Weight variable", source = "dataframe_selector", required = TRUE)
  strata_varslot <- rk.XML.varslot(id.name = "strata_var", label = "Strata variable (optional)", source = "dataframe_selector")
  id_varslot <- rk.XML.varslot(id.name = "id_var", label = "ID/Cluster variable (optional)", source = "dataframe_selector")
  nest_checkbox <- rk.XML.cbox(label="Nest clusters within strata (nest=TRUE)", id.name="nest_cbox", value="1")
  save_survey_object <- rk.XML.saveobj(label = "Save survey design object as", chk = TRUE, initial = "survey.design", id.name = "save_survey")

  main_dialog_content <- rk.XML.dialog(
    label = "Create Complex Survey Design",
    child = rk.XML.row(
        dataframe_selector,
        rk.XML.col(dataframe_object_slot, weight_varslot, strata_varslot, id_varslot, nest_checkbox, save_survey_object)
    )
  )

  # =========================================================================================
  # Component 1: svymean / svytotal
  # =========================================================================================
  svydesign_selector1 <- rk.XML.varselector(label = "Workspace objects", id.name = "svydesign_selector1")
  svydesign_object_slot1 <- rk.XML.varslot(label = "Survey design object", source = "svydesign_selector1", required = TRUE, id.name = "svydesign_object1")
  attr(svydesign_object_slot1, "classes") <- "svydesign"
  analysis_vars_slot1 <- rk.XML.varslot(label = "Analysis variables", source = "svydesign_selector1", multi = TRUE, required = TRUE, id.name = "analysis_vars1")
  attr(analysis_vars_slot1, "source_property") <- "variables"

  # NEW: Subset UI elements
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

  # NEW: Subset UI elements
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
      echo("svyby_result |> as.data.frame() |> rk.results(print.rownames=FALSE)\\n");
    }
  '

  by_component <- rk.plugin.component(
      "Grouped Survey Analysis",
      xml = list(dialog = by_dialog),
      js = list(require = "survey",calculate = js_calc_by, printout = js_print_by),
      hierarchy = list("Survey", "Grouped Survey Analysis (by)")
  )

  # =========================================================================================
  # Final Plugin Skeleton Call
  # =========================================================================================
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
    components = list(mean_total_component, by_component),
    pluginmap = list(
        name = "Create Survey Design",
        hierarchy = list("Survey", "Create Survey Design")
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  cat("\nPlugin package 'rk.survey.design' with 3 plugins generated.\n\nTo complete installation:\n\n")
  cat("  rk.updatePluginMessages(plugin.dir=\"rk.survey.design\")\n\n")
  cat("  devtools::install(\"rk.survey.design\")\n")
})
