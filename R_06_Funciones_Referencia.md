# R  Referencia de Funciones Comunes
> Todo lo que necesitas. Sin dplyr. Cada función explicada con cuándo y por qué usarla.

---

## TEXTO Y STRINGS

### gsub() / sub()
```r
# gsub(patrón, reemplazo, texto)
# Busca un patrón en un texto y lo reemplaza
# gsub  reemplaza TODAS las ocurrencias
# sub   reemplaza solo la PRIMERA

# CUÁNDO USARLO:
# - Quitar códigos numéricos al inicio: "01 Andalucía"  "Andalucía"
# - Quitar caracteres no deseados: puntos de miles, comas, símbolos
# - Reemplazar texto en una columna entera

gsub("^[0-9]+ ", "", "01 Andalucía")   #  "Andalucía"  (quita "01 " del inicio)
gsub("\\.", "", "1.234.567")            #  "1234567"    (quita todos los puntos)
gsub(",", ".", "3,14")                  #  "3.14"       (cambia coma por punto)
gsub("Total", "España", df$Autonomia)   # replace en toda la columna de un df
sub("a", "X", "banana")                #  "bXnana"     (solo reemplaza la primera 'a')
```

### trimws()
```r
# trimws(texto)
# Elimina espacios en blanco al inicio y al final de un texto
# CUÁNDO USARLO:
# - Antes de comparar con == (si hay espacios ocultos, la comparación falla)
# - Después de cargar datos del CSV/ODS que pueden traer espacios extra

trimws("  Andalucía  ")   #  "Andalucía"
trimws(df$Autonomia)      # aplicado a toda la columna
df$Autonomia <- trimws(df$Autonomia)  # guardarlo en el df
```

### grepl() / grep()
```r
# grepl(patrón, vector)  devuelve TRUE/FALSE para cada elemento
# grep(patrón, vector)   devuelve los ÍNDICES donde hay coincidencia

# CUÁNDO USAR grepl:
# - Filtrar filas que contienen cierto texto (no tienes el texto exacto)
# - Comprobar si una columna contiene una palabra

grepl("Ceuta", df$Autonomia)              # TRUE donde dice "Ceuta"
grepl("^18", df$Autonomia)               # TRUE donde empieza por "18"
grepl("Total$", df$Tipo)                 # TRUE donde termina en "Total"
grepl("ceuta", df$Autonomia, ignore.case=TRUE)  # no distingue mayúsculas

df[grepl("Ceuta", df$Autonomia), ]       # filtrar filas donde Autonomia contiene "Ceuta"

# CUÁNDO USAR grep (cuando necesitas el número de fila, no el TRUE/FALSE):
grep("Ceuta", df$Autonomia)              #  ej: c(18)  el número de la fila
fila <- grep("Ceuta", df$Autonomia)      # guardar en variable
df[fila, ]                               # acceder a esa fila
```

### paste() / paste0()
```r
# paste(a, b, c, sep=" ")  une texto con separador (defecto: espacio)
# paste0(a, b, c)          une texto SIN separador entre elementos

# CUÁNDO USARLO:
# - Construir mensajes para cat()
# - Combinar texto y variables en strings
# - Crear nombres dinámicos de columnas

paste("Autonomía:", "Madrid")            #  "Autonomía: Madrid"
paste("Anno", 2020)                      #  "Anno 2020"
paste0("Anno", 2020)                     #  "Anno2020" (sin espacio)
paste0("Col_", c(1, 2, 3))              #  c("Col_1", "Col_2", "Col_3")
paste(c("a","b","c"), collapse="-")      #  "a-b-c" (une vector con separador)
```

