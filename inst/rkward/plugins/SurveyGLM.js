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
   var f=preprocessSurveyOptions("lonely_psu_cbox5","subset_cbox5","subset_input5",getValue("svydesign_object5"));var r=getColumnName(getValue("response_var"));var p=getValue("predictor_vars").split(/\n/).filter(function(n){return n!=""});var b=r+" ~ "+p.map(getColumnName).join(" + ");var q=getValue("quasibinomial_cbox")=="1"? ", family=quasibinomial()":"";echo("svyglm_result <- svyglm("+b+", "+f+q+")\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey GLM Results")).print();
echo("rk.print(summary(svyglm_result))\n");
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

