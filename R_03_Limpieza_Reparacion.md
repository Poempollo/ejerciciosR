# R — Limpieza y Reparación de Datos
> Este es el bloque donde más se falla. Lee todo. Ctrl+F para buscar.

---

## ESQUEMA MENTAL antes de limpiar

Antes de tocar nada, responde estas preguntas:
1. ¿Qué forma tiene el df ahora? → `str()`, `head()`, `dim()`
2. ¿Qué forma tiene que tener al final? → lee el enunciado
3. ¿Hay NAs? → `sum(is.na(df))`, `which(is.na(df$col))`
4. ¿Los nombres de filas/columnas son correctos? → `colnames()`, `rownames()`
5. ¿Los tipos son correctos? → `str(df)`

**Luego actúas: primero repara NAs → luego agrupa/fusiona filas → luego añade totales → luego une dfs**

---

## 1. Detectar y tratar NAs

```r
# ------- Detectar -------
is.na(df$Total)                  # vector TRUE/FALSE
sum(is.na(df$Total))             # cuántos NA hay en esa columna
sum(is.na(df))                   # cuántos NA en todo el df
which(is.na(df$Total))           # en qué FILAS están los NA
df[is.na(df$Total), ]            # ver las FILAS con NA

# ------- Reemplazar NA por un valor fijo -------
df$Total[is.na(df$Total)] <- 0
df$Total[is.na(df$Total)] <- "Desconocido"

# ------- Reemplazar NA calculando (suma de otros valores) -------
# Ejemplo: Melilla Total = Hombres + Mujeres
fila_melilla <- which(df$Autonomia == "19 Melilla")
df$Total[fila_melilla] <- df$Hombres[fila_melilla] + df$Mujeres[fila_melilla]

# ------- Eliminar filas con NA -------
df <- na.omit(df)                        # elimina CUALQUIER fila con NA
df <- df[!is.na(df$Total), ]             # elimina filas con NA solo en Total
df <- df[complete.cases(df), ]           # igual que na.omit

# ------- Reemplazar NA con la media/mediana -------
df$Total[is.na(df$Total)] <- mean(df$Total, na.rm = TRUE)
df$Total[is.na(df$Total)] <- median(df$Total, na.rm = TRUE)
```

---

## 2. Modificar un valor concreto en una celda

**Este es el caso del examen: "arregla el valor de Melilla"**

```r
# ------- FORMA 1: por posición exacta [fila, columna] -------
df[19, 3] <- 86450          # fila 19, columna 3

# ------- FORMA 2: buscar la fila con which, columna por nombre -------
fila <- which(df$Autonomia == "19 Melilla")
df$Total[fila] <- 86450
# O equivalente:
df[fila, "Total"] <- 86450

# ------- FORMA 3: calcularlo y asignarlo en una línea -------
fila <- which(df$Autonomia == "19 Melilla")
df$Total[fila] <- sum(df[df$Autonomia == "19 Melilla" & df$Sexo != "Total", "Total"])
# ("la forma más elegante": calcular sumando hombres y mujeres)

# ------- FORMA 4: calcular de otro dataframe -------
# Si hombres y mujeres están en otro df (dfSexo)
hombres <- dfSexo$Total[dfSexo$Autonomia == "19 Melilla" & dfSexo$Sexo == "Hombres"]
mujeres <- dfSexo$Total[dfSexo$Autonomia == "19 Melilla" & dfSexo$Sexo == "Mujeres"]
fila <- which(df$Autonomia == "19 Melilla")
df$Total[fila] <- hombres + mujeres
```

---

## 3. Eliminar filas

```r
# ------- Por posición/índice -------
df <- df[-19, ]         # elimina fila 19
df <- df[-c(18, 19), ]  # elimina filas 18 y 19

# ------- Por condición -------
df <- df[df$Autonomia != "19 Melilla", ]
df <- df[!df$Autonomia %in% c("18 Ceuta", "19 Melilla"), ]

# ------- Con which() — más seguro si la posición puede variar -------
filas_borrar <- which(df$Autonomia %in% c("18 Ceuta", "19 Melilla"))
df <- df[-filas_borrar, ]

# ------- Con dplyr -------
library(dplyr)
df <- df %>% filter(!Autonomia %in% c("18 Ceuta", "19 Melilla"))
```

**TIP:** Después de borrar, R no renumera las filas. Si necesitas índices limpios:
```r
rownames(df) <- NULL   # resetea los índices de fila
```

---

## 4. Añadir una fila nueva (rbind)