### nchar() / substr() / strsplit()
```r
# nchar(texto)  número de caracteres
nchar("Andalucía")      #  9
nchar(df$Autonomia)     # longitud de cada valor de la columna

# substr(texto, inicio, fin)  extrae una parte del texto
substr("01 Andalucía", 1, 2)    #  "01"  (caracteres 1 y 2)
substr("01 Andalucía", 4, 15)   #  "Andalucía" (del 4 al final)

# strsplit(texto, separador)  divide el texto por el separador
# Devuelve una LISTA (cada elemento de la lista es un vector de partes)
strsplit("01 Andalucía", " ")           #  list(c("01", "Andalucía"))
strsplit("a,b,c", ",")                  #  list(c("a", "b", "c"))

# Para acceder al resultado de strsplit:
partes <- strsplit("01 Andalucía", " ")[[1]]  # [[1]] accede al primer elemento de la lista
partes[1]   #  "01"
partes[2]   #  "Andalucía"
```

### toupper() / tolower()
```r
# toupper  todo a mayúsculas, tolower  todo a minúsculas
toupper("andalucía")     #  "ANDALUCÍA"
tolower("ANDALUCÍA")     #  "andalucía"
df$Autonomia <- tolower(df$Autonomia)  # normalizar toda la columna
```

---

## VECTORES Y CONDICIONES LÓGICAS

### which()
```r
# which(condición)  devuelve los ÍNDICES donde la condición es TRUE
# CUÁNDO USARLO:
# - Encontrar la posición de una fila para luego modificarla
# - Obtener el número de fila de un valor específico

which(df$Autonomia == "19 Melilla")     #  ej: c(19)
which(df$Total > 5000)                  #  índices de todas las filas con Total > 5000
which(is.na(df$Total))                  #  índices de filas con NA en Total
which.max(df$Total)                     #  índice del MÁXIMO (una sola posición)
which.min(df$Total)                     #  índice del MÍNIMO (una sola posición)

# Usar which para modificar una celda concreta
fila <- which(df$Autonomia == "19 Melilla")
df$Total[fila] <- 86450                 # asignar valor a esa fila
```

### %in%
```r
# valor %in% vector  TRUE si el valor está dentro del vector
# CUÁNDO USARLO:
# - Filtrar por múltiples valores sin escribir varios == unidos con |

"Madrid" %in% c("Madrid", "Cataluña", "Ceuta")     #  TRUE
"Valencia" %in% c("Madrid", "Cataluña", "Ceuta")   #  FALSE

df[df$Autonomia %in% c("Ceuta", "Melilla"), ]       # filas de Ceuta o Melilla
df[!df$Autonomia %in% c("Ceuta", "Melilla"), ]      # todo EXCEPTO Ceuta y Melilla
```

### any() / all()
```r
# any(condición)  TRUE si AL MENOS uno cumple la condición
# all(condición)  TRUE si TODOS cumplen la condición

any(is.na(df$Total))       # ¿hay algún NA en Total? TRUE o FALSE
all(df$Total > 0)          # ¿todos los valores de Total son positivos?
any(df$Autonomia == "19 Melilla")  # ¿existe alguna fila con ese valor?
```

### is.na() / complete.cases()
```r
# is.na(x)  TRUE donde hay NA
# !is.na(x)  TRUE donde NO hay NA

is.na(df$Total)             # vector T/F: TRUE donde Total es NA
!is.na(df$Total)            # vector T/F: TRUE donde Total NO es NA
df[!is.na(df$Total), ]      # filas donde Total no es NA

complete.cases(df)           # TRUE para las filas que NO tienen ningún NA en ninguna columna
df[complete.cases(df), ]     # solo las filas completas (sin ningún NA)
```

### unique() / duplicated() / table()
```r
# unique(vector)  valores únicos (sin repetidos)
unique(df$Autonomia)          # lista de autonomías sin repetir
length(unique(df$Autonomia))  # cuántas autonomías distintas hay

# duplicated(vector)  TRUE para las filas que son duplicados
duplicated(df$Autonomia)      # TRUE en las filas que repiten un valor anterior
df[!duplicated(df$Autonomia), ] # quitar filas duplicadas por Autonomia

# table(vector)  cuenta cuántas veces aparece cada valor
table(df$Grupo)               # cuántas filas hay de cada Grupo
table(df$Autonomia)           # cuántas filas hay por autonomía
```

