use <pathbuilder.scad>
use <meshbuilder.scad>

//  This demo shows how versatile pathbuilder functions and meshbuilde can be
//  by directly generating a cube with rounded vertical edges without using any boolean operations.
//  I do hate that I have to go through convoluted code to form a parametric path string
//  But it is the only way to get my hands on the point lists directly.
//  Look closely at pb_scale_pts not only does it scale a list of points,
//  it also converts the 2D points list into a 3D one.
//  the thus formed loops each at their own z height can not be passed
//  as a list of 3D point lists to the meshbuilder.

//  This geometry is very difficult to achieve any other way.
//  You could try to put a hull around 4 leaning cylinders but I wish you luck getting the
//  outer dimensions correct.

module rounded_relief_cube(size=[1,1,1], radius=0.2, relief=0){
    f = str("fillet",radius);
    rot = relief<0? 180 : 0;
    dz = relief<0? size[2]: 0;
    s = tan(abs(relief))* size[2];
    xscale = (size[0]-s-s) / size[0];
    yscale = (size[1]-s-s) / size[1];
    valid = (xscale > 0) && (yscale > 0); 
    assert(valid, str("relief angle of ", relief, " deg too steep for this size"));
    if (valid) {
        x = size[0];
        y = size[1];
        path = str("M-",x/2,",-",y/2,f,"h",size[0],f,"v",size[1],f,"h-",x,f,"V0z");
        p1 = svgPoints(path);
        p2 = pb_scale_pts(p1[0], [xscale, yscale, size[2]]);
        translate([0,0,dz]) rotate([0,rot,0]) buildMeshFromPointLayers([p1[0], p2]);
    }
}

rounded_relief_cube([40,40,10], radius=5, relief=30);
