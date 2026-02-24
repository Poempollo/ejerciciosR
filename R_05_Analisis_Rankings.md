# R  Análisis, Rankings y Representación
> Solo R base. Ctrl+F. Cada línea explicada.

---

## 1. Estadísticas sobre una columna

```r
# Funciones que devuelven UN solo valor resumen
sum(df$Total, na.rm = TRUE)      # suma de todos los valores
mean(df$Total, na.rm = TRUE)     # media aritmética
median(df$Total, na.rm = TRUE)   # mediana (el valor del medio al ordenar)
min(df$Total, na.rm = TRUE)      # valor mínimo
max(df$Total, na.rm = TRUE)      # valor máximo
range(df$Total, na.rm = TRUE)    # c(mínimo, máximo)  devuelve dos valores
var(df$Total, na.rm = TRUE)      # varianza (dispersión)
sd(df$Total, na.rm = TRUE)       # desviación estándar (dispersión en mismas unidades)
length(df$Total)                  # número de elementos (cuenta también NAs)
sum(!is.na(df$Total))            # número de elementos NO nulos

# na.rm = TRUE  "NA remove TRUE"  ignorar los NA al calcular
# Sin na.rm=TRUE, si hay cualquier NA el resultado es NA

# Resumen completo de todo el df
summary(df)
# Muestra para cada columna: min, Q1, mediana, media, Q3, max, y cuántos NA hay
```

---

## 2. Crear columnas de análisis (métricas)

Cuando el enunciado dice "calcula una magnitud que indique la eficiencia / el rendimiento / la proporción":

```r
# MÉTRICA TÍPICA 1: ratio entre dos columnas
df$Ratio <- df$ColA / df$ColB
# Divide cada valor de ColA entre el correspondiente de ColB

# MÉTRICA TÍPICA 2: porcentaje
df$Porcentaje <- (df$ColA / df$ColB) * 100
# Multiplica por 100 para expresarlo como %

# MÉTRICA TÍPICA 3: per cápita (valor por habitante)
# Si las pérdidas están en miles de m3, multiplicar por 1000 para convertir a m3
df$Perdidas_per_capita <- (df$Perdidas * 1000) / df$Poblacion
# Cada persona de esa comunidad "genera" esos m3 de pérdida al año

# MÉTRICA TÍPICA 4: litros por persona y día
# miles de m3  m3 (*1000)  litros (*1000)  entre personas  entre 365 días
df$Litros_dia_persona <- (df$Perdidas * 1000 * 1000) / (df$Poblacion * 365)

# Redondear a 2 decimales para presentar mejor
df$Ratio <- round(df$Ratio, 2)
df$Perdidas_per_capita <- round(df$Perdidas_per_capita, 2)
```

**Cómo comentar una métrica en el examen:**
```r
# ---- MÉTRICA: Pérdidas per cápita ----
# Qué mide: cuántos m3 de agua se pierden por cada habitante al año
# Por qué sirve: permite comparar comunidades con diferente tamaño de población
# Unidad: m3 por habitante
# Nota: las pérdidas están en miles de m3, multiplicamos x1000 para convertir
df$Perdidas_per_capita <- round((df$Perdidas * 1000) / df$Poblacion, 2)
```

---

## 3. Ordenar y hacer rankings

```r
# order() devuelve los ÍNDICES en el orden que tú quieres
# Luego usas esos índices para reordenar el dataframe

df_rank <- df[order(df$Total), ]                      # ascendente (menor primero)
df_rank <- df[order(df$Total, decreasing = TRUE), ]   # descendente (mayor primero)
df_rank <- df[order(-df$Total), ]                     # también descendente (con -)
df_rank <- df[order(df$Col1, df$Col2), ]              # primero por Col1, luego Col2

# Añadir columna de posición numérica
rownames(df_rank) <- NULL                 # resetear índices tras ordenar
df_rank$Posicion <- 1:nrow(df_rank)       # 1, 2, 3, ... hasta el número de filas

# Ver solo el top N
head(df_rank, 5)        # los 5 primeros (top 5 si está ordenado desc)
head(df_rank, 10)       # los 10 primeros
tail(df_rank, 5)        # los 5 últimos (peores si está ordenado desc)
df_rank[1:5, ]          # equivale a head(df_rank, 5)

# Encontrar el máximo y mínimo directamente
df[which.max(df$Total), ]             # fila completa con el valor máximo
df$Autonomia[which.max(df$Total)]     # solo el nombre de la autonomía con el máximo
df[which.min(df$Total), ]             # fila completa con el valor mínimo
```

---

## 4. Agrupar y hacer sumas/medias por grupo  aggregate()

