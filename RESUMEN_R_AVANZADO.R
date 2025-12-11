################################################################################
# GUÍA AVANZADA DE R - BUCLES, CONDICIONALES Y FILTRADO AVANZADO
# Control de flujo, iteraciones y técnicas avanzadas de manipulación de datos
################################################################################

# ==============================================================================
# 1. ESTRUCTURAS IF / ELSE (CONDICIONALES)
# ==============================================================================

# --- IF SIMPLE ---
edad <- 20

if (edad >= 18) {
  print("Es mayor de edad")
}

# --- IF / ELSE ---
nota <- 7.5

if (nota >= 5) {
  print("Aprobado")
} else {
  print("Suspenso")
}

# --- IF / ELSE IF / ELSE (múltiples condiciones) ---
nota <- 8.5

if (nota >= 9) {
  calificacion <- "Sobresaliente"
} else if (nota >= 7) {
  calificacion <- "Notable"
} else if (nota >= 5) {
  calificacion <- "Aprobado"
} else {
  calificacion <- "Suspenso"
}

# --- IF ANIDADOS (cuidado, se complica) ---
edad <- 25
tiene_carnet <- TRUE

if (edad >= 18) {
  if (tiene_carnet) {
    print("Puede conducir")
  } else {
    print("Necesita sacarse el carnet")
  }
} else {
  print("Es menor de edad")
}

# --- CONDICIONES MÚLTIPLES ---
# AND: ambas deben cumplirse
if (edad >= 18 & tiene_carnet) {
  print("Puede conducir")
}

# OR: al menos una debe cumplirse
if (edad < 18 | !tiene_carnet) {
  print("No puede conducir")
}


# ==============================================================================
# 2. IFELSE() - ALTERNATIVA VECTORIZADA (MUY ÚTIL)
# ==============================================================================

# ifelse() aplica la condición a TODO un vector/columna
# Mucho más eficiente que un bucle con if

# --- SINTAXIS BÁSICA ---
# ifelse(condicion, valor_si_TRUE, valor_si_FALSE)

edades <- c(15, 20, 17, 25, 30)
categorias <- ifelse(edades >= 18, "Adulto", "Menor")
# Resultado: "Menor" "Adulto" "Menor" "Adulto" "Adulto"

# --- APLICADO A DATAFRAMES ---
datos$categoria <- ifelse(datos$edad >= 18, "Adulto", "Menor")

# --- IFELSE ANIDADO (múltiples categorías) ---
datos$nivel <- ifelse(datos$nota >= 9, "Excelente",
                     ifelse(datos$nota >= 7, "Bueno",
                           ifelse(datos$nota >= 5, "Regular", "Insuficiente")))

# --- EJEMPLO PRÁCTICO ---
# Crear columna indicando si una comunidad está por encima de la media
datos$superior_media <- ifelse(datos$valor > mean(datos$valor), "Sí", "No")


# ==============================================================================
# 3. CUÁNDO USAR IF vs IFELSE vs FILTRADO DIRECTO
# ==============================================================================

# --- USAR IF cuando: ---
# - Necesitas ejecutar CÓDIGO diferente según una condición
# - La condición afecta al flujo del programa (cargar un archivo u otro, etc.)
# - Trabajas con UN SOLO valor

# Ejemplo correcto de IF:
if (file.exists("datos.csv")) {
  datos <- read.csv("datos.csv")
} else {
  print("Archivo no encontrado")
  stop()
}

# --- USAR IFELSE cuando: ---
# - Quieres asignar valores a TODO un vector/columna
# - Necesitas categorizar datos
# - Trabajas con múltiples valores a la vez

# Ejemplo correcto de IFELSE:
datos$resultado <- ifelse(datos$puntos > 50, "Aprobado", "Suspenso")

# --- USAR FILTRADO DIRECTO cuando: ---
# - Solo necesitas SELECCIONAR filas que cumplen una condición
# - No necesitas ejecutar código ni asignar valores nuevos

# Ejemplo correcto de FILTRADO:
aprobados <- datos[datos$puntos > 50, ]  # Más eficiente que usar if o ifelse

# --- EJEMPLOS INCORRECTOS (NO HACER) ---

# ❌ MAL: Usar if en un vector (solo evalúa el primer elemento)
edades <- c(15, 20, 17)
if (edades >= 18) {  # Solo mira el primer valor (15)
  print("Mayor")
}

