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
    var lonely_psu = getValue("lonely_psu_cbox2");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\"adjust\")\n\n");
    }
    var use_subset = getValue("subset_cbox2");
    var subset_expr = getValue("subset_input2");
    var svy_obj = getValue("svydesign_object2");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\n");
        final_svy_obj = "svy_subset";
    }
    var analysis_vars_str = getValue("analysis_vars2");
    var by_vars_str = getValue("by_vars");
    var func = getValue("by_func");
    var save_name = getValue("save_by.objectname");
    var analysis_vars_array = analysis_vars_str.split(/\s+/).filter(function(n){ return n != "" });
    var clean_analysis_vars = analysis_vars_array.map(getColumnName);
    var formula = "~" + clean_analysis_vars.join(" + ");
    var by_vars_array = by_vars_str.split(/\s+/).filter(function(n){ return n != "" });
    var clean_by_vars = by_vars_array.map(getColumnName);
    var by_formula = "~" + clean_by_vars.join(" + ");
    echo(save_name + " <- svyby(" + formula + ", " + by_formula + ", " + final_svy_obj + ", " + func + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey by results")).print();
{
      echo("svyby_result |> as.data.frame() |> rk.results(print.rownames=FALSE)\n");
    }
  
	//// save result object
	// read in saveobject variables
	var saveBy = getValue("save_by");
	var saveByActive = getValue("save_by.active");
	var saveByParent = getValue("save_by.parent");
	// assign object to chosen environment
	if(saveByActive) {
		echo(".GlobalEnv$" + saveBy + " <- svyby_result\n");
	}

}

