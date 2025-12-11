# Práctica 2 - DF Avanzado

# 1. Carga de los Dataframe
setwd("C://Users//Javi//Desktop//Programación//R//")
getwd()

# Cargamos ambos dataframe, y cambiamos la columna fecha a tipo Date 
ventas <- read.csv("ventas_detalladas.csv")
tiendas <- read.csv("tiendas.csv")

ventas$fecha <- as.Date(ventas$fecha)
# str(tiendas)

# 2. Manejo de NA
!is.na(ventas)
ventas_clean <- ventas[!is.na(ventas$fecha), ]
# row.names(ventas_clean) Para reiniciar los índices

# 3. Crear nueva columna
ventas_clean$importe_total <- ventas_clean$precio * ventas_clean$cantidad

# 4. Filtrado avanzado
ventas_ofi <- ventas_clean[ventas_clean$precio > 100 & ventas_clean$categoria == "Oficina", ]
ventas_gay <- ventas_clean[ventas_clean$cantidad >= 2 & ventas_clean$categoria == "Gaming", ]
ventas_date <- ventas_clean[ventas_clean$fecha >= "2024-01-11" & ventas_clean$fecha <= "2024-01-13", ]

# 5. Agrupaciones avanzadas
aggregate(importe_total ~ tienda, ventas_clean, sum)
aggregate(cantidad ~ categoria, ventas_clean, sum)
aggregate(importe_total ~ tienda + categoria, ventas_clean, mean)

# 6. Ordenaciones
ventas_clean[order(-ventas_clean$importe_total), ] # igual se puede usar (..., decreasing=TRUE), ] en lugar del - al principio

# 7. Join
vpt <- merge(ventas_clean, tiendas, by = "tienda")
aggregate(importe_total ~ tienda + empleados, vpt, sum)

# 8. Aggregate
aggregate(importe_total ~ ciudad + categoria, vpt, sum)






