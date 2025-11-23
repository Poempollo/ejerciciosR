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
  
  return(resultado)
}

datos_teruel <- extraer_provincia(datos, "Teruel")

