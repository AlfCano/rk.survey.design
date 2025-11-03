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
   
      var by_options = [];
      if (getValue("by_keep_var_cbox") != "1") { by_options.push("keep.var=FALSE"); }
      if (getValue("by_keep_names_cbox") != "1") { by_options.push("keep.names=FALSE"); }
      if (getValue("by_verbose_cbox") == "1") { by_options.push("verbose=TRUE"); }
      if (getValue("by_drop_empty_cbox") != "1") { by_options.push("drop.empty.groups=FALSE"); }
      if (getValue("by_na_rm_by_cbox") != "1") { by_options.push("na.rm.by=FALSE"); }
      if (getValue("by_na_rm_all_cbox") == "1") { by_options.push("na.rm.all=TRUE"); }
      if (getValue("by_covmat_cbox") == "1") { by_options.push("covmat=TRUE"); }
      if (getValue("by_replicates_cbox") == "1") { by_options.push("return.replicates=TRUE"); }
      if (getValue("by_influence_cbox") == "1") { by_options.push("influence=TRUE"); }
      if (getValue("by_multicore_cbox") == "1") { by_options.push("multicore=TRUE"); }
      if (getValue("by_strings_cbox") == "1") { by_options.push("stringsAsFactors=TRUE"); }
      
      var vartypes = [];
      if (getValue("by_vartype_se_cbox") == "1") { vartypes.push("\"se\""); }
      if (getValue("by_vartype_ci_cbox") == "1") { vartypes.push("\"ci\""); }
      if (getValue("by_vartype_var_cbox") == "1") { vartypes.push("\"variance\""); }
      if (getValue("by_vartype_cv_cbox") == "1") { vartypes.push("\"cv\""); }
      if (vartypes.length > 0 && vartypes.length < 4) { by_options.push("vartype = c(" + vartypes.join(", ") + ")"); }

      if (getValue("by_parm_input")) { by_options.push("parm = " + getValue("by_parm_input")); }
      if (getValue("by_level_spin") != "0.95") { by_options.push("level = " + getValue("by_level_spin")); }
      if (getValue("by_df_input")) { by_options.push("df = " + getValue("by_df_input")); }

      var f=preprocessSurveyOptions("lonely_psu_cbox2","subset_cbox2","subset_input2",getValue("svydesign_object2"));
      var a=getValue("analysis_vars2").split(/\n/).filter(function(n){return n!=""});
      var b="~"+a.map(getColumnName).join(" + ");
      var c=getValue("by_vars").split(/\n/).filter(function(n){return n!=""});
      var d="~"+c.map(getColumnName).join(" + ");
      var final_opts = by_options.length > 0 ? ", " + by_options.join(", ") : "";

      echo("svyby_result <- svyby(" + b + ", " + d + ", " + f + ", " + getValue("by_func") + final_opts + ")\n");
    
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Survey by results")).print();
echo("rk.header(\"Survey by saved as: "+getValue("save_by.objectname")+"\",level=3)\n");echo("svyby_result|>as.data.frame()|>rk.results(print.rownames=FALSE)\n");
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

