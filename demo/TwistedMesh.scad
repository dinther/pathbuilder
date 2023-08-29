use <pathbuilder.scad>
use <meshbuilder.scad>
use <pointutils.scad>

$fn = 32;

angle=180;
start_radius = 40;
end_radius = 10;

//  Building a 2D profile
//  svgPoints returns a list of paths but for a
//  simple enclosed shape there is only one path.
//  So we grab the one at index 0.
shape = svgPoints("m0,0v5h27.5fillet3V30fillet8H60v-5h-27.5fillet3V0fillet8H0")[0];

//  This is what it looks like
color("blue") polygon(shape);

//  Building the mesh

//  Now we are going to  manipulate the shape point list
//  many times inside a loop counting from 0 to 1 in small steps
//  You see here several manipulation functions nested.

lp = [for (i=[0:0.002:1]) rotatePoints(translatePoints(scalePoints(shape,[1.2-(1*i),1,1]),[start_radius + (i*(end_radius - start_radius)), 0, 0]),[0,i*-angle,0])];
buildMeshFromPointLayers(lp, true, true, true,true);

//  Multiply the number of paths and points per path
//  to get the total number of vertices for the mesh.
echo(str(len(lp) * len(lp[0]), " vertices used"));
