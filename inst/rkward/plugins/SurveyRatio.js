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
   var f=preprocessSurveyOptions("lonely_psu_cbox4","subset_cbox4","subset_input4",getValue("svydesign_object4"));var n="~"+getColumnName(getValue("numerator_var"));var d="~"+getColumnName(getValue("denominator_var"));echo("svyratio_result <- svyratio("+n+", "+d+", "+f+")\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey Ratio")).print();
echo("result_name<-names(svyratio_result)\nfor(e in result_name){\nrk.header(paste0(\"Result: \",e),level=3)\nsvyratio_result[[e]]|>as.data.frame()|>rk.results()\n}\n");
	//// save result object
	// read in saveobject variables
	var saveRatio = getValue("save_ratio");
	var saveRatioActive = getValue("save_ratio.active");
	var saveRatioParent = getValue("save_ratio.parent");
	// assign object to chosen environment
	if(saveRatioActive) {
		echo(".GlobalEnv$" + saveRatio + " <- svyratio_result\n");
	}

}

