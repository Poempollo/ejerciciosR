# ================================================================
# Ejercicios de clase Volumen 2: Dataframes
# Autor: ChatGPT y Miguel A. Lopez (por ese orden)
# 3/11/2025
# ================================================================

# ----------------------------------------------------------------
# Ejercicio 1: Creación de un data frame
# Enunciado:
#   Cree un data frame llamado df_alumnos con las columnas:
#     nombre  = c("Ana", "Luis", "Marta", "Jorge", "Eva")
#     edad    = c(22, 25, 24, 23, 27)
#     nota    = c(8.5, 6.0, 9.2, 4.8, 7.5)
#   Asegúrese de que 'nombre' sea carácter y no factor.

nombre <- c("Ana", "Luis", "Marta", "Jorge", "Eva")
edad   <- c(22, 25, 24, 23, 27)
nota   <- c(8.5, 6.0, 9.2, 4.8, 7.5)

df_alumnos <- data.frame(
  nombre = nombre,
  edad   = edad,
  nota   = nota,
  stringsAsFactors = FALSE
)

print(df_alumnos)

# ----------------------------------------------------------------
# Ejercicio 2: Selección de filas por condición
# Enunciado:
#   Obtenga las filas de df_alumnos correspondientes
#   a estudiantes con nota >= 7.

#utilizando la funcion subset para extraer un subconjunto
alumnos_mas7 <- subset(df_alumnos, Nota >= 7)
print(alumnos_mas7)

#aplicando un filtro en base a una condición
alumnos_mas7 <- df_alumnos[df_alumnos$Nota >= 7]
print(alumnos_mas7)

# ----------------------------------------------------------------
# Ejercicio 3: Selección de columnas
# Enunciado:
#   Extraiga únicamente las columnas nombre y nota
#   en un nuevo data frame df_notas.

# accediendo por el nombre de la columna
df_notas <- df_alumnos[, c("nombre", "nota")]
print(df_notas)

# accediendo por el orde de la columna
df_notas <- df_alumnos[, c(1,3)]
print(df_notas)

# ----------------------------------------------------------------
# Ejercicio 4: Nueva columna calculada
# Enunciado:
#   Añada a df_alumnos una columna llamada "aprobado"
#   que valga TRUE si nota >= 5 y FALSE en caso contrario.

df_alumnos$aprobado <- df_alumnos$nota >= 5
print(df_alumnos)

# ----------------------------------------------------------------
# Ejercicio 5: Reordenación por una columna
# Enunciado:
#   Ordene df_alumnos de mayor a menor nota.
#   Guarde el resultado en df_ordenado.

# primera alternativa
orden_notas <- order(df_alumnos$nota, decreasing = TRUE)
df_ordenado <- df_alumnos[orden_notas, ]
print(df_ordenado)

# segunda alternativa estableciendo el orden descendente
df_ordenado <- df_alumnos[order(-df_alumnos$Nota), ]
rownames(df_ordenado) <- NULL  # con esto forzamos a rehacer el índice
print(df_ordenado)

# ----------------------------------------------------------------
# Ejercicio 6: Filtrado combinado
# Enunciado:
#   Seleccione las filas de df_alumnos donde:
#     - aprobado == TRUE
#     - edad es estrictamente mayor que 23
#   Guarde el resultado en df_filtrado.

df_filtrado <- df_alumnos[df_alumnos$aprobado == TRUE & df_alumnos$edad > 23, ]
print(df_filtrado)

# ----------------------------------------------------------------
# Ejercicio 7: Estadísticos agrupados "a mano"
# Enunciado:
#   Suponga que cada alumno pertenece a un grupo:
#     grupo = c("A", "A", "B", "B", "A")
#   Añada esta columna a df_alumnos y calcule la nota media por grupo
#   usando tapply().
# Solución:
df_alumnos$grupo <- c("A", "A", "B", "B", "A")
media_por_grupo <- tapply(df_alumnos$nota, df_alumnos$grupo, mean)
print(df_alumnos)
print(media_por_grupo)

# ----------------------------------------------------------------
# Ejercicio 8: Eliminación de filas con NA
# Enunciado:
#   Cree un nuevo data frame df_sensores con las columnas:
#     sensor_id = c("S1", "S2", "S3", "S4", "S5")
#     temperatura = c(20.1, NA, 19.8, NA, 22.5)
#     activo = c(TRUE, TRUE, FALSE, TRUE, TRUE)
#   Elimine todas las filas que tengan NA en la columna temperatura.
# Solución:
df_sensores <- data.frame(
  sensor_id   = c("S1", "S2", "S3", "S4", "S5"),
  temperatura = c(20.1, NA, 19.8, NA, 22.5),
  activo      = c(TRUE, TRUE, FALSE, TRUE, TRUE),
  stringsAsFactors = FALSE
)

print(df_sensores)

df_sensores_sin_na <- df_sensores[!is.na(df_sensores$temperatura), ]
print(df_sensores)
print(df_sensores_sin_na)

# ----------------------------------------------------------------
# Ejercicio 9: Unión por posición y por nombre
# Enunciado:
#   Considere dos data frames pequeños:
#     df_ids <- data.frame(
#       id   = c(101, 102, 103),
#       user = c("u1", "u2", "u3"),
#       stringsAsFactors = FALSE
#     )
#     df_scores <- data.frame(
#       user = c("u2", "u1", "u4"),
#       score = c(15, 20, 5),
#       stringsAsFactors = FALSE
#     )
#   1) Haga un "merge" por la columna común 'user' para unir la puntuación.
#   2) Interprete por qué un usuario puede tener NA.
# Solución:
df_ids <- data.frame(
  id   = c(101, 102, 103),
  user = c("u1", "u2", "u3"),
  stringsAsFactors = FALSE
)

df_scores <- data.frame(
  user  = c("u2", "u1", "u4", "u1"),
  score = c(15, 20, 5, 100),
  stringsAsFactors = FALSE
)

df_merged <- merge(df_ids, df_scores, by = "user", all.x = TRUE)
print(df_merged)
# Nota:
# 'u3' aparece en df_ids pero no en df_scores, por eso su score es NA.

# ----------------------------------------------------------------
# Ejercicio 10: Resumen estadístico columna a columna
# Enunciado:
#   Usando df_alumnos (con las columnas edad y nota),
#   calcule para cada columna numérica:
#     mínimo, máximo, media y sd.
#   Hágalo usando sapply() sobre un subconjunto numérico del data frame.
# Solución:
numericas <- df_alumnos[, c("edad", "nota")]
resumen <- data.frame(
  minimo = sapply(numericas, min),
  maximo = sapply(numericas, max),
  media  = sapply(numericas, mean),
  sd     = sapply(numericas, sd)
)
print(resumen)

# ============================== FIN ==============================
