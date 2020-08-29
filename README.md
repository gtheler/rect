# Problema

El problema a resolver consiste en la ecuación del calor

$$
\nabla \left( k \cdot \nabla T(x,y)\right) = 0
$$

\noindent
sobre un dominio rectangular $[0,r_c]\times[0,h]. Las condiciones de contorno son

$$
\begin{cases}
q^{\prime \prime} = 0 & \text{en $x=0$ (left)} \\
T(x,y) = V_n & \text{en $y=0$ (bottom)} \\
q^{\prime \prime} = \frac{1}{Z_m) \cdot(T(x,y) - V_m) & \text{en $y=h$ (top)} \\
q^{\prime \prime} = -\frac{r_c^2}{R_b) \cdot(T(x,y) - V_m) & \text{en $x=r_c$ (right)}
$$


# Solución

La solución mediante el método de elementos finitos se obtiene con el programa [Fino](https://www.seamplex.com/fino) utilizando una malla creada con el programa [Gmsh](http://gmsh.info/). Ambos son libres y abiertos.

## Malla

En un archivo llamado `rect.geo` se genera un rectángulo de $r_c \times h$ con el extremo izquiero inferior en el origen y genera una malla bi-dimensional de cuadrángulos estructurados. Las unidades están en centímetros. El refinamiento de la malla está dado por las variables `nx` y `ny` que controlan la cantidad de elementos en cada dirección.

```
rc = 7e-4;     // [ cm ]
h = 0.38e-7;   // [ cm ]

// cantidad de elementos en cada dirección
nx = 2000;
ny = 50;

// definición de los puntos del rectángulo
Point(1) = {0,  0, 0};
Point(2) = {rc, 0, 0};
Point(3) = {rc, h, 0};
Point(4) = {0,  h, 0};

// líneas
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// superficie
Curve Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

// definiciones para obtener una malla estrcturada
Transfinite Curve{1,3} = nx+1;
Transfinite Curve{2,4} = ny+1;
Transfinite Surface{1};
Mesh.RecombineAll = 1;   // sin esto se obtendrían triángulos

// definición de entidades físicas que van a tener las condiciones de contorno
Physical Curve("bottom") = {1};
Physical Curve("top") = {3};
Physical Curve("left") = {4};
Physical Curve("right") = {2};

Physical Surface("bulk") = {1};
```

## Elementos finitos

Para resolver la ecuación en derivadas parciales se utiliza el siguiente archivo llamado `rect.fin`:

```
MESH FILE_PATH rect.msh DIMENSIONS 2    # se lee la malla
FINO_PROBLEM thermal   # se indica que se requirere un problema termico
# FINO_SOLVER PROGRESS

# definicion de parametros del problema
rc = 7e-4   # [ cm ]
h = 0.38e-7 # [ cm ]

rho = 54    # [ ohm cm ]
Rb = 53.6   # [ ohm cm^2 ]
Cm = 2      # [ Fe-6 cm^{-2} ]
Zm = 1/(2*pi*Cm)

Vn = 1
Vm = 0

# la variable k es especial e indica la conductividad del problema térmico
k = 1/rho

# las condiciones de contorno
PHYSICAL_GROUP left   BC q=0
PHYSICAL_GROUP bottom BC T=Vn
PHYSICAL_GROUP top    BC h=+1/Zm    Tinf=Vm
PHYSICAL_GROUP right  BC h=-rc^2/Rb Tinf=Vm

FINO_STEP   # se resuelve el problema

# se escribe la funcion T(x,y) en un archivo ASCII llamado rect.dat
PRINT_FUNCTION FILE_PATH rect.dat T

# por si acaso se generan archivos para ser analizados por postprocesadores
MESH_POST FILE_PATH rect-results.vtk T
MESH_POST FILE_PATH rect-results.msh T

# para controlar que el tamaño de la malla sea razonable mostramos esto 
PRINT "nodos:   " nodes
PRINT "tiempo:  " time_wall_total "segundos"
PRINT "memoria: " memory/(1024*1024*1024) "Gb"
```


# Ejecución

## Gmsh

En una terminal, se debe llamar a Gmsh con el archivo de entrada `rect.geo` y el parámetro `-2` para generar la malla:

```
$ gmsh -2 rect.geo
```

Luego de este paso, debería haber un archivo `rect.msh` con la malla, que es el que lee Fino.
Si no se indica el argumento `-2` se abre una ventana gráfica donde es posible mallar y grabar el archivo de malla manualmente.

Si se desea modificar el tamaño del dominio o la cantidad de elementos se debe abrir el archivo `rect.geo`, editar los parámetros, grabarlo y volver a correr `gmsh`.

## Fino

Una vez obtenida la malla, se debe llamar a Fino con el archivo de entrada `rect.fin`:

```
$ fino rect.fin
nodos:          102051
tiempo:         0.395641        segundos
memoria:        0.478649        Gb
```

El resultado es un archivo llamado `rect.dat` con tres columnas, $x$, $y$ y $T(x,y)$.
Si se pasa el parámetro `--progress` se indica el progreso del ensamblado de la matrix y de la solución de las ecuaciones con barras de progreso:

```
$ fino rect.fin --progress
....................................................................................................
----------------------------------------------------------------------------------------------------
nodos:          102051
tiempo:         0.441557        segundos
memoria:        0.476871        Gb
```

