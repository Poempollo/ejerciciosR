# PIA - Primer Examen de R
# Javier Soria Alguacil
# 24/02/2026

# Cargamos la librería necesaria para leer archivos ODS (OpenDocument Spreadsheet)
library("readODS")

# Definimos la variable con la ruta del archivo que vamos a procesar
archivo_ods <- "IPCOct24.ods"

# --- EJERCICIO 1 --- 
# Enunciado: Cargar los datos en un dataframe, sin cabecera ni pie.

cargaDatos <- function(archivo) {
  # Leemos el archivo ODS especificando un rango que cubra todos los datos.
  # Ponemos col_names = FALSE para que NO use la primera fila encontrada como nombres de columna,
  # ya que queremos cargar los datos "brutos" y poner los nombres nosotros luego.
  datos <- read_ods(archivo, range = "A8:D300", col_names = FALSE)
  
  # Devolvemos el dataframe cargado
  return(datos)
}

# Llamamos a la función para obtener nuestros datos iniciales
datos <- cargaDatos(archivo_ods)

# Asignamos manualmente los nombres a las 4 columnas del dataframe
# "Grupo": Contendrá el nombre del grupo de consumo o el nombre de la Autonomía (cuando es cabecera)
names(datos) <- c("Grupo", "IPC", "Variacion_Mensual", "Variacion_Anual")

# Mostramos las primeras filas para verificar que se ha cargado bien
print(head(datos))


# --- EJERCICIO 2 ---
# Enunciado: Función que genere un dataframe con Autonomía e IPC de un grupo concreto.

ipcGrupo <- function(df, grupo_buscado) {
  
  # Inicializamos dos vectores vacíos donde iremos guardando los datos que nos interesan.
  # Uno para guardar el nombre de la autonomía y otro para el valor del IPC.
  columnas_autonomia <- c()
  columnas_ipc <- c()
  
  # Inicializamos una variable para "recordar" la autonomía actual mientras recorremos la tabla hacia abajo.
  # Empezamos con "Nacional" por si los primeros datos son nacionales.
  autonomia_actual <- "Nacional" 
  
  # Iniciamos un bucle que recorrerá el dataframe desde la fila 1 hasta la última (nrow(df))
  for (i in 1:nrow(df)) {
    
    # Comprobamos si la fila actual es un "Título de Autonomía".
    # En el archivo original, las filas que indican una nueva autonomía (ej: "01 Andalucía") 
    # tienen el dato del IPC vacío (NA).
    if (is.na(df$IPC[i])) {
      # Si es NA, significa que hemos cambiado de bloque de autonomía.
      # Actualizamos nuestra "memoria" con el nuevo nombre que está en la columna Grupo.
      autonomia_actual <- df$Grupo[i]
      
    } else {
      # Si el IPC NO está vacío, significa que estamos en una fila de datos de consumo.
      
      # Comprobamos si el nombre del grupo de esta fila coincide con el que nos piden por parámetro.
      if (df$Grupo[i] == grupo_buscado) {
        
        # Si coincide, guardamos en nuestros vectores:
        # 1. La autonomía que tenemos "activa" en memoria.
        columnas_autonomia <- c(columnas_autonomia, autonomia_actual)
        # 2. El valor del IPC de esta fila.
        columnas_ipc <- c(columnas_ipc, df$IPC[i])
      }
    }
  }
  
  # Una vez terminado el bucle, creamos un nuevo dataframe uniendo los dos vectores.
  resultado <- data.frame(
    Autonomia = columnas_autonomia,
    IPC = columnas_ipc
  )
  
  # Limpiamos el texto de la columna Autonomía.
  # Usamos gsub con la expresión regular "[[:digit:]]" para borrar cualquier número.
  # Así "01 Andalucía" se convierte en " Andalucía".
  resultado$Autonomia <- gsub("[[:digit:]]", "", resultado$Autonomia)
  
  # Devolvemos el dataframe limpio y filtrado
  return(resultado)
}

# Ejecutamos la función buscando el grupo "03 Vestido y calzado" y mostramos el resultado
datos_grupo_vestido <- ipcGrupo(datos, "03 Vestido y calzado")
print(datos_grupo_vestido)


# --- EJERCICIO 3 ---
# Enunciado: Ranking de las autonomías según variación mensual de un grupo (mayor proyección de subida).