# ✅ BIEN: Usar ifelse o filtrado
categorias <- ifelse(edades >= 18, "Mayor", "Menor")
mayores <- edades[edades >= 18]


# ==============================================================================
# 4. BUCLES FOR
# ==============================================================================

# --- SINTAXIS BÁSICA ---
for (i in 1:5) {
  print(i)
}
# Imprime: 1, 2, 3, 4, 5

# --- RECORRER VECTOR ---
ciudades <- c("Madrid", "Barcelona", "Valencia")

for (ciudad in ciudades) {
  print(paste("Ciudad:", ciudad))
}

# --- RECORRER CON ÍNDICES ---
for (i in 1:length(ciudades)) {
  print(paste("Posición", i, ":", ciudades[i]))
}

# --- RECORRER FILAS DE DATAFRAME ---
# ⚠️ ADVERTENCIA: Esto es LENTO en R, evítalo si puedes

for (i in 1:nrow(datos)) {
  # Acceder a cada fila
  valor <- datos[i, "columna"]
  print(valor)
}

# --- FOR CON ACUMULACIÓN ---
suma_total <- 0

for (i in 1:10) {
  suma_total <- suma_total + i
}
print(suma_total)  # 55

# --- EJEMPLO PRÁCTICO: Crear múltiples columnas ---
columnas_a_crear <- c("col1", "col2", "col3")

for (col in columnas_a_crear) {
  datos[[col]] <- 0  # Inicializar todas a 0
}

# --- BREAK y NEXT en bucles ---

# BREAK: Sale del bucle inmediatamente
for (i in 1:10) {
  if (i == 5) break
  print(i)
}  # Imprime 1, 2, 3, 4 y para

# NEXT: Salta a la siguiente iteración
for (i in 1:10) {
  if (i == 5) next
  print(i)
}  # Imprime todos excepto el 5


# ==============================================================================
# 5. BUCLES WHILE
# ==============================================================================

# --- WHILE BÁSICO ---
contador <- 1

while (contador <= 5) {
  print(contador)
  contador <- contador + 1
}

# --- WHILE con condición compleja ---
intentos <- 0
max_intentos <- 3

while (intentos < max_intentos) {
  # Simular algo que puede fallar
  resultado <- runif(1)  # Número aleatorio
  
  if (resultado > 0.7) {
    print("Éxito!")
    break
  } else {
    intentos <- intentos + 1
    print(paste("Intento", intentos, "fallido"))
  }
}

# ⚠️ CUIDADO: WHILE puede crear bucles infinitos si no actualizas la condición
# ❌ MAL:
# while (TRUE) {
#   print("Esto nunca termina")
# }


# ==============================================================================
# 6. CUÁNDO USAR BUCLES (Y CUÁNDO NO)
# ==============================================================================

# --- ❌ NO USAR BUCLES cuando puedas usar VECTORIZACIÓN ---

# MAL (lento):
resultado <- c()
for (i in 1:length(numeros)) {
  resultado[i] <- numeros[i] * 2
}

# BIEN (rápido):
resultado <- numeros * 2

# MAL (muy lento):
for (i in 1:nrow(datos)) {
  datos[i, "doble"] <- datos[i, "valor"] * 2
}

# BIEN (muy rápido):
datos$doble <- datos$valor * 2

# --- ✅ SÍ USAR BUCLES cuando: ---

# 1. Necesitas iterar por archivos
archivos <- c("datos1.csv", "datos2.csv", "datos3.csv")
lista_datos <- list()

for (i in 1:length(archivos)) {
  lista_datos[[i]] <- read.csv(archivos[i])
}

# 2. Cada iteración depende de la anterior
fibonacci <- c(1, 1)

for (i in 3:10) {
  fibonacci[i] <- fibonacci[i-1] + fibonacci[i-2]
}

# 3. Operaciones complejas que no se pueden vectorizar
for (i in 1:nrow(datos)) {
  if (datos[i, "tipo"] == "A") {
    # Proceso complejo A
  } else {
    # Proceso complejo B
  }
}


# ==============================================================================
# 7. FAMILIA APPLY (ALTERNATIVA A BUCLES)
# ==============================================================================

# La familia apply es más eficiente que bucles for en muchos casos

# --- APPLY: Para matrices/dataframes ---
# Aplicar función por filas (MARGIN = 1) o columnas (MARGIN = 2)

matriz <- matrix(1:12, nrow = 3)

