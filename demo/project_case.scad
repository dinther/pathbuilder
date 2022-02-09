use <pathbuilder.scad>

//  project case

width = 40;
length = 60;
height = 30;
thickness = 2;
radius = 1.2;

module outer(width, length, radius){
    $fn = 64;
    m(0,0)
    fillet(radius)
    v(width)
    fillet(radius)
    h(length)
    fillet(radius)
    v(-width)
    fillet(radius); 
}

module inner(width, length, radius){
    $fn = 64;
    m(0,0)
    fillet(-radius)
    v(width)
    fillet(-radius)
    h(length)
    fillet(-radius)
    v(-width)
    fillet(-radius); 
}

module case(width, length, height, thickness, radius){
    $fn = 64;
    union(){
        linear_extrude(thickness){
            outer(width, length, thickness);
        }
        translate([0,0,thickness]) linear_extrude(height - thickness){
            difference(){
                outer(width, length, thickness);
                translate([thickness, thickness]) inner(width - (thickness * 2), length- (thickness * 2), thickness);
                translate([thickness, thickness]) circle(r = radius);
                translate([thickness, width - thickness]) circle(r = radius);
                translate([length - thickness, thickness]) circle(r = radius);
                translate([length - thickness, width - thickness]) circle(r = radius);
            }
        }
    }
}

case(width, length, height, thickness, radius);
