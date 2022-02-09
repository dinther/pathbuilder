include <pathbuilder.scad>

pb_petal = "m0 -1c-25-30 25-30 0,0 z";
$pb_spline=66;                                  //  We want 36 line segments on each spline.
pts = svgPoints(pb_petal)[0];                      //  Generate points list for the svg path.
    //  Do your thing to the points here
for(a=[0:120:360]) rotate([0,15,a]) polygon(pts);