```r
# aggregate(columna ~ columna_agrupadora, data=df, FUN=función)
# Calcula FUN para cada grupo de columna_agrupadora

# Suma de Total para cada Autonomia
total_por_auto <- aggregate(Total ~ Autonomia, data = df, FUN = sum)

# Media de Indice para cada Grupo
media_por_grupo <- aggregate(Indice ~ Grupo, data = df, FUN = mean)

# Máximo por grupo
max_por_grupo <- aggregate(Indice ~ Grupo, data = df, FUN = max)

# Varias columnas agrupadas a la vez
res <- aggregate(cbind(Total, Hombres) ~ Autonomia, data = df, FUN = sum)
# cbind(col1, col2)  agrupa y calcula las dos columnas a la vez

# tapply  similar pero devuelve una tabla en vez de dataframe
tabla <- tapply(df$Total, df$Autonomia, sum)
# Resultado: vector con nombres  útil para ver rápido, no tanto para usar después
```

---

## 5. Gráficos básicos

### Gráfico de barras

```r
barplot(df$Total, names.arg = df$Autonomia)
# Barras de altura df$Total con etiquetas df$Autonomia

# Con parámetros completos
barplot(
  height = df$Total,             # alturas de las barras
  names.arg = df$Autonomia,      # etiquetas de cada barra
  main = "Título del gráfico",   # título que aparece arriba
  xlab = "Comunidad Autónoma",   # etiqueta del eje X
  ylab = "Valor (miles m3)",     # etiqueta del eje Y
  las = 2,        # 2 = etiquetas del eje X en vertical (para nombres largos)
  col = "steelblue",             # color de las barras
  cex.names = 0.7 # tamaño de las etiquetas (1 = normal, 0.7 = 70% del tamaño)
)

# Horizontal (para nombres muy largos)
barplot(df$Total, names.arg = df$Autonomia, horiz = TRUE, las = 1)
```

### Gráfico de líneas

```r
plot(df$Anno, df$Total,
  type = "l",              # "l"=línea, "p"=puntos, "b"=ambos, "h"=barras verticales
  main = "Evolución",
  xlab = "Año",
  ylab = "Total"
)

lines(df$Anno, df$Total2, col = "red")   # añadir una segunda línea al gráfico
legend("topright",                       # posición de la leyenda
  legend = c("Serie 1", "Serie 2"),      # textos
  col = c("black", "red"),              # colores
  lty = 1                               # tipo de línea (1 = sólida)
)
```

### Histograma

```r
hist(df$Total,
  main = "Distribución",
  xlab = "Total",
  col = "lightblue",
  breaks = 10           # número aproximado de barras
)
```

### Dispersión (scatter plot)

```r
plot(df$Poblacion, df$Perdidas,
  main = "Pérdidas vs Población",
  xlab = "Población",
  ylab = "Pérdidas",
  pch = 16,              # 16 = punto relleno (prueba del 1 al 25)
  col = "darkblue"
)
# Añadir etiquetas a los puntos
text(df$Poblacion, df$Perdidas, labels = df$Autonomia, cex = 0.6, pos = 3)
# cex = tamaño del texto, pos = posición respecto al punto (1=abajo, 3=arriba)
```

---

## 6. Ajuste de márgenes para gráficos con etiquetas largas

```r
# par() controla parámetros globales del gráfico
par(mar = c(10, 4, 4, 2))
# mar = c(abajo, izquierda, arriba, derecha) en líneas de texto
# Si las etiquetas del eje X son largas y se cortan, aumentar el primer número

# Volver a márgenes por defecto
par(mar = c(5, 4, 4, 2))

# Múltiples gráficos en una ventana
par(mfrow = c(2, 2))   # 2 filas y 2 columnas  4 gráficos en la misma ventana
# Luego llamas a barplot(), plot(), etc. y van llenando las posiciones
par(mfrow = c(1, 1))   # volver a un solo gráfico
```

---

## 7. Mostrar resultados con texto formateado

```r
# cat()  imprime texto y variables mezclados, sin formato especial
cat("Total Nacional:", sum(df$Total), "\n")
# \n = salto de línea

cat("Media:", round(mean(df$Total), 2), "m3\n")
# round(x, 2)  redondea a 2 decimales

cat("Máxima pérdida en:", df$Autonomia[which.max(df$Total)], "\n")

# paste()  une texto y variables en un string (separados por espacio por defecto)
texto <- paste("La autonomía", df$Autonomia[1], "tiene", df$Total[1], "m3")
print(texto)

# paste0()  igual que paste pero sin espacio entre elementos
texto <- paste0("Porcentaje: ", round(pct, 1), "%")

# sprintf()  formateo con precisión numérica como en C/Python
sprintf("%.2f%%", 15.6789)     #  "15.68%"  2 decimales y símbolo %
sprintf("%.0f", 12345.6)       #  "12346"  sin decimales
sprintf("%d personas", 1234L)  #  "1234 personas"  entero
```

---

## 8. Checklist antes de entregar

```r
# 1. El df tiene las dimensiones esperadas
nrow(resultado)
ncol(resultado)

# 2. No hay NAs inesperados
sum(is.na(resultado))
colSums(is.na(resultado))   # NAs por columna (identifica dónde está el problema)

# 3. Los tipos son correctos
str(resultado)

# 4. Los nombres de columna son los del enunciado
colnames(resultado)

# 5. El aspecto general es correcto
head(resultado)

# 6. El gráfico es legible (barras con nombres, ejes etiquetados, título)
#  main=, xlab=, ylab=, las=2 si los nombres son largos
```
