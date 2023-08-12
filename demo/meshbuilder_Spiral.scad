use <pathbuilder.scad>
use <meshbuilder.scad>

function rotate(x, y, z, angle) = let (
    c = cos(angle),
    s = sin(angle),
    nx = (c * x) + (s * y),
    ny = (c * y) - (s * x)) [nx, ny, z];

module spiral(shape, angle, step, pitch){
l = len(shape);
pl = [for(j=[0:l]) let(k=(j==l? 0:j)) [for(i=[0:step:angle-1])
    rotate( shape[k][0],shape[k][1], shape[k][2]+i*pitch/360, i)]];
n = len(pl[0]);
//  Manually add end caps
front_cap = [for(i=[0:l-1]) n*i];
end_cap = [for(i=[1:l]) n*i-1];
faces = [front_cap,end_cap];
buildMeshFromPointLayers(pl, true, false, false, false, faces);
}

spiral([[5,0,0],[5,0,0.3],[12,0,0.3],[12,0,0]], 720, 10, 3.6);
