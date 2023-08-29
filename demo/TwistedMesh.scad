use <pathbuilder.scad>
use <meshbuilder.scad>
use <pointutils.scad>

$fn = 32;

module handle(){
    pts = svgPoints("M0,0fillet3h20l5,3fillet4v8fillet4h-10fillet8")[0];
    pts1 = rotatePoints(pts,[5,0,0]);
    pts2 = translatePoints(rotatePoints(pts,[-5,0,0]),[0,0,3]);
    difference(){
        union(){
            translate([-10,1.5,0]) rotate([90,0,0]) buildMeshFromPointLayers([pts1,pts2]);
            stem();
        }
        rotate([5,-17,0])translate([7,1.45,2.5]) scale([1.7,0.15,0.7]) sphere(r=5, $fn=64);
        rotate([-5,-17,0])translate([7,-1.45,2.5]) scale([1.7,0.15,0.7]) sphere(r=5, $fn=64);
    }
}

module stem(){
    pts1 = svgPoints("M0,0h1.2l-1.2,5fillet0.7l-1.2,-5",0)[0];
    pts2 = svgPoints("M0 ,0h1.5l-1.5,8fillet1  l-1.5,-8",60)[0];
    translate([-60,0,0]) rotate([90,0,90])
    buildMeshFromPointLayers([pts1, pts2]);
}

module showPoints(pts, r= 0.1){
    for(pt = pts){
        echo(pt);
        translate(pt) sphere(r=r);
    }
}

lp = [for (i=[0:1:360]) rotatePoints(translatePoints(rotatePoints(scalePoints(circlePoints(r=10),[1,0.5,1]),[0,0,i*3]),[15,0,0]),[0,i,0])];
buildMeshFromPointLayers(lp, true, false, false);
