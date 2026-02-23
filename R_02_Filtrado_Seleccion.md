# R — Filtrado y Selección de Datos
> Ctrl+F para buscar. Múltiples formas de hacer lo mismo.

---

## ESQUEMA MENTAL antes de filtrar

Cuando el enunciado dice "filtra para quedarte con X e Y":
1. ¿Qué **filas** quiero? → condición sobre una columna
2. ¿Qué **columnas** quiero? → selección de columnas
3. ¿Cómo se llaman las columnas? → `colnames()` primero
4. ¿El resultado tiene el número de filas correcto? → `nrow()` para verificar

---

## 1. Filtrar filas — todas las formas

### Por corchetes `[]`
```r
# df[condición de filas, condición de columnas]
# Dejar la parte vacía = "todo"

# -------  Una condición -------
df[df$Tipo == "2. Volumen no registrada", ]   # filas donde Tipo es ese valor
df[df$Anio == 2020, ]                          # filas donde Año es 2020
df[df$Total > 1000, ]                          # filas donde Total > 1000

# ------- Condición con texto parcial (contiene) -------
df[grepl("Ceuta", df$Autonomia), ]            # filas donde Autonomia contiene "Ceuta"
df[grepl("^18", df$Autonomia), ]              # empieza por "18"

# ------- Condición negativa -------
df[df$Sexo != "Total", ]                       # filas donde Sexo NO es "Total"
df[!grepl("Total", df$Tipo), ]                # filas donde Tipo NO contiene "Total"

# ------- Múltiples condiciones (AND) -------
df[df$Tipo == "2. Volumen no registrada" & df$Anio == 2020, ]

# ------- Múltiples condiciones (OR) -------
df[df$Autonomia == "Ceuta" | df$Autonomia == "Melilla", ]

# ------- Condición con lista de valores (%in%) -------
df[df$Autonomia %in% c("Ceuta", "Melilla", "Madrid"), ]

# ------- Excluir valores de una lista -------
df[!df$Autonomia %in% c("Ceuta", "Melilla"), ]
```

### Con `subset()` — más legible
```r
# subset(dataframe, condición, select = columnas)

# ------- Filtrar solo filas -------
subset(df, Tipo == "2. Volumen no registrada")

# ------- Filtrar filas Y seleccionar columnas -------
subset(df, Tipo == "2. Volumen no registrada", select = c(Autonomia, Total_2020))

# ------- Múltiples condiciones -------
subset(df, Sexo == "Total" & Anio == 2020)

# ------- Excluir columnas -------
subset(df, select = -c(Codigo, Notas))   # todo menos esas columnas
```

### Con `dplyr` — el más moderno
```r
library(dplyr)

df %>% filter(Tipo == "2. Volumen no registrada")
df %>% filter(Sexo == "Total", Anio == 2020)        # coma = AND
df %>% filter(Autonomia %in% c("Madrid", "Ceuta"))
df %>% filter(!is.na(Total))                         # quitar NAs
```

---

## 2. Seleccionar columnas — todas las formas

```r
# ------- Por nombre de columna -------
df[, c("Autonomia", "Total_2020")]
df[, "Autonomia"]           # una sola columna → vector
df["Autonomia"]             # una sola columna → sigue siendo dataframe

# ------- Por posición -------
df[, 1]           # primera columna
df[, c(1, 5)]     # columnas 1 y 5
df[, 2:8]         # columnas 2 a 8

# ------- Excluir columnas por posición -------
df[, -1]          # todo menos la primera columna
df[, -c(1, 2)]    # todo menos columnas 1 y 2

# ------- Con dplyr -------
df %>% select(Autonomia, Total_2020)
df %>% select(-Codigo, -Notas)           # excluir
df %>% select(starts_with("2020"))       # columnas que empiezan por "2020"
df %>% select(contains("2020"))          # columnas que contienen "2020"
```

---

## 3. Filtrar Y seleccionar en una sola línea

