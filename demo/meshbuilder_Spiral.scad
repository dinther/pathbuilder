use <pathbuilder.scad>
use <meshbuilder.scad>

function rotate(x, y, z, angle) = let (
    c = cos(angle),
    s = sin(angle),
    nx = (c * x) + (s * y),
    ny = (c * y) - (s * x)) [nx, ny, z];

points = [[5,0,0],[5,0,0.3],[12,0,0.3],[12,0,0]];
angle = 720;
angle_step = 10;
p1 = [for(i=[0:angle_step:angle-1])
    rotate( points[0][0],points[0][1], points[0][2]+i*0.01, i)];
p2 = [for(i=[0:angle_step:angle-1])
    rotate( points[1][0],points[1][1], points[1][2]+i*0.01, i)];
p3 = [for(i=[0:angle_step:angle-1])
    rotate( points[2][0],points[2][1], points[2][2]+i*0.01, i)];
p4 = [for(i=[0:angle_step:angle-1])
    rotate( points[3][0],points[3][1], points[3][2]+i*0.01, i)];
n = len(p1);

//  Manually add end caps
faces = [[0, n, n * 2, n * 3],[n-1, n*2-1, n*3-1, n*4-1]];

buildMeshFromPointLayers([p1,p2,p3,p4,p1], true, false, false, false, faces);
