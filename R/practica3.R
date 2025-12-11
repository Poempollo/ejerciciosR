# EXAMEN PIA 2 AHORA ES PERSONAL
library("readODS")

# EJERCICIO 1: INGESTA DE DATOS
setwd("C://Users//Javi//Desktop//Programación//R//Prueba_UT1")
getwd()

datosAgua <- read_ods("agua.ods", range = ("A7:S121")) 
datosCenso <- read.csv("censo.csv", sep = ";")

datosCenso$Total <- as.numeric(gsub("\\.", "", datosCenso$Total))

# EJERCICIO 2: FILTRADO DE DATOS (PUTADA)
# Sacamos el nuevo df datosAguaFiltrados
datosAguaFiltrados <- datosAgua[datosAgua$...1 == "2. Volumen de agua no registrada", c(1, 2)]

# Creamos un filtro que va a ser para obtener el nombre de cada provincia
filtro <- which(datosAgua$...1 == "2. Volumen de agua no registrada") - 3

# Creamos un df con los nombres de las provincias y sólo la primera columna
# provincias <- datosAgua[filtro, 1] Así provincias es un df de una única columna, no un vector PROBLEMA
provincias <- datosAgua[filtro, 1][[1]] # Para extraer el vector

# Le pasamos al nuevo df los nuevos nombres para sus filas
datosAguaFiltrados$...1 <- provincias

colnames(datosAguaFiltrados)[1] <- "autonomia"
names(datosAguaFiltrados)[2] <- "perdidas"
colnames(datosAguaFiltrados)

# A por los datos del censo
datosCenso$Provincias[datosCenso$Provincias == ""] <- NA
datosCenso$Comunidades.y.Ciudades.Autónomas[datosCenso$Comunidades.y.Ciudades.Autónomas == ""] <- NA

filtro <- which(datosCenso$Periodo == "2020" & 
                  datosCenso$Sexo == "Total" & 
                  is.na(datosCenso$Provincias))

datosCensoFiltrados <- datosCenso[filtro, c(2, 6)]
row.names(datosCensoFiltrados) <- NULL

datosCensoFiltrados$Comunidades.y.Ciudades.Autónomas[is.na(datosCensoFiltrados$Comunidades.y.Ciudades.Autónomas)] <- "Total Nacional"
# datosCensoFiltrados$Comunidades.y.Ciudades.Autónomas[1] <- "Total Nacional"

colnames(datosCensoFiltrados)[1] <- "autonomia"
names(datosCensoFiltrados)[2] <- "poblacion"

# EJERCICIO 3: REPARACIÓN DE DATOS
filtro <- datosCenso[ datosCenso$Comunidades.y.Ciudades.Autónomas == "19 Melilla" &
                        is.na(datosCenso$Provincias) &
                        datosCenso$Sexo != "Total" & 
                        datosCenso$Periodo == 2020,
]

# Vamos a seleccionar esa entrada
# datosCensoFiltrados[datosCensoFiltrados$autonomia == "19 Melilla", "poblacion"] <- total_melilla
#
# indice <- which(datosCensoFiltrados$autonomia == "19 Melilla")
# datosCensoFiltrados[indice, "poblacion"] <- total_melilla
datosCensoFiltrados[is.na(datosCensoFiltrados$poblacion), "poblacion"] <- sum(filtro$Total, na.rm = TRUE)   

# Obtenemos la suma
# pob_ceuta <- datosCensoFiltrados[datosCensoFiltrados$autonomia == "18 Ceuta", 2]
# pob_melilla <- datosCensoFiltrados[datosCensoFiltrados$autonomia == "19 Melilla", 2]
filtro_CyM <- datosCensoFiltrados[datosCensoFiltrados$autonomia == "18 Ceuta" | 
                                    datosCensoFiltrados$autonomia == "19 Melilla", ]
totalCyM <- sum(filtro_CyM$poblacion)

# Eliminamos Ceuta y Melilla del df
datosCensoFiltrados <- datosCensoFiltrados[!(datosCensoFiltrados$autonomia == "18 Ceuta" | 
                                             datosCensoFiltrados$autonomia == "19 Melilla"), ]

datosCensoFiltrados <- rbind(datosCensoFiltrados, c("Ceuta y Melilla", totalCyM))
# RBIND CAMBIA EL TIPO DE VALOR, CUIDADO QUE ES IMPORTANTE ESTO PORFAVOR
datosCensoFiltrados$poblacion <- as.numeric(datosCensoFiltrados$poblacion)

# EJERCICIO 4: CONSTRUIR EL CONJUNTO DE DATOS

# Debemos asegurarnos de que ambas columnas son vectores simples
datosAguaFiltrados$autonomia <- unlist(datosAguaFiltrados$autonomia)
datosCensoFiltrados$autonomia <- unlist(datosCensoFiltrados$autonomia)

# a) Unir ambos dataframes
conjuntoDatos <- merge(datosAguaFiltrados, datosCensoFiltrados, by = "autonomia", all = TRUE)

# b) Calcular magnitudes de eficiencia

# Magnitud 1: Litros perdidos por habitante (LpH)
# Las pérdidas están en miles de m³, así que multiplicamos por 1.000.000 para pasar a litros
conjuntoDatos$LpH <- conjuntoDatos$perdidas * 1000000 / conjuntoDatos$poblacion

# Magnitud 2: Diferencia Porcentual respecto a la Media (DPM)
# Calculamos la media nacional
mediaPerdidaNacional <- conjuntoDatos[conjuntoDatos$autonomia == "Total Nacional", ]$LpH

# Calculamos la diferencia porcentual de cada comunidad respecto a la media
conjuntoDatos$DPM <- round((conjuntoDatos$LpH - mediaPerdidaNacional) / mediaPerdidaNacional * 100)
