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
   var f=preprocessSurveyOptions("lonely_psu_cbox7","subset_cbox7","subset_input7",getValue("svydesign_object7"));var b="~"+getColumnName(getValue("row_var"));if(getValue("col_var")){b+=" + "+getColumnName(getValue("col_var"));}echo("svytable_result<-svytable("+b+", "+f+")\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey Table")).print();
echo("rk.results(svytable_result)\n");
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

