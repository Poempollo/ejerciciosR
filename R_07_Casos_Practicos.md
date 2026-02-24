# R  Casos Prácticos: Situaciones Rarunas
> Problemas inventados con solución comentada. Para cuando te bloqueas.

---

## CASO 1: Seleccionar datos de una fila sabiendo que están N posiciones más abajo

**Situación:** El df tiene una estructura donde primero viene la fila del nombre de la región y, exactamente 5 filas más abajo, está el dato que te interesa. Quieres construir un resumen con [nombre_región, dato].

```r
# Supongamos este df:
#   Fila 1: "Andalucía"  | NA    nombre de región
#   Fila 2: "Tipo A"     | 100
#   Fila 3: "Tipo B"     | 200
#   Fila 4: "Tipo C"     | 300
#   Fila 5: "Tipo D"     | 400
#   Fila 6: "TOTAL"      | 1000  el dato que te interesa está 5 filas más abajo
#   Fila 7: "Cataluña"   | NA    siguiente región
#   ...

# PASO 1: encontrar qué filas tienen los nombres de región
# Imagina que los nombres de región no tienen valor numérico (NA en columna 2)
filas_region <- which(is.na(df$V2))
#  devuelve los índices de las filas donde V2 es NA: c(1, 7, 13, ...)

# PASO 2: para cada fila de región, el dato está exactamente 5 filas más abajo
resultado <- data.frame(
  Region = character(),
  Total  = numeric(),
  stringsAsFactors = FALSE
)

for (fila in filas_region) {
  nombre <- df$V1[fila]           # el nombre de la región está en la fila actual
  dato   <- df$V2[fila + 5]       # el dato está 5 filas más abajo
  # fila + 5  simplemente suma 5 al índice de fila actual

  nueva <- data.frame(Region = nombre, Total = dato, stringsAsFactors = FALSE)
  resultado <- rbind(resultado, nueva)
}

print(resultado)
```

**Variante: el dato está en la misma fila pero en la columna del año concreto**

```r
# El df tiene muchas columnas de años y quieres construir un resumen
# con el nombre de la región y el valor del año 2020
# El año 2020 está en la columna 15 (por ejemplo)

# Opción A: por posición de columna
resultado <- df[df$V2 == "Total", c(1, 15)]
# Fila: donde V2 == "Total", Columna: la 1 (nombre) y la 15 (dato 2020)
colnames(resultado) <- c("Region", "Dato_2020")

# Opción B: por nombre de columna (más seguro si sabes cómo se llama)
resultado <- df[df$V2 == "Total", c("V1", "Anno_2020")]
colnames(resultado) <- c("Region", "Dato_2020")
```

---

## CASO 2: El df tiene varias filas por región (una por sexo) y quieres solo el Total

**Situación:** El censo tiene 3 filas por comunidad (Total, Hombres, Mujeres). Solo quieres las filas de "Total".

```r
# Estructura del df:
#   Andalucía | Total    | 8500000
#   Andalucía | Hombres  | 4100000
#   Andalucía | Mujeres  | 4400000
#   Cataluña  | Total    | 7700000
#   ...

# SOLUCIÓN: filtrar solo las filas donde Sexo es "Total"
df_total <- df[df$Sexo == "Total", ]
# Simple como filtrar por condición, pero la clave es saber QUÉ filtrar

# Verificar que el resultado es correcto
nrow(df_total)          # debe ser nrow(df) / 3 si hay siempre 3 filas por región
unique(df_total$Sexo)   # debe devolver solo "Total"
```

---

## CASO 3: Hay un dato que falta (NA), calcularlo a partir de OTRAS filas del mismo df

**Situación:** La fila "Total" de Melilla tiene NA, pero en el mismo df tienes las filas de "Hombres" y "Mujeres" de Melilla. Calcula el Total y rellénalo.