# Sumar cada fila
apply(matriz, 1, sum)

# Sumar cada columna
apply(matriz, 2, sum)

# Media de cada columna en dataframe
apply(datos[, c("col1", "col2", "col3")], 2, mean)

# --- LAPPLY: Para listas/vectores, devuelve lista ---
numeros <- list(a = 1:5, b = 6:10, c = 11:15)

# Calcular media de cada elemento
lapply(numeros, mean)

# --- SAPPLY: Como lapply pero simplifica el resultado ---
sapply(numeros, mean)  # Devuelve un vector

# --- TAPPLY: Aplicar función por grupos ---
# tapply(valores, grupos, función)

# Calcular media de ventas por ciudad
tapply(datos$ventas, datos$ciudad, mean)

# --- EJEMPLO PRÁCTICO ---
# Calcular suma de varias columnas numéricas
columnas_numericas <- c("ventas", "costos", "beneficios")
sapply(datos[columnas_numericas], sum, na.rm = TRUE)


# ==============================================================================
# 8. FILTRADO AVANZADO - PREPARACIÓN PARA MERGE
# ==============================================================================

# --- CASO 1: Extraer valores únicos para match ---

# Problema: Tengo ciudades con espacios o variaciones, necesito limpiarlas

# Ver valores únicos
unique(datos$ciudad)  # Muestra todos los valores diferentes

# Limpiar espacios en blanco
datos$ciudad <- trimws(datos$ciudad)  # Elimina espacios inicio/fin

# Convertir a minúsculas para match
datos$ciudad <- tolower(datos$ciudad)

# Reemplazar valores específicos
datos$ciudad[datos$ciudad == "bcn"] <- "barcelona"
datos$ciudad[datos$ciudad == "mad"] <- "madrid"

# --- CASO 2: Crear identificadores para match ---

# Tengo nombres completos en un df y apellidos en otro
datos1$nombre_completo <- paste(datos1$nombre, datos1$apellido)
datos2$nombre_completo <- paste(datos2$nombre, datos2$apellido)

# Ahora puedo hacer merge por nombre_completo
resultado <- merge(datos1, datos2, by = "nombre_completo")

# --- CASO 3: Extraer subcadenas para match ---

# Tengo códigos "ES-MAD-001" y quiero solo "MAD"
library(stringr)  # O usar substr/substring

datos$codigo_ciudad <- substr(datos$codigo_completo, 4, 6)

# O con strsplit
datos$codigo_ciudad <- sapply(strsplit(datos$codigo_completo, "-"), `[`, 2)

# --- CASO 4: Filtrar df1 según valores que existen en df2 ---

# Obtener lista de ciudades válidas de df2
ciudades_validas <- unique(df2$ciudad)

# Filtrar df1 solo con esas ciudades
df1_filtrado <- df1[df1$ciudad %in% ciudades_validas, ]

# Operador %in% es MUY ÚTIL para esto
# x %in% y devuelve TRUE si x está en el vector y

# Ejemplo práctico:
provincias_norte <- c("Asturias", "Cantabria", "País Vasco")
datos_norte <- datos[datos$provincia %in% provincias_norte, ]

# --- CASO 5: Excluir valores (NOT IN) ---

# Quitar ciertas ciudades
ciudades_excluir <- c("Ceuta", "Melilla")
datos_sin_excluidas <- datos[!(datos$ciudad %in% ciudades_excluir), ]

# --- CASO 6: Detectar y manejar duplicados antes de merge ---

# Ver si hay duplicados
duplicated(datos$id)  # TRUE donde hay duplicado

# Ver qué filas están duplicadas
datos[duplicated(datos$id), ]

# Quedarse solo con registros únicos
datos_unicos <- datos[!duplicated(datos$id), ]

# Otra forma: usar unique() en todo el dataframe
datos_unicos <- unique(datos)

# --- CASO 7: Filtrado con múltiples condiciones para match ---

# Problema: Necesito hacer match por año Y ciudad, pero df1 tiene años como
# número y df2 como carácter

# Homogeneizar tipos
df1$año <- as.character(df1$año)
df2$año <- as.character(df2$año)

# Crear clave compuesta
df1$clave <- paste(df1$año, df1$ciudad, sep = "_")
df2$clave <- paste(df2$año, df2$ciudad, sep = "_")

# Merge por clave compuesta
resultado <- merge(df1, df2, by = "clave")