```r
# ------- FORMA 1: crear una fila como dataframe y unir -------
nueva_fila <- data.frame(
  Autonomia = "Ceuta y Melilla",
  Total = 170000,
  stringsAsFactors = FALSE
)
df <- rbind(df, nueva_fila)

# ------- FORMA 2: crear con los mismos nombres de columna -------
# Importante: los nombres de columna deben coincidir EXACTAMENTE
nueva_fila <- data.frame(
  Autonomia = "Total Nacional",
  Total = sum(df$Total),
  stringsAsFactors = FALSE
)
df <- rbind(df, nueva_fila)

# ------- FORMA 3: añadir calculando sobre el propio df -------
total_nacional <- data.frame(
  Autonomia = "Total Nacional",
  Perdidas = sum(df$Perdidas, na.rm = TRUE)
)
df <- rbind(df, total_nacional)
```

**PROBLEMA CLÁSICO con rbind:** las columnas deben tener exactamente los mismos nombres y tipos.
```r
# Ver nombres de columnas antes de rbind
colnames(df)
colnames(nueva_fila)
# Deben ser idénticos
```

---

## 5. Fusionar/agrupar filas (el caso Ceuta y Melilla)

**Problema:** tienes "18 Ceuta" y "19 Melilla" como filas separadas, quieres una sola "Ceuta y Melilla" sumando sus valores.

```r
# ------- PASO 1: calcular la fila nueva -------
# Sacar los valores de Ceuta y Melilla
ceuta   <- df$Total[df$Autonomia == "18 Ceuta"]
melilla <- df$Total[df$Autonomia == "19 Melilla"]

nueva_fila <- data.frame(
  Autonomia = "Ceuta y Melilla",
  Total = ceuta + melilla,
  stringsAsFactors = FALSE
)

# ------- PASO 2: eliminar las filas originales -------
df <- df[!df$Autonomia %in% c("18 Ceuta", "19 Melilla"), ]

# ------- PASO 3: añadir la nueva fila -------
df <- rbind(df, nueva_fila)

# ------- FORMA ALTERNATIVA con aggregate (si tienes muchas filas a agrupar) -------
# Ejemplo: agrupar por Autonomia sumando Total
df_agrupado <- aggregate(Total ~ Autonomia, data = df, FUN = sum)
```

**FORMA ELEGANTE en una sola operación (más avanzado):**
```r
library(dplyr)
# Crear la fila Ceuta y Melilla
cymel <- df %>%
  filter(Autonomia %in% c("18 Ceuta", "19 Melilla")) %>%
  summarise(Autonomia = "Ceuta y Melilla", Total = sum(Total))

# Eliminar las originales y añadir la nueva
df <- df %>%
  filter(!Autonomia %in% c("18 Ceuta", "19 Melilla")) %>%
  rbind(cymel)
```

---

## 6. Calcular y añadir el Total Nacional

```r
# ------- FORMA 1: suma de toda la columna -------
total <- sum(df$Total, na.rm = TRUE)    # na.rm=TRUE ignora NAs
fila_total <- data.frame(Autonomia = "Total Nacional", Total = total)
df <- rbind(df, fila_total)

# ------- FORMA 2: en una línea -------
df <- rbind(df, data.frame(Autonomia = "Total Nacional", Total = sum(df$Total, na.rm = TRUE)))

# IMPORTANTE: calcular el total ANTES de añadir la fila de total
# (si lo calculas después de añadirla, se suma a sí misma)
```

---

## 7. Limpiar texto con `gsub()` y `sub()`

**Uso típico:** quitar el código numérico del nombre de autonomía ("01 Andalucía" → "Andalucía")

```r
# gsub(patrón, reemplazo, texto)  — reemplaza TODAS las ocurrencias
# sub(patrón, reemplazo, texto)   — reemplaza solo la PRIMERA ocurrencia

# ------- Quitar código numérico al inicio ("01 Andalucía" → "Andalucía") -------
gsub("^[0-9]+ ", "", "01 Andalucía")      # → "Andalucía"
gsub("^\\d{2} ", "", "01 Andalucía")      # → "Andalucía" (solo 2 dígitos)
gsub("^[0-9]+ ", "", df$Autonomia)        # aplicado a toda la columna

# ------- Quitar espacios extra -------
trimws("  Andalucía  ")        # quita espacios al inicio y al final
gsub("  +", " ", texto)       # reemplaza múltiples espacios por uno

# ------- Reemplazar parte de un texto -------
gsub("Total Nacional", "España", df$Autonomia)
gsub(" y ", "/", df$Autonomia)   # reemplaza " y " por "/"

# ------- Aplicar a toda la columna del dataframe -------
df$Autonomia <- gsub("^[0-9]+ ", "", df$Autonomia)
df$Autonomia <- trimws(df$Autonomia)

# ------- Quitar caracteres especiales -------
gsub("[^a-zA-ZáéíóúÁÉÍÓÚñÑ ]", "", df$Autonomia)  # solo letras y espacios

# ------- Extraer solo los números -------
gsub("[^0-9]", "", "01 Andalucía")  # → "01"
```