```r
# Con corchetes
resultado <- df[df$Tipo == "2. Volumen no registrada", c("Autonomia", "Total_2020")]

# Con subset
resultado <- subset(df, Tipo == "2. Volumen no registrada", select = c(Autonomia, Total_2020))

# Con dplyr
resultado <- df %>%
  filter(Tipo == "2. Volumen no registrada") %>%
  select(Autonomia, Total_2020)
```

---

## 4. Renombrar columnas en el resultado

```r
# Después de filtrar, las columnas pueden tener nombres raros (V3, V15...)
# Renombrar:
colnames(datosAguaFiltrados) <- c("Autonomia", "Perdidas_2020")
colnames(datosAguaFiltrados)[1] <- "Autonomia"   # solo la primera
colnames(datosAguaFiltrados)[2] <- "Perdidas_2020"

# Con dplyr
datosAguaFiltrados <- datosAguaFiltrados %>% rename(Autonomia = V1, Perdidas_2020 = V15)
```

---

## 5. Filtrar por posición de fila (por número)

```r
df[1, ]          # primera fila
df[c(1, 3, 5), ] # filas 1, 3 y 5
df[1:10, ]        # filas 1 a 10
df[-1, ]          # todo menos la primera fila
df[-c(1, 2), ]    # todo menos filas 1 y 2
df[nrow(df), ]    # última fila
```

---

## 6. Filtrar con `which()` — útil para encontrar posiciones

```r
# which() devuelve los ÍNDICES (posiciones) donde se cumple la condición
which(df$Autonomia == "18 Ceuta")       # → devuelve ej. c(18)
which(grepl("Melilla", df$Autonomia))   # → devuelve ej. c(19)
which(is.na(df$Total))                  # → posiciones con NA

# Usar el índice para acceder
fila <- which(df$Autonomia == "18 Ceuta")
df[fila, ]        # ver esa fila
df[fila, "Total"] # ver solo el valor Total de esa fila
df$Total[fila]    # mismo resultado, otra forma
```

---

## 7. Filtrar con `grepl()` para texto parcial

```r
# grepl(patrón, vector) → devuelve TRUE/FALSE
grepl("Ceuta", df$Autonomia)           # contiene "Ceuta"
grepl("^18", df$Autonomia)             # empieza por "18"
grepl("Total$", df$Tipo)               # termina en "Total"
grepl("(?i)ceuta", df$Autonomia)       # ignora mayúsculas/minúsculas

# Usar en filtro
df[grepl("Ceuta", df$Autonomia), ]

# grep() devuelve los ÍNDICES (como which pero para texto)
grep("Ceuta", df$Autonomia)            # → índices donde aparece "Ceuta"
```

---

## 8. Errores y problemas comunes al filtrar

| Problema | Causa | Solución |
|---|---|---|
| Resultado vacío cuando no debería | Espacios extra en el texto | Usar `trimws()` antes de comparar |
| `NA` en la condición | Valores NA en la columna | Usar `%in%` en vez de `==` o añadir `!is.na()` |
| Columna no encontrada | Nombre mal escrito | `colnames(df)` para ver nombres exactos |
| Resultado es vector, no dataframe | Seleccionaste una sola columna con `[, "col"]` | Usar `[, "col", drop=FALSE]` |
| Condición de tipo error | Comparando texto con número | Revisar `str(df)` y convertir tipo |

```r
# PROBLEMA: espacios extra en valores
df$Tipo <- trimws(df$Tipo)   # elimina espacios al inicio y al final
# Luego ya puedes filtrar con ==

# PROBLEMA: resultado es vector, quiero dataframe
col <- df[, "Total"]                  # → vector
col <- df[, "Total", drop = FALSE]    # → dataframe de 1 columna
col <- df["Total"]                     # → dataframe de 1 columna
```

---

## 9. Verificar el resultado

```r
nrow(datosAguaFiltrados)       # número de filas — ¿es el esperado?
colnames(datosAguaFiltrados)   # nombres de columnas
head(datosAguaFiltrados)       # ver primeras filas
unique(datosAguaFiltrados$Autonomia)  # ver valores únicos — ¿están todas las CC.AA.?
table(df$Tipo)                 # contar cuántas filas hay de cada tipo
```
