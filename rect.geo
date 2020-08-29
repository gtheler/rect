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
