# Script autocontenido para generar el plugin 'rk.survey.design' limpio, sin línea basura
# `.GlobalEnv$Grdrbjtd.obj <- Grdrbjtd.obj` y sin encabezado duplicado.

local({
  # =========================================================================================
  # SECCIÓN DE PREPARACIÓN
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  output.dir <- "."
  overwrite <- TRUE
  guess.getter <- FALSE
  rk.set.indent(by = "\t")

  # =========================================================================================
  # SECCIÓN DE DEFINICIÓN DEL PLUGIN
  # =========================================================================================

  # --- METADATOS (Información "About") ---
  aboutPlugin <- rk.XML.about(
    name = "rk.survey.design",
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "Plugin para el diseño de encuestas complejas",
      version = "0.2.8",
      url = "https://github.com/AlfCano/rk.survey.design",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # INFORMACIÓN DE AYUDA EN LISTA SIMPLE (MODIFICABLE POR EL USUARIO)
  # =========================================================================================
  plugin_help <- list(
    summary = "Crea un objeto de diseño de encuesta (survey design) utilizando el paquete \"survey\". Este objeto es fundamental para realizar análisis de encuestas complejas.",
    usage = "1. Seleccione el data.frame que contiene los datos de la encuesta en la pestaña \"Configuración del Diseño\".\n2. Especifique la variable de Peso (obligatoria), opcionalmente las variables de Estrato e ID, y si los clusters están anidados.\n3. En la pestaña \"Opciones de Salida\", asigne un nombre al objeto de R que se creará.\n4. Ejecute el análisis. Se generará un objeto 'svydesign' en su entorno de trabajo.",
    title = "rk Survey Design",
    sections = list(
      list(
        title = "Configuración del Diseño",
        text = "Define las variables para el diseño de la encuesta."
      ),
      list(
        title = "Opciones de Salida",
        text = "Selecciona dónde y con qué nombre guardar el objeto de diseño."
      )
    )
  )

  # =========================================================================================
  # TRADUCCIÓN DE LA LISTA DE AYUDA A XiMpLe.node (REGLA DE ORO)
  # =========================================================================================
  help_sections <- lapply(plugin_help$sections, function(x) {
    rk.rkh.section(title = x$title, text = x$text, short = x$title)
  })

  help_document <- rk.rkh.doc(
    summary = rk.rkh.summary(text = plugin_help$summary),
    usage = rk.rkh.usage(text = plugin_help$usage),
    sections = help_sections,
    title = rk.rkh.title(text = plugin_help$title)
  )

  # =========================================================================================
  # DEFINICIÓN DEL JAVASCRIPT (LIMPIO: Sin línea basura ni encabezado duplicado)
  # =========================================================================================
  js_calculate_code <- "
    // Obtenemos los nombres completos de las variables
    var weight_var_full = getValue(\"weight_var\");
    var strata_var_full = getValue(\"strata_var\");
    var id_var_full = getValue(\"id_var\");
    var dataframe = weight_var_full.split(/\\[\\[|\\\\$/)[0];
    var nest_option = getValue(\"nest_cbox\");

    function getColumnName(fullName) {
        if (!fullName) return \"\";
        if (fullName.indexOf(\"[[\") > -1) {
            return fullName.match(/\\[\\[\\\"(.*?)\\\"\\]\\]/)[1];
        } else if (fullName.indexOf(\"$\") > -1) {
            return fullName.substring(fullName.lastIndexOf(\"$\") + 1);
        } else {
            return fullName;
        }
    }

    var weight_col = getColumnName(weight_var_full);
    var strata_col = getColumnName(strata_var_full);
    var id_col = getColumnName(id_var_full);

    var options = new Array();

    if (id_col) {
        options.push(\"ids = ~\" + id_col);
    } else {
        options.push(\"ids = ~1\");
    }
    if (strata_col) {
        options.push(\"strata = ~\" + strata_col);
    }
    options.push(\"weights = ~\" + weight_col);
    options.push(\"data = \" + dataframe);

    // Manejo robusto de la casilla nest_cbox
    if(nest_option == \"1\" || nest_option == 1 || nest_option == \"true\" || nest_option === true){
        options.push(\"nest=TRUE\");
    }

    // Se crea el objeto con un nombre temporal y fijo.
    echo('result <- svydesign(' + options.join(', ') + ')\\n');
  "

  # =========================================================================================
  # DEFINICIÓN DEL DIÁLOGO (XML) - SÓLO SE USA LA SINTAXIS COMPATIBLE
  # =========================================================================================
  dataframe_selector <- rk.XML.varselector(id.name = "dataframe", label = "Datos (data.frame)")
  attr(dataframe_selector, "required") <- "1"
  attr(dataframe_selector, "classes") <- "data.frame"

  weight_varslot <- rk.XML.varslot(id.name = "weight_var", label = "Variable de Peso", source = "dataframe")
  attr(weight_varslot, "required") <- "1"

  strata_varslot <- rk.XML.varslot(id.name = "strata_var", label = "Variable de Estrato (opcional)", source = "dataframe")
  attr(strata_varslot, "required") <- "0"

  id_varslot <- rk.XML.varslot(id.name = "id_var", label = "Variable de ID (opcional)", source = "dataframe")
  attr(id_varslot, "required") <- "0"

  nest_checkbox <- rk.XML.cbox(label="Anidar clusters en estratos (nest=TRUE)", id.name="nest_cbox")

  save_survey_object <- rk.XML.saveobj(
  label = "Guardar objeto de diseño",
  chk = TRUE,
  checkable = TRUE,
  initial = "result",
  required = FALSE,
  id.name = "save_survey")


  dialog.content <- rk.XML.dialog(
    label = "Crear Diseño de Encuesta Compleja",
    child = rk.XML.tabbook(
      tabs = list(
        "Configuración del Diseño" = rk.XML.row(
            dataframe_selector,
            rk.XML.col(
            rk.XML.col(
            weight_varslot,
            strata_varslot,
            id_varslot,
            nest_checkbox)
          )
        ),
        "Opciones de Salida" = rk.XML.row(
          rk.XML.col(
            save_survey_object
          )
        )
      )
    )
  )

  # =========================================================================================
  # SECCIÓN DE CREACIÓN DEL PLUGIN (LLAMADA PRINCIPAL)
  # =========================================================================================
  plugin.dir <- rk.plugin.skeleton(
    about = aboutPlugin,
    path = output.dir,
    guess.getter = guess.getter,
    xml = list(
      dialog = dialog.content
    ),
    js = list(
      require = "survey",
      calculate = js_calculate_code
    ),
    rkh = list(
      help = help_document
    ),
    pluginmap = list(
      name = "rk.survey.design",
      hierarchy = list("Survey", "Create Survey Design"),
      po_id = "rk.survey.design"
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    overwrite = overwrite,
    load = TRUE,
    show = TRUE
  )

  message("¡Archivos del plugin '", aboutPlugin@name, "' generados con éxito en '", plugin.dir, "'!")
  message("SIGUIENTE PASO: Abra RKWard, navegue a esta carpeta y ejecute los comandos de compilación e instalación.")
})
