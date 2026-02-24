# R  Limpieza y Reparación de Datos
> El bloque donde más se falla. Solo R base. Ctrl+F. Cada línea explicada.

---

## Orden de operaciones (hazlo SIEMPRE en este orden)

1. Inspecciona el df: `str()`, `head()`, `dim()`, `colnames()`
2. Repara NAs (si los hay)
3. Limpia texto (quitar códigos, espacios)
4. Fusiona/agrupa filas que hay que unir
5. Añade filas que faltan (totales, agregados)
6. Une los dataframes entre sí
7. Añade columnas calculadas

---

## 1. Detectar qué tiene el dataframe

```r
str(df)              # FUNDAMENTAL: tipo de cada columna, primeros valores
head(df)             # primeras 6 filas. Si está bien cargado, aquí se ve
dim(df)              # c(nfilas, ncols)  comprobar que tiene las dimensiones esperadas
colnames(df)         # nombres de las columnas
sum(is.na(df))       # cuántos NA hay en TODO el df
colSums(is.na(df))   # cuántos NA hay en CADA columna
which(is.na(df$col)) # en qué filas hay NA en la columna "col"
```

---

## 2. Detectar y tratar NAs

```r
# --- Detectar ---
is.na(df$Total)           # vector TRUE/FALSE  TRUE donde hay NA
sum(is.na(df$Total))      # cuenta cuántos NA hay en la columna Total
which(is.na(df$Total))    # dice en qué FILAS están los NA (ej: c(5, 19))
df[is.na(df$Total), ]     # muestra las filas completas que tienen NA en Total

# --- Reemplazar NA por un valor fijo ---
df$Total[is.na(df$Total)] <- 0
# Lee: "en la columna Total, donde haya NA, pon 0"

# --- Reemplazar NA calculándolo (caso típico del examen) ---
# Tenemos NA en la fila de Melilla porque falta el Total
# Pero en el mismo df hay filas para Hombres y Mujeres de Melilla
# Podemos calcular: Total Melilla = Hombres Melilla + Mujeres Melilla
fila_melilla <- which(df$Autonomia == "19 Melilla" & df$Sexo == "Total")
# which() nos da el número de fila donde está Melilla+Total

hombres <- df$Total[df$Autonomia == "19 Melilla" & df$Sexo == "Hombres"]
# Busca en la columna Total la fila donde Autonomia es Melilla Y Sexo es Hombres

mujeres <- df$Total[df$Autonomia == "19 Melilla" & df$Sexo == "Mujeres"]
# Busca el Total donde Autonomia es Melilla Y Sexo es Mujeres

df$Total[fila_melilla] <- hombres + mujeres
# Asigna la suma a la fila que tiene el NA

# --- Forma más compacta (en una línea) ---
fila <- which(df$Autonomia == "19 Melilla" & df$Sexo == "Total")
df$Total[fila] <- sum(df$Total[df$Autonomia == "19 Melilla" & df$Sexo != "Total"])
# sum() suma todos los Totales de Melilla que NO son la fila "Total" (es decir, H+M)

# --- Eliminar filas con NA ---
df <- na.omit(df)                   # elimina CUALQUIER fila que tenga algún NA
df <- df[!is.na(df$Total), ]        # elimina solo las filas con NA en Total
df <- df[complete.cases(df), ]      # igual que na.omit (requiere que TODOS los campos sean válidos)
```

---

## 3. Modificar un valor concreto en una celda

```r
# FORMA 1  por posición exacta [fila, columna]
df[19, 3] <- 86450
# Cambia el valor de la fila 19, columna 3 a 86450
# Malo: si cambias el df, los números de fila pueden cambiar

# FORMA 2  buscar la fila con which, columna por nombre (la más segura)
fila <- which(df$Autonomia == "19 Melilla")
# which() nos da el número de fila donde Autonomia es "19 Melilla"
df$Total[fila] <- 86450
# Asignamos el valor 86450 a la columna Total de esa fila

# FORMA 3  equivalente con notación [fila, "nombre"]
fila <- which(df$Autonomia == "19 Melilla")
df[fila, "Total"] <- 86450
# df[fila, "Total"] accede exactamente a esa celda

# FORMA 4  asignarlo calculado (lo más elegante)
fila <- which(df$Autonomia == "19 Melilla")
df[fila, "Total"] <- df[fila, "Hombres"] + df[fila, "Mujeres"]
# Calcula Hombres + Mujeres de esa misma fila y lo asigna a Total
```

---

## 4. Eliminar filas

