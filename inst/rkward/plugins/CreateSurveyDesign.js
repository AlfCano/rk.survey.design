// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(survey)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            var match = lastPart.match(/\[\[\"(.*?)\"\]\]/);
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
            echo("options(survey.lonely.psu=\"adjust\")\n\n");
        }
        var use_subset = getValue(subset_cbox_id);
        var subset_expr = getValue(subset_input_id);
        var final_svy_obj = svy_obj_name;
        if (use_subset == "1" && subset_expr) {
            echo("svy_subset <- subset(" + svy_obj_name + ", subset = " + subset_expr + ")\n");
            final_svy_obj = "svy_subset";
        }
        return final_svy_obj;
    }
   
    if(getValue("main_lonely_psu_cbox") == "1"){
      echo("options(survey.lonely.psu = \"adjust\")\n\n");
    }
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
    if (getValue("variance_pps")) { options.push("variance = \"" + getValue("variance_pps") + "\""); }
    if (getValue("dbtype_input")) { options.push("dbtype = \"" + getValue("dbtype_input") + "\""); }
    if (getValue("dbname_input")) { options.push("dbname = \"" + getValue("dbname_input") + "\""); }
    echo("survey.design <- svydesign(" + options.join(", ") + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Create Survey Design results")).print();
echo("rk.header(\"Survey design object saved as: " + getValue("save_survey.objectname") + "\")\n");
	//// save result object
	// read in saveobject variables
	var saveSurvey = getValue("save_survey");
	var saveSurveyActive = getValue("save_survey.active");
	var saveSurveyParent = getValue("save_survey.parent");
	// assign object to chosen environment
	if(saveSurveyActive) {
		echo(".GlobalEnv$" + saveSurvey + " <- survey.design\n");
	}

}

