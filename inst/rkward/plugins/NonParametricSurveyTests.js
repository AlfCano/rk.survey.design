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
   
    var svy_obj = preprocessSurveyOptions("lonely_psu_cbox10", "subset_cbox10", "subset_input10", getValue("svydesign_object10"));
    var outcome_var = getColumnName(getValue("outcome_var10"));
    var grouping_var = getColumnName(getValue("grouping_var10"));
    var formula = outcome_var + " ~ " + grouping_var;
    var test_type = getValue("ranktest_type");
    var r_command = "data.bound <- svyranktest(" + formula + ", design = " + svy_obj + ", test=\"" + test_type + "\")";
    echo(r_command + "\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Non-Parametric Survey Rank Test")).print();

    if(getValue("save_ranktest.active")){
      echo("rk.header(\"Rank test result saved as: " + getValue("save_ranktest.objectname") + "\")\n");
    }
    echo("rk.print(data.bound)\n");
  
	//// save result object
	// read in saveobject variables
	var saveRanktest = getValue("save_ranktest");
	var saveRanktestActive = getValue("save_ranktest.active");
	var saveRanktestParent = getValue("save_ranktest.parent");
	// assign object to chosen environment
	if(saveRanktestActive) {
		echo(".GlobalEnv$" + saveRanktest + " <- data.bound\n");
	}

}

