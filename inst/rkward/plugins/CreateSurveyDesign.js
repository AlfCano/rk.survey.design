// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(survey)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    // Get values from UI
    var dataframe = getValue("dataframe_object");
    var id_var_full = getValue("id_var");
    var probs_var_full = getValue("probs_var");
    var strata_var_full = getValue("strata_var");
    var fpc_var_full = getValue("fpc_var");
    var weight_var_full = getValue("weight_var");
    var nest_option = getValue("nest_cbox");
    var check_strata_option = getValue("check_strata_cbox");
    var pps_option = getValue("pps_input");
    var variance_option = getValue("variance_pps");
    var calibrate_formula = getValue("calibrate_formula_input");
    var dbtype_val = getValue("dbtype_input");
    var dbname_val = getValue("dbname_input");

    // Helper function to extract column name from full object path
    function getColumnName(fullName) {
        if (!fullName) return "";
        if (fullName.indexOf("[[") > -1) { return fullName.match(/\[\[\"(.*?)\"\]\]/)[1]; }
        else if (fullName.indexOf("$") > -1) { return fullName.substring(fullName.lastIndexOf("$") + 1); }
        else { return fullName; }
    }

    // Clean the column names
    var id_col = getColumnName(id_var_full);
    var probs_col = getColumnName(probs_var_full);
    var strata_col = getColumnName(strata_var_full);
    var fpc_col = getColumnName(fpc_var_full);
    var weight_col = getColumnName(weight_var_full);

    // Build the options array for the svydesign call
    var options = new Array();

    if (id_col) { options.push("ids = ~" + id_col); } else { options.push("ids = ~1"); }
    if (probs_col) { options.push("probs = ~" + probs_col); }
    if (strata_col) { options.push("strata = ~" + strata_col); }
    if (fpc_col) { options.push("fpc = ~" + fpc_col); }
    if (weight_col) { options.push("weights = ~" + weight_col); }
    if (calibrate_formula) { options.push("calibrate.formula = " + calibrate_formula); }

    options.push("data = " + dataframe);

    if (nest_option == "1"){ options.push("nest=TRUE"); }
    if (check_strata_option == "1"){ options.push("check.strata=TRUE"); }

    if (pps_option) {
        options.push("pps = " + pps_option);
    }
    if (variance_option) {
        options.push("variance = \"" + variance_option + "\"");
    }

    if (dbtype_val) { options.push("dbtype = \"" + dbtype_val + "\""); }
    if (dbname_val) { options.push("dbname = \"" + dbname_val + "\""); }

    echo('survey.design <- svydesign(' + options.join(', ') + ')\n');
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Create Survey Design results")).print();
{
        var save_name = getValue("save_survey.objectname");
        var header_cmd = "rk.header(\"Survey design object saved as: " + save_name + "\");\n";
        echo(header_cmd);
    }
  
	//// save result object
	// read in saveobject variables
	var saveSurvey = getValue("save_survey");
	var saveSurveyActive = getValue("save_survey.active");
	var saveSurveyParent = getValue("save_survey.parent");
	// assign object to chosen environment
	if(saveSurveyActive) {
		echo(".GlobalEnv$" + saveSurvey + " <- survey.design\n");
	}

}

