// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(survey)){stop(" + i18n("Preview not available, because package survey is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(survey)\n");
	}	if(is_preview) {
		echo("if(!base::require(dplyr)){stop(" + i18n("Preview not available, because package dplyr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(dplyr)\n");
	}	if(is_preview) {
		echo("if(!base::require(ggplot2)){stop(" + i18n("Preview not available, because package ggplot2 is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(ggplot2)\n");
	}	if(is_preview) {
		echo("if(!base::require(tidyr)){stop(" + i18n("Preview not available, because package tidyr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(tidyr)\n");
	}	if(is_preview) {
		echo("if(!base::require(forcats)){stop(" + i18n("Preview not available, because package forcats is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(forcats)\n");
	}	if(is_preview) {
		echo("if(!base::require(stringr)){stop(" + i18n("Preview not available, because package stringr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(stringr)\n");
	}	if(is_preview) {
		echo("if(!base::require(RColorBrewer)){stop(" + i18n("Preview not available, because package RColorBrewer is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(RColorBrewer)\n");
	}
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
   
    var svyby_obj = getValue("svyby_object");
    if(!svyby_obj) return;
    var xaxis_clean = getColumnName(getValue("xaxis_var"));
    var estimate_vars_full = getValue("estimate_vars");
    var se_vars_full = getValue("se_vars");
    var prefix_clean = getValue("prefix_clean_input");
    var facet_var_full = getValue("facet_var");
    var conf_level = getValue("conf_level") / 100;
    
    echo("ci_multiplier <- qnorm(1 - (1 - " + conf_level + ") / 2)\n");

    var estimate_array = estimate_vars_full.split(/\n/).filter(function(n){ return n != "" }).map(function(item) { return "\"" + getColumnName(item) + "\""; });
    var se_array = se_vars_full.split(/\n/).filter(function(n){ return n != "" }).map(function(item) { return "\"" + getColumnName(item) + "\""; });
    
    var by_vars = new Array();
    by_vars.push("\"" + xaxis_clean + "\"");
    by_vars.push("\"respuesta\"");
    var facet_clean = "";
    if(facet_var_full){
      facet_clean = getColumnName(facet_var_full);
      by_vars.push("\"" + facet_clean + "\"");
    }

    echo("est <- " + svyby_obj + "\n");
    echo("piv1 <- tidyr::pivot_longer(est, cols=dplyr::all_of(c(" + estimate_array.join(",") + ")), names_to = \"respuesta\", values_to = \"recuento\")\n");
    echo("piv2 <- tidyr::pivot_longer(est, cols=dplyr::all_of(c(" + se_array.join(",") + ")), names_to = \"variable\", values_to = \"se\")\n");
    echo("piv2 <- dplyr::mutate(piv2, respuesta = stringr::str_remove(variable, \"^se\\\\.\"))\n");
    echo("piv3 <- dplyr::left_join(piv1, piv2, by = c(" + by_vars.join(", ") + "))\n");
    
    if(prefix_clean){
      echo("piv3[[\"respuesta\"]] <- gsub(\"" + prefix_clean + "\", \"\", piv3[[\"respuesta\"]] )\n");
    }
    echo("piv3[[\"respuesta\"]] <- forcats::fct_rev(piv3[[\"respuesta\"]] )\n");
    
    echo("p <- ggplot2::ggplot(piv3, ggplot2::aes(x = " + xaxis_clean + ", y = recuento, color = respuesta, group = respuesta)) +\n");
    echo("  ggplot2::geom_line() +\n");
    echo("  ggplot2::geom_errorbar(ggplot2::aes(ymin = recuento - ci_multiplier*se, ymax = recuento + ci_multiplier*se), width = 0.2) +\n");
    echo("  ggplot2::scale_color_brewer(palette = \"" + getValue("palette_input") + "\", labels = function(x) stringr::str_wrap(x, width = 20)) +\n");
    
    var labs_list = new Array();
    var title = getValue("title_input");
    if(title) { labs_list.push("title = \"" + title + "\""); }
    labs_list.push("x = \"" + getValue("xlab_input") + "\"");
    labs_list.push("y = \"" + getValue("ylab_input") + "\"");
    labs_list.push("color = \"" + getValue("colorlab_input") + "\"");
    labs_list.push("caption = \"" + getValue("caption_input") + "\"");
    echo("  ggplot2::labs(" + labs_list.join(", ") + ") +\n");
    
    echo("  ggplot2::theme_bw()\n");
    
    if(facet_var_full){
      var facet_layout = getValue("facet_layout");
      var facet_opts = "";
      if (facet_layout == "row") { facet_opts = ", nrow = 1"; }
      else if (facet_layout == "col") { facet_opts = ", ncol = 1"; }
      echo("p <- p + ggplot2::facet_wrap(~ " + facet_clean + facet_opts + ")\n");
    }
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Line Graph results")).print();	
	}
    if(!is_preview){
      echo("rk.graph.on()\n");
    }
    echo("try({\n");
    echo("  print(p)\n");
    echo("})\n");
    if(!is_preview){
      echo("rk.graph.off()\n");
    }
  

}