# ==============================================================================
# 9. FILTRADO AVANZADO - TRUE/FALSE Y CONDICIONES COMPLEJAS
# ==============================================================================

# --- CREAR VECTORES LÓGICOS (TRUE/FALSE) ---

# Condición simple
mayores <- datos$edad > 18  # Vector de TRUE/FALSE

# Ver cuántos cumplen la condición
sum(mayores)  # TRUE cuenta como 1, FALSE como 0
table(mayores)  # Tabla de frecuencias

# Usar el vector lógico para filtrar
datos_mayores <- datos[mayores, ]

# --- CONDICIONES COMPLEJAS CON & y | ---

# Personas entre 18 y 65 años de Madrid
condicion <- datos$edad >= 18 & datos$edad <= 65 & datos$ciudad == "Madrid"
datos_filtrados <- datos[condicion, ]

# Madrid O Barcelona, mayores de edad
condicion <- (datos$ciudad == "Madrid" | datos$ciudad == "Barcelona") & datos$edad >= 18
datos_filtrados <- datos[condicion, ]

# --- NEGAR CONDICIONES CON ! ---

# Todos excepto Madrid
no_madrid <- !(datos$ciudad == "Madrid")
datos_sin_madrid <- datos[no_madrid, ]

# Equivalente más directo:
datos_sin_madrid <- datos[datos$ciudad != "Madrid", ]

# --- COMBINAR with() y which() ---

# which() devuelve ÍNDICES (posiciones) donde la condición es TRUE
indices <- which(datos$edad > 18)
datos_mayores <- datos[indices, ]

# which() con múltiples condiciones
indices <- which(datos$edad > 18 & datos$ciudad == "Madrid")

# which() es útil cuando necesitas los índices para otra operación
# Ejemplo: Obtener la fila 3 posiciones antes de donde aparece algo
indices_objetivo <- which(datos$tipo == "Total")
indices_datos <- indices_objetivo - 3
valores <- datos[indices_datos, "columna"]

# --- subset() - ALTERNATIVA más legible ---

# subset(dataframe, condición)
datos_filtrados <- subset(datos, edad > 18 & ciudad == "Madrid")

# Ventaja: Sintaxis más limpia
# Desventaja: Más lento en datasets grandes

# --- CONDICIONES CON grepl() - Búsqueda de texto ---

# Filtrar filas que CONTIENEN cierto texto
datos_con_auto <- datos[grepl("auto", datos$descripcion, ignore.case = TRUE), ]

# grepl devuelve TRUE/FALSE si encuentra el patrón
# ignore.case = TRUE para que no distinga mayúsculas/minúsculas

# Buscar múltiples patrones
contiene_patron <- grepl("auto|coche|vehiculo", datos$descripcion, ignore.case = TRUE)
datos_vehiculos <- datos[contiene_patron, ]

# --- CONDICIONES con stringr (más potente) ---
library(stringr)

# Filtrar por inicio de cadena
datos[str_starts(datos$codigo, "ES-"), ]

# Filtrar por final de cadena
datos[str_ends(datos$nombre, "SA"), ]

# Detectar patrón
datos[str_detect(datos$texto, "error"), ]


# ==============================================================================
# 10. TÉCNICAS AVANZADAS DE FILTRADO PARA EXÁMENES
# ==============================================================================

# --- TÉCNICA 1: Filtrado en cascada ---

# Paso 1: Filtrar datos base
paso1 <- datos[datos$año == 2020, ]

# Paso 2: Filtrar sobre el resultado anterior
paso2 <- paso1[paso1$categoria == "A", ]

# Paso 3: Seleccionar columnas finales
resultado_final <- paso2[, c("id", "valor")]

# O todo en uno (menos legible pero más compacto):
resultado <- datos[datos$año == 2020 & datos$categoria == "A", c("id", "valor")]

# --- TÉCNICA 2: Filtrado con agregación ---

# Obtener solo la fila con el valor máximo
fila_max <- datos[datos$ventas == max(datos$ventas), ]

# Filtrar valores por encima de la media
por_encima_media <- datos[datos$valor > mean(datos$valor), ]

# Filtrar valores en el cuartil superior
q3 <- quantile(datos$valor, 0.75)
cuartil_superior <- datos[datos$valor > q3, ]

# --- TÉCNICA 3: Filtrado con múltiples operadores ---

