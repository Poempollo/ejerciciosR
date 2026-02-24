# R  Filtrado y Selección de Datos
> Solo R base. Ctrl+F para buscar. Cada línea explicada.

---

## Los corchetes []  cómo funcionan

```r
# La estructura básica para acceder a un dataframe es:
df[filas, columnas]
# - Si dejas filas vacío  todas las filas
# - Si dejas columnas vacío  todas las columnas
# - Puedes usar números, nombres o condiciones TRUE/FALSE

df[3, 2]           # fila 3, columna 2  devuelve UN valor
df[3, ]            # fila 3, TODAS las columnas  devuelve una fila entera
df[, 2]            # TODAS las filas, columna 2  devuelve una columna entera
df[3, "Total"]     # fila 3, columna llamada "Total"
df["Total"]        # columna llamada "Total"  sigue siendo dataframe
df[, "Total"]      # columna llamada "Total"  se convierte en vector
```

**Diferencia importante:**
- `df["Total"]`  devuelve un **dataframe** de 1 columna
- `df[, "Total"]`  devuelve un **vector** (se pierde la estructura de dataframe)
- Para la mayoría de operaciones de filtrado, quieres el resultado como dataframe

---

## 1. Filtrar filas con condiciones

### Forma básica con corchetes []

```r
# SINTAXIS: df[condición, ]
# La condición genera un vector de TRUE/FALSE, R devuelve solo las filas TRUE

# --- Una condición sobre una columna ---
df[df$Tipo == "2. Volumen no registrada", ]
# Lee: "dame las filas donde la columna Tipo vale exactamente ese texto"

df[df$Anno == 2020, ]
# Lee: "dame las filas donde Anno es 2020" (número, sin comillas)

df[df$Total > 1000, ]
# Lee: "dame las filas donde Total es mayor que 1000"

# --- Condición negativa (lo contrario) ---
df[df$Sexo != "Total", ]           # donde Sexo NO es igual a "Total"
df[df$Total >= 0, ]                # donde Total es mayor o igual a 0

# --- Dos condiciones AND (las dos deben cumplirse) ---
df[df$Tipo == "Perdidas" & df$Anno == 2020, ]
# El & significa "Y": solo devuelve filas donde AMBAS condiciones son TRUE

# --- Dos condiciones OR (basta que una se cumpla) ---
df[df$Autonomia == "Ceuta" | df$Autonomia == "Melilla", ]
# El | significa "O": devuelve filas donde AL MENOS UNA condición es TRUE

# --- Condición con lista de valores (%in%) ---
df[df$Autonomia %in% c("Ceuta", "Melilla", "Madrid"), ]
# %in% comprueba si el valor está dentro del vector c(...)
# Equivalente a múltiples == con | pero mucho más limpio

# --- Excluir valores de una lista ---
df[!df$Autonomia %in% c("Ceuta", "Melilla"), ]
# El ! invierte el resultado: devuelve las filas donde Autonomia NO está en esa lista
```

### Con subset()  más legible para condiciones largas

```r
# SINTAXIS: subset(df, condición)
# O con selección de columnas: subset(df, condición, select = c(col1, col2))

subset(df, Tipo == "2. Volumen no registrada")
# Igual que df[df$Tipo == "..."] pero sin repetir "df$"

subset(df, Sexo == "Total" & Anno == 2020)
# Condición múltiple: igual que con &, pero más legible

subset(df, Tipo == "Perdidas", select = c(Autonomia, Total))
# Filtra filas Y selecciona solo las columnas Autonomia y Total a la vez

subset(df, select = -c(Codigo, Notas))
# Sin condición de fila: selecciona todas las filas pero EXCLUYE esas columnas
```

---

## 2. Seleccionar columnas

```r
# --- Por nombre ---
df[, c("Autonomia", "Total")]       # dos columnas  dataframe
df[, "Total"]                       # una columna  vector (se pierde estructura df)
df[, "Total", drop = FALSE]         # una columna  sigue siendo dataframe
df["Total"]                         # una columna  sigue siendo dataframe

# --- Por posición ---
df[, 1]           # primera columna
df[, c(1, 5)]     # columnas 1 y 5
df[, 2:8]         # columnas desde la 2 hasta la 8

# --- Excluir columnas por posición ---
df[, -1]          # todo menos la primera columna
df[, -c(1, 2)]    # todo menos las columnas 1 y 2
```

---

## 3. Filtrar filas Y seleccionar columnas de una vez

```r
# Con corchetes: [condición de fila, selección de columna]
resultado <- df[df$Tipo == "Perdidas", c("Autonomia", "Total")]
# Fila: donde Tipo es "Perdidas"
# Columna: solo Autonomia y Total

# Con subset  todo en uno, más legible
resultado <- subset(df, Tipo == "Perdidas", select = c(Autonomia, Total))
# Mismo resultado que arriba, distinta sintaxis

# Con condición múltiple y selección de columna
resultado <- df[df$Sexo == "Total" & df$Anno == 2020, c("Autonomia", "Total")]
```

