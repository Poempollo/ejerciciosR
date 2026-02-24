# R  Ingesta de Datos
> Solo R base. Ctrl+F para buscar. Cada línea explicada.

---

## Qué significa "ingestar datos"
Cargar un fichero externo (Excel, CSV, ODS) y meterlo en un dataframe de R.
Un **dataframe** es una tabla: filas = registros, columnas = variables.

---

## 1. Directorio de trabajo  setwd()

```r
# setwd() le dice a R en qué carpeta buscar ficheros.
# Sin esto, R no encontrará tu .ods ni tu .csv aunque estén ahí.

setwd("C:/Users/javier/Desktop/datos")      # slash normal /
setwd("C:\\Users\\javier\\Desktop\\datos")  # o doble backslash \\

getwd()      # muestra el directorio actual  para verificar que está bien
list.files() # lista los ficheros que hay en ese directorio
```

---

## 2. Cargar un .ods con read_ods()

```r
install.packages("readODS")  # solo la PRIMERA vez que lo instalas en el PC
library(readODS)              # esto sí va en CADA script que lo use
```

### Parámetros de read_ods()

| Parámetro  | Para qué sirve                                          | Ejemplo           |
|------------|---------------------------------------------------------|-------------------|
| path       | Ruta al fichero                                         | "datos.ods"       |
| sheet      | Qué hoja leer (número o nombre)                         | 1 o "Hoja1"       |
| col_names  | ¿La primera fila del rango es cabecera?                 | TRUE / FALSE      |
| range      | Rango exacto de celdas                                  | "A7:S121"         |
| na         | Qué valores del fichero tratar como NA en R             | c("", "-", "N/A") |
| skip       | Cuántas filas saltar desde el inicio antes de leer      | 6                 |

### Variantes

```r
# VARIANTE 1  rango exacto, sin cabecera (la más habitual en el examen)
# range="A7:S121"   lee exactamente desde A7 hasta S121, no más
# col_names=FALSE  la primera fila del rango son datos, no nombres de columna
df <- read_ods(
  path = "datos.ods",
  sheet = 1,
  range = "A7:S121",
  col_names = FALSE
)

# VARIANTE 2  skip para saltar las filas de cabecera al inicio del fichero
# Cuando no sabes el rango exacto pero sabes cuántas filas de "título" hay arriba
# skip=6  salta filas 1-6 y empieza a leer desde la 7
df <- read_ods(
  path = "datos.ods",
  sheet = 1,
  skip = 6,
  col_names = TRUE  # ahora la fila 7 SÍ es la cabecera con nombres
)

# VARIANTE 3  por nombre de hoja en vez de número
# Útil si el .ods tiene varias pestañas y necesitas una concreta
df <- read_ods(
  path = "datos.ods",
  sheet = "DatosAgua",   # nombre exacto de la pestaña (sensible a mayúsculas)
  range = "A7:S121",
  col_names = FALSE
)

# VARIANTE 4  con tratamiento de celdas vacías y guiones
# na=c(...)  cualquier celda con esos valores se convierte en NA automáticamente
# Útil cuando el .ods usa "-" o espacios vacíos para indicar "sin dato"
df <- read_ods(
  path = "datos.ods",
  sheet = 1,
  range = "A7:S121",
  col_names = FALSE,
  na = c("", " ", "-", "N/A")
)
```

**Diferencia clave entre col_names y skip:**
- `col_names = FALSE`  la primera fila del RANGO son datos, no cabecera
- `skip = N`  salta N filas del fichero completo antes de empezar
- Si usas `range`, usa `col_names = FALSE`. Si no usas `range`, usa `skip`.

---

## 3. Cargar un .csv

```r
# VARIANTE 1  separador coma, formato inglés
# La mayoría de CSVs descargados de webs en inglés usan coma
df <- read.csv("censo.csv")

# VARIANTE 2  separador punto y coma, formato español
# El INE y la mayoría de organismos españoles usan ; como separador
# porque en España la coma ya se usa como separador decimal
df <- read.csv2("censo.csv")

# VARIANTE 3  read.table para control total
# Cuando el fichero tiene algo raro: separador inusual, decimal con coma...
df <- read.table(
  "censo.csv",
  header = TRUE,           # TRUE = primera fila = nombres de columna
  sep = ";",               # separador de columnas es punto y coma
  dec = ",",               # separador decimal es coma (España)
  fileEncoding = "UTF-8",  # para que tildes y ñ se lean bien
  fill = TRUE              # si alguna fila tiene menos columnas, rellena con NA
)
```

