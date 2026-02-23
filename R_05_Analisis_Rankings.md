# R — Análisis, Rankings y Representación
> Ctrl+F para buscar. Operaciones de análisis, cálculo de métricas y gráficos.

---

## 1. Estadísticas descriptivas básicas

```r
# Una columna
mean(df$Total, na.rm = TRUE)     # media
median(df$Total, na.rm = TRUE)   # mediana
sum(df$Total, na.rm = TRUE)      # suma
min(df$Total, na.rm = TRUE)      # mínimo
max(df$Total, na.rm = TRUE)      # máximo
range(df$Total, na.rm = TRUE)    # c(min, max)
var(df$Total, na.rm = TRUE)      # varianza
sd(df$Total, na.rm = TRUE)       # desviación estándar
length(df$Total)                  # número de elementos
sum(!is.na(df$Total))            # número de no-NAs

# Resumen de todo el dataframe
summary(df)

# Tabla de frecuencias
table(df$Autonomia)
table(df$Grupo, df$Autonomia)   # tabla cruzada
```

---

## 2. Crear nuevas columnas como métricas de análisis

**Caso del examen:** "calcula dos magnitudes que informen de la eficiencia del suministro de agua"

```r
# Ejemplo: pérdidas expresadas en miles de m3, población en personas

# ------- Métrica 1: pérdidas per cápita (m3 por persona) -------
conjuntoDatos$Perdidas_per_capita <- (conjuntoDatos$Perdidas * 1000) / conjuntoDatos$Poblacion
# Interpretación: cuántos m3 de agua se pierden por habitante

# ------- Métrica 2: tasa de pérdida (% sobre total suministrado) -------
# Si tienes el total suministrado
conjuntoDatos$Tasa_perdida_pct <- (conjuntoDatos$Perdidas / conjuntoDatos$TotalSuministrado) * 100

# ------- Métrica 3: litros perdidos por persona al día -------
conjuntoDatos$Litros_dia_persona <- (conjuntoDatos$Perdidas * 1000 * 1000) / (conjuntoDatos$Poblacion * 365)
# *1000 para pasar de miles de m3 a m3, *1000 para pasar m3 a litros

# ------- Redondear resultados -------
conjuntoDatos$Perdidas_per_capita <- round(conjuntoDatos$Perdidas_per_capita, 2)
```

**TIP para el examen:** cuando el enunciado dice "las pérdidas están en miles de m3", recuerda multiplicar por 1000 para convertir a m3 reales.

---

## 3. Rankings y ordenación

```r
# ------- FORMA 1: order() — devuelve índices para reordenar -------
df_ranking <- df[order(df$Total), ]                      # ascendente
df_ranking <- df[order(df$Total, decreasing = TRUE), ]   # descendente (mayor primero)
df_ranking <- df[order(-df$Total), ]                     # también descendente

# ------- Añadir columna de posición -------
df_ranking$Posicion <- 1:nrow(df_ranking)

# ------- FORMA 2: rank() — asigna el rango como valor numérico -------
df$Ranking <- rank(-df$Total)   # el - hace que el mayor sea el 1

# ------- FORMA 3: Con dplyr -------
library(dplyr)
df_ranking <- df %>% arrange(desc(Total)) %>% mutate(Posicion = row_number())

# ------- Ver top N -------
head(df_ranking, 5)                        # top 5
df_ranking[1:5, ]                          # igual
tail(df_ranking, 5)                        # bottom 5 (los últimos si está ordenado desc)
```

---

## 4. Agregación (agrupar y calcular)

```r
# ------- aggregate() — agrupar por columna y aplicar función -------
# aggregate(columna ~ agrupacion, data = df, FUN = función)

total_por_grupo <- aggregate(Total ~ Grupo, data = df, FUN = sum)
media_por_auto  <- aggregate(Total ~ Autonomia, data = df, FUN = mean)
max_por_auto    <- aggregate(Total ~ Autonomia, data = df, FUN = max)

# Múltiples columnas de resultado
result <- aggregate(cbind(Total, Hombres) ~ Autonomia, data = df, FUN = sum)

# ------- tapply() — aplicar función a grupos -------
tapply(df$Total, df$Autonomia, sum)     # suma de Total por Autonomia → named vector

# ------- Con dplyr -------
library(dplyr)
df %>% group_by(Autonomia) %>% summarise(Total = sum(Total))
df %>% group_by(Autonomia) %>% summarise(Media = mean(Total), Max = max(Total))
```

---

## 5. Gráficos básicos

### Gráfico de barras (`barplot`)
```r
# ------- Básico -------
barplot(df$Total, names.arg = df$Autonomia)

# ------- Con parámetros -------
barplot(
  height = df$Total,
  names.arg = df$Autonomia,
  main = "Pérdidas de agua por comunidad",   # título
  xlab = "Comunidad Autónoma",               # etiqueta eje X
  ylab = "Miles de m3",                      # etiqueta eje Y
  las = 2,        # etiquetas eje X verticales (1=horizontal, 2=vertical)
  col = "steelblue",
  cex.names = 0.7  # tamaño texto etiquetas
)

# ------- Horizontal -------
barplot(df$Total, names.arg = df$Autonomia, horiz = TRUE, las = 1)
```

