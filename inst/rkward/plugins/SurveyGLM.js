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
            return lastPart.match(/\[\[\"(.*?)\"\]\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }
    var lonely_psu = getValue("lonely_psu_cbox5");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\"adjust\")\n\n");
    }
    var use_subset = getValue("subset_cbox5");
    var subset_expr = getValue("subset_input5");
    var svy_obj = getValue("svydesign_object5");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\n");
        final_svy_obj = "svy_subset";
    }
    var response_str = getValue("response_var");
    var predictors_str = getValue("predictor_vars");
    var save_name = getValue("save_glm.objectname");
    var clean_response = getColumnName(response_str);
    var predictors_array = predictors_str.split(/\s+/).filter(function(n){ return n != "" });
    var clean_predictors = predictors_array.map(getColumnName);
    var formula = clean_response + " ~ " + clean_predictors.join(" + ");
    var family_str = "";
    if (getValue("quasibinomial_cbox") == "1") {
        family_str = ", family=quasibinomial()";
    }
    echo("svyglm_result <- svyglm(" + formula + ", " + final_svy_obj + family_str + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey GLM Results")).print();
{
      echo("rk.print(summary(svyglm_result))\n");
    }
  
	//// save result object
	// read in saveobject variables
	var saveGlm = getValue("save_glm");
	var saveGlmActive = getValue("save_glm.active");
	var saveGlmParent = getValue("save_glm.parent");
	// assign object to chosen environment
	if(saveGlmActive) {
		echo(".GlobalEnv$" + saveGlm + " <- svyglm_result\n");
	}

}

