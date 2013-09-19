# Orga2 TP2

## Tareas generales
* hacer el esqueleto del informe con archivos independientes
* hacer la carátula del informe
* ponernos de acuerdo sobre cómo medir tiempos (en el código)
* ponernos de acuerdo sobre cómo exportar los tiempos medidos y cómo graficarlos
* escribir conclusiones (al final, supongo)

## Tareas comunes a los tres filtros
* programarlo en C
* programarlo en ASM usando SSE
* hacer comparaciones sobre la estructura de las dos implementaciones
* medir tiempos y hacer gráficos comparativos

## Filtro de Color (tareas particulares)
* analizar el código que genera el compilador
* estudiar distintas optimizaciones del compilador
* explicar cómo medimos y cómo evitamos errores cuando el SO interrumpe nuestro programa
* analizar el impacto de los saltos adentro de un ciclo
* modificar la implementación de ASM desenrollando ciclos
* hacer gráficos comparativos entre todas las distintas implementaciones
* explicar en qué momento del algoritmo conviene hacer conversiones entre tipos de datos

### Ejercicio 1
Programar el Filtro de Color en lenguaje C.

### Ejercicio 2
Utilizando el código C del ejercicio anterior como pseudocódigo, programar el Filtro de Color en
ASM haciendo uso de las instrucciones SSE.
Nota: No intentar realizar el código ASM directamente, utilizar el código C anterior como pseu-
docódigo para realizar el código ASM. Si el código C no parece servir para este objetivo, es fuertemente
recomendado replantearse el código realizado.

### Ejercicio 3
¿Cuáles son las diferencias estructurales entre la versión C y la de ASM de los ejercicios anteriores?
¿Qué cambia escencialmente entre las dos versiones? Utilice la herramienta objdump para verificar como
el compilador de C deja ensamblado el código C. Como es el código generado, ¿como se manipulan las
variables locales?¿le parece que ese código generado podria optimizarse?

### Ejercicio 4
Compile el código del ejercicio 1 con optimizaciones del compilador, por ejemplo, pasando el flag
-O1. ¿Que optimizaciones encuentra?¿Que otras flags de optimización brinda el compilador?¿Para que
sirven?

### Ejercicio 5
Realice una medición de las diferencias de performance entre las versiones de los ejercicios 1, 2 y
4 (este último con -O1, -O2 y -O3).
¿Como realizó la medición?¿Como sabe que su medición es una buena medida?¿Como afecta a la
medición la existencia de outliers?¿De que manera puede minimizar su impacto?¿Que resultados
obtiene si mientras corre los tests ejecuta otras aplicaciones que utilicen al máximo la CPU? Realizar
un gráfico que represente estas diferencias y un análisis científico de los resultados.

### Ejercicio 6
Se desea conocer que tanto impactan los saltos condicionales en el código del ejercicio 4 con -O1.
Para poder medir esto, una posibilidad es quitar las comparaciones al procesar cada pixel. Por más
que la imagen resultante no sea correcta, será posible tomar una medida del impacto de los saltos
condicionales. Analizar científicamente las diferencias. Si se le ocurren, mencionar otras posibles formas
de medir el impacto de los saltos condicionales.

### Ejercicio 7
La técnica para desenrollar ciclos (loop unrolling, loop unwinding) es muy útil a la hora transformar
los ciclos para optimizar la ejecución del código.
Estudiar esta técnica y proponer un aplicación al código del Ejercicio 2.
Utilizando el código ASM del Ejercicio 2, programar el Filtro de Color en ASM haciendo uso de
las instrucciones SSE y la técnica de desenrollado de ciclos.

### Ejercicio 8
¿Cuáles son las diferencias de performace entre las versiones de los Ejercicios 1, 2 y 7?
Realizar gráficos que representen estas diferencias y permitan realizar este análisis.

### Ejercicio 9
Debido a las operaciones necesarias para llevar adelante el filtro, quizás deban transformarse los
tipos de datos, ya sea por extensión/compresión de la representación, por ejemplo char/int, o por
conversión de la precisión, por ejemplo int/float.
Indicar en qué momento del código del filtro implementado en el Ejercicio 2 es más conveniente
realizar estas conversiones, tanto para manejar los datos de entrada como para devolver los resultados.
¿Qué otras optimizaciones proponen?

## Filtro Miniature (tareas particulares)
* como se comparan las implementaciones C vs ASM para diferentes tamaños de entrada
* explicar qué partes del filtro fue más importante optimizar

### Ejercicio 10
Programar el filtro Miniature en lenguaje C.

### Ejercicio 11
Utilizando el código C del ejercicio anterior como pseudocódigo, programar el filtro Miniature en
ASM haciendo uso de las instrucciones SSE.

### Ejercicio 12
¿Cuáles son las diferencias estrucutrales entre la versión en C y la de ASM de los Ejercicios 10 y
11?
¿Qué cambia escencialmente entre las dos versiones?
¿Cuáles son las diferencias de performace entre esta dos versiones?
Realizar gráficos que representen estas diferencias y permitan realizar este análisis.

### Ejercicio 13
¿Las diferencias anteriores se mantienen con distintos tamaños de entrada?
¿Influye en estas diferencias la multiplicidad de las filas y columnas de la entrada?
¿Cuales son los aspectos del filtro que encontrarón más prioritarios para optimizar y porqué? ¿Los
analisis finales lo confirman?

### Ejercicio 14
En el caso de existir diferencias, ¿a qué se deben? ¿cuál es su origen? ¿Tienen alguna relación con
las diferencias estrucutrales entre la versión C y ASM de los Ejercicios 12 y 13? Justificar.

## Filtro Decodificación Esteganográfica (tareas particulares)
* como se comparan las implementaciones C vs ASM para diferentes tamaños de entrada
* modificar la implementación de ASM agregando software pipelining y out-of-order execution

### Ejercicio 15
Programar el filtro Decodificación Esteganográfica en lenguaje C.

### Ejercicio 16
Utilizando el código C del ejercicio anterior como pseudocódigo, programar el filtro Decodificación
Esteganográfica en ASM haciendo uso de las instrucciones SSE.

### Ejercicio 17
¿Cuáles son las diferencias estructurales entre la versión C y la de ASM de los Ejercicios 15 y 16?
¿Qué cambia escencialmente entre las dos versiones?
¿Cuáles son las diferencias de performace entre esta dos versiones?
¿Estas diferencias se mantiene con distintos tamaños de entrada?
¿Influye la multiplicidad de las filas y columnas de la entrada?
Realizar gráficos que representen estas diferencias y permitan realizar este análisis.

### Ejercicio 18
La técnica de entubado de código (software pipelining, out-of-order execution) es otra técnica muy
utilizada para optimizar ciclos realizando ejecución fuera de orden y aprovechando los recursos de
harware del procesador.
Estudiar esta técnica y proponer una aplicación al código del Ejercicio 16.
Utilizando el código ASM del Ejercicio 16, programar el filtro Decodificación Esteganográfica en
ASM haciendo uso de las instrucciones SSE y la técnica de entubado de código.
Proponer optimizaciones que surjan de su desarrollo y decisiones puntuales que hayan tomado.
Hacer un analisis de las mismas.

### Ejercicio 19
¿Cuáles son las diferencias de performace entre las versiones de los Ejercicios 15, 16 y 18?
Realizar gráficos que representen estas diferencias y permitan realizar este análisis.
