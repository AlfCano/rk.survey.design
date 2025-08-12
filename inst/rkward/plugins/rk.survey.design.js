// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(survey)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    // Obtenemos los nombres completos de las variables
    var weight_var_full = getValue("weight_var");
    var strata_var_full = getValue("strata_var");
    var id_var_full = getValue("id_var");
    var dataframe = weight_var_full.split(/\[\[|\\$/)[0];
    var nest_option = getValue("nest_cbox");

    function getColumnName(fullName) {
        if (!fullName) return "";
        if (fullName.indexOf("[[") > -1) {
            return fullName.match(/\[\[\"(.*?)\"\]\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }

    var weight_col = getColumnName(weight_var_full);
    var strata_col = getColumnName(strata_var_full);
    var id_col = getColumnName(id_var_full);

    var options = new Array();

    if (id_col) {
        options.push("ids = ~" + id_col);
    } else {
        options.push("ids = ~1");
    }
    if (strata_col) {
        options.push("strata = ~" + strata_col);
    }
    options.push("weights = ~" + weight_col);
    options.push("data = " + dataframe);

    // Manejo robusto de la casilla nest_cbox
    if(nest_option == "1" || nest_option == 1 || nest_option == "true" || nest_option === true){
        options.push("nest=TRUE");
    }

    // Se crea el objeto con un nombre temporal y fijo.
    echo('result <- svydesign(' + options.join(', ') + ')\n');
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("rk.survey.design results")).print();

	//// save result object
	// read in saveobject variables
	var saveSurvey = getValue("save_survey");
	var saveSurveyActive = getValue("save_survey.active");
	var saveSurveyParent = getValue("save_survey.parent");
	// assign object to chosen environment
	if(saveSurveyActive) {
		echo(".GlobalEnv$" + saveSurvey + " <- result\n");
	}

}

