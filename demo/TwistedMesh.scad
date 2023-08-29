use <pathbuilder.scad>
use <meshbuilder.scad>
use <pointutils.scad>

$fn = 32;

angle=180;
radius = 30;

//  Building a 2D profile
//  We define a start shape and end shape and use the svgTweenPath.
//  to generate the path definitions in between. This way we can
//  keep a consistent radius in the model.

start_shape = "m0,0v5h27.5fillet3V40fillet8H60v-5h-27.5fillet3V0fillet8H0";
end_shape = "m0,0v5h27.5fillet3V20fillet8H60v-5h-27.5fillet3V0fillet8H0";

//  This is what the shapes looks like

translate([30,40,0]) color("blue") polygon(svgPoints(svgTweenPath(start_shape, end_shape, 0))[0]);
translate([-30,40,0]) color("red") mirror([-1,0,0]) polygon(svgPoints(svgTweenPath(start_shape, end_shape, 1))[0]);

//  Building the mesh

//  Now we are going to  manipulate the shape point list
//  many times inside a loop counting from 0 to 1 in small steps
//  You see here several manipulation functions nested.

lp = [for (i=[0:0.002:1]) rotatePoints(translatePoints(svgPoints(svgTweenPath(start_shape, end_shape,i))[0],[radius, 0, 0]),[0,i*-angle,0])];
buildMeshFromPointLayers(lp, true, true, true,true);

//  Multiply the number of paths and points per path
//  to get the total number of vertices for the mesh.
echo(str(len(lp) * len(lp[0]), " vertices used"));
