################################################################################
# RESUMEN COMPLETO DE R PARA EXÁMENES DE DATAFRAMES
# Guía práctica para cargar, limpiar, filtrar y operar con datos
################################################################################

# ==============================================================================
# 1. CONFIGURACIÓN INICIAL Y CARGA DE DATOS
# ==============================================================================

# --- Establecer directorio de trabajo ---
setwd("C://Users//Javi//Desktop//carpeta")  # Establecer donde están los archivos
getwd()  # Ver directorio actual

# --- Cargar librerías necesarias ---
library(readODS)  # Para archivos .ods de Excel/LibreOffice

# --- CARGAR DIFERENTES TIPOS DE ARCHIVOS ---

# CSV (el más común)
datos <- read.csv("archivo.csv", sep = ";", header = TRUE)
# sep = ";" si usa punto y coma, sep = "," si usa coma
# header = TRUE si la primera fila son nombres de columnas

# ODS (Excel/LibreOffice)
datos <- read_ods("archivo.ods", range = "A1:Z100")  # Especificar rango
datos <- read_ods("archivo.ods", sheet = 1)  # Especificar hoja

# TXT
datos <- read.table("archivo.txt", header = TRUE, sep = "\t")


# ==============================================================================
# 2. EXPLORACIÓN INICIAL DE DATOS (MUY IMPORTANTE)
# ==============================================================================

# Ver primeras filas
head(datos)      # Primeras 6 filas
head(datos, 10)  # Primeras 10 filas

# Ver últimas filas
tail(datos)      # Últimas 6 filas

# Estructura del dataframe
str(datos)       # Tipos de datos de cada columna

# Resumen estadístico
summary(datos)   # Min, max, media, mediana, etc.

# Dimensiones
dim(datos)       # Devuelve (filas, columnas)
nrow(datos)      # Número de filas
ncol(datos)      # Número de columnas

# Nombres de columnas
names(datos)
colnames(datos)

# Ver los datos completos (cuidado con datasets grandes)
View(datos)


# ==============================================================================
# 3. ACCESO A DATOS (INDEXACIÓN)
# ==============================================================================

# --- ACCEDER A COLUMNAS ---
datos$nombre_columna           # Por nombre (devuelve vector)
datos[, "nombre_columna"]      # Por nombre (devuelve dataframe de 1 columna)
datos[, 2]                     # Por número (columna 2)
datos[, c(1, 3, 5)]           # Varias columnas

# DIFERENCIA IMPORTANTE:
df$columna                     # Vector simple
df[, "columna"]               # Puede ser dataframe o vector según contexto
df[, "columna"][[1]]          # Vector extraído de dataframe de 1 columna

# --- ACCEDER A FILAS ---
datos[5, ]                     # Fila 5 completa
datos[1:10, ]                 # Filas 1 a 10
datos[c(1, 5, 10), ]          # Filas 1, 5 y 10

# --- ACCEDER A ELEMENTOS ESPECÍFICOS ---
datos[3, 5]                    # Fila 3, columna 5
datos[3, "nombre"]             # Fila 3, columna "nombre"
datos[1:5, c("nombre", "edad")]  # Filas 1-5, columnas nombre y edad


# ==============================================================================
# 4. FILTRADO DE DATOS (CLAVE PARA EL EXAMEN)
# ==============================================================================

# --- OPERADORES DE COMPARACIÓN ---
# ==  igual a
# !=  diferente de
# >   mayor que
# <   menor que
# >=  mayor o igual
# <=  menor o igual

# --- OPERADORES LÓGICOS ---
# &   AND (ambas condiciones deben cumplirse)
# |   OR (al menos una condición debe cumplirse)
# !   NOT (negación)

# --- FILTRAR FILAS POR CONDICIÓN ---

# Una condición
mayores <- datos[datos$edad > 18, ]

# Varias condiciones con AND
filtro1 <- datos[datos$edad > 18 & datos$ciudad == "Madrid", ]

# Varias condiciones con OR
filtro2 <- datos[datos$ciudad == "Madrid" | datos$ciudad == "Barcelona", ]

# Condición compleja (ejemplo del examen)
filtro_complejo <- datos[datos$Periodo == "2020" & 
                         datos$Sexo == "Total" & 
                         datos$Provincias == "", ]