**Referencia de patrones regex básicos:**
| Patrón | Significa |
|---|---|
| `^` | Inicio de la cadena |
| `$` | Final de la cadena |
| `[0-9]` | Cualquier dígito |
| `\\d` | Cualquier dígito (equivalente) |
| `[0-9]+` | Uno o más dígitos |
| `\\s` | Espacio en blanco |
| `.` | Cualquier carácter |
| `.*` | Cualquier cosa (0 o más) |

---

## 8. Unir dos dataframes (merge / cbind / rbind)

### `merge()` — unir por columna clave (como JOIN en SQL)
```r
# ------- FORMA 1: inner join (solo filas que coinciden en ambos) -------
conjuntoDatos <- merge(datosAguaFiltrados, datosCensoFiltrados, by = "Autonomia")

# ------- FORMA 2: left join (todas las del primero, coincidan o no) -------
conjuntoDatos <- merge(datosAguaFiltrados, datosCensoFiltrados, by = "Autonomia", all.x = TRUE)

# ------- FORMA 3: full join (todas las filas de ambos) -------
conjuntoDatos <- merge(datosAguaFiltrados, datosCensoFiltrados, by = "Autonomia", all = TRUE)

# ------- FORMA 4: columnas clave con distinto nombre en cada df -------
conjuntoDatos <- merge(df1, df2, by.x = "Nombre_Autonomia", by.y = "Autonomia")
```

**TIP:** Después del merge, verifica con `nrow()` que tienes las filas que esperas. Un inner join puede "comerse" filas si los nombres no coinciden exactamente.

### `cbind()` — unir columnas (uno al lado del otro)
```r
# Solo si tienen el mismo número de filas Y en el mismo orden
conjuntoDatos <- cbind(datosAguaFiltrados, datosCensoFiltrados["Poblacion"])
```

### `rbind()` — apilar filas (uno encima del otro)
```r
# Solo si tienen las mismas columnas
df_completo <- rbind(df1, df2)
```

---

## 9. Añadir una columna nueva al dataframe

```r
# ------- FORMA 1: asignación directa -------
df$Nueva_Columna <- 0                           # columna de ceros
df$Nueva_Columna <- df$Col1 / df$Col2           # ratio entre columnas
df$Nueva_Columna <- df$Col1 / df$Col2 * 1000   # con escala

# ------- FORMA 2: con transform -------
df <- transform(df, Ratio = Perdidas / Poblacion * 1000)

# ------- FORMA 3: con dplyr mutate -------
df <- df %>% mutate(Ratio = Perdidas / Poblacion * 1000)

# ------- FORMA 4: columna basada en condición (if/else vectorizado) -------
df$Nivel <- ifelse(df$Total > 10000, "Alto", "Bajo")
df$Nivel <- ifelse(df$Total > 10000, "Alto",
             ifelse(df$Total > 5000, "Medio", "Bajo"))  # múltiples niveles
```

---

## 10. Convertir tipos dentro del dataframe

```r
# Una columna
df$Total <- as.integer(df$Total)
df$Total <- as.numeric(df$Total)
df$Nombre <- as.character(df$Nombre)
df$Tipo <- as.factor(df$Tipo)

# Varias columnas a la vez
cols <- c("Total", "Hombres", "Mujeres")
df[cols] <- lapply(df[cols], as.integer)

# Columna con puntos de miles
df$Total <- as.integer(gsub("\\.", "", df$Total))
```

---

## 11. Resetear índices / ordenar

```r
# Resetear índices (después de eliminar filas, los índices quedan huecos)
rownames(df) <- NULL

# Ordenar df por una columna
df <- df[order(df$Autonomia), ]                        # alfabético A→Z
df <- df[order(df$Total), ]                            # numérico ascendente
df <- df[order(df$Total, decreasing = TRUE), ]         # numérico descendente
df <- df[order(df$Col1, df$Col2), ]                    # por dos columnas

# Con dplyr
df <- df %>% arrange(Autonomia)
df <- df %>% arrange(desc(Total))
```

---

## 12. Problemas típicos del examen y sus soluciones

| Situación | Qué hacer |
|---|---|
| "Calcula el total de Melilla (falta el dato)" | Buscar filas de Hombres y Mujeres, sumar, asignar con `which()` |
| "Agrupa Ceuta y Melilla en uno" | Calcular suma → crear fila nueva → borrar las originales → `rbind` |
| "Añade el Total Nacional" | `sum()` de la columna → `rbind` con nueva fila |
| "Los nombres no coinciden entre dfs" | `gsub()` para limpiar códigos, `trimws()` para espacios |
| "rbind da error" | Los nombres de columna no coinciden — verificar con `colnames()` |
| "merge devuelve 0 filas" | Los valores clave no coinciden — comparar con `unique()` en ambos |
| "NA en columna numérica" | Usar `na.rm = TRUE` en sumas, o reparar antes con `which(is.na(...))` |
