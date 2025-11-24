# APARTADO 3

install.packages("readr")
library(readr) # Llamamos la librería

setwd("C:/Users/Javi/Desktop/Programación/R/") # Establecemos el directorio de trabajo
getwd()

datos <- read.csv("69959.csv", sep=";") # Leemos el .csv, con sep=";" para que distinga varias columnas.
head(datos) # devuelve los 6 primeros valores, con head(datos, X), X serán las filas que se devuelvan

# APARTADO 4

datos <- datos[, -c(1)] 
# Para eliminar exactamente las columnas que queramos -c(1, 2, ...). Se puede con datos[, -1] todas menos la primera columna, o con datos$columna <- NULL

names(datos) <- tolower(names(datos)) #c cambiamos los titulos de cada columna names() que las selecciona, y las hacemos minuscula.

names(datos) <- gsub("\\..*", "", names(datos)) 
# "." significa todos los caracteres, con \\. seleccionamos solo los puntos. Además, .* significa todo lo que haya apartir de ahí, por eso \\..*
# sub() hace lo mismo, pero para el primer resultado.

names(datos) <- chartr("áéíóú", "aeiou", names(datos)) #sustituye los primeros caracteres por los segundos en el siguiente df.
# con janitor (se llama asi el package y library), su funcion datos <- clean_names(datos) y lo deja todo en min, sin tildes, ni espacios.

datos$comunidades[datos$comunidades == ""] <- "Nacional"
datos$provincias[datos$provincias == ""] <- NA

# APARTADO 5

extraer_provincia <- function(df, nombre_provincia) {
  # Comprobaciones básicas
  required_cols <- c("provincias", "ocupacion", "periodo", "sexo", "total") # columnas que necesita el df
  if (!all(required_cols %in% names(df))) {
    stop("El dataframe no contiene las columnas necesarias") # Comprobamos si falta alguna de las columnas en los names() del dataframe
  }
  
  # Limpiamos los códigos de provincia para buscar sólo por el nombre
  provincia_sin_codigo <- gsub("^[0-9]+\\s+", "", df$provincia)
  
  # Comprobamos si existe la provincia
  if (!nombre_provincia %in% provincia_sin_codigo) {
    stop(paste0("Provincia '", nombre_provincia, "' no encontrada en el dataframe"))
  }
  
  # Filtramos las filas de la provincia
  filas <- which(provincia_sin_codigo == nombre_provincia & df$sexo == "Total") # al filtrar, para que los NA no se cuelen, usamos which
  resultado <- df[filas, c("ocupacion", "periodo", "total")]
  
  colnames(resultado)[colnames(resultado) == "total"] <- "profesionales"
  
  row.names(resultado) <- NULL # eliminamos los indices para que se regeneren. row.names es la columna del indice como tal.
  
  return(resultado)
}

datos_teruel <- extraer_provincia(datos, "Teruel")

# APARTADO 6
empleados_domesticos_2022 <- datos[
  datos$ocupacion == "91 Empleados domésticos" &
  !is.na(datos$provincias) & # En el apartado 4 añadimos "Nacional" cuando comunidad estaba vacía, y NA en provincias para nacionales y autonómicos
  # Entonces, si provincia es NA, no la queremos.
  grepl("2022", datos$periodo) & # podríamos utilizar ^ como empieza por. grepl devuelve TRUE/FALSE y grep devuelve el indice de los elementos
  datos$sexo != "Total", # queremos hombres y mujeres, pero no el Total.
]

row.names(empleados_domesticos_2022) <- NULL 

colnames(empleados_domesticos_2022)[colnames(empleados_domesticos_2022) == "total"] <- "profesionales"
 
# APARTADO 7
datos_bucle <- datos[
  datos$ocupacion == "91 Empleados domésticos" &
    !is.na(datos$provincias) &
    grepl("2022", datos$periodo) &
    datos$sexo %in% c("Hombres", "Mujeres"),
]

# Convertimos la columna total a numérico (por si viene como character del CSV)
datos_bucle$total <- as.numeric(gsub(",", ".", datos_bucle$total))

# Convertimos la columna total a numérico (por si viene como character del CSV)
datos_bucle$total <- as.numeric(gsub(",", ".", datos_bucle$total))

provincias_unicas <- unique(datos_bucle$provincias)

hombres <- c()
mujeres <- c()
total <- c()
prop_hombres <- c()

for (provincia in provincias_unicas) {
  # Filtramos las filas de esta provincia específica
  filas_provincia <- datos_bucle$provincias == provincia
  
  # Calculamos suma de hombres
  filas_hombres <- filas_provincia & datos_bucle$sexo == "Hombres"
  suma_hombres <- sum(datos_bucle$total[filas_hombres], na.rm = TRUE)
  
  # Calculamos suma de mujeres
  filas_mujeres <- filas_provincia & datos_bucle$sexo == "Mujeres"
  suma_mujeres <- sum(datos_bucle$total[filas_mujeres], na.rm = TRUE)
  
  # Calculamos total
  suma_total <- suma_hombres + suma_mujeres
  
  # Calculamos proporción
  if (suma_total > 0) {
    prop <- (suma_hombres / suma_total) * 100
  } else {
    prop <- NA
  }
  
  # Añadimos los valores a los vectores
  hombres <- c(hombres, suma_hombres)
  mujeres <- c(mujeres, suma_mujeres)
  total <- c(total, suma_total)
  prop_hombres <- c(prop_hombres, round(prop, 1))
}

# Creamos el dataframe resumen
resumen <- data.frame(
  provincia = provincias_unicas,
  hombres = hombres,
  mujeres = mujeres,
  total = total,
  prop_hombres = prop_hombres
)

# Ordenamos por provincia
resumen <- resumen[order(resumen$provincia), ]
row.names(resumen) <- NULL



