```r
# El df tiene:
#   19 Melilla | Total    | NA        esto es lo que hay que rellenar
#   19 Melilla | Hombres  | 43000
#   19 Melilla | Mujeres  | 43450

# PASO 1: encontrar el valor de Hombres de Melilla
# Filtramos la fila donde Autonomia es "19 Melilla" Y Sexo es "Hombres"
hombres <- df$Total[df$Autonomia == "19 Melilla" & df$Sexo == "Hombres"]
# hombres es ahora un vector con un solo valor: 43000

# PASO 2: encontrar el valor de Mujeres
mujeres <- df$Total[df$Autonomia == "19 Melilla" & df$Sexo == "Mujeres"]

# PASO 3: encontrar la fila del NA (la fila de Total de Melilla)
fila_na <- which(df$Autonomia == "19 Melilla" & df$Sexo == "Total")
# fila_na es el número de fila, ej: 57

# PASO 4: asignar el valor calculado
df$Total[fila_na] <- hombres + mujeres
# Ya no hay NA en esa fila

# FORMA COMPACTA (todo en una línea, más elegante):
fila_na <- which(df$Autonomia == "19 Melilla" & df$Sexo == "Total")
df$Total[fila_na] <- sum(df$Total[df$Autonomia == "19 Melilla" & df$Sexo != "Total"])
# sum(...) suma todos los Totales de Melilla donde Sexo NO es "Total" (es decir, H+M)
# na.rm=TRUE no hace falta aquí porque solo H y M no tienen NA
```

---

## CASO 4: Construir un df resumen iterando y extrayendo un dato de cada grupo

**Situación:** Tienes un df con muchas filas por autonomía (una por cada categoría de producto o año). Para cada autonomía, quieres el valor de una categoría específica.

```r
# Estructura del df:
#   Andalucía | Alimentación | IPC = 2.3
#   Andalucía | Vivienda     | IPC = 1.5
#   Andalucía | Transporte   | IPC = 3.1
#   Cataluña  | Alimentación | IPC = 2.1
#   ...

# OBJETIVO: dataframe con [Autonomia, IPC_Vivienda] para cada comunidad

# OPCIÓN 1: filtrar directamente (la más simple)
df_vivienda <- df[df$Categoria == "Vivienda", c("Autonomia", "IPC")]
colnames(df_vivienda) <- c("Autonomia", "IPC_Vivienda")

# OPCIÓN 2: con bucle (cuando la lógica es más compleja)
autonomias <- unique(df$Autonomia)    # lista de autonomías sin repetir

resultado <- data.frame(
  Autonomia    = character(),
  IPC_Vivienda = numeric(),
  stringsAsFactors = FALSE
)

for (auto in autonomias) {
  filas_auto <- df[df$Autonomia == auto, ]
  # filas_auto tiene solo las filas de esa autonomía

  fila_vivienda <- filas_auto[filas_auto$Categoria == "Vivienda", ]
  # dentro de esas filas, buscamos la de Vivienda

  nueva <- data.frame(
    Autonomia    = auto,
    IPC_Vivienda = fila_vivienda$IPC,   # el IPC de Vivienda para esta autonomía
    stringsAsFactors = FALSE
  )

  resultado <- rbind(resultado, nueva)
}

print(resultado)
```

---

## CASO 5: Para cada autonomía, el grupo con el valor máximo (which.max por grupos)

**Situación:** El df tiene varias filas por autonomía (una por grupo de consumo). Para cada autonomía quieres saber QUÉ grupo tiene el IPC más alto.

