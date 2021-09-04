//  pathbuilder
//
//  This libray is designed to create complex 2D shapes
//  It uses commands similar to the svg path syntax
//
//  example:
//
//  linear_extrude(1) s(0,0) h(2) v(1) c(1, 1, 1) h(1) v(-1) l(2,2) l(-2,2) v(-1) h(-1) C(0,1,-3) draw();
//
//  The above statement creates a 2D right angle arrow that is then extruded
//  Lowercase commands are drawn relative to the last drawn point.
//  Uppercase commands are drawn as absolute coordinates.
//
//  Latest version here: https://github.com/dinther/pathbuilder
//
//  By: Paul van Dinther


//  Helper functions:

function last(list) = list[len(list)-1];                                //  Returns last item from a list
function angle(pt1, pt2) = atan2(pt2[0] - pt1[0], pt2[1] - pt1[1]);     //  Returns angle of line between point 1 and point 2
function calcExitAngle(list) = angle(list[len(list)-2], last(list));    //  Returns angle of last line segment in points list
function dist(pt1, pt2) = sqrt(pow(pt2[0] - pt1[0],2) + pow(pt2[1] - pt1[1],2));  //  Returns distance between two points
function hypot(pt) = sqrt(pow(pt[0],2)+pow(pt[1],2));                         //  Calculates hypotenuse pythagoras
function subList(list, s=0, e) = [for(i=[s:max(s,min(e==undef? len(list)-1 : e, len(list) - 1))]) list[i]];  //  Returns subset of list sefined by s start and e end index

//  Calculates tangent fillet for a given point    
function fillet(pts, index, radius, flip=false, $fn=$fn) = let(
    a = index==0? pts[len(pts)-1] : pts[index-1],
    b = pts[index],
    c = index == len(pts)-1? pts[0]:pts[index+1],
    ba = a-b,
    bc = c-b,
    l1 = hypot(ba),
    l2 = hypot(bc),
    cos_angle = ba * bc / (l1 * l2),
    tan_half_angle = sqrt((1 - cos_angle) / (1 + cos_angle)),
    bf_length = radius / tan_half_angle,
    ba_u = ba/l1,
    bc_u = bc/l2,
    bf = ba_u*bf_length,
    bg = bc_u*bf_length,
    f = b + bf,
    g = b + bg,
    sig = sign(ba[0] * bc[1] - ba[1] * bc[0]) * (flip? -1 : 1),
    ps = curveBetweenPoints(f, g, radius * sig, true, $fn)
    //Calculate origin
    //v = ba_u * radius
    //o = f + [-v[1] * sig, v[0] * sig] : []
) ps;

//  Calculates a chamfer for a given point  
function chamfer(pts, index, size) = let(
    a = index==0? pts[len(pts)-1] : pts[index-1],
    b = pts[index],
    c = index == len(pts)-1? pts[0]:pts[index+1],
    d = size/2,
    ba = a-b,
    bc = c-b,
    l1 = hypot(ba),
    l2 = hypot(bc),
    cos_angle = ba * bc / (l1 * l2),
    tan_half_angle = sqrt((1 - cos_angle) / (1 + cos_angle)),
    bf_length = sqrt(pow(d/tan_half_angle,2) + pow(d,2)),
    ba_u = ba/l1,
    bc_u = bc/l2,
    bf = ba_u*bf_length,
    bg = bc_u*bf_length,
    f = b + bf,
    g = b + bg
) [f, g];

//  Returns point list following a circle segment with given radius between two points.
//  Flip the curve solution by changing the radius value to negative.
//  Radius value bust be at least half the distance between the two points.
function curveBetweenPoints(pt1, pt2, radius, incl_start_pt = true, $fn=$fn) = let(
    d = dist(pt1, pt2),
    r = abs(radius),
    e = assert(r*2>d, "Radius is too small"),
    y3 = (pt1[1] + pt2[1])/2,
    x3 = (pt1[0]+pt2[0])/2,
    basex = sqrt(pow(r,2) - pow((d/ 2),2)) * (pt1[1] - pt2[1]) / d,
    basey = sqrt(pow(r,2) - pow((d / 2),2)) * (pt2[0] - pt1[0]) / d,
    pc = radius > 0? [x3 - basex, y3 - basey] : [x3 + basex, y3 + basey],
    a1 = atan2(pt1[0]-pc[0], pt1[1]-pc[1]),
    a2 = atan2(pt2[0]-pc[0], pt2[1]-pc[1]),
    da = a2 - a1 % 360,
    cda = da<-180? 360 + da : da>180? -360 + da : da,
    steps = floor(abs(cda/360*($fn==0? 360/$fa : $fn))),
    step_angle = cda/steps,
    pts = concat(incl_start_pt? [pt1]: [],[for(i=[1:steps-1]) [sin(a1 + (step_angle * i)) * r + pc[0], cos(a1 + (step_angle * i)) * r + pc[1]]],[pt2])
) pts;

