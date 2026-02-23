# R — Funciones
> Ctrl+F para buscar. Todo lo que necesitas para el examen de funciones.

---

## ESQUEMA MENTAL para diseñar una función

1. ¿Qué **recibe** la función? (parámetros de entrada)
2. ¿Qué **devuelve**? (el `return()`)
3. ¿Es **autocontenida**? (el profesor lo pide: no llama a otras funciones tuyas)
4. ¿Qué pasa si el parámetro es inválido? (mínimo un `if` de comprobación)

---

## 1. Sintaxis básica de una función

```r
# Estructura mínima
mi_funcion <- function(param1, param2) {
  # cuerpo
  resultado <- param1 + param2
  return(resultado)
}

# Invocar
mi_funcion(3, 5)           # → 8
res <- mi_funcion(3, 5)    # guardar el resultado
```

### Con parámetros por defecto
```r
mi_funcion <- function(df, columna = "Total", top = 5) {
  # Si no se pasa columna, usa "Total"
  # Si no se pasa top, usa 5
  resultado <- head(df[order(df[[columna]], decreasing = TRUE), ], top)
  return(resultado)
}

mi_funcion(datos)                      # usa columna="Total", top=5
mi_funcion(datos, columna = "Precio")  # cambia columna
mi_funcion(datos, "Precio", 10)        # sin nombres
```

---

## 2. Acceder a columnas con nombre variable (¡MUY IMPORTANTE!)

Este es el error más común en el examen. Cuando el nombre de la columna viene como parámetro:

```r
# MAL — esto no funciona cuando "columna" viene de un parámetro
df$columna       # busca literalmente una columna llamada "columna"

# BIEN — usar doble corchete [[]]
df[[columna]]    # busca la columna cuyo nombre está en la variable "columna"

# Ejemplo completo
obtener_ipc <- function(df, grupo_consumo) {
  # grupo_consumo es un string como "04 Vivienda"
  df[, c("Autonomia", grupo_consumo)]    # con corchetes, en select
  # O:
  data.frame(Autonomia = df$Autonomia, Valor = df[[grupo_consumo]])
}
```

**REGLA:** `df$nombre` → solo cuando el nombre es literal. `df[[variable]]` → cuando el nombre viene de una variable.

---

## 3. Función para cargar datos (Ejercicio 1 del examen 2)

```r
cargar_ipc <- function() {
  library(readODS)

  ruta <- "C:/ruta/al/fichero/IPCOct24.ods"  # variable de ruta al inicio

  df <- read_ods(
    path = ruta,
    sheet = 1,
    range = "A7:S121",
    col_names = FALSE
  )

  # Poner nombres a las columnas
  colnames(df) <- c("Autonomia", "Grupo", "Indice", "VariacionMensual",
                    "VariacionAnual", "VariacionAnio")  # adaptar al enunciado

  return(df)
}

# Invocar y mostrar
datos <- cargar_ipc()
print(datos)
head(datos)
```

---

## 4. Función para filtrar por parámetro (Ejercicio 2 del examen 2)

**Caso típico:** dado el df completo, devolver un df con autonomías + IPC de un grupo de consumo.

```r
# FUNCIÓN AUTOCONTENIDA: no usa otras funciones propias, solo las de R base
ipc_por_grupo <- function(df, grupo_consumo) {

  # Filtrar solo las filas del grupo indicado
  df_filtrado <- df[df$Grupo == grupo_consumo, ]

  # Limpiar el nombre de la autonomía (quitar código numérico)
  df_filtrado$Autonomia <- gsub("^[0-9]+ ", "", df_filtrado$Autonomia)

  # Seleccionar solo las columnas que interesan
  resultado <- data.frame(
    Autonomia = df_filtrado$Autonomia,
    IPC = df_filtrado$Indice,
    stringsAsFactors = FALSE
  )

  return(resultado)
}

# Invocar
resultado <- ipc_por_grupo(datos, "04 Vivienda, agua, electricidad")
print(resultado)
```

---

## 5. Función para ranking (Ejercicio 3 del examen 2)

**Caso típico:** devolver un ranking de autonomías ordenadas por una variación.

```r
ranking_variacion <- function(df, grupo_consumo) {

  # Filtrar el grupo
  df_grupo <- df[df$Grupo == grupo_consumo, ]

  # Limpiar nombre de autonomía
  df_grupo$Autonomia <- gsub("^[0-9]+ ", "", df_grupo$Autonomia)

  # Ordenar por variación mensual (descendente = mayor subida primero)
  df_ordenado <- df_grupo[order(df_grupo$VariacionMensual, decreasing = TRUE), ]

  # Añadir columna de posición en el ranking
  df_ordenado$Ranking <- 1:nrow(df_ordenado)

  # Seleccionar columnas relevantes
  resultado <- data.frame(
    Ranking = df_ordenado$Ranking,
    Autonomia = df_ordenado$Autonomia,
    VariacionMensual = df_ordenado$VariacionMensual
  )

  return(resultado)
}

# Invocar
ranking <- ranking_variacion(datos, "04 Vivienda, agua, electricidad")
print(ranking)
```

---

## 6. Función con which.max / which.min (Ejercicio 4 del examen 2)

**Caso típico:** para cada autonomía, devolver el grupo con mayor variación de año.