```r
# Estructura del df:
#   Andalucía | Alimentación | 2.3
#   Andalucía | Vivienda     | 1.5
#   Andalucía | Transporte   | 3.1    máximo para Andalucía
#   Cataluña  | Alimentación | 2.1
#   Cataluña  | Vivienda     | 4.0    máximo para Cataluña

autonomias <- unique(df$Autonomia)

resultado <- data.frame(
  Autonomia   = character(),
  GrupoMaximo = character(),
  Valor       = numeric(),
  stringsAsFactors = FALSE
)

for (auto in autonomias) {
  filas_auto <- df[df$Autonomia == auto, ]
  # Todas las filas de esta autonomía

  idx_max <- which.max(filas_auto$IPC)
  # which.max devuelve LA POSICIÓN (dentro de filas_auto) donde IPC es máximo
  # Si IPC son c(2.3, 1.5, 3.1)  idx_max = 3 (posición del 3.1)

  grupo_max <- filas_auto$Categor[idx_max]
  # Accedemos a la columna Categoria EN la posición idx_max
  #  esto nos da el nombre del grupo con el máximo IPC

  valor_max <- filas_auto$IPC[idx_max]
  # El propio valor máximo

  resultado <- rbind(resultado, data.frame(
    Autonomia   = auto,
    GrupoMaximo = grupo_max,
    Valor       = valor_max,
    stringsAsFactors = FALSE
  ))
}

print(resultado)
```

---

## CASO 6: Dos df con las mismas filas pero en distinto orden  alinearlos antes de unir

**Situación:** Tienes df1 con autonomías en orden alfabético y df2 con autonomías en otro orden. Si haces cbind(), las filas no se corresponden.

```r
# SOLUCIÓN 1: usar merge()  lo alinea automáticamente por la columna clave
resultado <- merge(df1, df2, by = "Autonomia")
# merge busca la Autonomia de cada fila de df1 en df2 y las une correctamente
# No importa el orden, las empareja por valor

# SOLUCIÓN 2: ordenar ambos df por el mismo criterio antes de cbind
df1_ord <- df1[order(df1$Autonomia), ]    # ordenar df1 alfabéticamente
df2_ord <- df2[order(df2$Autonomia), ]    # ordenar df2 igual

rownames(df1_ord) <- NULL   # resetear índices
rownames(df2_ord) <- NULL

resultado <- cbind(df1_ord, df2_ord["Poblacion"])
# Ahora las filas se corresponden porque ambos están en el mismo orden

# SOLUCIÓN 3: match() para reordenar df2 según df1
posiciones <- match(df1$Autonomia, df2$Autonomia)
# match(a, b)  para cada elemento de a, en qué posición está en b
# posiciones[i] = posición en df2 de la autonomía que está en df1[i]

df2_alineado <- df2[posiciones, ]    # reordena df2 según el orden de df1
resultado <- cbind(df1, df2_alineado["Poblacion"])
```

---

## CASO 7: La columna tiene texto y número mezclados, separar en dos columnas

**Situación:** La columna Autonomia tiene valores como "01 Andalucía" y quieres separar el código ("01") del nombre ("Andalucía").

```r
# OPCIÓN 1: extraer el código con substr (si siempre tiene exactamente 2 dígitos)
df$Codigo <- substr(df$Autonomia, 1, 2)
# substr(texto, inicio, fin)  extrae los caracteres del 1 al 2: "01"

df$Nombre <- substr(df$Autonomia, 4, nchar(df$Autonomia))
# Del carácter 4 hasta el final: "Andalucía"
# nchar() devuelve la longitud del texto  así llega hasta el final sin importar el largo

# OPCIÓN 2: extraer con gsub
df$Codigo <- gsub("[^0-9]", "", df$Autonomia)   # quita todo lo que no sea número  "01"
df$Nombre <- gsub("^[0-9]+ ", "", df$Autonomia) # quita "01 " del inicio  "Andalucía"

# OPCIÓN 3: con strsplit (partir por el espacio)
partes <- strsplit(df$Autonomia, " ")
# Devuelve una LISTA: list(c("01","Andalucía"), c("02","Aragón"), ...)

df$Codigo <- sapply(partes, function(x) x[1])   # primer elemento de cada split
df$Nombre <- sapply(partes, function(x) x[2])   # segundo elemento de cada split
# sapply aplica la función a cada elemento de la lista y devuelve vector
# x[1] = primer elemento: "01", x[2] = segundo: "Andalucía"
```

---

