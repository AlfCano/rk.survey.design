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
    var lonely_psu = getValue("lonely_psu_cbox8");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\"adjust\")\n\n");
    }
    var use_subset = getValue("subset_cbox8");
    var subset_expr = getValue("subset_input8");
    var svy_obj = getValue("svydesign_object8");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\n");
        final_svy_obj = "svy_subset";
    }
    var var1_str = getValue("var1_chisq");
    var var2_str = getValue("var2_chisq");
    var save_name = getValue("save_chisq.objectname");
    var clean_var1 = getColumnName(var1_str);
    var clean_var2 = getColumnName(var2_str);
    var formula = "~" + clean_var1 + " + " + clean_var2;
    echo("svychisq_result <- svychisq(" + formula + ", " + final_svy_obj + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey Chi-squared Test")).print();
{
      echo("rk.print(svychisq_result)\n");
      echo("rk.print(summary(svychisq_result))\n");
      echo("rk.header(paste0(\"Expected: \"), level=3)\n");
      echo("rk.results(svychisq_result$expected)\n");
      echo("rk.header(paste0(\"Observed: \"), level=3)\n");
      echo("rk.results(svychisq_result$observed)\n");
      echo("rk.header(paste0(\"Residuals: \"), level=3)\n");
      echo("rk.results(svychisq_result$residuals)\n");
      echo("rk.header(paste0(\"Standar residuals: \"), level=3)\n");
      echo("rk.results(svychisq_result$stdres)\n");
    }
  
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

