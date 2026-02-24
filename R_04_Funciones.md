# R  Diseñar Funciones
> Solo R base. Ctrl+F. Cada línea explicada.

---

## Qué es una función y para qué sirve

Una función es un bloque de código que puedes reutilizar con distintos datos.
En vez de repetir el mismo código para cada autonomía, lo metes en una función
y la llamas pasándole los parámetros que cambien.

```r
# Estructura básica
nombre_funcion <- function(parametro1, parametro2) {
  # código que hace algo con los parámetros
  resultado <- parametro1 + parametro2
  return(resultado)  # return() es lo que devuelve la función
}

# Llamar a la función
nombre_funcion(3, 5)         #  8
x <- nombre_funcion(3, 5)    # guardar el resultado en una variable
print(x)                     # mostrar el resultado
```

---

## 1. Acceder a columnas con nombre variable  EL ERROR MÁS COMÚN

**Cuando el nombre de la columna viene como parámetro, NO puedes usar df$columna.**

```r
# SITUACIÓN: tienes una función que recibe el nombre de la columna como parámetro
mi_funcion <- function(df, nombre_col) {

  df$nombre_col    # MAL: R busca literalmente una columna llamada "nombre_col"
                   # No entiende que nombre_col es una variable que contiene el nombre

  df[[nombre_col]] # BIEN: los dobles corchetes [[]] evalúan la variable
                   # Si nombre_col = "Total", esto es equivalente a df$Total

  df[, nombre_col]           # también funciona y devuelve un vector
  df[, nombre_col, drop=FALSE] # también funciona y devuelve un dataframe
}

# Ejemplo concreto
obtener_columna <- function(df, col) {
  valores <- df[[col]]    # col = "Total"  equivale a df$Total
  return(valores)
}
obtener_columna(datos, "Total")    # funciona
obtener_columna(datos, "Anno2020") # funciona con cualquier columna
```

**REGLA:** `df$nombre`  cuando el nombre es texto fijo. `df[[variable]]`  cuando el nombre viene de un parámetro.

---

## 2. Parámetros por defecto

```r
# Puedes dar valores por defecto a los parámetros
# Si la función se llama sin ese parámetro, usa el valor por defecto

ranking <- function(df, columna = "Total", top = 5) {
  # Si no se pasa columna, usa "Total"
  # Si no se pasa top, usa 5

  df_ordenado <- df[order(df[[columna]], decreasing = TRUE), ]
  # Ordena el df por la columna indicada, mayor primero

  return(head(df_ordenado, top))
  # Devuelve solo las primeras "top" filas
}

ranking(datos)                  # usa columna="Total", top=5
ranking(datos, "Perdidas")      # columna="Perdidas", top=5
ranking(datos, "Perdidas", 10)  # columna="Perdidas", top=10
ranking(datos, top = 3)         # columna="Total", top=3 (por nombre de parámetro)
```

---

## 3. Plantilla base de script para el examen

```r
# PIA - Examen de R
# Nombre Apellidos
# Fecha

# ---- Paquetes necesarios ----
library(readODS)

# ---- Ruta del fichero (siempre al inicio) ----
ruta <- "C:/ruta/al/fichero/datos.ods"

# ============================================================
# EJERCICIO 1: Carga de datos
# Descripción: carga el fichero y devuelve el dataframe limpio
# Parámetros: ninguno (usa la variable global ruta)
# Devuelve: dataframe con los datos del .ods
# ============================================================

cargar_datos <- function() {

  df <- read_ods(
    path = ruta,          # ruta definida arriba como variable global
    sheet = 1,            # primera hoja
    range = "A7:S121",    # rango exacto dado en el enunciado
    col_names = FALSE     # la primera fila del rango son datos, no cabecera
  )

  # Poner nombres a las columnas (adaptar según lo que haya en el .ods)
  colnames(df) <- c("Autonomia", "Grupo", "Indice", "VarMensual", "VarAnual", "VarAnio")

  # Convertir columnas numéricas si hace falta
  df$Indice    <- as.numeric(df$Indice)
  df$VarMensual <- as.numeric(df$VarMensual)

  return(df)  # devuelve el dataframe listo para usar
}

# Invocar y mostrar resultado
datos <- cargar_datos()
print(datos)
```

---

## 4. Función de filtrado  recibe el df y un parámetro de filtro

```r
# ============================================================
# EJERCICIO 2: Filtrar por grupo de consumo
# Descripción: devuelve autonomías con el IPC del grupo indicado
# Parámetros:
#   df          el dataframe cargado (el que devuelve cargar_datos)
#   grupo       texto con el nombre del grupo, ej: "04 Vivienda..."
# Devuelve: dataframe con columnas Autonomia e Indice
# ============================================================

ipc_por_grupo <- function(df, grupo) {

  # Filtrar las filas donde la columna Grupo vale exactamente el parámetro "grupo"
  df_filtrado <- df[df$Grupo == grupo, ]

  # Limpiar los nombres de autonomía: "01 Andalucía"  "Andalucía"
  # ^[0-9]+  = uno o más dígitos al inicio
  # (espacio) = espacio después del número
  # "" = reemplazar por nada (borrar el código)
  df_filtrado$Autonomia <- gsub("^[0-9]+ ", "", df_filtrado$Autonomia)

  # Construir el dataframe resultado con solo las columnas que interesan
  resultado <- data.frame(
    Autonomia = df_filtrado$Autonomia,  # nombres de autonomía ya limpios
    IPC       = df_filtrado$Indice,     # valor del IPC para ese grupo
    stringsAsFactors = FALSE            # evita que los textos se conviertan en factor
  )

  return(resultado)
}

# Invocar y mostrar
res <- ipc_por_grupo(datos, "04 Vivienda, agua, electricidad, gas y otros combustibles")
print(res)
```