### Gráfico de líneas (`plot`)
```r
plot(df$Anio, df$Total, type = "l",   # "l"=línea, "p"=puntos, "b"=ambos
     main = "Evolución temporal",
     xlab = "Año", ylab = "Total")

# Añadir línea a un gráfico existente
lines(df$Anio, df$Total2, col = "red")
points(df$Anio, df$Total3, col = "blue", pch = 16)

# Añadir leyenda
legend("topright", legend = c("Serie1", "Serie2"), col = c("black", "red"), lty = 1)
```

### Histograma
```r
hist(df$Total, main = "Distribución", xlab = "Total", col = "lightblue", breaks = 10)
```

### Diagrama de dispersión
```r
plot(df$Poblacion, df$Perdidas,
     main = "Pérdidas vs Población",
     xlab = "Población", ylab = "Pérdidas (miles m3)",
     pch = 16, col = "darkblue")
# Añadir etiquetas a los puntos
text(df$Poblacion, df$Perdidas, labels = df$Autonomia, cex = 0.6, pos = 3)
```

### Diagrama de caja
```r
boxplot(df$Total, main = "Distribución Total", ylab = "Valor")
boxplot(Total ~ Grupo, data = df, las = 2, main = "Total por Grupo")
```

---

## 6. Ajustar el área de gráficos (márgenes, múltiples)

```r
# Aumentar márgenes para etiquetas largas
par(mar = c(10, 4, 4, 2))    # c(abajo, izquierda, arriba, derecha)

# Múltiples gráficos en la misma ventana
par(mfrow = c(2, 2))   # 2 filas, 2 columnas → 4 gráficos
barplot(...)
plot(...)
hist(...)
# ...

# Volver a un gráfico por ventana
par(mfrow = c(1, 1))
```

---

## 7. Mostrar resultados con formato

```r
# print — muestra el dataframe/valor
print(df)
print(head(df))

# cat — para mensajes de texto con valores
cat("Total Nacional:", sum(df$Total), "\n")
cat("Media pérdidas:", round(mean(df$Perdidas), 2), "miles de m3\n")
cat("Comunidad con más pérdidas:", df$Autonomia[which.max(df$Total)], "\n")

# paste / paste0 — construir strings
paste("Autonomía", df$Autonomia[1], "tiene", df$Total[1], "m3")
paste0("Porcentaje: ", round(pct, 1), "%")

# sprintf — formatear con precisión
sprintf("%.2f%%", 15.6789)   # → "15.68%"
sprintf("%.0f m3", 12345.6)  # → "12346 m3"
```

---

## 8. Exportar resultados

```r
# Guardar como CSV
write.csv(conjuntoDatos, "resultado.csv", row.names = FALSE)
write.csv2(conjuntoDatos, "resultado.csv", row.names = FALSE)  # con punto y coma

# Guardar como texto
write.table(conjuntoDatos, "resultado.txt", sep = "\t", row.names = FALSE)

# Guardar gráfico
png("grafico.png", width = 800, height = 600)
barplot(df$Total, names.arg = df$Autonomia, las = 2)
dev.off()   # IMPORTANTE: cierra el dispositivo gráfico
```

---

## 9. Comentar el análisis — lo que el profesor valora

Cuando calcules una métrica en el examen, la estructura de comentario ideal:

```r
# ---- MÉTRICA 1: Pérdidas per cápita ----
# Qué es: volumen de agua no registrada dividido entre la población
# Unidad: m3 por habitante al año
# Por qué es útil: normaliza las pérdidas por tamaño de la comunidad,
#   permite comparar comunidades grandes vs pequeñas
# Nota: las pérdidas están en miles de m3, multiplicamos x1000 para convertir
conjuntoDatos$Perdidas_per_capita <- (conjuntoDatos$Perdidas * 1000) / conjuntoDatos$Poblacion

# ---- MÉTRICA 2: Índice de eficiencia hídrica ----
# Qué es: ratio pérdidas / total suministrado (si lo tenemos)
# Unidad: tanto por uno (0 = sin pérdidas, 1 = todo se pierde)
# Por qué es útil: mide la ineficiencia relativa del sistema
conjuntoDatos$Eficiencia <- conjuntoDatos$Perdidas / conjuntoDatos$TotalSuministrado
```

---

## 10. Checklist final antes de entregar

```r
# 1. ¿El df tiene el número correcto de filas?
nrow(conjuntoDatos)

# 2. ¿Hay NAs inesperados?
sum(is.na(conjuntoDatos))
colSums(is.na(conjuntoDatos))   # NAs por columna

# 3. ¿Los tipos son correctos?
str(conjuntoDatos)

# 4. ¿Los nombres de columna son los pedidos?
colnames(conjuntoDatos)

# 5. ¿El resultado tiene el aspecto que pide el enunciado?
head(conjuntoDatos)

# 6. ¿El gráfico tiene título, etiquetas de ejes y es legible?
# → main=, xlab=, ylab=, las=2 para etiquetas verticales si son largas
```
