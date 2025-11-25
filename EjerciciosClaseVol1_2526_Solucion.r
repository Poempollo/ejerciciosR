# ================================================================
# Ejercicios de clase Volumen 1: Vectores en R 
# Autor: ChatGPT y Miguel A. Lopez (por ese orden)
# 23/10/2025
# ================================================================

# ----------------------------------------------------------------
# Ejercicio 1: Seleccion condicional vectorizada
# Enunciado:
#   Dado a <- c(3, -1, 0, 5, -2), cree un nuevo vector con el valor TRUE
#   donde a sea positivo y FALSE en caso contrario.

a <- c(3, -1, 0, 5, -2)

positivos <- a >= 0
print(positivos)

# Y un vector de enteros? 1 donde sea positivo y 0 donde sea negativo
positivos <- as.numeric(a >= 0)
print(positivos)


# ----------------------------------------------------------------
# Ejercicio 2: Filtrado condicional múltiple
# Enunciado:
#   Cree un vector "temperaturas" con los valores:
#   c(15, 22, 18, 30, 25, 10, 28, 19, 16, 33)
#   Obtenga un nuevo vector con las temperaturas entre 18 y 28 grados,
#   ambos inclusive.

temperaturas<-c(15, 22, 18, 30, 25, 10, 28, 19, 16, 33)
temp <- temperaturas[temperaturas>=18 & temperaturas<=28]
                     
#Y si no quiero las temperaturas sino sus posiciones?
which(temperaturas>=18 & temperaturas<=28)

#Y otra forma de hacerlo
seq(length(temperaturas))[temperaturas>=18 & temperaturas<=28]

# ----------------------------------------------------------------
# Ejercicio 3: Reemplazo condicional
# Enunciado:
#   A partir del mismo vector "temperaturas", reemplace todos los valores
#   menores que 18 por NA y muestre el resultado.

temperaturas_mod <- temperaturas
temperaturas_mod[temperaturas_mod < 18] <- NA
print(temperaturas_mod)

# O de otra forma
temperaturas_mod2 <- replace(temperaturas, temperaturas < 18, NA)
print(temperaturas_mod2)

# ----------------------------------------------------------------
# Ejercicio 4: Estadísticas personalizadas (sin mean() ni sd())
# Enunciado:
#   Calcule, sin usar mean() ni sd(), la media y la desviación estandar
#   de "temperaturas", empleando operaciones vectoriales basicas y
#   funciones como sum() y length().

# Calcular la media de los datos
# mean(temperaturas)
media <- sum(temperaturas)  / length(temperaturas)

# Restar la media a cada punto + hacer el cuadrado del resultado
# sd(temperaturas)
resta <- (temperaturas - media) ^ 2
suma <- sum(resta)
muestra <- suma / (length(temperaturas) - 1)
desviacion <- sqrt(muestra)

# En una sola linea
optimizado <- sqrt(sum((temperaturas - (sum(temperaturas)/length(temperaturas)))^2) / (length(temperaturas) - 1))

# Para comprobar
mean(temperaturas)
sd(temperaturas)

# ----------------------------------------------------------------
# Ejercicio 5: Escalado de valores
# Enunciado:
#   Cree un vector v <- c(5, 10, 15, 20, 25) y escalelo de forma
#   que su suma total sea igual a 1.

v <- c(5, 10, 15, 20, 25)
v_escalado <- v / sum(v)
sum(v_escalado)


# ----------------------------------------------------------------
# Ejercicio 6: Transformación lineal (tipificacion)
# Enunciado:
#   Transforme el vector x <- 1:6 para que tenga media 0 y desviacion
#   estándar 1 (tipificacion).

x <- 1:6
tip <- (x - mean(x)) / sd(x)

mean(tip)
sd(tip)

# ----------------------------------------------------------------
# Ejercicio 7: Operaciones vectoriales combinadas (margen %)
# Enunciado:
#   Cree dos vectores:
#     ventas <- c(120, 150, 100, 180, 200)
#     costes <- c(80, 90, 70, 110, 130)
#   Calcule el beneficio porcentual de cada elemento y guárdelo en
#   un nuevo vector `margen`.

ventas <- c(120, 150, 100, 180, 200)
costes <- c(80, 90, 70, 110, 130)
margen <- (ventas - costes) / costes * 100
print(margen)

# ----------------------------------------------------------------
# Ejercicio 8: Indexado con vectores logicos (mayores que la media)
# Enunciado:
#   Cree un vector
#     edades <- c(22, 34, 29, 41, 18, 55, 23, 37)
#   Obtenga las edades que sean mayores que la media del vector.

edades <- c(22, 34, 29, 41, 18, 55, 23, 37)
edades2 <- edades[edades > mean(edades)]
print(edades2)

# Y si quisieramos eliminar las edades menores que la media
edades_mayores <- edades
edades_mayores[edades < mean(edades)] <- NA
print(edades_mayores)

# ----------------------------------------------------------------
# Ejercicio 9: Secuencias y repeticion + ordenación descendente
# Enunciado:
#   Genere un vector que repita la secuencia c("A", "B", "C") 4 veces
#   y luego ordene el resultado de forma descendente alfabéticamente.

v <- rep(c("A", "B", "C"), 4)
v_ordenado <- sort(v)
print(v_ordenado)

# Y en orden inverso
v <- rep(c("A", "B", "C"), 4)
v_ordenado <- sort(v,decreasing = TRUE) # o rev()
print(v_ordenado)

# ----------------------------------------------------------------
# Ejercicio 10: Reordenacion basada en otro vector
# Enunciado:
#   Dado nombres <- c("Ana", "Luis", "Eva", "Carlos") y
#        edades <- c(25, 30, 22, 28),
#   ordenelos de menor a mayor edad.