**Cómo saber qué variante usar:**
Abre el CSV en el Bloc de Notas:
- Si los valores están separados por `,`  `read.csv`
- Si por `;`  `read.csv2`
- Si aparecen caracteres raros (tildes mal)  añade `fileEncoding = "latin1"` o `"UTF-8"`

---

## 4. Poner nombres a las columnas

Cuando cargas con `col_names = FALSE`, R pone nombres automáticos (`V1`, `V2`...).
Hay que cambiarlos para poder referenciar las columnas por nombre.

```r
colnames(df)       # ver los nombres actuales de todas las columnas
names(df)          # exactamente igual, otra forma de hacer lo mismo

# Cambiar TODOS los nombres de golpe (el orden es izquierda a derecha)
colnames(df) <- c("Autonomia", "Tipo", "Anno2018", "Anno2019", "Anno2020")

# Cambiar una sola columna  por posición
colnames(df)[1] <- "Autonomia"  # la columna 1 pasa a llamarse "Autonomia"
colnames(df)[3] <- "Anno2020"   # la columna 3 pasa a llamarse "Anno2020"

# Cambiar una columna  buscando por su nombre actual
# Útil cuando no sabes en qué posición está pero sí cómo se llama
colnames(df)[colnames(df) == "V3"] <- "Anno2020"
# Lee como: "busca la columna cuyo nombre actual es V3 y cámbialo a Anno2020"
```

---

## 5. Convertir tipos de columnas

Después de cargar, los números a veces se leen como texto (character). Hay que convertirlos.

```r
str(df)           # muestra el tipo de CADA columna: int, chr, num...
class(df$Total)   # tipo de una columna concreta: "character", "integer"...

# Convertir a entero (sin decimales: 1, 2, 1000)
df$Total <- as.integer(df$Total)

# Convertir a número con decimales (1.5, 3.14)
df$Total <- as.numeric(df$Total)

# Convertir a texto
df$Nombre <- as.character(df$Nombre)

# PROBLEMA: columna tiene puntos de miles  "1.234.567"
# R lee el punto como separador decimal, así que no puede convertir directamente
# Solución: primero quitar los puntos, luego convertir
df$Total <- as.integer(gsub("\\.", "", df$Total))
# gsub("\\.", "", x)  busca todos los puntos y los reemplaza por nada (los borra)
# \\.  el . en regex significa "cualquier caracter", así que hay que escaparlo con \\

# PROBLEMA: columna tiene coma decimal  "1.234,56"
# Quitar puntos de miles y cambiar coma decimal por punto
df$Total <- as.numeric(
  gsub(",", ".",          # PASO 2: cambia la coma decimal por punto
    gsub("\\.", "",       # PASO 1: borra los puntos de miles
      df$Total
    )
  )
)

# Convertir VARIAS columnas a la vez con lapply
cols <- c("Total", "Hombres", "Mujeres")  # columnas que quieres convertir
df[cols] <- lapply(df[cols], as.integer)  # aplica as.integer a cada una
# lapply(lista, función)  aplica la función a cada elemento de la lista
```

---

## 6. Verificar que la carga fue bien  siempre hacer esto

```r
head(df)        # primeras 6 filas  ver si los datos tienen buen aspecto
tail(df)        # últimas 6 filas  ver si el pie está bien cargado o da basura
dim(df)         # c(nº filas, nº columnas)  verificar dimensiones
nrow(df)        # solo el número de filas
ncol(df)        # solo el número de columnas
str(df)         # estructura: nombres, tipos y primeros valores de cada columna
summary(df)     # estadísticas por columna (media, min, max, NAs...)
colnames(df)    # solo los nombres de las columnas
```

---

## 7. Problemas frecuentes al cargar

| Problema                            | Por qué pasa                         | Solución                                |
|-------------------------------------|--------------------------------------|-----------------------------------------|
| could not find function "read_ods"  | Paquete no cargado                   | library(readODS) antes de usarlo        |
| Tildes y ñ salen raras              | Encoding incorrecto                  | fileEncoding = "UTF-8" o "latin1"       |
| Todo en una sola columna            | CSV con ; pero usas read.csv         | Usar read.csv2                          |
| Menos filas de las esperadas        | El range está mal                    | Verificar el rango abriendo el .ods     |
| Columnas V1, V2, V3...              | Cargaste con col_names=FALSE         | Asignar nombres con colnames(df) <-     |
| Sumas dan NA en vez de número       | La columna es texto, no número       | as.numeric() o as.integer()             |
