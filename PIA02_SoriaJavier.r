library(readODS)

# EJERCICIO 1
setwd("/home/alumnot/Documentos/R/Prueba UT1/")

datosAgua <- read_ods("agua.ods", range = "A7:S121") # Cargamos el .ods en el rango 7:121
# No cargar header o footer

datosCenso <- read.csv("censo.csv", sep=";") # Cargamos el .csv separando las columnas por ;
datosCenso$Total <- as.numeric(gsub("\\.", "", datosCenso$Total)) # Transformamos la columna total a enteros

# EJERCICIO 2
filas <- which(datosAgua$...1 == "2. Volumen de agua no registrada") # Obtenemos las filas deseadas volumen de agua no registrada
datosAguaFiltrada <- datosAgua[filas, 2] # Reconstruimos el df con dichas filas y la columna 2020

comunidades <- is.na(datosAgua$`2020`) # Intento obtener las filas que sean NA ya que estas son las de cada comunidad
comunidades <- unique(comunidades)
comunidades <- comunidades[-c(2, 3, 4, 5)]

datosAguaFiltrada$autonomias <- comunidades

filas <- which(datosCenso$V4 == "Total" & datosCenso$V3 == "" & datosCenso$V5 == "2020")
datosCensoFiltrados <- datosCenso[filas, -c(1, 3, 4, 5)]

# APARTADO 3


# APARTADO 4
conjuntoDatos <- merge(datosCensoFiltrados, datosAguaFiltrada, by = "autonomia") # si funcionase se haría así