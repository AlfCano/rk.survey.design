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
   var f=preprocessSurveyOptions("lonely_psu_cbox3","subset_cbox3","subset_input3",getValue("svydesign_object3"));var b="~"+getColumnName(getValue("analysis_var3"));echo("svyquantile_result <- svyquantile("+b+", "+f+", quantiles=c("+getValue("quantiles_input")+"))\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey Quantiles")).print();
echo("result_name<-names(svyquantile_result)\nfor(e in result_name){\nrk.header(paste0(\"Quantiles for variable: \",e),level=3)\nsvyquantile_result[[e]]|>as.data.frame()|>rk.results()\n}\n");
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