---

## 4. Filtrar por posición de fila (por número)

```r
df[1, ]            # primera fila
df[c(1, 3, 5), ]  # filas 1, 3 y 5 concretamente
df[1:10, ]         # filas de la 1 a la 10
df[-1, ]           # todo el df menos la primera fila
df[-c(1, 2), ]     # todo el df menos las filas 1 y 2
df[nrow(df), ]     # última fila (nrow(df) devuelve el número de filas)
```

---

## 5. which()  encontrar la POSICIÓN de las filas que cumplen una condición

```r
# which(condición)  devuelve los ÍNDICES (números de fila) donde es TRUE
# Muy útil para luego modificar o acceder a esas filas exactas

which(df$Autonomia == "18 Ceuta")
#  devuelve ej. c(18) si la fila 18 tiene "18 Ceuta"

which(df$Total > 5000)
#  devuelve los índices de todas las filas donde Total supera 5000

which(is.na(df$Total))
#  devuelve los índices de todas las filas donde Total es NA

# Una vez tienes el índice, accedes a la fila así:
fila <- which(df$Autonomia == "18 Ceuta")  # fila = 18
df[fila, ]              # toda la fila
df[fila, "Total"]       # solo el valor de la columna Total en esa fila
df$Total[fila]          # exactamente igual, otra sintaxis
```

---

## 6. grepl() y grep()  buscar texto dentro de una columna

```r
# grepl(patrón, vector)  devuelve TRUE/FALSE para cada elemento
# Útil para filtrar por texto PARCIAL (no tienes que escribir el valor exacto)

grepl("Ceuta", df$Autonomia)
#  TRUE en las filas donde Autonomia contiene la palabra "Ceuta" en algún lugar

grepl("^18", df$Autonomia)        # ^ = empieza por...  empieza por "18"
grepl("Total$", df$Tipo)          # $ = termina en...  termina en "Total"
grepl("ceuta", df$Autonomia, ignore.case = TRUE)  # ignora mayúsculas/minúsculas

# Usar grepl como condición de filtro
df[grepl("Ceuta", df$Autonomia), ]
# Lee: "dame las filas donde Autonomia contiene la palabra Ceuta"

# grep() es como grepl() pero devuelve los ÍNDICES en vez de TRUE/FALSE
grep("Ceuta", df$Autonomia)
#  devuelve c(18) si la fila 18 tiene "Ceuta"
# Útil cuando necesitas el número de fila, no el TRUE/FALSE
```

---

## 7. Renombrar columnas después de filtrar

```r
# Cuando filtras, las columnas pueden tener nombres genéricos (V1, V3, V15...)
# Siempre renombrar antes de trabajar con el resultado

colnames(df) <- c("Autonomia", "Perdidas")    # cambia TODOS los nombres
colnames(df)[1] <- "Autonomia"                # cambia solo la primera columna
colnames(df)[2] <- "Perdidas"                 # cambia solo la segunda columna

# Cambiar por nombre conocido (no por posición)
colnames(df)[colnames(df) == "V15"] <- "Perdidas"
# Lee: encuentra la columna que se llama "V15" y renómbrala "Perdidas"
```

---

## 8. Verificar el resultado del filtrado

```r
nrow(resultado)                    # ¿cuántas filas tiene? ¿es el número esperado?
colnames(resultado)                # ¿los nombres de columna son correctos?
head(resultado)                    # ¿el aspecto general es correcto?
unique(resultado$Autonomia)        # ¿están todas las comunidades que deben estar?
table(df$Tipo)                     # contar cuántas filas hay de cada tipo (para saber cuál filtrar)
```

---

## 9. Problemas comunes al filtrar

| Problema                              | Causa                                | Solución                                          |
|---------------------------------------|--------------------------------------|---------------------------------------------------|
| Resultado con 0 filas                 | El valor de comparación tiene espacios extra | trimws(df$col) antes de filtrar           |
| NA aparecen en el resultado           | NA en la columna filtrante           | Añadir !is.na(df$col) & condición                 |
| "object not found" al poner df$col    | El nombre de columna está mal escrito | colnames(df) para ver los nombres exactos         |
| Resultado es vector en vez de df      | df[, "col"] en vez de df["col"]      | Usar df["col"] o df[, "col", drop=FALSE]          |
| Condición da error de tipos           | Comparas texto con número o al revés | str(df) para ver tipos, as.numeric() si hace falta|

```r
# Solución al problema de espacios en valores de texto
df$Tipo <- trimws(df$Tipo)   # elimina espacios al principio y al final de cada valor
# Después de esto ya puedes comparar con == sin problema de espacios ocultos
```
