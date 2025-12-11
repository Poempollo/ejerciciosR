# Práctica 1 - DF Básico

# 1. Carga del Dataframe
setwd("C://Users//Javi//Desktop//Programación//R//")
getwd()

df_ventas <- read.csv("ventas.csv")
head(df_ventas)

# 2. Filtrado básico
df_gaming <- df_ventas[df_ventas$categoria == "Gaming", ] # la coma porque sólo queremos seleccionar las filas

# 3. Nueva columna
importe_total <- df_ventas$precio * df_ventas$cantidad

df_ventas$importe_total <- importe_total

# 4. Estadística (precio medio, total vendido y producto más caro)
# Precio medio de pedido
mean(df_ventas$importe_total)
# Precio medio de producto
mean(df_ventas$precio)

# Total vendido
sum(df_ventas$importe_total)

# Producto más caro
df_ventas[which.max(df_ventas$precio), c("producto", "precio")] # which extrae una fila

subset(df_ventas, subset = precio >= 200)

# 5. Agrupación de ingresos y total de productos vendidos por tienda
aggregate(precio ~ tienda, df_ventas, sum) #suma de precio por tienda

# Total de ingresos
aggregate(cbind(precio * cantidad) ~ tienda, df_ventas, sum)
# aquí queremos el total de ingresos, por eso, precio * cantidad para cada fila de una misma tienda

# Total de productos vendidos por tienda
aggregate(cantidad ~ tienda + categoria, df_ventas, sum)

# 6. Filtrado Avanzado, sólo filas categoria = "Oficina", precio > 100 y cantidad >= 1
str(df_ventas) # vemos la estructura. Suele ser recomendable eliminar los factores con df$cat <- as.character(df$cat)
# && y || devuelven un único valor, utilizamos solo & y |

filtro <- df_ventas$categoria == "Oficina" &
          df_ventas$precio > 100 &
          df_ventas$cantidad >= 1

df_oficina_filtrado <- df_ventas[filtro, ]

# poddríamos hacer !is.na(df_ventas) & df_ventas$categoria == "Oficina" & ... para evitar valores NA en cada columna
