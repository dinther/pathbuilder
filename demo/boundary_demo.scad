include <pathbuilder.scad>

//  helper function to visualize a polyline
module draw_polyline(pts, w = 0.25, c=false) {
    pts=c? concat(pts,[pts[0]]) : pts;
    for(i = [0:len(pts)-2]) hull(){ translate(pts[i]) circle(d=w,$fn=16); translate(pts[i+1]) circle(d=w); }
}

//  Boundary
//  Demonstrates how a path can be constructed as a string and how the 
//  Forward command can be used to ray cast a line at a given angle to a list of points representing boundary line segments
boundary = "0 0 0 10 5 10 20 20 30 10";
linear_extrude(0.1) draw_polyline(svgPoints(str("M0 0L",boundary))[0]);  //  Show where the boundary is

for (i=[-80:10:80]){
    pts = svgPoints(str("m2 0h7angle",(i),"Forward",boundary))[0];
        //Do your thing to the points here
    if (len(pts)>2) color(rands(0,1,3),0.3) linear_extrude(0.081+i/1000) polygon(pts);
}