---

## 5. Función de ranking

```r
# ============================================================
# EJERCICIO 3: Ranking de autonomías por variación mensual
# Descripción: ordena las autonomías de mayor a menor variación
# Parámetros:
#   df     dataframe completo
#   grupo  grupo de consumo a analizar
# Devuelve: df con columnas Posicion, Autonomia, Variacion
# ============================================================

ranking_variacion <- function(df, grupo) {

  # Filtrar solo las filas del grupo indicado
  df_grupo <- df[df$Grupo == grupo, ]

  # Limpiar nombres de autonomía
  df_grupo$Autonomia <- gsub("^[0-9]+ ", "", df_grupo$Autonomia)

  # Ordenar por VarMensual de mayor a menor (decreasing=TRUE)
  # order() devuelve los ÍNDICES en el orden deseado, no los valores
  df_ordenado <- df_grupo[order(df_grupo$VarMensual, decreasing = TRUE), ]

  # Resetear índices para que vayan del 1 al nrow
  rownames(df_ordenado) <- NULL

  # Añadir columna de posición en el ranking
  df_ordenado$Posicion <- 1:nrow(df_ordenado)
  # 1:nrow(df_ordenado) genera una secuencia 1, 2, 3, ... hasta el número de filas

  # Devolver solo las columnas relevantes
  resultado <- df_ordenado[, c("Posicion", "Autonomia", "VarMensual")]

  return(resultado)
}

print(ranking_variacion(datos, "04 Vivienda, agua, electricidad, gas y otros combustibles"))
```

---

## 6. Función que itera por grupos  for + which.max

```r
# ============================================================
# EJERCICIO 4: Para cada autonomía, el grupo con mayor variación anual
# Descripción: itera por autonomías y busca en cada una qué grupo sube más
# Parámetros:
#   df  dataframe completo con todas las autonomías y grupos
# Devuelve: df con Autonomia, GrupoLider y Variacion
# ============================================================

grupo_lider_por_autonomia <- function(df) {

  # Limpiar nombres antes de iterar
  df$Autonomia <- gsub("^[0-9]+ ", "", df$Autonomia)

  # Crear el dataframe resultado vacío con las columnas que queremos
  resultado <- data.frame(
    Autonomia  = character(),   # columna de texto vacía
    GrupoLider = character(),   # columna de texto vacía
    Variacion  = numeric(),     # columna numérica vacía
    stringsAsFactors = FALSE
  )

  # Obtener lista de autonomías únicas (sin repetidos)
  autonomias <- unique(df$Autonomia)
  # unique() elimina duplicados: si "Andalucía" aparece 10 veces, la devuelve una vez

  # Iterar por cada autonomía
  for (auto in autonomias) {
    # auto toma el valor de cada autonomía en cada vuelta del bucle

    # Filtrar solo las filas de esta autonomía
    filas_auto <- df[df$Autonomia == auto, ]
    # Ahora filas_auto tiene solo las filas de esa comunidad autónoma

    # Encontrar el índice del grupo con mayor VarAnio en esas filas
    idx <- which.max(filas_auto$VarAnio)
    # which.max() devuelve la POSICIÓN (dentro de filas_auto) del valor máximo

    # Construir la fila del resultado
    nueva_fila <- data.frame(
      Autonomia  = auto,                      # nombre de la autonomía
      GrupoLider = filas_auto$Grupo[idx],     # el grupo en la posición del máximo
      Variacion  = filas_auto$VarAnio[idx],   # el valor de variación máxima
      stringsAsFactors = FALSE
    )

    # Añadir la fila al dataframe resultado
    resultado <- rbind(resultado, nueva_fila)
  }

  return(resultado)
}

print(grupo_lider_por_autonomia(datos))
```

---

## 7. Iterar sobre filas  for con índice

```r
# FORMA 1: iterar por índice de fila (accedes a la fila por posición)
for (i in 1:nrow(df)) {
  # i toma los valores 1, 2, 3, ... hasta el número de filas
  valor <- df$Total[i]     # accede al Total de la fila i
  nombre <- df$Autonomia[i] # accede a la Autonomia de la fila i
  cat(i, "-", nombre, ":", valor, "\n")  # imprime en consola
}

# FORMA 2: iterar por valores de una columna
for (nombre in df$Autonomia) {
  # nombre toma el valor de cada celda de la columna Autonomia
  cat(nombre, "\n")
}
# Inconveniente: no tienes el índice i disponible, no puedes acceder a otras columnas

# FORMA 3: apply  aplica una función a cada fila sin for explícito
# apply(df, 1, FUN)  aplica FUN a cada fila (1=filas, 2=columnas)
sumas_por_fila <- apply(df[, 3:10], 1, sum)
# Suma las columnas 3 a 10 para cada fila
# Resultado: vector con una suma por fila

maximos_por_fila <- apply(df[, 3:10], 1, max)
# El valor máximo de las columnas 3-10 para cada fila
```