## CASO 8: Construir un df con totales acumulados o sumas por año

**Situación:** Tienes un df con una columna por año (Anno2010, Anno2015, Anno2020). Quieres añadir una columna que sea la suma de todos los años para cada fila.

```r
# El df tiene:
#   Autonomia | Anno2010 | Anno2015 | Anno2020
#   Andalucía | 1000     | 1200     | 1500
#   Cataluña  | 900      | 1100     | 1400

# OPCIÓN 1: apply con suma por fila (MARGIN=1)
df$Total_Todas <- apply(df[, c("Anno2010", "Anno2015", "Anno2020")], 1, sum)
# apply(subdf, 1, sum)  para cada FILA, suma las columnas seleccionadas
# El resultado es un vector que se añade como nueva columna

# OPCIÓN 2: suma manual (más explícito)
df$Total_Todas <- df$Anno2010 + df$Anno2015 + df$Anno2020

# OPCIÓN 3: por rango de columnas (si sabes que las columnas 3 a 8 son años)
df$Total_Todas <- apply(df[, 3:8], 1, sum, na.rm = TRUE)
# na.rm=TRUE ignora NAs en la suma

# AÑADIR: la media de todos los años
df$Media_Annos <- apply(df[, c("Anno2010", "Anno2015", "Anno2020")], 1, mean, na.rm = TRUE)
df$Media_Annos <- round(df$Media_Annos, 2)   # redondear a 2 decimales
```

---

## CASO 9: Filtrar columnas que contienen un patrón en su nombre

**Situación:** Tu df tiene 20 columnas y las que te interesan se llaman "Anno2010", "Anno2015", "Anno2020"... Quieres seleccionar todas las columnas que empiezan por "Anno" sin escribirlas una a una.

```r
# grepl en los NOMBRES de columna (no en los valores)
cols_anno <- colnames(df)[grepl("^Anno", colnames(df))]
# grepl("^Anno", colnames(df))  TRUE para columnas que empiezan por "Anno"
# colnames(df)[...]  selecciona los nombres donde es TRUE
# cols_anno = c("Anno2010", "Anno2015", "Anno2020")

df_solo_annos <- df[, cols_anno]          # seleccionar solo esas columnas
df_con_nombre <- df[, c("Autonomia", cols_anno)]  # con la columna de nombres también

# Lo mismo pero con grep (devuelve índices)
idx_cols <- grep("^Anno", colnames(df))   # índices de columnas que empiezan por "Anno"
df_solo_annos <- df[, idx_cols]
```

---

## ERRORES COMUNES Y SU SOLUCIÓN

```r
# ERROR: "incorrect number of dimensions"
# Causa: intentas hacer df[fila, col] en un vector (no dataframe)
# Solución: usar df["columna"] en vez de df[, "columna"] para mantener estructura df

# ERROR: "undefined columns selected"  
# Causa: el nombre de columna que pones no existe
df$nombrequenoexi  # R devuelve NULL silenciosamente
df[, "nombrequenoexi"]  # R da error
# Solución: colnames(df) para ver los nombres exactos

# ERROR: resultado de merge tiene 0 filas
# Causa: los valores de la columna clave no coinciden exactamente (espacios, mayúsculas)
unique(df1$Autonomia)     # ver valores en df1
unique(df2$Autonomia)     # ver valores en df2
# Comparar y limpiar con trimws() y gsub() antes de hacer merge

# ERROR: rbind falla por "names do not match"
# Causa: los dos df tienen nombres de columna distintos
colnames(df)           # columnas del df existente
colnames(nueva_fila)   # columnas de la fila nueva  deben coincidir exactamente

# ERROR: which() devuelve integer(0) (vector vacío)
# Causa: ninguna fila cumple la condición, el valor no existe
which(df$Autonomia == "19 Melilla")  # si devuelve integer(0), es que no hay ninguna fila con ese valor
# Solución: verificar con unique(df$Autonomia) cómo están escritos los valores
```
