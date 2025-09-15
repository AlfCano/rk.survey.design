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
    var lonely_psu = getValue("lonely_psu_cbox1");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\"adjust\")\n\n");
    }

    var use_subset = getValue("subset_cbox1");
    var subset_expr = getValue("subset_input1");
    var svy_obj = getValue("svydesign_object1");
    var final_svy_obj = svy_obj;

    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\n");
        final_svy_obj = "svy_subset";
    }

    var analysis_vars_str = getValue("analysis_vars1");
    var func = getValue("mean_total_func");
    var vars_array = analysis_vars_str.split(/\s+/).filter(function(n){ return n != "" });
    var clean_vars_array = vars_array.map(getColumnName);
    var formula = "~" + clean_vars_array.join(" + ");
    echo("svystat_result <- " + func + "(" + formula + ", " + final_svy_obj + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey svystat results")).print();
{
      echo("svystat_result |> as.data.frame() |> rk.results()\n");
    }
  
	//// save result object
	// read in saveobject variables
	var saveMeanTotal = getValue("save_mean_total");
	var saveMeanTotalActive = getValue("save_mean_total.active");
	var saveMeanTotalParent = getValue("save_mean_total.parent");
	// assign object to chosen environment
	if(saveMeanTotalActive) {
		echo(".GlobalEnv$" + saveMeanTotal + " <- svystat_result\n");
	}

}

