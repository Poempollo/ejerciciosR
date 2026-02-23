# R — Ingesta de Datos
> Ctrl+F para buscar. Múltiples formas de hacer lo mismo. Sin relleno.

---

## 1. Establecer directorio de trabajo

```r
# Forma estándar — backslash doble o slash normal
setwd("C:/Users/usuario/Documents/datos")
setwd("C:\\Users\\usuario\\Documents\\datos")

# Verificar dónde estás
getwd()

# Ver qué ficheros hay en el directorio actual
list.files()
list.files(pattern = "\\.ods$")  # solo .ods
```

**TIP:** Si el .ods y el script están en la misma carpeta, `setwd` apunta a esa carpeta. El resto de rutas son relativas.

---

## 2. Cargar `.ods` con `readODS::read_ods()`

Primero instalar/cargar el paquete:
```r
# Instalar (solo la primera vez)
install.packages("readODS")

# Cargar
library(readODS)
```

### Parámetros clave de `read_ods()`

| Parámetro | Qué hace | Ejemplo |
|---|---|---|
| `path` | Ruta al fichero | `"agua.ods"` |
| `sheet` | Hoja (número o nombre) | `1` o `"Hoja1"` |
| `col_names` | ¿Primera fila es cabecera? | `TRUE` / `FALSE` |
| `range` | Rango de celdas a leer | `"A7:S121"` |
| `na` | Qué tratar como NA | `c("", "-", "NA")` |
| `skip` | Filas a saltar al inicio | `6` (salta 6 filas) |

### Variantes de carga

```r
# ------- VARIANTE 1: Con rango exacto (lo más habitual en el examen) -------
datosAgua <- read_ods(
  path = "agua.ods",
  sheet = 1,
  range = "A7:S121",   # filas 7 a 121, columnas A a S
  col_names = FALSE    # no cargar cabecera
)

# ------- VARIANTE 2: Saltando filas de cabecera con skip -------
datosAgua <- read_ods(
  path = "agua.ods",
  sheet = 1,
  skip = 6,            # salta las 6 primeras filas
  col_names = FALSE
)

# ------- VARIANTE 3: Con nombre de hoja -------
datosAgua <- read_ods(
  path = "agua.ods",
  sheet = "Datos",     # nombre exacto de la pestaña
  range = "A7:S121",
  col_names = FALSE
)

# ------- VARIANTE 4: Tratando celdas vacías como NA -------
datosAgua <- read_ods(
  path = "agua.ods",
  sheet = 1,
  range = "A7:S121",
  col_names = FALSE,
  na = c("", " ", "-", "N/A")  # todo esto se convertirá en NA
)
```

**DIFERENCIA `col_names` vs `skip`:**
- `col_names = FALSE` → la primera fila del rango NO se usa como nombre de columna
- `skip = N` → salta N filas **antes** de empezar a leer (sin rango definido)
- Con `range` lo más limpio es `col_names = FALSE`

---

## 3. Cargar `.csv`

```r
# ------- VARIANTE 1: CSV con coma como separador (inglés) -------
datosCenso <- read.csv("censo.csv", encoding = "UTF-8")

# ------- VARIANTE 2: CSV con punto y coma como separador (español/europeo) -------
datosCenso <- read.csv2("censo.csv", encoding = "UTF-8")

# ------- VARIANTE 3: read.table — control total -------
datosCenso <- read.table(
  "censo.csv",
  header = TRUE,       # primera fila es cabecera
  sep = ";",           # separador
  dec = ",",           # decimal con coma (España)
  encoding = "UTF-8",
  fill = TRUE,         # rellena filas incompletas
  quote = '"'
)

# ------- VARIANTE 4: readr (más moderno, más rápido) -------
library(readr)
datosCenso <- read_csv("censo.csv")   # coma
datosCenso <- read_csv2("censo.csv")  # punto y coma
```

**TIP:** Si ves caracteres raros (ñ, tildes), añade `encoding = "UTF-8"` o `encoding = "latin1"`.

---

## 4. Convertir tipos de columnas después de cargar

El problema típico: una columna es texto cuando debería ser número.

```r
# ------- Ver tipos actuales -------
str(datosCenso)       # estructura completa
class(datosCenso$Total)  # tipo de una columna concreta

# ------- Convertir a entero -------
datosCenso$Total <- as.integer(datosCenso$Total)

# ------- Convertir a número (con decimales) -------
datosCenso$Total <- as.numeric(datosCenso$Total)

# ------- Convertir a texto -------
datosCenso$Nombre <- as.character(datosCenso$Nombre)

# ------- PROBLEMA: columna tiene puntos de miles "1.234.567" -------
# Primero quitar los puntos, luego convertir
datosCenso$Total <- as.integer(gsub("\\.", "", datosCenso$Total))

# ------- PROBLEMA: columna tiene comas decimales "1.234,56" -------
datosCenso$Total <- as.numeric(gsub(",", ".", gsub("\\.", "", datosCenso$Total)))

# ------- Convertir varias columnas a la vez -------
cols_numericas <- c("Total", "Hombres", "Mujeres")
datosCenso[cols_numericas] <- lapply(datosCenso[cols_numericas], as.integer)
```

---

## 5. Poner nombres a las columnas manualmente

Cuando cargas sin cabecera, R pone nombres tipo `A`, `B`... o `V1`, `V2`...

```r
# Ver nombres actuales
colnames(datosAgua)
names(datosAgua)

# Poner nombres a todas las columnas
colnames(datosAgua) <- c("Autonomia", "Tipo", "2015", "2016", "2017", "2018", "2019", "2020")

# Cambiar solo una columna (por posición)
colnames(datosAgua)[1] <- "Autonomia"
colnames(datosAgua)[5] <- "Total_2020"

# Cambiar por nombre antiguo
colnames(datosAgua)[colnames(datosAgua) == "V1"] <- "Autonomia"
```

---

## 6. Verificar que la carga fue bien

```r
head(datosAgua)           # primeras 6 filas
tail(datosAgua)           # últimas 6 filas
head(datosAgua, 10)       # primeras 10 filas
dim(datosAgua)            # filas x columnas
nrow(datosAgua)           # número de filas
ncol(datosAgua)           # número de columnas
str(datosAgua)            # estructura y tipos
summary(datosAgua)        # estadísticas rápidas
View(datosAgua)           # abre visor visual en RStudio
colnames(datosAgua)       # nombres de columnas
```

---

## 7. Qué hacer si hay problemas al cargar

| Problema | Causa probable | Solución |
|---|---|---|
| `could not find function "read_ods"` | Paquete no cargado | `library(readODS)` |
| Tildes/ñ mal | Encoding incorrecto | Añadir `encoding = "UTF-8"` o `"latin1"` |
| Columnas desplazadas | Separador incorrecto | Cambiar `sep` |
| Todo en una sola columna | CSV con `;` pero usas `read.csv` | Usar `read.csv2` |
| NAs donde no debería | Celdas vacías o guiones | Añadir `na = c("", "-")` |
| Menos filas de las esperadas | `range` mal especificado | Verificar el rango en el .ods |