# Usar is.na() para valores faltantes
sin_NA <- datos[!is.na(datos$edad), ]  # Filas donde edad NO es NA
con_NA <- datos[is.na(datos$edad), ]   # Filas donde edad ES NA

# --- FUNCIÓN which() - Obtener índices ---
# Muy útil cuando necesitas las POSICIONES que cumplen una condición

indices <- which(datos$edad > 18)  # Vector de posiciones
datos_filtrados <- datos[indices, ]

# Ejemplo práctico del examen:
# Encontrar filas que contengan cierto texto y obtener las 3 filas anteriores
indices_objetivo <- which(datos$...1 == "2. Volumen de agua no registrada")
indices_provincias <- indices_objetivo - 3  # 3 filas antes
nombres_provincias <- datos[indices_provincias, 1]


# ==============================================================================
# 5. LIMPIEZA DE DATOS
# ==============================================================================

# --- VALORES FALTANTES (NA) ---

# Detectar NA
is.na(datos$columna)           # Vector TRUE/FALSE
sum(is.na(datos$columna))      # Cuenta cuántos NA hay

# Reemplazar vacíos por NA
datos$Provincias[datos$Provincias == ""] <- NA

# Eliminar filas con NA
datos_limpios <- na.omit(datos)  # Elimina TODAS las filas con algún NA
datos_limpios <- datos[!is.na(datos$columna_importante), ]  # Solo esa columna

# Reemplazar NA por un valor
datos$edad[is.na(datos$edad)] <- 0  # Poner 0 donde hay NA

# --- CONVERSIÓN DE TIPOS DE DATOS ---

# Ver tipo actual
class(datos$columna)

# Convertir a numérico
datos$Total <- as.numeric(datos$Total)

# Convertir caracteres con formato especial (ejemplo: "1.234.567")
datos$Total <- gsub("\\.", "", datos$Total)  # Quitar puntos
datos$Total <- as.numeric(datos$Total)       # Luego convertir

# Convertir a carácter
datos$codigo <- as.character(datos$codigo)

# Convertir a factor
datos$categoria <- as.factor(datos$categoria)


# ==============================================================================
# 6. MANIPULACIÓN DE COLUMNAS
# ==============================================================================

# --- RENOMBRAR COLUMNAS ---

# Renombrar una columna específica
colnames(datos)[1] <- "nuevo_nombre"
names(datos)[2] <- "otro_nombre"

# Renombrar varias
colnames(datos) <- c("col1", "col2", "col3", "col4")

# --- CREAR NUEVAS COLUMNAS ---

# Columna simple
datos$nueva_columna <- 10

# Columna calculada
datos$total <- datos$precio * datos$cantidad
datos$porcentaje <- (datos$valor / datos$total) * 100

# Columna condicional
datos$categoria <- ifelse(datos$edad < 18, "Menor", "Adulto")

# --- ELIMINAR COLUMNAS ---
datos$columna_no_deseada <- NULL


# ==============================================================================
# 7. MANIPULACIÓN DE FILAS
# ==============================================================================

# --- NOMBRES DE FILAS ---

# Ver nombres de filas
rownames(datos)

# Resetear nombres de filas (1, 2, 3...)
rownames(datos) <- NULL
row.names(datos) <- NULL  # Alternativa

# Asignar nombres personalizados
rownames(datos) <- datos$nombre

# --- AGREGAR FILAS ---

# Agregar una fila al final
nueva_fila <- c("Ceuta y Melilla", 150000)
datos <- rbind(datos, nueva_fila)

# Agregar al principio
datos <- rbind(nueva_fila, datos)

# IMPORTANTE: rbind puede cambiar tipos de datos
# Siempre reconvertir después si es necesario
datos$poblacion <- as.numeric(datos$poblacion)

# --- ELIMINAR FILAS ---

# Por índice
datos <- datos[-5, ]           # Eliminar fila 5
datos <- datos[-c(1, 3, 5), ]  # Eliminar filas 1, 3 y 5

# Por condición
datos <- datos[!(datos$ciudad == "Madrid"), ]  # Quitar todas las de Madrid


# ==============================================================================
# 8. UNIR DATAFRAMES (MERGE)
# ==============================================================================

# --- MERGE - Unir por columna común ---

