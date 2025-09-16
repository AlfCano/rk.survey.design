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
    var lonely_psu = getValue("lonely_psu_cbox4");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\"adjust\")\n\n");
    }
    var use_subset = getValue("subset_cbox4");
    var subset_expr = getValue("subset_input4");
    var svy_obj = getValue("svydesign_object4");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\n");
        final_svy_obj = "svy_subset";
    }
    var numerator_str = getValue("numerator_var");
    var denominator_str = getValue("denominator_var");
    var save_name = getValue("save_ratio.objectname");
    var clean_num = getColumnName(numerator_str);
    var clean_den = getColumnName(denominator_str);
    var num_formula = "~" + clean_num;
    var den_formula = "~" + clean_den;
    echo("svyratio_result <- svyratio(" + num_formula + ", " + den_formula + ", " + final_svy_obj + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey Ratio")).print();
{
      var save_name = getValue("save_ratio.objectname");
      echo("result_name <- names(svyratio_result)\n");
      echo("for(e in result_name){\n");
      echo("rk.header(paste0(\"Result: \", e), level=3)\n");
      echo("svyratio_result[[e]] |> as.data.frame () |> rk.results()\n");
      echo("}\n");
    }
  
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

