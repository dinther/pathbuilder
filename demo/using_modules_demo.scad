include <pathbuilder.scad>

pb_arrow = "m 0 0chamfer4h5fillet1v20fillet10h20fillet1v-5fillet1l20 7.5fillet1l-20 7.5fillet1v-5H0fillet15z";

//  In code
//  Pathbuilder can also be used directly in code. The same commands apply but here we are using the openSCAD modules
//  The advantage here is that you can directly use your parameters as further shown in the last demo.
//  Also a demonstration of the use of $fa and $fs. Pathbuilder respects $fn, $fa and $fs in it's approximation of circle and ellipse curves.

$fa=6;                  //  new segment when angle reaches 6 degrees
$fs=0.4;                //  don't make a new segment when it is smaller than 0.4 units

    m(0,0)              //  start at origin
    chamfer(4)          //  apply a chamfer of 4 long at this point
    h(5)                //  move horizontal along by 5
    fillet(1)           //  apply a fillet with a radius of 1
    v(20)               //  move vertical up by 20
    fillet(10)          //  apply a fillet with a radius of 10
    h(20)               //  move horizontal along by 20
    fillet(1)           //  apply a fillet with a radius of 1
    v(-5)               //  move vertical down by 5
    fillet(1)           //  apply a fillet with a radius of 1
    l(20,7.5)           //  move right by 20 and up by 7.5
    fillet(1)           //  apply a fillet with a radius of 1
    l(-20,7.5)          //  move left by 20 and up by 7.5
    fillet(1)           //  apply a fillet with a radius of 1
    v(-5)               //  move vertical down by 5
    fillet(1)           //  apply a fillet with a radius of 1
    H(0)                //  move horizontal to x coordinate 0
    fillet(15);         //  apply a fillet with a radius of 15

 //  this red arrow uses the same commands in string format.
 color("red") translate([15,-15])
 svgShape("m 0 0chamfer4h5fillet1v20fillet10h20fillet1v-5fillet1l20 7.5fillet1l-20 7.5fillet1v-5H0fillet15z");