---

## FAMILIA apply  ITERAR SIN FOR

### apply()
```r
# apply(df, MARGEN, FUN)
# MARGEN=1  aplica FUN a cada FILA
# MARGEN=2  aplica FUN a cada COLUMNA
# FUN = función a aplicar (sum, mean, max, min, etc.)

# CUÁNDO USARLO:
# - Calcular algo sobre varias columnas de cada fila (por ejemplo: suma de años)
# - No quieres un for explícito

apply(df[, 3:10], 1, sum)   # suma de las columnas 3-10 para CADA FILA  vector
apply(df[, 3:10], 2, max)   # máximo de CADA COLUMNA  vector
apply(df[, 3:10], 1, mean)  # media de las columnas 3-10 para cada fila
```

### sapply()
```r
# sapply(vector_o_lista, FUN)  aplica FUN a cada elemento, devuelve VECTOR o MATRIZ
# CUÁNDO USARLO:
# - Aplicar una transformación a cada valor de un vector o columna
# - Cuando quieres el resultado como vector directamente

sapply(df$Autonomia, nchar)
# Para cada valor de df$Autonomia, calcula cuántos caracteres tiene  vector numérico

sapply(df$Autonomia, function(x) gsub("^[0-9]+ ", "", x))
# Para cada valor, aplica la función anónima que quita el código numérico
# function(x) define una función anónima (sin nombre) donde x es cada elemento

df$Autonomia <- sapply(df$Autonomia, toupper)
# Convierte todos los valores de la columna a mayúsculas
```

### lapply()
```r
# lapply(lista, FUN)  aplica FUN a cada elemento, devuelve LISTA
# CUÁNDO USARLO:
# - Cuando quieres el resultado como lista (o para operaciones sobre df)
# - Para convertir tipos de varias columnas a la vez

cols <- c("Total", "Hombres", "Mujeres")
df[cols] <- lapply(df[cols], as.integer)
# Convierte las tres columnas a integer a la vez
# lapply devuelve lista  se asigna como dataframe con df[cols] <-

lapply(df, class)    # clase (tipo) de cada columna del df  lista
```

---

## DATAFRAME  OPERACIONES ESTRUCTURALES

### order()
```r
# order(vector)  índices para reordenar en orden ascendente
# CUÁNDO USARLO:
# - Ordenar un dataframe por una columna

df[order(df$Total), ]                      # ascendente
df[order(df$Total, decreasing = TRUE), ]   # descendente
df[order(df$Col1, df$Col2), ]              # primero Col1, luego Col2 como desempate
```

### aggregate()
```r
# aggregate(columna ~ grupo, data=df, FUN=función)
# CUÁNDO USARLO:
# - Calcular suma/media/max por grupo (como GROUP BY de SQL)
# - Resumir un df que tiene varias filas por comunidad

aggregate(Total ~ Autonomia, data = df, FUN = sum)   # suma de Total por autonomía
aggregate(Total ~ Grupo, data = df, FUN = mean)       # media de Total por grupo
aggregate(cbind(H, M) ~ Autonomia, data = df, FUN = sum) # dos columnas a la vez
```

### match()
```r
# match(vector_a, vector_b)  para cada elemento de vector_a, su posición en vector_b
# CUÁNDO USARLO:
# - Reordenar un df para que siga el orden de otro
# - Alinear dos df que tienen las mismas filas pero en distinto orden

posiciones <- match(df1$Autonomia, df2$Autonomia)
# posiciones[i] = posición en df2 donde está df1$Autonomia[i]
df2_reordenado <- df2[posiciones, ]
# Reordena df2 para que siga el mismo orden que df1
```

