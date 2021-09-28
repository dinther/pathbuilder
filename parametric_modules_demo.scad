include <pathbuilder.scad>

col = [[0.109, 0.277, 0.715],[0.996, 0.449, 0.707],[0.832, 0.113, 0.102],[0.953, 0.363, 0.137],[0.980, 0.789, 0.066]];
//  Code with params
//  Here parameters and the loop variable are used directly in pathbuilder commands resulting in multiple arrows branching out.

aw = 20;                //  arrow shaft width
$fa=6;                  //  new segment when angle reaches 6 degrees
$fs=0.4;                //  don't make a new segment when it is smaller than 0.4 units

for (al=[10:20:90]) color(col[(al-10)/20])
    translate([20, 20, 0])
    linear_extrude(10-al/10)
    m(0,0)              //  start at origin
    chamfer(10)         //  apply a chamfer of 10 long at this point
    h(aw)               //  move horizontal along by given distance
    fillet(2)           //  apply a fillet with given radius
    v(al*2)             //  move vertical along by given distance
    fillet(al)          //  apply a fillet with given radius
    h(al*2)             //  move horizontal along by given distance
    fillet(2)           //  apply a fillet with given radius
    v(-aw/2)            //  move vertical along by given distance
    fillet(2)           //  apply a fillet with given radius
    l(35,aw)            //  move along by given x and y distance
    fillet(2)           //  apply a fillet with given radius
    l(-35, aw)          //  move along by given x and y distance
    fillet(2)           //  apply a fillet with given radius
    v(-aw/2)            //  move vertical along by given distance
    H(0)                //  move horizontal along to given x coordinate
    fillet(al+20);      //  apply a fillet with given radius