```r
# FORMA 1  por número de fila
df <- df[-19, ]          # elimina la fila 19
df <- df[-c(18, 19), ]   # elimina las filas 18 y 19

# FORMA 2  por condición (más robusto que por posición)
df <- df[df$Autonomia != "19 Melilla", ]
# Mantiene todas las filas EXCEPTO donde Autonomia es ese valor

df <- df[!df$Autonomia %in% c("18 Ceuta", "19 Melilla"), ]
# Mantiene todas las filas donde Autonomia NO está en esa lista

# FORMA 3  con which (más explícito, más fácil de entender)
filas_a_borrar <- which(df$Autonomia %in% c("18 Ceuta", "19 Melilla"))
# filas_a_borrar = c(18, 19) por ejemplo
df <- df[-filas_a_borrar, ]
# El - delante elimina esas filas

# IMPORTANTE: después de borrar filas, los índices quedan con huecos
# (ej: 1,2,3,...,17,20,21  faltan el 18 y 19)
# Si necesitas índices limpios y consecutivos:
rownames(df) <- NULL
# Resetea los rownames para que vuelvan a ser 1,2,3,4...
```

---

## 5. Añadir una fila nueva  rbind()

```r
# rbind() une dos dataframes APILÁNDOLOS (uno encima del otro)
# REQUISITO: ambos tienen que tener exactamente los mismos nombres de columna

# FORMA 1  crear la fila como data.frame y unirla
nueva_fila <- data.frame(
  Autonomia = "Ceuta y Melilla",     # columna 1
  Total = 170000,                    # columna 2
  stringsAsFactors = FALSE           # evita que los textos se conviertan en factor
)
df <- rbind(df, nueva_fila)
# df queda con todas las filas anteriores MÁS la nueva al final

# FORMA 2  todo en una línea
df <- rbind(df, data.frame(Autonomia = "Total Nacional", Total = 0))

# FORMA 3  calcular el valor y añadirlo en una línea
df <- rbind(df, data.frame(
  Autonomia = "Total Nacional",
  Total = sum(df$Total, na.rm = TRUE)  # la suma de toda la columna Total
))
# IMPORTANTE: calcular sum() ANTES de añadir la fila de Total
# Si lo calculas después, el Total ya está en el df y se suma a sí mismo

# PROBLEMA CLÁSICO  error en rbind por nombres distintos
# Causa: el df y la nueva_fila tienen columnas con distinto nombre
# Solución: verificar antes
colnames(df)           # nombres del df original
colnames(nueva_fila)   # nombres de la nueva fila  deben ser IDÉNTICOS
```

---

## 6. Fusionar dos filas en una (el caso Ceuta y Melilla)

El problema: tienes "18 Ceuta" y "19 Melilla" como filas separadas.
El objetivo: una sola fila "Ceuta y Melilla" que sea la suma de ambas.

```r
# PASO 1  extraer los valores de cada fila que vas a fusionar
ceuta   <- df$Total[df$Autonomia == "18 Ceuta"]
melilla <- df$Total[df$Autonomia == "19 Melilla"]
# Ahora ceuta y melilla son variables con sus valores numéricos

# PASO 2  crear la fila combinada
fila_combinada <- data.frame(
  Autonomia = "Ceuta y Melilla",
  Total = ceuta + melilla,       # suma de ambas
  stringsAsFactors = FALSE
)

# PASO 3  eliminar las filas originales del df
df <- df[!df$Autonomia %in% c("18 Ceuta", "19 Melilla"), ]

# PASO 4  añadir la nueva fila combinada
df <- rbind(df, fila_combinada)

# Resetear índices para que sean consecutivos
rownames(df) <- NULL
```

---

## 7. Añadir el Total Nacional

```r
# Siempre calcular el total ANTES de añadirlo al df
total_valor <- sum(df$Total, na.rm = TRUE)
# na.rm=TRUE  ignora los NA al sumar (si hay algún NA no fastidia el total)

# Añadirlo
df <- rbind(df, data.frame(Autonomia = "Total Nacional", Total = total_valor))
```

---

## 8. Limpiar texto  gsub() y trimws()

```r
# gsub(patron, reemplazo, texto)  reemplaza TODAS las ocurrencias del patrón
# sub(patron, reemplazo, texto)   reemplaza solo la PRIMERA ocurrencia
# El patrón puede ser texto literal o expresión regular (regex)

# --- Quitar código numérico al inicio ("01 Andalucía"  "Andalucía") ---
gsub("^[0-9]+ ", "", "01 Andalucía")
# ^         = inicio de la cadena
# [0-9]+    = uno o más dígitos
# (espacio) = espacio después de los dígitos
# ""        = reemplazar por nada (borrar)

# Aplicar a toda la columna de una vez
df$Autonomia <- gsub("^[0-9]+ ", "", df$Autonomia)
# Pasa "01 Andalucía"  "Andalucía", "19 Melilla"  "Melilla", etc.

# --- Quitar espacios al inicio y al final ---
df$Autonomia <- trimws(df$Autonomia)
# trimws() limpia espacios extra: "  Madrid  "  "Madrid"
# Si el merge no funciona y los nombres parecen iguales, prueba esto

# --- Reemplazar texto ---
df$Autonomia <- gsub("Comunidad de ", "", df$Autonomia)
# Borra "Comunidad de " de todos los valores

# --- Extraer solo el nombre (ignorar código al inicio) ---
df$Autonomia <- gsub("^\\d{2} ", "", df$Autonomia)
# \\d{2} = exactamente 2 dígitos  quita "01 ", "18 ", "19 "...

# Patrones regex útiles:
# ^      inicio de la cadena
# $      final de la cadena
# [0-9]  cualquier dígito
# \\d    cualquier dígito (igual que [0-9])
# +      uno o más del elemento anterior
# *      cero o más del elemento anterior
# .      cualquier carácter
# \\s    espacio en blanco
# \\b    borde de palabra
```