nombres <- c("Ana", "Luis", "Eva", "Carlos")
edades <- c(25, 30, 22, 28)

NombresOrdenados <- nombres[order(edades)]
print(NombresOrdenados)

# ----------------------------------------------------------------
# Ejercicio 11: Conteo rápido
# ** Es necesario explicar la funcion table. 
# ** Se podria no utilizar? Estructuras de control de flujo.
# Enunciado:
#   Con valores <- c(1, 2, 2, 3, 1, 1, 2, 3, 3, 3), cuente cuántas
#   veces aparece cada número.

valores <- c(1, 2, 2, 3, 1, 1, 2, 3, 3, 3)

# la solucion de Erik
df_valores <- data.frame(
  "n1" = length(c(valores[valores == 1])),
  "n2" = length(c(valores[valores == 2])),
  "n3" = length(c(valores[valores == 3]))
)

# la solucion de Santiago
count <- c(length(which(valores == 1)),
           length(which(valores == 2)),
           length(which(valores == 3)))

# Y con table
conteo <- table(valores)
print(conteo)

# ----------------------------------------------------------------
# Ejercicio 12: Funciones aplicadas a subconjuntos
# ** Es necesario explicar los if en linea
# Enunciado:
#   Dado un vector
#     notas <- c(7, 4, 9, 5, 6, 10, 8, 3, 5, 9)
#   calcule la media de las notas aprobadas (>= 5) y la media de las
#   suspensas (< 5) usando unicamente indexado y funciones basicas.

notas <- c(7, 4, 9, 5, 6, 10, 8, 3, 5, 9)

media_a <- mean(notas[notas >= 5])
media_s <- mean(notas[notas < 5])

media_a
media_s

# Y con if_else
aprobadas <- notas[notas >= 5]
suspendidas <- notas[notas < 5]

media_aprobadas <- if (length(aprobadas) > 0) sum(aprobadas) / length(aprobadas) else NA
media_suspendidas <- if (length(suspendidas) > 0) sum(suspendidas) / length(suspendidas) else NA

print(media_aprobadas)
print(media_suspendidas)


# ----------------------------------------------------------------
# Ejercicio 13: Sustitucion sin ifelse
# Enunciado:
#   Dado x <- c(4, 9, NA, 16, NA), sustituya los valores NA por la
#   media de los elementos no nulos.
# Solución:

x <- c(4, 9, NA, 16, NA)

# La solucion de Javier
vector <- x[!is.na(x)]
media2 <- mean(vector)
x[is.na(x)] <- media2
print(x)

# La solucion de Alexander
refactorizado <- x
refactorizado[is.na(x)] <- mean(x, na.rm = TRUE)
print(refactorizado)

# La solucion de Dennys
refactorizado <- x
refactorizado[is.na(x)] <- mean(sort(x))
print(refactorizado)

# La solucion del profe
refactorizado <- x
refactorizado[is.na(x)] <- mean(x[!is.na(x)])
print(refactorizado)

# Otra solucion del profe
x <- c(4, 9, NA, 16, NA)
media_x <- mean(x, na.rm = TRUE)
x_sin_na <- replace(x, is.na(x), media_x)
print(x_sin_na)


# ----------------------------------------------------------------
# Ejercicio 14: Creacion dinamica, concatenacion, orden y unicos
# Enunciado:
#   Cree tres vectores:
#     v1 <- 1:4
#     v2 <- seq(10, 40, by = 10)
#     v3 <- rep(5, 3)
#   Concatene los tres en un unico vector "v_total", ordenelo de forma
#   descendente y elimine los duplicados.

v1 <- 1:4
v2 <- seq(10, 40, by = 10)
v3 <- rep(5, 3)

v_con <- c(v1,v2,v3)
v_total <- sort(unique(v_con), decreasing=TRUE)


# ----------------------------------------------------------------
# Ejercicio 15: Funciones vectorizadas con sapply / vapply
# ** Es necesario explicar las funciones vectorizadas
# Enunciado:
#   Cree un vector
#     x <- c(-2, 4, -6, 8, -10)
#   Aplique una función anónima que devuelva el valor absoluto multiplicado
#   por 2 para cada elemento, usando sapply() o vapply().

# Con sappy
x <- c(-2, 4, -6, 8, -10)
x_absoluto <- sapply(x, function(i) { abs(i) * 2 })

# No es necesario aplicarlo en forma de función
x_absoluto <- sapply(x,abs(i) * 2)

# Y con vapply
x_absoluto_con_vapply <- vapply(x, function(i) { 
  abs(i) * 2
}, numeric(1))


# ----------------------------------------------------------------
# Ejercicio 16: Funcion normalizar() (0–1) y prueba con runif
# ** Es necesario explicar funciones, estructura if y generacion de aleatorios
# Enunciado:
#   Defina una funcion `normalizar()` que reciba un vector numerico y devuelva
#   su version normalizada entre 0 y 1:
#     x' = (x - min(x)) / (max(x) - min(x))
#   Pruebe su funcionamiento con un vector aleatorio generado con
#   runif(10, min=50, max=100).

normalizar <- function(vec) {
  vmin <- min(vec)
  vmax <- max(vec)
  rango <- vmax - vmin
  if (rango == 0) {
    return(rep(0, length(vec)))  # todos iguales
  }
  (vec - vmin) / rango
}

# Vamos a probarla con  un vector de aleatorios fijando la semilla
set.seed(123) 
v_aleatorio <- runif(10, min = 50, max = 100)
v_norm <- normalizar(v_aleatorio)
print(v_aleatorio)
print(v_norm)
print(range(v_norm))  # comprobación: 0 y 1 (aprox.)