ranking <- function(df, grupo_buscado) {
  
  # Inicializamos vectores para guardar los resultados del ranking
  vec_autonomias <- c()
  vec_variacion <- c()
  
  # Variable auxiliar para recordar la autonomía mientras recorremos filas
  autonomia_actual <- "Nacional"
  
  # Recorremos todas las filas del dataframe original
  for (i in 1:nrow(df)) {
    
    # Si la celda de IPC es NA, es que estamos ante un encabezado de Autonomía.
    # Actualizamos la variable auxiliar.
    if (is.na(df$IPC[i])) {
      autonomia_actual <- df$Grupo[i]
      
    # Si no es encabezado, miramos si es el grupo que nos interesa clasificar.
    } else if (df$Grupo[i] == grupo_buscado) {
      
      # Si coincide, guardamos la autonomía actual en el vector de nombres...
      vec_autonomias <- c(vec_autonomias, autonomia_actual)
      # ...y guardamos el valor de la Variación Mensual en el vector de datos.
      vec_variacion <- c(vec_variacion, df$Variacion_Mensual[i])
    }
  }
  
  # Creamos el dataframe con los datos extraídos
  df_ranking <- data.frame(
    Autonomia = vec_autonomias,
    # Convertimos la variación a numérico por si R la leyó como texto.
    # gsub cambia comas por puntos (formato decimal inglés que usa R).
    Variacion = as.numeric(gsub(",", ".", vec_variacion)) 
  )
  
  # Calculamos el orden de los índices basándonos en la columna Variacion.
  # decreasing = TRUE significa que queremos los valores más altos primero.
  orden <- order(df_ranking$Variacion, decreasing = TRUE)
  
  # Reordenamos las filas del dataframe usando el índice calculado
  df_ranking <- df_ranking[orden, ]
  
  # Limpiamos el nombre de la autonomía quitando los números (ej. "02 Aragón" -> " Aragón")
  df_ranking$Autonomia <- gsub("[[:digit:]]", "", df_ranking$Autonomia)
  
  # Devolvemos el ranking ordenado
  return(df_ranking)
}

# Ejecutamos la función para "04 Vivienda..." y mostramos el resultado
datos_ranking <- ranking(datos, "04 Vivienda, agua, electricidad, gas y otros combustibles")
print(datos_ranking)


# --- EJERCICIO 4 ---
# Enunciado: Construir un dataframe con el grupo con mayor "Variación en lo que va de Año" para cada autonomía.

mayorVariacionAnual <- function(df) {
  
  # Como necesitamos procesar datos por autonomía, primero vamos a crear una versión del dataframe
  # que tenga una columna explícita con la Autonomía en cada fila.
  df_trabajo <- df
  df_trabajo$Autonomia_Asignada <- NA # Creamos la columna vacía
  autonomia_actual <- "Nacional"      # Variable memoria
  
  # Bucle 1: Rellenar la columna Autonomia_Asignada en todas las filas
  for (i in 1:nrow(df_trabajo)) {
    # Si IPC es NA -> Es un título de sección -> Actualizamos memoria
    if (is.na(df_trabajo$IPC[i])) {
      autonomia_actual <- df_trabajo$Grupo[i]
    } else {
      # Si tiene datos -> Le asignamos la autonomía de la memoria
      df_trabajo$Autonomia_Asignada[i] <- autonomia_actual
    }
  }
  
  # Limpieza previa:
  # 1. Quitamos las filas que tienen IPC nulo (los títulos de las secciones), ya obtuvimos su info.
  df_trabajo <- df_trabajo[!is.na(df_trabajo$IPC), ] 
  # 2. Quitamos el grupo "Índice general" porque suele ser un promedio y falsearía el resultado del "grupo máximo".
  df_trabajo <- df_trabajo[df_trabajo$Grupo != "Índice general", ] 
  
  # Aseguramos que la columna Variación Anual sea numérica (cambiando coma por punto si hace falta)
  df_trabajo$Variacion_Anual <- as.numeric(gsub(",", ".", df_trabajo$Variacion_Anual))
  
  # Obtenemos la lista única de autonomías que existen en los datos
  autonomias_unicas <- unique(df_trabajo$Autonomia_Asignada)
  
  # Inicializamos un dataframe vacío donde iremos acumulando los ganadores
  tabla_final <- data.frame()
  
  # Bucle 2: Para cada autonomía, buscar su máximo
  for (aut in autonomias_unicas) {
    
    # Filtramos el dataframe grande para quedarnos SOLAMENTE con las filas de esta autonomía actual
    sub_df <- df_trabajo[df_trabajo$Autonomia_Asignada == aut, ]
    
    # Buscamos la posición (índice) donde está el valor máximo de Variación Anual
    pos_max <- which.max(sub_df$Variacion_Anual)
    
    # Extraemos esa fila completa ganadora
    fila_max <- sub_df[pos_max, ]
    
    # Añadimos (pegamos por debajo) esta fila ganadora a nuestra tabla final.
    # Construimos un pequeño dataframe de 1 fila con los datos limpios.
    tabla_final <- rbind(tabla_final, data.frame(
      Autonomia = aut,
      Grupo = fila_max$Grupo,
      Variacion_Anual = fila_max$Variacion_Anual
    ))
  }
  
  # Limpiamos los nombres de las autonomías en el resultado final (quitar dígitos)
  tabla_final$Autonomia <- gsub("[[:digit:]]", "", tabla_final$Autonomia)
  
  # Devolvemos la tabla resumen
  return(tabla_final)
}

# Ejecutamos la función y mostramos el resultado
resultado_final <- mayorVariacionAnual(datos)
print(resultado_final)