//  Initialise the pathbuilder with the s command. It initialises the global point list $pb__pts with [[x,y]]
module s(x, y, $fn=$fn){
    $pb__pts = [[x,y]];
    $pb__spec = [[0,0,0]];  //  start tag
    children();
}

//  Adds a point at distance d relative from the last point in the last direction.
//  This command assumes the direction angle is zero when less then two points are defined
module d(d){
    l = last($pb__pts);
    a = $pb__pts[1]!= undef? calcExitAngle($pb__pts) : 0;
    n = [l[0] + sin(a) * d, l[1] + cos(a) * d];
    $pb__pts = concat($pb__pts, [n]);
    children();
}

//  Adds a point x,y relative from the last point
module l(x, y){
    l = last($pb__pts);
    n = [l[0] + x, l[1] + y];
    $pb__pts = concat($pb__pts, [n]);
    children();    
}

//  Adds a point with the given absolute coordinates x,y
module L(x, y){
    l = last($pb__pts);
    n = [x, y];
    $pb__pts = concat($pb__pts, [n]);
    children();    
}

//  Adds a point relative from the last point along the horizontal x axis
module h(x){
    l = last($pb__pts);
    n = [l[0] + x, l[1]];
    $pb__pts = concat($pb__pts, [n]);
    children();     
}

//  Adds a point along the horizontal x axis at an absolute x coordinate.
module H(x){
    l = last($pb__pts);
    n = [x, l[1]];
    $pb__pts = concat($pb__pts, [n]);
    children();     
}

//  Adds a point vertically y along from the last point
module v(y){
    l = last($pb__pts);
    n = [l[0], l[1] + y];
    $pb__pts = concat($pb__pts, [n]);
    children();     
}

//  Adds a point vertically from the last point to absolute coordinate y
module V(y){
    l = last($pb__pts);
    n = [l[0], y];
    $pb__pts = concat($pb__pts, [n]);
    children();     
}

//  Adds multiple points to form a circle segment from the last point to relative point x,y with given radius
//  An error is shown if the radius is less than half the distance between the two points.
//  You can flip the circle segment inside out by changing the radius to negative
module r(x, y, r,  $fn=$fn){
    l = last($pb__pts);
    n = [l[0] + x, l[1] + y];
    $pb__pts = r==0? concat($pb__pts, [n]) : concat($pb__pts,curveBetweenPoints(l, n, r, false, $fn));
    children(); 
}

//  Adds multiple points to form a circle segment from the last point to absolute point x,y with given radius
//  An error is shown if the radius is less than half the distance between the two points.
//  You can flip the circle segment inside out by changing the radius to negative
module R(x, y, r){
    l = last($pb__pts);
    n = [x, y];
    $pb__pts = r==0? concat($pb__pts, [n]) : concat($pb__pts,curveBetweenPoints(l, n, r, false, $fn));
    children(); 
}

//  Inserts a fillet at the current point with the given radius. set Flip=true to turn the fillet outwards
module f(r, flip=false, $fn=$fn){
    $pb__spec = concat($pb__spec, r==0? [] : [[2,len($pb__pts)-1,r,flip, $fn]]);  //  fillet tag
    children();  
}

//  Inserts a chamfer with size s on this point
module c(s){
    $pb__spec = concat($pb__spec, [[3,len($pb__pts)-1,s, false]]);  //  fillet tag
    children(); 
}

//  Draws the final shape of $tutle_pts as a polygon
module draw(){
    $pb__spec = concat($pb__spec, [[1,len($pb__pts)-1,0]]);  //end tag
    $pb__pts = [for (i = [0: len($pb__spec)-2]) let(
        s1   = subList($pb__pts, $pb__spec[i][1], $pb__spec[i+1][1] - ($pb__spec[i+1][0]==2? 1 : 0)),
        fill = $pb__spec[i][0]==2? fillet($pb__pts, $pb__spec[i][1], $pb__spec[i][2],$pb__spec[i][3],$pb__spec[i][4]) : [],
        cham = $pb__spec[i][0]==3? chamfer($pb__pts, $pb__spec[i][1], $pb__spec[i][2]) : []      
    ) for (p=concat(fill, cham, s1)) p];
    echo($pb__pts);
    polygon($pb__pts);
}
