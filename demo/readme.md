### TwistedMesh.scad
PathBuilder, MeshBuilder and pointutils in action together. With these tools you have absolute control over the dimensions and it is FAST. No boolean operations. Meshbuilder just spits out a mesh.
![image](https://github.com/dinther/pathbuilder/assets/1192916/bc98df98-11b8-48dd-914e-d1989ed8c6f6)


```
use <pathbuilder.scad>
use <meshbuilder.scad>
use <pointutils.scad>

$fn = 32;

angle=180;
start_radius = 40;
end_radius = 10;

//  Building a 2D profile
//  We define a start shape and end shape and use the svgTweenPath.
//  to generate the path definitions in between. This way we can
//  keep a consistent radius in the model.

start_shape = "m0,0v5h27.5fillet3V40fillet8H60v-5h-27.5fillet3V0fillet8H0";
end_shape = "m0,0v5h27.5fillet3V20fillet8H60v-5h-27.5fillet3V0fillet8H0";

//  This is what the shapes looks like

color("blue") polygon(svgPoints(svgTweenPath(start_shape, end_shape, 0))[0]);
color("red")  polygon(svgPoints(svgTweenPath(start_shape, end_shape, 1))[0]);

//  Building the mesh

//  Now we are going to  manipulate the shape point list
//  many times inside a loop counting from 0 to 1 in small steps
//  You see here several manipulation functions nested.

lp = [for (i=[0:0.002:1]) rotatePoints(translatePoints(svgPoints(svgTweenPath(start_shape, end_shape,i))[0],[start_radius + (i*(end_radius - start_radius)), 0, 0]),[0,i*-angle,0])];
buildMeshFromPointLayers(lp, true, true, true,true);

//  Multiply the number of paths and points per path
//  to get the total number of vertices for the mesh.
echo(str(len(lp) * len(lp[0]), " vertices used"));
```

### svgTweenPath demo

svgTweenPath takes two pathBuilder SVG path strings and interpolates the path values between the start and end shape using a factor variable between 0 and 1. Both SVG path strings must have the same number AND sequence of commands.

![image](https://user-images.githubusercontent.com/1192916/196610075-ef84996e-5148-4dd4-baef-17a06771d73f.png)

```
include <pathbuilder.scad>

//  This demo takes two svg paths and morphs the path parameters to create a 3D mesh

$pb_spline = 20;

function scaleXYPoints(pts, pos_scale=[1,1,1], neg_scale=[1,1,1]) = [for(pt=pts) [pt[0]<0? pt[0]*neg_scale[0]: pt[0]*pos_scale[0],pt[1]<0? pt[1]*neg_scale[1]: pt[1]*pos_scale[1],pt[2]<0? pt[2]*neg_scale[2]: pt[2] * pos_scale[2]]];

module buildMeshFromPointLayers(pointLayers = [], sides = true, bottom=true, top=true){
    n = len(pointLayers[0]);
    pts = [for (deck=[0:1:len(pointLayers)-1]) each pointLayers[deck]];
	faces = [for (d = [0:1:len(pointLayers)-2], p = [0:1:len(pointLayers[d])-2])	let(c = (n * d)+ p) [c,c+1, c+n+1,c+n]];
    bottom_points = bottom? pointLayers[len(pointLayers)-1] : [];
    bottom_faces = bottom? [for(i=[len(bottom_points)-1:-1:0]) i] : [];
    top_points = top? pointLayers[0] : [];
    top_faces = top? [for(i=[len(pts) - len(top_points):len(pts)-1]) i] : [];
    with_top_faces = top? concat(sides? faces: [], [top_faces]) : sides? faces: [];
    all_faces = bottom? concat(with_top_faces, [bottom_faces]) : with_top_faces;
	polyhedron(points = pts, faces = all_faces, convexity = 10);
} 

//  Note that the path must be closed with Z. This is not strictly nessesary when used with polygons because
//  polygons are always closed

p1 = "M -1170 0 V -185 C -980 -336 -738 -305 -507 -305 H 300 C 668 -305 882 -124 1034 -66  C 1179 -8   1260 -13 1260 0Z";
p2 = "M -1200 0 V -250 C -922 -353 -738 -345 -507 -345 H 400 C 548 -345 815 -287 1034 -215 C 1241 -143 1400 -57 1400 0Z";

point_layers = [for (i=[0:0.05:1]) scaleXYPoints(svgPoints(svgTweenPath(p1, p2, i),(1-cos(i*90))*150)[0],[1-sin(i*140)*0.1,1,1],[1,1,1])];
buildMeshFromPointLayers(point_layers, sides=true, bottom=true, top=true);
mirror([0,1,0]) buildMeshFromPointLayers(point_layers, sides=true, bottom=true, top=true);
```

### project_case.scad
![image](https://user-images.githubusercontent.com/1192916/153139548-ab34fd3d-5e7c-433b-9cf6-48fa8a1eebe7.png)

### Meshbuilder spiral
An advanced demo of a spiral generated with meshbuilder.
![image](https://github.com/dinther/pathbuilder/assets/1192916/bcef11be-5208-4ec0-b845-a0dca418b3fa)



