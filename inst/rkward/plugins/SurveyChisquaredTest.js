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
   var f=preprocessSurveyOptions("lonely_psu_cbox8","subset_cbox8","subset_input8",getValue("svydesign_object8"));var b="~"+getColumnName(getValue("var1_chisq"))+" + "+getColumnName(getValue("var2_chisq"));echo("svychisq_result<-svychisq("+b+", "+f+")\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey Chi-squared Test")).print();
echo("rk.print(svychisq_result)\n");echo("rk.print(summary(svychisq_result))\n");echo("rk.header(\"Expected:\",level=3);rk.results(svychisq_result$expected)\n");echo("rk.header(\"Observed:\",level=3);rk.results(svychisq_result$observed)\n");echo("rk.header(\"Residuals:\",level=3);rk.results(svychisq_result$residuals)\n");echo("rk.header(\"Standardized Residuals:\",level=3);rk.results(svychisq_result$stdres)\n");
	//// save result object
	// read in saveobject variables
	var saveChisq = getValue("save_chisq");
	var saveChisqActive = getValue("save_chisq.active");
	var saveChisqParent = getValue("save_chisq.parent");
	// assign object to chosen environment
	if(saveChisqActive) {
		echo(".GlobalEnv$" + saveChisq + " <- svychisq_result\n");
	}

}