# Inner join (solo filas que coinciden en ambos)
resultado <- merge(df1, df2, by = "columna_comun")

# Outer join (todas las filas, NA donde no coincida)
resultado <- merge(df1, df2, by = "columna_comun", all = TRUE)

# Left join (todas de df1, NA si no está en df2)
resultado <- merge(df1, df2, by = "columna_comun", all.x = TRUE)

# Right join (todas de df2, NA si no está en df1)
resultado <- merge(df1, df2, by = "columna_comun", all.y = TRUE)

# Merge con diferentes nombres de columna
resultado <- merge(df1, df2, by.x = "id_tabla1", by.y = "id_tabla2")

# Ejemplo práctico:
conjuntoDatos <- merge(datosAguaFiltrados, datosCensoFiltrados, 
                      by = "autonomia", all = TRUE)


# ==============================================================================
# 9. OPERACIONES ESTADÍSTICAS
# ==============================================================================

# --- FUNCIONES BÁSICAS ---
sum(datos$columna)              # Suma
mean(datos$columna)             # Media
median(datos$columna)           # Mediana
min(datos$columna)              # Mínimo
max(datos$columna)              # Máximo
sd(datos$columna)               # Desviación estándar
var(datos$columna)              # Varianza

# Con NA - usar na.rm = TRUE
sum(datos$columna, na.rm = TRUE)
mean(datos$columna, na.rm = TRUE)

# --- OPERACIONES POR GRUPOS (AGGREGATE) ---

# Calcular media por grupo
aggregate(ventas ~ ciudad, data = datos, FUN = mean)

# Varias funciones
aggregate(ventas ~ ciudad, data = datos, FUN = function(x) c(media = mean(x), suma = sum(x)))

# --- REDONDEAR ---
round(3.14159, 2)  # 3.14 (2 decimales)
round(3.14159)     # 3 (sin decimales)


# ==============================================================================
# 10. VECTORIZACIÓN Y EXTRACCIÓN (COMÚN EN EXÁMENES)
# ==============================================================================

# --- PROBLEMA: Dataframe de 1 columna vs Vector ---

# Esto devuelve un dataframe de 1 columna:
df_columna <- datos[, "nombre"]

# Para extraer como vector:
vector <- datos$nombre                    # Opción 1: Con $
vector <- datos[, "nombre"][[1]]         # Opción 2: Extraer con [[1]]
vector <- unlist(datos[, "nombre"])      # Opción 3: unlist

# unlist() es muy útil antes de hacer merge
datos1$id <- unlist(datos1$id)
datos2$id <- unlist(datos2$id)

# --- CONVERTIR VECTOR A DATAFRAME ---
vector <- c(1, 2, 3, 4)
df <- data.frame(valores = vector)


# ==============================================================================
# 11. CÁLCULOS Y MAGNITUDES DERIVADAS
# ==============================================================================

# Ejemplo del examen: Calcular litros perdidos por habitante

# 1. Crear nueva columna con cálculo
conjuntoDatos$LpH <- conjuntoDatos$perdidas * 1000000 / conjuntoDatos$poblacion

# 2. Calcular media nacional
mediaNacional <- conjuntoDatos[conjuntoDatos$autonomia == "Total Nacional", ]$LpH

# 3. Calcular diferencia porcentual respecto a media
conjuntoDatos$DPM <- (conjuntoDatos$LpH - mediaNacional) / mediaNacional * 100

# 4. Redondear resultado
conjuntoDatos$DPM <- round(conjuntoDatos$DPM)


# ==============================================================================
# 12. TRUCOS Y CONSEJOS PARA EL EXAMEN
# ==============================================================================

# --- SIEMPRE VERIFICAR TUS DATOS ---
# Después de cada operación importante, usa:
head(datos)
summary(datos)
str(datos)

# --- DEBUGGING: Ver qué tienes ---
print(variable)
class(variable)
typeof(variable)

# --- OPERACIONES SEGURAS ---
# Si no estás seguro del resultado, guarda en nueva variable
datos_nuevo <- datos[filtro, ]  # No sobreescribir original

# --- ATENCIÓN CON rbind ---
# SIEMPRE vuelve a convertir tipos después de rbind
datos <- rbind(datos, nueva_fila)
datos$numero <- as.numeric(datos$numero)

