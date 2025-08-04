// La función preprocess() ha sido eliminada por ser redundante.
// El componente <saveobject> en el XML ahora se encarga de toda la validación.

function calculate() {
    // Obtenemos los nombres completos de las variables
    var weight_var_full = getValue("weight_var");
    var strata_var_full = getValue("strata_var");
    var id_var_full = getValue("id_var");
    var dataframe = weight_var_full.split(/\[\[|\\$/)[0];

    // Función para obtener solo el nombre de la columna
    function getColumnName(fullName) {
        if (!fullName) return "";
        if (fullName.indexOf("[[") > -1) {
            return fullName.match(/\[\["(.*?)"\]\]/)[1];
        } else if (fullName.indexOf("$") > -1) {
            return fullName.substring(fullName.lastIndexOf("$") + 1);
        } else {
            return fullName;
        }
    }

    var weight_col = getColumnName(weight_var_full);
    var strata_col = getColumnName(strata_var_full);
    var id_col = getColumnName(id_var_full);

    // Obtenemos los valores de salida desde las propiedades del 'saveobject'
    var object_name = getValue("save_survey.objectname");
    var workplace = getValue("save_survey.workplace");

    // Red de seguridad final para el 'workplace'
    if (!workplace) {
        workplace = ".GlobalEnv";
    }

    var options = new Array();

    // Construimos los argumentos para svydesign
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
    
    echo('require(survey)\n\n');

    // Construimos la línea de código final
    var full_object_name = workplace + '$' + object_name;
    echo(full_object_name + ' <- svydesign(' + options.join(', ') + ')\n\n');
    
    // Imprimimos un resumen del objeto creado
    echo('print("Resumen del objeto de diseño de encuesta creado:")\n');
    echo('print(' + full_object_name + ')\n');
}