### do.call() + rbind
```r
# do.call(FUN, lista)  llama a FUN con los elementos de la lista como argumentos
# CUÁNDO USARLO:
# - Unir una lista de dataframes en uno solo con rbind

lista_dfs <- list(df1, df2, df3)        # lista de dataframes
df_unido <- do.call(rbind, lista_dfs)   # equivale a rbind(df1, df2, df3)
# Útil cuando tienes muchos df que unir y no quieres escribir todos los nombres
```

---

## TIPOS Y CONVERSIÓN

```r
class(x)              # tipo de la variable: "character", "integer", "numeric", "logical"
is.numeric(x)         # TRUE si es número
is.character(x)       # TRUE si es texto
is.integer(x)         # TRUE si es entero
is.na(x)              # TRUE si es NA

as.integer(x)         # convierte a entero (trunca decimales: 3.9  3)
as.numeric(x)         # convierte a número con decimales
as.character(x)       # convierte a texto
as.logical(x)         # convierte a TRUE/FALSE (0FALSE, restoTRUE)
```

---

## SECUENCIAS Y VECTORES

```r
1:10                        #  c(1, 2, 3, ..., 10)  secuencia de 1 a 10
seq(1, 10)                  # igual que 1:10
seq(1, 10, by = 2)          #  c(1, 3, 5, 7, 9)  paso de 2 en 2
seq(0, 1, length.out = 5)   #  c(0, 0.25, 0.5, 0.75, 1)  5 valores entre 0 y 1
seq_along(df$Autonomia)     # equivale a 1:length(df$Autonomia)  índices del vector
seq_len(10)                 # equivale a 1:10

rep(0, 5)                   #  c(0, 0, 0, 0, 0)  repite 0 cinco veces
rep(c(1,2), 3)              #  c(1,2,1,2,1,2)  repite el vector 3 veces
rep(c(1,2), each = 3)       #  c(1,1,1,2,2,2)  repite cada elemento 3 veces

c(1, 2, 3)                  # crear un vector con esos valores
vector <- c(vector, 99)     # añadir el valor 99 al final de un vector existente
```

---

## CONDICIONALES DENTRO DEL CÓDIGO

### ifelse()  condicional vectorizado
```r
# ifelse(condición, valor_si_TRUE, valor_si_FALSE)
# Opera sobre todo un vector a la vez (más eficiente que un for)

ifelse(df$Total > 0, "Positivo", "Cero o negativo")
# Para cada fila: si Total > 0 devuelve "Positivo", si no "Cero o negativo"

df$Categoria <- ifelse(df$Total > 10000, "Alto", "Bajo")
# Añade columna Categoria según si Total supera 10000

# Anidado para más de dos categorías
df$Nivel <- ifelse(df$Total > 50000, "Alto",
              ifelse(df$Total > 10000, "Medio", "Bajo"))
```

### if / else  condicional normal (para una sola condición, no vectorizada)
```r
# if / else normal  para UNA condición, no para todo el vector
if (nrow(df) == 0) {
  cat("El dataframe está vacío\n")
} else {
  cat("El dataframe tiene", nrow(df), "filas\n")
}

# Dentro de una función:
mi_funcion <- function(df, col) {
  if (!col %in% colnames(df)) {
    cat("La columna", col, "no existe en el df\n")
    return(NULL)           # return(NULL) termina la función y devuelve NULL
  }
  return(df[[col]])
}
```

---

## IMPRIMIR Y FORMATEAR

```r
print(df)                         # muestra el objeto en consola
cat("Texto y", variable, "\n")    # imprime texto mezclado con variables, \n = nueva línea
sprintf("%.2f", 3.14159)          # "3.14"  formatea con 2 decimales
sprintf("%.0f%%", 87.6)           # "88%"  sin decimales y con % literal
round(3.14159, 2)                 #  3.14  redondea a N decimales
floor(3.9)                        #  3  redondea hacia abajo
ceiling(3.1)                      #  4  redondea hacia arriba
abs(-5)                           #  5  valor absoluto
```