# BETWEEN (entre dos valores)
# R no tiene between nativo, se hace así:
entre_20_y_30 <- datos[datos$edad >= 20 & datos$edad <= 30, ]

# O con función personalizada:
between <- function(x, a, b) { x >= a & x <= b }
datos[between(datos$edad, 20, 30), ]

# NOT BETWEEN
fuera_rango <- datos[datos$edad < 20 | datos$edad > 30, ]

# --- TÉCNICA 4: Filtrado excluyendo NA antes de operar ---

# Problema común: Quiero filtrar pero hay NA que dan problemas

# Mal (puede dar errores):
datos_filtrados <- datos[datos$valor > 100, ]

# Bien (excluye NA primero):
datos_filtrados <- datos[!is.na(datos$valor) & datos$valor > 100, ]

# --- TÉCNICA 5: Filtrado por posición relativa ---

# Primeras 10 filas
head(datos, 10)
datos[1:10, ]

# Últimas 10 filas
tail(datos, 10)
datos[(nrow(datos)-9):nrow(datos), ]

# Filas pares
datos[seq(2, nrow(datos), by = 2), ]

# Filas impares
datos[seq(1, nrow(datos), by = 2), ]

# Cada 5 filas
datos[seq(1, nrow(datos), by = 5), ]

# --- TÉCNICA 6: Sampling (muestreo) ---

# Muestra aleatoria de N filas
muestra <- datos[sample(nrow(datos), 100), ]

# Muestra aleatoria del X%
porcentaje <- 0.1  # 10%
n_filas <- ceiling(nrow(datos) * porcentaje)
muestra <- datos[sample(nrow(datos), n_filas), ]


# ==============================================================================
# 11. PREPARACIÓN AVANZADA PARA MERGE
# ==============================================================================

# --- CASO REAL COMPLETO: Preparar dos dataframes para merge ---

# SITUACIÓN: Tengo ventas por ciudad y población por provincia
# Necesito unirlos pero los nombres no coinciden exactamente

# DataFrame 1: Ventas
ventas <- data.frame(
  ciudad = c("madrid", "BARCELONA", "valencia  ", "Madrid"),
  ventas = c(100, 200, 150, 50)
)

# DataFrame 2: Población
poblacion <- data.frame(
  municipio = c("Madrid", "Barcelona", "Valencia"),
  habitantes = c(3000000, 1600000, 800000)
)

# PASO 1: Normalizar nombres en ventas
ventas$ciudad <- tolower(trimws(ventas$ciudad))

# PASO 2: Normalizar nombres en población
poblacion$municipio <- tolower(trimws(poblacion$municipio))

# PASO 3: Ver si hay duplicados (Madrid aparece 2 veces)
table(ventas$ciudad)

# PASO 4: Agregar duplicados
library(dplyr)  # O hacerlo con aggregate
ventas_agregadas <- aggregate(ventas ~ ciudad, data = ventas, FUN = sum)

# O sin dplyr:
ventas_agregadas <- aggregate(list(ventas = ventas$ventas), 
                              by = list(ciudad = ventas$ciudad), 
                              FUN = sum)

# PASO 5: Renombrar para que coincidan
names(poblacion)[1] <- "ciudad"

# PASO 6: Merge final
resultado <- merge(ventas_agregadas, poblacion, by = "ciudad", all = TRUE)

# PASO 7: Verificar qué no hizo match
filas_sin_match <- resultado[is.na(resultado$ventas) | is.na(resultado$habitantes), ]
print(filas_sin_match)

# --- PREPARACIÓN CON TABLAS DE CONVERSIÓN ---

# Tengo códigos en un df y nombres en otro
# Crear tabla de conversión

conversion <- data.frame(
  codigo = c("MAD", "BCN", "VAL"),
  nombre = c("Madrid", "Barcelona", "Valencia")
)

# Agregar nombres a df que solo tiene códigos
df_con_codigos <- merge(df_con_codigos, conversion, by = "codigo")

# Ahora puedo hacer merge con el otro df
resultado <- merge(df_con_codigos, df_con_nombres, by = "nombre")

# --- ANTI-JOIN: Encontrar lo que NO hace match ---

# Quiero ver qué ciudades de df1 NO están en df2
ciudades_df2 <- unique(df2$ciudad)
no_en_df2 <- df1[!(df1$ciudad %in% ciudades_df2), ]

# O al revés
ciudades_df1 <- unique(df1$ciudad)
no_en_df1 <- df2[!(df2$ciudad %in% ciudades_df1), ]


