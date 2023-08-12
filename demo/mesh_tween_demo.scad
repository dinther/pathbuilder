use <meshbuilder.scad>
use <pathbuilder.scad>

$fn=32;

c1 = "M2,0 fillet3,9 L6,9 fillet16,6 L12,15 H-12 L-6,9 fillet16,6 L-2,0 fillet3,9";
c2 = "M10,0 fillet8,9 L14,10 fillet16,6 L15,15 H-15 L-14,10 fillet16,6 L-10,0  fillet8,9";

pl = [for(i=[0:30]) svgPoints(svgTweenPath(c1, c2, i/30), i)[0]];
buildMeshFromPointLayers(pl, true, true, true);    



