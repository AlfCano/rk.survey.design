// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(survey)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var weight_var_full = getValue("weight_var");
    var strata_var_full = getValue("strata_var");
    var id_var_full = getValue("id_var");
    var dataframe = getValue("dataframe_object");
    var nest_option = getValue("nest_cbox");
    function getColumnName(fullName) {
        if (!fullName) return "";
        if (fullName.indexOf("[[") > -1) { return fullName.match(/\[\[\"(.*?)\"\]\]/)[1]; }
        else if (fullName.indexOf("$") > -1) { return fullName.substring(fullName.lastIndexOf("$") + 1); }
        else { return fullName; }
    }
    var weight_col = getColumnName(weight_var_full);
    var strata_col = getColumnName(strata_var_full);
    var id_col = getColumnName(id_var_full);
    var options = new Array();
    if (id_col) { options.push("ids = ~" + id_col); } else { options.push("ids = ~1"); }
    if (strata_col) { options.push("strata = ~" + strata_col); }
    if (weight_col) { options.push("weights = ~" + weight_col); }
    options.push("data = " + dataframe);
    if(nest_option == "1"){ options.push("nest=TRUE"); }
    echo('survey.design <- svydesign(' + options.join(', ') + ')\n');
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Create Survey Design results")).print();

    if(getValue("save_survey") == "1"){
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

