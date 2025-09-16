// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(survey)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var subset_expr = getValue("subset_input6");
    var svy_obj = getValue("svydesign_object6");
    var save_name = getValue("save_subset.objectname");
    echo("svy_subset <- subset(" + svy_obj + ", subset = " + subset_expr + ")\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Subset Survey Object results")).print();

    if(getValue("save_subset") == "1"){
        var save_name = getValue("save_subset.objectname");
        var header_cmd = "rk.header(\"Survey subset object saved as: " + save_name + "\");\n";
        echo(header_cmd);
    }
  
	//// save result object
	// read in saveobject variables
	var saveSubset = getValue("save_subset");
	var saveSubsetActive = getValue("save_subset.active");
	var saveSubsetParent = getValue("save_subset.parent");
	// assign object to chosen environment
	if(saveSubsetActive) {
		echo(".GlobalEnv$" + saveSubset + " <- svy_subset\n");
	}

}