# ==============================================================================
# 12. ERRORES COMUNES Y DEBUGGING
# ==============================================================================

# --- ERROR 1: "object 'variable' not found" ---
# CAUSA: La variable no existe, mal escrita, o no la has creado

# Cómo debuggear:
ls()  # Ver todas las variables que existen
exists("variable")  # Ver si existe una variable específica

# Solución: Revisa el nombre, verifica que la creaste antes

# --- ERROR 2: "undefined columns selected" ---
# CAUSA: Intentas acceder a columna que no existe

# Cómo debuggear:
names(datos)  # Ver nombres de columnas exactos
colnames(datos)

# Solución: Copia y pega el nombre exacto de la columna

# --- ERROR 3: "subscript out of bounds" ---
# CAUSA: Intentas acceder a posición que no existe

# Cómo debuggear:
dim(datos)  # Ver dimensiones (filas, columnas)
nrow(datos)
ncol(datos)

# Ejemplo del error:
datos[1000, ]  # Error si solo hay 100 filas

# --- ERROR 4: "missing value where TRUE/FALSE needed" ---
# CAUSA: Hay NA en tu condición

# Mal:
datos[datos$edad > 18, ]  # Error si edad tiene NA

# Bien:
datos[!is.na(datos$edad) & datos$edad > 18, ]

# --- ERROR 5: "argument is of length zero" ---
# CAUSA: Vector vacío

# Cómo debuggear:
length(variable)  # Ver longitud

# Prevenir:
if (length(variable) > 0) {
  # hacer operación
}

# --- ERROR 6: "non-numeric argument to binary operator" ---
# CAUSA: Intentas operación matemática con texto/factor

# Cómo debuggear:
class(datos$columna)
str(datos$columna)

# Solución:
datos$columna <- as.numeric(datos$columna)

# --- ERROR 7: "cannot coerce type 'list' to vector" ---
# CAUSA: Intentas usar dataframe como vector

# Mal:
sum(datos[, "columna"])  # Puede dar error

# Bien:
sum(datos$columna)  # O
sum(datos[, "columna"][[1]])

# --- ERROR 8: "$ operator is invalid for atomic vectors" ---
# CAUSA: Intentas usar $ en un vector

# Mal:
vector <- c(1, 2, 3)
vector$elemento  # Error

# Bien:
vector[1]  # Acceso por índice

# --- ERROR 9: "replacement has X rows, data has Y" ---
# CAUSA: Asignas vector de diferente longitud

# Mal:
datos$nueva <- c(1, 2, 3)  # Error si datos tiene 100 filas

# Bien:
datos$nueva <- rep(1, nrow(datos))  # Repetir valor
datos$nueva <- 1  # R lo replica automáticamente

# --- ERROR 10: "Error in if: argument is not interpretable as logical" ---
# CAUSA: Usas if con un vector en vez de valor único

# Mal:
if (datos$edad > 18) { }  # datos$edad es un vector

# Bien:
if (datos$edad[1] > 18) { }  # Un solo valor
# O mejor aún:
ifelse(datos$edad > 18, "Mayor", "Menor")

# --- ERROR 11: "'x' must be numeric" ---
# CAUSA: Función espera número pero recibe texto

# Debuggear:
class(variable)

# Solución:
variable <- as.numeric(variable)
# O limpiar antes:
variable <- gsub("[^0-9.]", "", variable)  # Quitar todo excepto números
variable <- as.numeric(variable)

# --- ERROR 12: "NAs introduced by coercion" ---
# ADVERTENCIA (no error): Al convertir a numérico, algunos valores se volvieron NA

# Investigar:
datos$columna[is.na(as.numeric(datos$columna))]  # Ver qué valores dan problema

# Comúnmente: espacios, comas, texto mezclado
# Limpiar primero:
datos$columna <- gsub(",", ".", datos$columna)  # Cambiar coma por punto
datos$columna <- gsub(" ", "", datos$columna)   # Quitar espacios
datos$columna <- as.numeric(datos$columna)

# --- ERROR 13: "number of items to replace is not a multiple" ---
# CAUSA: Desajuste en asignación

# Mal:
datos[1:10, "col"] <- c(1, 2)  # 10 posiciones, 2 valores

# Bien:
datos[1:10, "col"] <- rep(c(1, 2), 5)  # Repetir para que coincida

