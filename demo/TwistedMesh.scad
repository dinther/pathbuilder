use <pathbuilder.scad>
use <meshbuilder.scad>
use <pointutils.scad>

$fn = 32;

svgString = "m0,0v5h27.5fillet3V30fillet8H60v-5h-27.5fillet3V0fillet8H0";

//  Example of shape used
svgShape(svgString);

//  Building the mesh
lp = [for (i=[0:0.002:1]) rotatePoints(translatePoints(rotatePoints(scalePoints(svgPoints(svgString)[0],[1.2-(1*i),1.2-(1*i)]),[0,0,-i*0]),[40 - (i*10), 0, 0]),[0,i*150])];
buildMeshFromPointLayers(lp, true, true, true,true);
echo(str(len(lp) * len(lp[0]), " vertices used"));