---

## 9. Unir dos dataframes  merge()

```r
# merge() une dos df buscando filas que tengan el mismo valor en una columna clave
# Equivalente a un JOIN en SQL

# INNER JOIN  solo las filas que coinciden en AMBOS df
# Si una Autonomia está en df1 pero no en df2, NO aparece en el resultado
resultado <- merge(df1, df2, by = "Autonomia")

# LEFT JOIN  todas las filas del primero (df1), coincidan o no
# Si una Autonomia de df1 no está en df2, aparece con NA en las columnas de df2
resultado <- merge(df1, df2, by = "Autonomia", all.x = TRUE)

# FULL JOIN  todas las filas de ambos, coincidan o no
resultado <- merge(df1, df2, by = "Autonomia", all = TRUE)

# Cuando la columna clave tiene distinto nombre en cada df
resultado <- merge(df1, df2, by.x = "NombreRegion", by.y = "Autonomia")
# by.x = nombre en df1, by.y = nombre en df2

# TRUCO: si merge devuelve 0 filas, los valores no coinciden exactamente
# Comparar con unique() para ver qué hay en cada df
unique(df1$Autonomia)  # autonomías en df1
unique(df2$Autonomia)  # autonomías en df2
# Si "Andalucía" está en uno y "01 Andalucía" en el otro  limpiar primero con gsub
```

---

## 10. Añadir una columna calculada

```r
# FORMA 1  asignación directa: df$NuevaColumna <- calculo
df$Ratio <- df$Perdidas / df$Poblacion
# Opera columna a columna: divide cada elemento de Perdidas entre el de Poblacion

df$Ratio_pct <- (df$Perdidas / df$Total) * 100
# Multiplica por 100 para obtener porcentaje

# FORMA 2  basada en condición con ifelse()
df$Nivel <- ifelse(df$Total > 10000, "Alto", "Bajo")
# ifelse(condición, valor_si_TRUE, valor_si_FALSE)
# Para cada fila: si Total > 10000, escribe "Alto", si no "Bajo"

# FORMA 3  ifelse anidado para más de dos niveles
df$Nivel <- ifelse(df$Total > 50000, "Alto",
              ifelse(df$Total > 10000, "Medio", "Bajo"))
# Primero mira si es Alto, si no si es Medio, si no es Bajo
```

---

## 11. Reordenar y resetear índices

```r
# Ordenar por una columna
df <- df[order(df$Autonomia), ]                      # orden alfabético AZ
df <- df[order(df$Total), ]                          # numérico ascendente
df <- df[order(df$Total, decreasing = TRUE), ]       # numérico descendente
df <- df[order(df$Col1, df$Col2), ]                  # por dos columnas

# Resetear índices tras borrar o reordenar filas
rownames(df) <- NULL
# Después de borrar/reordenar, los índices quedan desordenados o con huecos
# rownames(df) <- NULL los resetea a 1, 2, 3...
```

---

## 12. Tabla de situaciones típicas de examen

| Situación en el enunciado                          | Qué hacer                                                              |
|----------------------------------------------------|------------------------------------------------------------------------|
| "El total de Melilla no está, calcúlalo"           | which() para la fila, sumar H+M de otras filas, asignar               |
| "Agrupa Ceuta y Melilla en un solo registro"       | Extraer valores  crear fila nueva  borrar originales  rbind        |
| "Añade el Total Nacional"                          | sum() de la columna antes  rbind con nueva fila                      |
| "El merge no devuelve las filas esperadas"         | Los nombres no coinciden, limpiar con gsub() y trimws() antes         |
| "rbind da error"                                   | colnames() en ambos df, deben ser IDÉNTICOS                           |
| "Hay NAs en una columna numérica al hacer sumas"   | na.rm=TRUE en sum(), o reparar el NA antes con which(is.na())         |
| "Quita el código numérico de las autonomías"       | gsub("^[0-9]+ ", "", df$Autonomia)                                    |
