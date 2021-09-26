include <pathbuilder.scad>
//Select which demo you want to see
show_demo = 1; // [1:(1) Quick shape, 2:(2) Points first, 3:(3) Step by step, 4:(4) Boundary, 5:(5) In code, 6:(6) With params]


//example shapes
pb_arrow = "m 0 0chamfer10h20fillet2v10segment10 10 10h10fillet2v-10fillet2l35 20fillet2L40 50fillet2v-10h-10Segment0 10-30z";
pb_polar = "m0 0Polar 20 30segment20 0 -15 64forward20V0";
pb_swoosh ="M68.56-4L18.4-25.36Q12.16-28 7.92-28q-4.8 0-6.96 3.36-1.36 2.16-.8 5.48t2.96 7.08q2 3.04 6.56 8-1.6-2.56-2.24-5.28-1.2-5.12 2.16-7.52Q11.2-18 14-18q2.24 0 5.04 .72z";
pb_petal = "m0 -1c-25-30 25-30 0,0 z";


module polyline(pts, w = 0.25, c=false) {
    pts=c? concat(pts,[pts[0]]) : pts;
    for(i = [0:len(pts)-2]) hull(){ translate(pts[i]) circle(d=w,$fn=16); translate(pts[i+1]) circle(d=w); }
}

//  (1) Quick Shape
if (show_demo==1){
    svgShape("m 0 0chamfer10h20fillet2v10segment10 10 10h10fillet2v-10fillet2l35 20fillet2L40 50fillet2v-10h-10Segment0 10-30z");
}

//  (2) Points first
if (show_demo==2){
    $pb_spline=36;                                  //  We want 36 line segments on each spline.
    pts = svgPoints(pb_petal);                        //  Generate points list for the svg path.
    //Do your thing to the points here
    for(a=[0:120:360]) rotate([0,15,a]) polygon(pts);
}

//  (3) Step by step
//  Demonstrates how a path string is first tokenized then processed and finally post processed.
//  Intermediate values can be examined with echo.
//  Normally you would just use svgPoints or svgShape to get an immediate result.
//  In this case the resulting pts list is re-used which is more efficient.
if (show_demo==3){
    cmds = pb_tokenizeSvgPath(pb_swoosh);
    for (c=cmds) echo(c);                           //  show the command list data after tokenizing the path.
    data = pb_processCommands(cmds);
    echo("demo 3",data=data);
    pts = pb_postProcessPath(data);
    echo("demo 3",pts=pts);
    
    //Flip the shape on the y axis because in SVG data obtained online the +y axis points down as is standard with SVG.
    scale([1,1]) polygon(pts);
}

//  Boundary
//  Demonstrates how a path can be constructed as a string and how the 
//  Forward command can be used to ray cast a line at a given angle to a list of points representing boundary line segments
if (show_demo==4){
    boundary = "0 0 0 10 5 10 20 20 30 10";
    linear_extrude(0.1) polyline(svgPoints(str("M0 0L",boundary)));  //  Show the boundary
    for (i=[-80:10:80]){
        pts = svgPoints(str("m2 0h7angle",(i),"Forward",boundary));
            //Do your thing to the points here
        if (len(pts)>2) color(rands(0,1,3),0.3) linear_extrude(0.081+i/1000) polygon(pts);
    }
}

//  In code
//  Pathbuilder can also be used directly in code. The same commands apply but here we are using the openSCAD modules
//  The advantage here is that you can directly use your parameters as further shown in the last demo.
//  Also a demonstration of the use of $fa and $fs. Pathbuilder respects $fn, $fa and $fs in it's approximation of circle and ellipse curves.
if (show_demo==5){
    $fs=0.3; $fa=6;
    m(0,0,0) chamfer(4) h(5) fillet(1) v(10) segment(10,10,10) h(10) fillet(1) v(-5) fillet(1) l(25,7.5) fillet(1) l(-25,7.5) fillet(1) v(-5) fillet(1) h(-10) Segment(0,10,-15);
}

col = [[0.109, 0.277, 0.715],[0.996, 0.449, 0.707],[0.832, 0.113, 0.102],[0.953, 0.363, 0.137],[0.980, 0.789, 0.066]];
//  Code with params
//  Here parameters and the loop variable are used directly in pathbuilder commands resulting in multiple arrows branching out.
if (show_demo==6){
    for (al=[10:20:90]) color(col[(al-10)/20]) translate([20, 20, 0]) linear_extrude(10-al/10) m(0,0,0,$fn=128) chamfer(10) h(20) fillet(2) v(al) segment(al, al, al) h(al) fillet(2) v(-10) fillet(2) l(35,20) fillet(2) l(-35, 20) fillet(2) v(-10) h(-al) Segment(0,al,-(al+20), $fn=48);
} 
/*
M(68.56,-4,0,$pb_spline=4)
L(18.4,-25.36)
Q(12.16,-28,7.92,-28)
q([-4.8,0,-6.96,3.36,-1.36,2.16,-.8,5.48])
t(2.96,7.08)
q([2,3.04,6.56,8,-1.6,-2.56,-2.24,-5.28,-1.2,-5.12,2.16,-7.5,2])
Q(11.2,-18,14,-18)
q(2.24,0,5.04,.72);*/




