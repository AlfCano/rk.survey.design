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
    var lonely_psu = getValue("lonely_psu_cbox7");
    if (lonely_psu == "1") {
        echo("options(survey.lonely.psu=\"adjust\")\n\n");
    }
    var use_subset = getValue("subset_cbox7");
    var subset_expr = getValue("subset_input7");
    var svy_obj = getValue("svydesign_object7");
    var final_svy_obj = svy_obj;
    if (use_subset == "1" && subset_expr) {
        echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\n");
        final_svy_obj = "svy_subset";
    }
    var row_str = getValue("row_var");
    var col_str = getValue("col_var");
    var save_name = getValue("save_table.objectname");
    var clean_row = getColumnName(row_str);
    var clean_col = getColumnName(col_str);
    var formula = "~" + clean_row;
    if (clean_col) {
        formula += " + " + clean_col;
    }
    echo("svytable_result <- svytable(" + formula + ", " + final_svy_obj + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey Table")).print();
{
      echo("rk.results(svytable_result)\n");
    }
  
	//// save result object
	// read in saveobject variables
	var saveTable = getValue("save_table");
	var saveTableActive = getValue("save_table.active");
	var saveTableParent = getValue("save_table.parent");
	// assign object to chosen environment
	if(saveTableActive) {
		echo(".GlobalEnv$" + saveTable + " <- svytable_result\n");
	}

}