# --- ERROR 14: Bucle infinito (no da error, se cuelga) ---
# CAUSA: Condición never se vuelve FALSE

# Mal:
i <- 1
while (i > 0) {
  print(i)
  i <- i + 1  # i nunca será ≤ 0
}

# Prevenir: Siempre tener condición de salida o contador máximo
intentos <- 0
while (condicion & intentos < 1000) {
  # código
  intentos <- intentos + 1
}


# ==============================================================================
# 13. TRUCOS DE DEBUGGING AVANZADOS
# ==============================================================================

# --- VER VALOR DE VARIABLE DURANTE EJECUCIÓN ---
print(variable)
cat("Valor:", variable, "\n")

# --- PAUSAR EJECUCIÓN ---
browser()  # Pausa aquí y puedes inspeccionar variables

# --- VER ESTRUCTURA COMPLETA ---
str(datos)  # Muestra tipo y primeros valores

# --- VERIFICAR CONDICIONES ---
# Ver cuántas filas cumplirían el filtro ANTES de aplicarlo
sum(datos$edad > 18, na.rm = TRUE)
table(datos$ciudad)  # Ver distribución

# --- INSPECCIONAR PASO A PASO ---
# Guarda resultados intermedios
paso1 <- datos[datos$año == 2020, ]
print(nrow(paso1))

paso2 <- paso1[paso1$ciudad == "Madrid", ]
print(nrow(paso2))

# --- TESTING PEQUEÑO ---
# Prueba tu código con subset pequeño primero
datos_test <- head(datos, 10)
# Ejecuta tu código con datos_test


# ==============================================================================
# 14. CHECKLIST RÁPIDO PARA EXAMEN
# ==============================================================================

# [ ] ¿Cargué los datos correctamente? → head(), str()
# [ ] ¿Hay NA donde no debería? → sum(is.na())
# [ ] ¿Los tipos son correctos? → class(), as.numeric()
# [ ] ¿Tengo duplicados? → duplicated(), unique()
# [ ] ¿Los nombres coinciden para merge? → unique(), tolower(), trimws()
# [ ] ¿Las condiciones son correctas? → sum(condicion)
# [ ] ¿Los resultados tienen sentido? → summary(), dim()
# [ ] ¿Usé vectorización o bucles innecesarios? → ifelse() vs for


# ==============================================================================
# 15. PATRONES COMUNES EN EXÁMENES
# ==============================================================================

# --- PATRÓN 1: Encontrar fila relacionada con otra ---
# "Obten el nombre de la provincia que está 3 filas antes de los totales"

indices_totales <- which(datos$tipo == "Total")
indices_provincias <- indices_totales - 3
nombres <- datos[indices_provincias, "provincia"]

# --- PATRÓN 2: Agregar subcategorías ---
# "Melilla tiene datos por sexo, suma para obtener total"

filtro <- datos[datos$ciudad == "Melilla" & datos$sexo != "Total", ]
total_melilla <- sum(filtro$poblacion)
datos[datos$ciudad == "Melilla" & datos$sexo == "Total", "poblacion"] <- total_melilla

# --- PATRÓN 3: Combinar categorías ---
# "Unir Ceuta y Melilla en una sola"

# Extraer datos
filtro <- datos[datos$ciudad == "Ceuta" | datos$ciudad == "Melilla", ]
total_combinado <- sum(filtro$valor)

# Eliminar originales
datos <- datos[!(datos$ciudad %in% c("Ceuta", "Melilla")), ]

# Agregar combinado
datos <- rbind(datos, c("Ceuta y Melilla", total_combinado))
datos$valor <- as.numeric(datos$valor)  # Reconvertir

# --- PATRÓN 4: Calcular diferencia respecto a referencia ---
# "Calcular % diferencia de cada comunidad respecto al total nacional"

valor_nacional <- datos[datos$region == "Total Nacional", "valor"]
datos$diferencia_porc <- round((datos$valor - valor_nacional) / valor_nacional * 100)

# --- PATRÓN 5: Filtrado con múltiples datasets ---
# "Obtener solo las provincias que aparecen en ambos datasets"

provincias_comunes <- intersect(df1$provincia, df2$provincia)
df1_filtrado <- df1[df1$provincia %in% provincias_comunes, ]
df2_filtrado <- df2[df2$provincia %in% provincias_comunes, ]

################################################################################
# ¡MUCHA SUERTE EN LA RECUPERACIÓN!
################################################################################