# --- CUIDADO CON LOS ÍNDICES ---
# Al eliminar filas, los índices no se resetean automáticamente
# Usa rownames(datos) <- NULL si necesitas resetearlos


# ==============================================================================
# 13. EJEMPLO COMPLETO PASO A PASO (TIPO EXAMEN)
# ==============================================================================

# Escenario: Tenemos datos de ventas y datos de empleados

# PASO 1: Cargar datos
setwd("C://Users//Javi//Desktop")
ventas <- read.csv("ventas.csv", sep = ";")
empleados <- read.csv("empleados.csv", sep = ";")

# PASO 2: Explorar
head(ventas)
str(ventas)

# PASO 3: Limpiar tipos
ventas$Total <- gsub("\\.", "", ventas$Total)
ventas$Total <- as.numeric(ventas$Total)

# PASO 4: Filtrar datos necesarios
ventas_2020 <- ventas[ventas$Año == 2020 & ventas$Sucursal != "", ]
empleados_activos <- empleados[empleados$Estado == "Activo", ]

# PASO 5: Seleccionar columnas
ventas_filtradas <- ventas_2020[, c("Sucursal", "Total")]
empleados_filtrados <- empleados_activos[, c("Sucursal", "Cantidad")]

# PASO 6: Renombrar si es necesario
names(ventas_filtradas) <- c("sucursal", "ventas_totales")
names(empleados_filtrados) <- c("sucursal", "num_empleados")

# PASO 7: Arreglar datos (ejemplo: sumar subcategorías)
filtro <- empleados[empleados$Sucursal == "Central" & empleados$Turno != "Total", ]
total_central <- sum(filtro$Cantidad)
empleados_filtrados[empleados_filtrados$sucursal == "Central", "num_empleados"] <- total_central

# PASO 8: Unir dataframes
datos_completos <- merge(ventas_filtradas, empleados_filtrados, by = "sucursal", all = TRUE)

# PASO 9: Calcular magnitudes derivadas
datos_completos$ventas_por_empleado <- datos_completos$ventas_totales / datos_completos$num_empleados

# PASO 10: Calcular diferencia respecto a media
media_general <- mean(datos_completos$ventas_por_empleado, na.rm = TRUE)
datos_completos$diferencia_porc <- round((datos_completos$ventas_por_empleado - media_general) / media_general * 100)

# PASO 11: Verificar resultado final
head(datos_completos)
summary(datos_completos)


# ==============================================================================
# 14. ERRORES COMUNES Y CÓMO EVITARLOS
# ==============================================================================

# ERROR: "subscript out of bounds"
# CAUSA: Intentas acceder a una posición que no existe
# SOLUCIÓN: Verifica dim(datos) antes de acceder

# ERROR: "cannot coerce type 'list' to vector"
# CAUSA: Intentas operaciones con un dataframe que deberías hacer con vector
# SOLUCIÓN: Usa [[1]] o unlist() o $

# ERROR: "non-numeric argument to binary operator"
# CAUSA: Intentas sumar/restar/etc. con columnas no numéricas
# SOLUCIÓN: Usa as.numeric() primero

# ERROR: "cannot add rows"
# CAUSA: Las columnas no coinciden en número/nombre al hacer rbind
# SOLUCIÓN: Asegúrate que ambos dataframes tienen las mismas columnas

# ERROR: "object not found"
# CAUSA: Variable no existe o mal escrita
# SOLUCIÓN: Verifica nombres con ls() y corrige


# ==============================================================================
# 15. RESUMEN DE FUNCIONES CLAVE
# ==============================================================================

# CARGA:        read.csv(), read_ods()
# EXPLORACIÓN:  head(), str(), summary(), dim(), names()
# FILTRADO:     datos[condicion, ], which(), subset()
# LIMPIEZA:     is.na(), na.omit(), as.numeric(), gsub()
# COLUMNAS:     colnames(), names(), $, [, ]
# FILAS:        rownames(), rbind(), row.names()
# UNIR:         merge()
# ESTADÍSTICA:  sum(), mean(), median(), min(), max(), round()
# EXTRACCIÓN:   [[1]], unlist(), $

################################################################################
# ¡ÉXITO EN TU EXAMEN!
################################################################################
