// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(survey)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
var s=getValue("svydesign_object6");echo("svy_subset<-subset("+s+",subset="+getValue("subset_input6")+")\nfor(col_name in names(svy_subset$variables)){\ntry({\nattr(svy_subset$variables[[col_name]],\".rk.meta\")<-attr("+s+"$variables[[col_name]],\".rk.meta\")\n},silent=TRUE)\n}\n");
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Subset Survey Object results")).print();
if(getValue("save_subset")=="1"){echo("rk.header(\"Survey subset object saved as: "+getValue("save_subset.objectname")+"\")\n");}
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

