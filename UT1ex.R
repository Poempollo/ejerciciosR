
library(readODS)

################################# Apartado 1 ##################################

# Establecemos el espacio de trabajo
setwd("C:\\Users\\Lopema\\Desktop\\Docencia 2025\\PIA - Presencial\\Pruebas R\\Prueba R 2025 v1.2") 
getwd() 
agua <- "agua.ods"
censo <- "censo.csv"

# Cargamos los dos conjuntos de datos
datosAgua  <- read_ods(agua, range = "tabla-53447!A7:S121")
datosCenso <- read.csv(censo, header = TRUE, sep = ";", stringsAsFactors = FALSE)

# Convertimos a numérico la columna total de datosCenso
datosCenso$Total <- gsub("\\.", "", datosCenso$Total)
datosCenso$Total <- as.numeric(datosCenso$Total)

################################# Apartado 2 ##################################

# Procesamos el conjunto de datos del agua
# Filtramos las líneas que corresponden con el agua no registrada - pérdidas
perdidas = which (datosAgua$...1=="2. Volumen de agua no registrada")
# Localizamos las filas donde se encuentran los nombres de las comunidades a
# que corresponden
autonomias = perdidas-3
# Escogemos la columna con el año de interés 2020
años = c(2)

# Extraemos el nombre de la comunidad, construimos el dataframe y le damos
# nombre a la columna
datosAguaFiltrados=datosAgua[autonomias,1]
names(datosAguaFiltrados) <- c("autonomia")
# Ahora extraemos la columna con las pérdidas, accediendo a sus valores
datosAguaFiltrados$perdidas=datosAgua[perdidas,años][[1]]
head(datosAguaFiltrados)

# Procesamos el conjunto de datos del censo

# Filtramos los datos del dataframe para extraer solo los datos correspondientes
# las comunidades autónomas, sin desglosar por provincias ni sexo (Total) y 
# correspondientes al año 2020
filtro <- datosCenso[ datosCenso$Comunidades.y.Ciudades.Autónomas != "" &
                      datosCenso$Provincias == "" &
                      datosCenso$Sexo == "Total" & 
                      datosCenso$Periodo == 2020,
]

# Construimos un dataframe a partir de los datos filtrados
datosCensoFiltrados <- data.frame(
  autonomia = filtro$Comunidades.y.Ciudades.Autónomas,
  poblacion = filtro$Total
)

head(datosCensoFiltrados)

datosCensoFiltrados$poblacion

################################# Apartado 3 ##################################

## Calculamos la población de Melilla

filtro <- datosCenso[ datosCenso$Comunidades.y.Ciudades.Autónomas == "19 Melilla" &
                      datosCenso$Provincias == "" &
                      datosCenso$Sexo != "Total" & 
                      datosCenso$Periodo == 2020,
]
sum(filtro$Total)

datosCensoFiltrados[datosCensoFiltrados$autonomia == "19 Melilla",][2]=sum(filtro$Total)

## Calculamos la población de Ceuta y Melilla

filtro <- datosCensoFiltrados[ datosCensoFiltrados$autonomia == "19 Melilla" |
                               datosCensoFiltrados$autonomia == "18 Ceuta" ,
]
totalCyM <- sum(filtro$poblacion)

# Borramos los antiguos registros de Ceuta y Melilla
datosCensoFiltrados <- datosCensoFiltrados[-c(18, 19), ]

# Añadimos el registro con el agregado
datosCensoFiltrados <- rbind(datosCensoFiltrados, c("Ceuta y Melilla", totalCyM))

# Al hacer rbind es necesario volver a pasar a numérico la poblacion
datosCensoFiltrados$poblacion <- as.numeric(datosCensoFiltrados$poblacion)

## Y ahora el Total Nacional

totalNacional <- sum(datosCensoFiltrados$poblacion)

# Añadimos el registro con el agregado del Total Nacional
datosCensoFiltrados <- rbind(c("Total Nacional", totalNacional), datosCensoFiltrados)

# Al hacer rbind es necesario volver a pasar a numérico la poblacion
datosCensoFiltrados$poblacion <- as.numeric(datosCensoFiltrados$poblacion)

################################# Apartado 4 ##################################

conjuntoDatos <- merge(datosAguaFiltrados, datosCensoFiltrados, by = "autonomia", all = TRUE)

# Litros perdidos por habitante
conjuntoDatos$LpH <- conjuntoDatos$perdidas*1000000/conjuntoDatos$poblacion

# Ahora calculamos la diferencia porcentual con respecto a la media
mediaPerdidaNacional <- conjuntoDatos[ conjuntoDatos$autonomia == "Total Nacional", ]$LpH
conjuntoDatos$DPM <- round((conjuntoDatos$LpH - mediaPerdidaNacional) / mediaPerdidaNacional * 100)
