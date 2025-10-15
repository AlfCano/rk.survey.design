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
      version = "0.7.6",
      url = "https://github.com/AlfCano/rk.survey.design",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # --- Reusable UI and JS Helpers ---
  # =========================================================================================

  js_helpers <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            var match = lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
            if (match) {
                return match[1];
            }
        }
        if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }

    function preprocessSurveyOptions(lonely_psu_id, subset_cbox_id, subset_input_id, svy_obj_name) {
        var lonely_psu = getValue(lonely_psu_id);
        if (lonely_psu == "1") {
            echo("options(survey.lonely.psu=\\"adjust\\")\\n\\n");
        }
        var use_subset = getValue(subset_cbox_id);
        var subset_expr = getValue(subset_input_id);
        var final_svy_obj = svy_obj_name;
        if (use_subset == "1" && subset_expr) {
            echo("svy_subset <- subset(" + svy_obj_name + ", subset = " + subset_expr + ")\\n");
            final_svy_obj = "svy_subset";
        }
        return final_svy_obj;
    }
  '

  generate_survey_input <- function(id_suffix) {
    list(
      selector = rk.XML.varselector(label = "Workspace objects", id.name = paste0("svydesign_selector", id_suffix)),
      slot = rk.XML.varslot(label = "Survey design object", source = paste0("svydesign_selector", id_suffix), required = TRUE, id.name = paste0("svydesign_object", id_suffix), classes = "svydesign")
    )
  }

  generate_subset_frame <- function(id_suffix) {
    rk.XML.frame(
      rk.XML.cbox(label="Subset the survey design", value="1", id.name=paste0("subset_cbox", id_suffix)),
      rk.XML.input(label="Subset expression", id.name=paste0("subset_input", id_suffix)),
      label="Subset Option"
    )
  }

  generate_lonely_psu_cbox <- function(id_suffix){
    rk.XML.cbox(label="Adjust for lonely PSUs (single-cluster strata)", value="1", id.name=paste0("lonely_psu_cbox", id_suffix))
  }

  # =========================================================================================
  # Main Plugin: Create Survey Design
  # =========================================================================================
  dataframe_selector <- rk.XML.varselector(id.name = "dataframe_selector", label="Select data object")
  dataframe_object_slot <- rk.XML.varslot(label = "Survey data (data.frame)", source = "dataframe_selector", classes = "data.frame", required = TRUE, id.name = "dataframe_object")
  id_varslot <- rk.XML.varslot(id.name = "id_var", label = "ID/Cluster variable (~1 for no cluster)", source = "dataframe_selector")
  strata_varslot <- rk.XML.varslot(id.name = "strata_var", label = "Strata variable (optional)", source = "dataframe_selector")
  weight_varslot <- rk.XML.varslot(id.name = "weight_var", label = "Weight variable (or use probs)", source = "dataframe_selector")
  probs_varslot <- rk.XML.varslot(id.name = "probs_var", label = "Sampling probabilities (optional)", source = "dataframe_selector")
  fpc_varslot <- rk.XML.varslot(id.name = "fpc_var", label = "Finite Population Correction (optional)", source = "dataframe_selector")
  save_survey_object <- rk.XML.saveobj(label = "Save survey design object as", chk = TRUE, initial = "survey.design", id.name = "save_survey")

  main_dialog_content <- rk.XML.dialog(
    label = "Create Complex Survey Design",
    child = rk.XML.row(
      dataframe_selector,
      rk.XML.col(
        rk.XML.tabbook(tabs = list(
            "Basic Design" = rk.XML.col(dataframe_object_slot, id_varslot, strata_varslot, weight_varslot, probs_varslot, fpc_varslot, rk.XML.cbox(label="Nest clusters within strata (nest=TRUE)", id.name="nest_cbox", value="1")),
            "Advanced Options" = rk.XML.col(
              rk.XML.cbox(label="Check nesting of clusters in strata (check.strata=TRUE)", id.name="check_strata_cbox", value="1"),
              rk.XML.input(label = "PPS method (e.g., 'brewer') or object", id.name = "pps_input"),
              rk.XML.dropdown(label="PPS variance estimator", options=list("Horvitz-Thompson (default)"=list(val=""), "Yates-Grundy"=list(val="YG")), id.name="variance_pps"),
              rk.XML.input(label = "Calibration formula (e.g., ~var1+var2)", id.name = "calibrate_formula_input"),
              rk.XML.frame(rk.XML.input(label = "Database type (e.g., 'SQLite')", id.name = "dbtype_input"), rk.XML.input(label = "Database name (e.g., 'survey.db')", id.name = "dbname_input"), label = "Database Options (optional)"))
        )),
        save_survey_object
      )
    )
  )

  js_calc_main <- paste(js_helpers, '
    var dataframe = getValue("dataframe_object");
    var options = new Array();
    var id_col = getColumnName(getValue("id_var"));
    options.push(id_col ? "ids = ~" + id_col : "ids = ~1");
    if (getValue("probs_var")) { options.push("probs = ~" + getColumnName(getValue("probs_var"))); }
    if (getValue("strata_var")) { options.push("strata = ~" + getColumnName(getValue("strata_var"))); }
    if (getValue("fpc_var")) { options.push("fpc = ~" + getColumnName(getValue("fpc_var"))); }
    if (getValue("weight_var")) { options.push("weights = ~" + getColumnName(getValue("weight_var"))); }
    if (getValue("calibrate_formula_input")) { options.push("calibrate.formula = " + getValue("calibrate_formula_input")); }
    options.push("data = " + dataframe);
    if (getValue("nest_cbox") == "1"){ options.push("nest=TRUE"); }
    if (getValue("check_strata_cbox") == "1"){ options.push("check.strata=TRUE"); }
    if (getValue("pps_input")) { options.push("pps = " + getValue("pps_input")); }
    if (getValue("variance_pps")) { options.push("variance = \\"" + getValue("variance_pps") + "\\""); }
    if (getValue("dbtype_input")) { options.push("dbtype = \\"" + getValue("dbtype_input") + "\\""); }
    if (getValue("dbname_input")) { options.push("dbname = \\"" + getValue("dbname_input") + "\\""); }
    echo("survey.design <- svydesign(" + options.join(", ") + ")\\n");
  ')

  js_print_main <- 'echo("rk.header(\\"Survey design object saved as: " + getValue("save_survey.objectname") + "\\")\\n");'

  # --- Component Definitions ---

    # Component 1: svymean / svytotal
  survey_inputs1 <- generate_survey_input(1)
  analysis_vars_slot1 <- rk.XML.varslot(label = "Analysis variables", source = "svydesign_selector1", multi = TRUE, required = TRUE, id.name = "analysis_vars1")
  attr(analysis_vars_slot1, "source_property") <- "variables"
  mean_total_component <- rk.plugin.component("Survey Mean or Total",
    xml=list(dialog=rk.XML.dialog(label="Survey Mean or Total", child=rk.XML.row(survey_inputs1$selector, rk.XML.col(survey_inputs1$slot, analysis_vars_slot1, generate_subset_frame(1), rk.XML.dropdown(label="Function", options=list("Mean"=list(val="svymean", chk=TRUE), "Total"=list(val="svytotal")), id.name="mean_total_func"), generate_lonely_psu_cbox(1), rk.XML.saveobj(label = "Save result as", initial = "svystat_result", chk = TRUE, id.name = "save_mean_total"))))),
    js=list(require="survey", calculate=paste(js_helpers, 'var f=preprocessSurveyOptions("lonely_psu_cbox1","subset_cbox1","subset_input1",getValue("svydesign_object1"));var a=getValue("analysis_vars1").split(/\\n/).filter(function(n){return n!=""});var b="~"+a.map(getColumnName).join(" + ");echo("svystat_result <- "+getValue("mean_total_func")+"("+b+", "+f+")\\n");'), printout='echo("rk.header(\\"Survey Stat saved as: "+getValue("save_mean_total.objectname")+"\\",level=3)\\n");echo("svystat_result|>as.data.frame()|>rk.results()\\n");', results.header="Survey svystat results"),
    hierarchy=list("Survey"))

  # Component 2: svyby
  survey_inputs2 <- generate_survey_input(2)
  analysis_vars_slot2 <- rk.XML.varslot(label="Analysis variables", source="svydesign_selector2", multi=TRUE, required=TRUE, id.name="analysis_vars2")
  attr(analysis_vars_slot2, "source_property") <- "variables"
  by_vars_slot <- rk.XML.varslot(label="Grouping variables (by)", source="svydesign_selector2", multi=TRUE, required=TRUE, id.name="by_vars")
  attr(by_vars_slot, "source_property") <- "variables"
  by_component <- rk.plugin.component("Grouped Survey Analysis (by)",
    xml=list(dialog=rk.XML.dialog(label="Grouped Survey Analysis (by)", child=rk.XML.row(survey_inputs2$selector, rk.XML.col(survey_inputs2$slot, analysis_vars_slot2, by_vars_slot, generate_subset_frame(2), rk.XML.dropdown(label="Function (FUN)", options=list("Mean"=list(val="svymean", chk=TRUE), "Total"=list(val="svytotal")), id.name="by_func"), generate_lonely_psu_cbox(2), rk.XML.saveobj(label="Save result as", initial="svyby_result", chk=TRUE, id.name="save_by"))))),
    js=list(require="survey", calculate=paste(js_helpers, 'var f=preprocessSurveyOptions("lonely_psu_cbox2","subset_cbox2","subset_input2",getValue("svydesign_object2"));var a=getValue("analysis_vars2").split(/\\n/).filter(function(n){return n!=""});var b="~"+a.map(getColumnName).join(" + ");var c=getValue("by_vars").split(/\\n/).filter(function(n){return n!=""});var d="~"+c.map(getColumnName).join(" + ");echo("svyby_result <- svyby("+b+", "+d+", "+f+", "+getValue("by_func")+")\\n");'), printout='echo("rk.header(\\"Survey by saved as: "+getValue("save_by.objectname")+"\\",level=3)\\n");echo("svyby_result|>as.data.frame()|>rk.results(print.rownames=FALSE)\\n");', results.header="Survey by results"),
    hierarchy=list("Survey"))

  # Component 3: svyquantile
  survey_inputs3 <- generate_survey_input(3)
  analysis_var_slot3 <- rk.XML.varslot(label="Analysis variable", source="svydesign_selector3", required=TRUE, id.name="analysis_var3")
  attr(analysis_var_slot3, "source_property") <- "variables"
  quantile_component <- rk.plugin.component("Survey Quantiles",
    xml=list(dialog=rk.XML.dialog(label="Survey Quantiles", child=rk.XML.row(survey_inputs3$selector, rk.XML.col(survey_inputs3$slot, analysis_var_slot3, rk.XML.input(label="Quantiles (comma-separated)", initial="0.25, 0.5, 0.75", id.name="quantiles_input"), generate_subset_frame(3), generate_lonely_psu_cbox(3), rk.XML.saveobj(label="Save result as", initial="svyquantile_result", chk=TRUE, id.name="save_quantile"))))),
    js=list(require="survey", calculate=paste(js_helpers, 'var f=preprocessSurveyOptions("lonely_psu_cbox3","subset_cbox3","subset_input3",getValue("svydesign_object3"));var b="~"+getColumnName(getValue("analysis_var3"));echo("svyquantile_result <- svyquantile("+b+", "+f+", quantiles=c("+getValue("quantiles_input")+"))\\n");'), printout='echo("result_name<-names(svyquantile_result)\\nfor(e in result_name){\\nrk.header(paste0(\\"Quantiles for variable: \\",e),level=3)\\nsvyquantile_result[[e]]|>as.data.frame()|>rk.results()\\n}\\n");', results.header="Survey Quantiles"),
    hierarchy=list("Survey"))

  # Component 4: svyratio
  survey_inputs4 <- generate_survey_input(4)
  numerator_var_slot <- rk.XML.varslot(label="Numerator variable", source="svydesign_selector4", required=TRUE, id.name="numerator_var")
  attr(numerator_var_slot, "source_property") <- "variables"
  denominator_var_slot <- rk.XML.varslot(label="Denominator variable", source="svydesign_selector4", required=TRUE, id.name="denominator_var")
  attr(denominator_var_slot, "source_property") <- "variables"
  ratio_component <- rk.plugin.component("Survey Ratio",
    xml=list(dialog=rk.XML.dialog(label="Survey Ratio", child=rk.XML.row(survey_inputs4$selector, rk.XML.col(survey_inputs4$slot, numerator_var_slot, denominator_var_slot, generate_subset_frame(4), generate_lonely_psu_cbox(4), rk.XML.saveobj(label="Save result as", initial="svyratio_result", chk=TRUE, id.name="save_ratio"))))),
    js=list(require="survey", calculate=paste(js_helpers, 'var f=preprocessSurveyOptions("lonely_psu_cbox4","subset_cbox4","subset_input4",getValue("svydesign_object4"));var n="~"+getColumnName(getValue("numerator_var"));var d="~"+getColumnName(getValue("denominator_var"));echo("svyratio_result <- svyratio("+n+", "+d+", "+f+")\\n");'), printout='echo("result_name<-names(svyratio_result)\\nfor(e in result_name){\\nrk.header(paste0(\\"Result: \\",e),level=3)\\nsvyratio_result[[e]]|>as.data.frame()|>rk.results()\\n}\\n");', results.header="Survey Ratio"),
    hierarchy=list("Survey"))

  # Component 5: svyglm
  survey_inputs5 <- generate_survey_input(5)
  response_var_slot <- rk.XML.varslot(label="Response variable", source="svydesign_selector5", required=TRUE, id.name="response_var")
  attr(response_var_slot, "source_property") <- "variables"
  predictor_vars_slot <- rk.XML.varslot(label="Predictor variables", source="svydesign_selector5", multi=TRUE, required=TRUE, id.name="predictor_vars")
  attr(predictor_vars_slot, "source_property") <- "variables"
  glm_component <- rk.plugin.component("Survey GLM",
    xml=list(dialog=rk.XML.dialog(label="Survey GLM", child=rk.XML.row(survey_inputs5$selector, rk.XML.col(survey_inputs5$slot, response_var_slot, predictor_vars_slot, rk.XML.cbox(label="Use quasibinomial family", value="1", id.name="quasibinomial_cbox"), generate_subset_frame(5), generate_lonely_psu_cbox(5), rk.XML.saveobj(label="Save result as", initial="svyglm_result", chk=TRUE, id.name="save_glm"))))),
    js=list(require="survey", calculate=paste(js_helpers, 'var f=preprocessSurveyOptions("lonely_psu_cbox5","subset_cbox5","subset_input5",getValue("svydesign_object5"));var r=getColumnName(getValue("response_var"));var p=getValue("predictor_vars").split(/\\n/).filter(function(n){return n!=""});var b=r+" ~ "+p.map(getColumnName).join(" + ");var q=getValue("quasibinomial_cbox")=="1"? ", family=quasibinomial()":"";echo("svyglm_result <- svyglm("+b+", "+f+q+")\\n");'), printout='echo("rk.print(summary(svyglm_result))\\n");', results.header="Survey GLM Results"),
    hierarchy=list("Survey"))

  # Component 6: Subset Survey Object
  survey_inputs6 <- generate_survey_input(6)
  subset_component <- rk.plugin.component("Subset Survey Object",
    xml=list(dialog=rk.XML.dialog(label="Subset Survey Object", child=rk.XML.row(survey_inputs6$selector, rk.XML.col(survey_inputs6$slot, rk.XML.input(label="Subset expression", required=TRUE, id.name="subset_input6"), rk.XML.saveobj(label="Save subsetted object as", initial="svy_subset", chk=TRUE, id.name="save_subset"))))),
    js=list(require="survey", calculate='var s=getValue("svydesign_object6");echo("svy_subset<-subset("+s+",subset="+getValue("subset_input6")+")\\nfor(col_name in names(svy_subset$variables)){\\ntry({\\nattr(svy_subset$variables[[col_name]],\\".rk.meta\\")<-attr("+s+"$variables[[col_name]],\\".rk.meta\\")\\n},silent=TRUE)\\n}\\n");', printout='if(getValue("save_subset")=="1"){echo("rk.header(\\"Survey subset object saved as: "+getValue("save_subset.objectname")+"\\")\\n");}'),
    hierarchy=list("Survey"))

  # Component 7: svytable
  survey_inputs7 <- generate_survey_input(7)
  row_var_slot <- rk.XML.varslot(label="Row variable", source="svydesign_selector7", required=TRUE, id.name="row_var")
  attr(row_var_slot, "source_property") <- "variables"
  col_var_slot <- rk.XML.varslot(label="Column variable (optional)", source="svydesign_selector7", id.name="col_var")
  attr(col_var_slot, "source_property") <- "variables"
  table_component <- rk.plugin.component("Survey Table",
    xml=list(dialog=rk.XML.dialog(label="Survey Table", child=rk.XML.row(survey_inputs7$selector, rk.XML.col(survey_inputs7$slot, row_var_slot, col_var_slot, generate_subset_frame(7), generate_lonely_psu_cbox(7), rk.XML.saveobj(label="Save table as", initial="svytable_result", chk=TRUE, id.name="save_table"))))),
    js=list(require="survey", calculate=paste(js_helpers, 'var f=preprocessSurveyOptions("lonely_psu_cbox7","subset_cbox7","subset_input7",getValue("svydesign_object7"));var b="~"+getColumnName(getValue("row_var"));if(getValue("col_var")){b+=" + "+getColumnName(getValue("col_var"));}echo("svytable_result<-svytable("+b+", "+f+")\\n");'), printout='echo("rk.results(svytable_result)\\n");', results.header="Survey Table"),
    hierarchy=list("Survey"))

  # Component 8: svychisq
  survey_inputs8 <- generate_survey_input(8)
  var1_chisq_slot <- rk.XML.varslot(label="Variable 1", source="svydesign_selector8", required=TRUE, id.name="var1_chisq")
  attr(var1_chisq_slot, "source_property") <- "variables"
  var2_chisq_slot <- rk.XML.varslot(label="Variable 2", source="svydesign_selector8", required=TRUE, id.name="var2_chisq")
  attr(var2_chisq_slot, "source_property") <- "variables"
  chisq_component <- rk.plugin.component("Survey Chi-squared Test",
    xml=list(dialog=rk.XML.dialog(label="Survey Chi-squared Test", child=rk.XML.row(survey_inputs8$selector, rk.XML.col(survey_inputs8$slot, var1_chisq_slot, var2_chisq_slot, generate_subset_frame(8), generate_lonely_psu_cbox(8), rk.XML.saveobj(label="Save result as", initial="svychisq_result", chk=TRUE, id.name="save_chisq"))))),
    js=list(require="survey", calculate=paste(js_helpers, 'var f=preprocessSurveyOptions("lonely_psu_cbox8","subset_cbox8","subset_input8",getValue("svydesign_object8"));var b="~"+getColumnName(getValue("var1_chisq"))+" + "+getColumnName(getValue("var2_chisq"));echo("svychisq_result<-svychisq("+b+", "+f+")\\n");'), printout='echo("rk.print(svychisq_result)\\n");echo("rk.print(summary(svychisq_result))\\n");echo("rk.header(\\"Expected:\\",level=3);rk.results(svychisq_result$expected)\\n");echo("rk.header(\\"Observed:\\",level=3);rk.results(svychisq_result$observed)\\n");echo("rk.header(\\"Residuals:\\",level=3);rk.results(svychisq_result$residuals)\\n");echo("rk.header(\\"Standardized Residuals:\\",level=3);rk.results(svychisq_result$stdres)\\n");', results.header="Survey Chi-squared Test"),
    hierarchy=list("Survey"))

  # =========================================================================================
  # Final Plugin Skeleton Call
  # =========================================================================================
  all_components <- list(
    mean_total_component, by_component, quantile_component, ratio_component,
    glm_component, subset_component, table_component, chisq_component
  )

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = main_dialog_content),
    js = list(require = "survey", calculate = js_calc_main, printout = js_print_main),
    rkh = list(help = rk.rkh.doc(
      title = rk.rkh.title(text = "Create Survey Design"),
      summary = rk.rkh.summary(text = "Creates a survey design object using svydesign() from the 'survey' package."),
      usage = rk.rkh.usage(text = "Select the data.frame, specify the design variables, and assign a name for the resulting survey design object."))),
    components = all_components,
    pluginmap = list(name = "Create Survey Design", hierarchy = list("Survey")),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  cat("\nCleaned plugin package 'rk.survey.design' with 9 plugins generated.\n\nTo complete installation:\n\n")
  cat("  rk.updatePluginMessages(plugin.dir=\"rk.survey.design\")\n\n")
  cat("  devtools::install(\"rk.survey.design\")\n")
})
