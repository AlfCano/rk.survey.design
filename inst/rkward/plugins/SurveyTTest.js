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
   
    var svy_obj = preprocessSurveyOptions("lonely_psu_cbox9", "subset_cbox9", "subset_input9", getValue("svydesign_object9"));
    var outcome_var = getColumnName(getValue("outcome_var9"));
    var grouping_var = getColumnName(getValue("grouping_var9"));
    var formula = outcome_var + " ~ " + grouping_var;
    echo("data.bound <- svyttest(" + formula + ", design = " + svy_obj + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Parametric Survey Test (t-test)")).print();

    if(getValue("save_ttest.active")){
      echo("rk.header(\"T-test result saved as: " + getValue("save_ttest.objectname") + "\")\n");
    }
    echo("rk.print(data.bound)\n");
  
	//// save result object
	// read in saveobject variables
	var saveTtest = getValue("save_ttest");
	var saveTtestActive = getValue("save_ttest.active");
	var saveTtestParent = getValue("save_ttest.parent");
	// assign object to chosen environment
	if(saveTtestActive) {
		echo(".GlobalEnv$" + saveTtest + " <- data.bound\n");
	}

}