```r
grupo_mayor_variacion <- function(df) {

  # Obtener lista de autonomías únicas
  autonomias <- unique(df$Autonomia)

  # Preparar dataframe resultado
  resultado <- data.frame(
    Autonomia = character(),
    GrupoMayor = character(),
    Variacion = numeric(),
    stringsAsFactors = FALSE
  )

  # Iterar por cada autonomía
  for (auto in autonomias) {

    # Filtrar filas de esa autonomía
    filas_auto <- df[df$Autonomia == auto, ]

    # Encontrar el índice del grupo con mayor variación anual
    idx_max <- which.max(filas_auto$VariacionAnio)

    # Crear la fila del resultado
    nueva_fila <- data.frame(
      Autonomia = auto,
      GrupoMayor = filas_auto$Grupo[idx_max],
      Variacion = filas_auto$VariacionAnio[idx_max],
      stringsAsFactors = FALSE
    )

    # Añadir al resultado
    resultado <- rbind(resultado, nueva_fila)
  }

  return(resultado)
}

# Invocar
resultado <- grupo_mayor_variacion(datos)
print(resultado)
```

---

## 7. Recorrer un dataframe con bucles

```r
# ------- FORMA 1: for sobre filas (el más directo) -------
for (i in 1:nrow(df)) {
  cat("Fila", i, ":", df$Autonomia[i], "-", df$Total[i], "\n")
}

# ------- FORMA 2: for sobre una columna de valores -------
for (val in df$Autonomia) {
  cat(val, "\n")
}

# ------- FORMA 3: apply — aplicar función a columnas -------
# apply(df, 1, función)  → por filas (1)
# apply(df, 2, función)  → por columnas (2)
totales_fila <- apply(df[, 3:10], 1, sum)     # suma de columnas 3-10 por fila
maximos_col  <- apply(df[, 3:10], 2, max)     # máximo de cada columna

# ------- FORMA 4: sapply / lapply — aplicar función y obtener vector/lista -------
# sapply devuelve vector o matriz; lapply devuelve lista
nombres_limpios <- sapply(df$Autonomia, function(x) gsub("^[0-9]+ ", "", x))
df$Autonomia <- sapply(df$Autonomia, function(x) gsub("^[0-9]+ ", "", x))
```

---

## 8. Construir un dataframe resultado vacío e ir llenándolo

```r
# ------- FORMA 1: iniciar vacío y hacer rbind en el bucle -------
resultado <- data.frame(
  Autonomia = character(),
  Valor = numeric(),
  stringsAsFactors = FALSE
)

for (auto in unique(df$Autonomia)) {
  filas <- df[df$Autonomia == auto, ]
  nueva <- data.frame(Autonomia = auto, Valor = max(filas$Total))
  resultado <- rbind(resultado, nueva)
}

# ------- FORMA 2: pre-alojar el dataframe (más eficiente) -------
n <- length(unique(df$Autonomia))
resultado <- data.frame(
  Autonomia = character(n),
  Valor = numeric(n),
  stringsAsFactors = FALSE
)

for (i in seq_along(unique(df$Autonomia))) {
  auto <- unique(df$Autonomia)[i]
  filas <- df[df$Autonomia == auto, ]
  resultado$Autonomia[i] <- auto
  resultado$Valor[i] <- max(filas$Total)
}
```

---

## 9. `which.max()` y `which.min()`

```r
which.max(c(3, 1, 7, 2))    # → 3  (posición del máximo)
which.min(c(3, 1, 7, 2))    # → 2  (posición del mínimo)

# Obtener el valor máximo
max(df$Total)                           # el valor
df$Total[which.max(df$Total)]           # mismo resultado
df$Autonomia[which.max(df$Total)]       # el nombre de la autonomía con el máximo

# Obtener la FILA completa del máximo
df[which.max(df$Total), ]

# Obtener el grupo con mayor variación por autonomía
idx <- which.max(filas_auto$VariacionAnio)
grupo_ganador <- filas_auto$Grupo[idx]
```

---

## 10. Plantilla base para el examen de funciones

Según las instrucciones del examen, el script tiene que tener esta estructura:

```r
# PIA - Examen de R
# Nombre Apellidos
# Fecha

# ---- Importaciones ----
library(readODS)
# library(dplyr)  # si lo usas

# ---- Ruta del fichero ----
ruta <- "C:/ruta/al/fichero/datos.ods"

# ====================================================
# EJERCICIO 1: Carga de datos
# ====================================================
# Descripción: esta función carga los datos del IPC desde el .ods
# Parámetros: ninguno (usa la variable global ruta)
# Devuelve: dataframe con los datos cargados

cargar_datos <- function() {
  df <- read_ods(path = ruta, sheet = 1, range = "A7:S50", col_names = FALSE)
  colnames(df) <- c("Autonomia", "Grupo", "Indice", "VarMensual", "VarAnual", "VarAnio")
  # Limpiamos tipos si hace falta
  df$Indice <- as.numeric(df$Indice)
  return(df)
}

# Invocar y mostrar
datos <- cargar_datos()
print(datos)

# ====================================================
# EJERCICIO 2: Filtrado por grupo de consumo
# ====================================================
# ...

funcion_ej2 <- function(df, grupo) {
  # ...
  return(resultado)
}

print(funcion_ej2(datos, "04 Vivienda"))
```
