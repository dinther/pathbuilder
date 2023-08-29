use <pathbuilder.scad>
use <meshbuilder.scad>
use <pointutils.scad>
$fn=32;

module spiral(shape, angle, step, pitch){
    l = len(shape);
    pl = [for(j=[l:-1:0]) let(k=(j==l? 0:j)) [for(i=[0:step:angle-1])
        rotatePoint( [shape[k][0],shape[k][1], shape[k][2]+i*pitch/360], i)]];
    n = len(pl[0]);
    //  Manually add end caps
    front_cap = [for(i=[0:l-1]) n*i];
    end_cap = [for(i=[l:-1:1]) n*i-1];
    faces = [front_cap, end_cap];
    buildMeshFromPointLayers(pl, true, false, false, false, faces);
}

points = svgPoints("m5,0 h1 a10,10,0,0,1,10,0h1,v-2 a12,12,0,0,0,-12,0")[0];
//echo(points);
//points = [[M]];
//  swap y and z axis
shape = [for(pt = points) [pt[0],0,pt[1]]];
 
spiral(shape, 720, 5, 14);
