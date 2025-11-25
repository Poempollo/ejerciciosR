# ================================================================
# Ejercicios de clase Volumen 3: Estructuras de control y funciones
# Autor: ChatGPT y Miguel A. Lopez (por ese orden)
# 17/11/2025
# ================================================================

# ---------------------------------------------------------------------
# Ejercicio 1: if / else básico
# Enunciado:
#   Dados dos números a y b, imprima cuál es mayor o si son iguales
#   utilizando if / else.

a <- 4 
b <- 7

if (a > b) {
  mensaje <- paste(a,"es mayor que", b)
} else if (a < b) {
  mensaje <- sprintf("b (%d) es mayor que a (%d)", b, a)
} else {
  mensaje <- "a y b son iguales"
}
print(mensaje)

# ---------------------------------------------------------------------
# Ejercicio 2: switch para mapear códigos
# Enunciado:
#   Cree una función categoria(nivel) que devuelva:
#     1 -> "Bajo", 2 -> "Medio", 3 -> "Alto"; cualquier otro -> "Desconocido"
#   Use switch().
#   https://r-coder.com/funcion-switch-r/

categoria <- function(nivel) {
  res <- switch(as.character(nivel),
                "1" = "Bajo",
                "2" = "Medio",
                "3" = "Alto",
                "Desconocido")
  return(res)
}
print(c(categoria(1), categoria(2), categoria(5)))

categoria <- function(nivel) {
  res <- switch(nivel, "Bajo", "Medio", "Alto")
  if (is.null(res)) { res <- "Desconocido"  }
  return(res)
}
print(c(categoria(1), categoria(2), categoria(8)))

# ---------------------------------------------------------------------
# Ejercicio 3: for con next y break
# Enunciado:
#   Recorra 1:10 e imprima solo los números impares hasta encontrar el 7.
#   Use next para saltar pares y break al llegar a 7.

# la solución del profe
for (i in 1:10) {
  if (i %% 2 == 0) next
  if (i == 7) { print(i); break }
  print(paste("impar menor que 7:",i))
}

# la solución de Zuhir
for(i in 1:10){
  if (i %% 2 == 0) {
    next
  }
  print(i)
  if (i == 7) {
    break
  }
}

# de forma clasica, sin hacer caso al enunciado
for(i in 1:10){
  if ((i %% 2 != 0) & (i<=7)) {
     print(i)
  }
}

# ---------------------------------------------------------------------
# Ejercicio 4: while con condición de parada
# Enunciado:
#   Genere números uniformes U(0,1) hasta que la suma supere 3.
#   Cuente cuántos números fueron necesarios.

# la solución del profe
set.seed(42)
suma <- 0; conteo <- 0
while (suma <= 3) {
  x <- runif(1)
  suma <- suma + x
  conteo <- conteo + 1
}
print(list(suma = suma, n = conteo))


# la solución de Dennys
suma <- 0
contador <- 0

while (suma <= 3) {
  numero <- runif(1,min = 0, max = 1)         
  suma <- suma + numero
  print(suma)
  contador <- contador + 1
}

print(contador)

# ---------------------------------------------------------------------
# Ejercicio 5: repeat con validación y salida por break
# Enunciado:
#   Simule tiradas de un dado justo (1..6) hasta obtener un 6.
#   Use repeat y salga con break.
#   https://r-coder.com/funcion-sample-r/

set.seed(4586)
repeat {
  d <- sample(1:6, size = 1)
  print(d)
  if (d == 6) break
}

# la solucion de Francisco
x <- 1:6
resultado <- 0
repeat {
  resultado <- sample(x, 1, replace = TRUE)
  print(resultado)
  if (resultado == 6) break
}

# Y ahora sin bucle

tirarDado <- function(x) {
  resultado <- sample(x, 1, replace = TRUE)
  print(resultado)
  if(resultado != 6) tirarDado(1:6)
}
tirarDado(1:6)

tiradas <- sample(1:6, size = 100000, replace = TRUE)
n <- match(6, tiradas)
tiradas[1:n]

# ---------------------------------------------------------------------
# Ejercicio 6: Función con argumentos por defecto y validación
# Enunciado:
#   Defina una función escalar(x, factor = 1) que multiplique un vector numérico
#   por 'factor'. Valide que x sea numérico y que factor sea escalar finito;
#   en caso contrario lance error con stop().

escalar <- function(x, factor = 1) {
  if (!is.numeric(x)) stop("'x' debe ser numérico.")
  if (!is.numeric(factor) || length(factor) != 1 || !is.finite(factor)) {
    stop("'factor' debe ser un número finito de longitud 1.")
  }
  x * factor
}
print(escalar(1:5, 2))
print(escalar(1:5, Inf))

# ---------------------------------------------------------------------
# Ejercicio 7: Función que devuelve múltiples valores (lista)
# Enunciado:
#   Defina una función resumen_num(x) que devuelva una lista con
#   minimo, maximo, media y sd de un vector numérico, ignorando NA.

resumen_num <- function(x) {
  if (!is.numeric(x)) stop("'x' debe ser numérico.")
  list(
    minimo = min(x, na.rm = TRUE),
    maximo = max(x, na.rm = TRUE),
    media  = mean(x, na.rm = TRUE),
    sd     = sd(x, na.rm = TRUE)
  )
}
print(resumen_num(c(1, 3, NA, 7, 9)))

print(resumen_num(c(2, 2, NA, 2, 2)))

# ---------------------------------------------------------------------
# Ejercicio 8: Función de orden superior (recibe otra función)
# Enunciado:
#   Defina aplicar2(x, f) que aplique una función 'f' elemento a elemento
#   sobre 'x'. Valide que 'f' sea una función. Devuelva el mismo tipo que sapply.

aplicar2 <- function(x, f) {
  
  if (!is.function(f)) stop("'f' debe ser una función.")
  
  sapply(x, f)
}
print(aplicar2(1:5, function(z) z^2))

# ---------------------------------------------------------------------
# Ejercicio 9: Clausuras (closures)
# Enunciado:
#   Implemente fabrica_suma(k) que devuelva una función g(x) = x + k,
#   capturando el valor de k en el entorno.

fabrica_suma <- function(k) {
  function(x) x + k
}
sumar5 <- fabrica_suma(5)
print(sumar5(10))  # 15

# veamolos aplicado al ejercicio anterior
print(aplicar2(1:5, sumar5))

# ---------------------------------------------------------------------
# Ejercicio 10: Recursión (factorial) con control de errores
# Enunciado:
#   Escriba factorial_r(n) recursivo que:
#     - Lance error si n no es entero no negativo.
#     - Use caso base para n==0 o n==1.

factorial_r <- function(n) {
  if (!is.numeric(n) || length(n) != 1 || n < 0 || n != floor(n)) {
    stop("'n' debe ser un entero no negativo.")
  }
  if (n == 0 || n == 1) return(1)
  return(n * factorial_r(n - 1))
}
print(factorial_r(5))

# ---------------------------------------------------------------------
# Ejercicio 11: Manejo de errores con tryCatch
# Enunciado:
#   Defina segura_sqrt(x) que devuelva sqrt(x) y, si x < 0, capture el error
#   y devuelva NA con una advertencia (warning()).

segura_sqrt <- function(x) {
  tryCatch(
    sqrt(x),
    warning = function(w) { warning(w$message); NA_real_ },
    error   = function(e) { warning(e$message); NA_real_ }
  )
}
salida <- c(segura_sqrt(9), segura_sqrt(-1))
