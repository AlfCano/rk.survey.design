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
    var lonely_psu = getValue("lonely_psu_cbox3");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\"adjust\")\n\n");
    }
    var use_subset = getValue("subset_cbox3");
    var subset_expr = getValue("subset_input3");
    var svy_obj = getValue("svydesign_object3");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\n");
        final_svy_obj = "svy_subset";
    }
    var analysis_var_str = getValue("analysis_var3");
    var quantiles_str = getValue("quantiles_input");
    var save_name = getValue("save_quantile.objectname");
    var clean_var = getColumnName(analysis_var_str);
    var formula = "~" + clean_var;
    echo("svyquantile_result <- svyquantile(" + formula + ", " + final_svy_obj + ", quantiles=c(" + quantiles_str + "))\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey Quantiles")).print();
{
      echo("result_name <- names(svyquantile_result)\n");
      echo("for(e in result_name){\n");
      echo("rk.header(paste0(\"Quantiles for variable: \", e), level=3)\n");
      echo("svyquantile_result[[e]] |> as.data.frame () |> rk.results()\n");
      echo("}\n");
    }
  
	//// save result object
	// read in saveobject variables
	var saveQuantile = getValue("save_quantile");
	var saveQuantileActive = getValue("save_quantile.active");
	var saveQuantileParent = getValue("save_quantile.parent");
	// assign object to chosen environment
	if(saveQuantileActive) {
		echo(".GlobalEnv$" + saveQuantile + " <- svyquantile_result\n");
	}

}

