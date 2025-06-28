# Introduction
![Image of right_arrow](images/pathbuilder_welcome.png)

Pathbuilder is a tool for openSCAD that make the creation of complex 2D shapes easier with a syntax similar to the one used for svg path. Pathbuilder supports [the complete svg command set](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d#path_commands) and several extra commands to make the creation of 2d shapes as easy as possible.

You can place fillets or Chamfers at any point. Extend lines up to an arbitrary boundary and much more.

# Installation
Although this library has grown to three code units, Pathbuilder is contained in a single .scad file and in has no dependencies on other libraries. Just copy pathbuilder.scad to your openSCAD library folder and put 
```
use <pathbuilder.scad>
```
at the top of your code unit and you are ready to go. Copy this code into a new blank openSCAD file to make sure it all works. Dont forget to check out the [demo folder](https://github.com/dinther/pathbuilder/tree/main/demo) it contains 6 examples on how Pathbuilder can be used.

### Quick test
```
include <pathbuilder.scad>

svgShape("m 0 0chamfer8h20fillet2v20fillet10h20v-10fillet2l35 20fillet2l-35 20fillet2v-10h-40fillet30", $fn=32);
```
Note that you can always add $fn or other global openSCAD parameters exclusivly into any function or module. 
You should see this.

![image](https://github.com/user-attachments/assets/f95b67f1-01f8-4429-8c9a-97c9d5168f60)

# flexible

There are two ways to use pathbuilder. You can use a normal svg path string in Pathbuilder. This means that you can also draw your shapes in vector drawing programs such as inkscape and copy the path string into Pathbuilder.

However the power of openSCAD is of course in its parametric capabilities. Although you could string together a svg path string with some variables, it isn't exactly elegant.

Pathbuilder also offers access to every command directly in your code. Commands are simply chained just like you are used to with openSCAD. A polygon is drawn at the end of the command sequence. This way you can pass your parameters directly into pathbuilder commands.

![image](https://user-images.githubusercontent.com/1192916/194191591-ef2b22b1-cdb1-4212-a432-21c76471f459.png)
In the above example I used pathbuilder to generate complex ship hull shapes. Here I made extensive use of the svgPoints() function which returns a list of coordinates rather than letting pathbuilder produce the polygon. The points are then processed to produce the polyhedron in the picture. The mesh is perfect and my 3D printer slicer didn't report any issues.

## S bracket example

![image](https://user-images.githubusercontent.com/1192916/153122019-61eb8e5a-9a15-42e6-a4ba-5fbb8efa8b66.png)

### code

```
use <pathbuilder.scad>

//  S bracket

width = 40;
length = 60;
height = 30;
thickness = 5;
inner_radius = 3;

$fn = 64;
linear_extrude(width){
    m(0,0)
    v(thickness)
    h((length - thickness)/2)
    fillet(inner_radius)
    V(height)
    fillet(inner_radius + thickness)
    H(length)
    v(-thickness)
    h(-(length - thickness)/2)
    fillet(inner_radius)
    V(0)
    fillet(inner_radius + thickness)
    H(0);
}
```
Each method has its own benefits and drawbacks. The SVG path string method can create a polygon or return a point list which you can manipulate as desired. But modules also allow a much finer control over the curve segmentation as you can slip in a $fa, $fs or $fn parameter with every command module.

# Rip and pillage
If Pathbuilder isn't quite your thing you might still was to have a look at some of the functions. Pathbuilder has no dependencies and the functions have been written as self contained as possible and sensible. Even easier is to jump over to my other repository of stand-alone ready to use openSCAD functions called [openSCAD_functions](https://github.com/dinther/openSCAD_functions)

Here are just a few examples:

```
function curveBetweenPoints(pt1, pt2, radius, incl_start_pt = true)
```
Returns a list of points representing the shortest curve between two points with a given radius.

```
function fillet(pts, index, radius)
```
Returns a list of points representing an arc with a given radius that is the tangent to pt1 and pt2 also known as a fillet.
```
function chamfer(pts, index, size)
```
Returns two points for a nice balanced symetrical chamfer of size for a given point in the point list.

# Command overview
Here is a quick overview of the commands implemented so far. Check out the detailed [command documentation in the wiki](https://github.com/dinther/pathbuilder/wiki)

Most path commands have an uppercase and a lowercase version in Pathbuilder. This is an important distriction because the case defines if the command works in absolute coordinates `(Uppercase)` or relative `(lowercase)` from the current point. More about this in the wiki. In this overview I ignore the details case has on the commands.

## High level commands
When using the SVG path syntax in string format you will need to call a function to have the commands in the string processed. The main two are at the top of this list. The other three are more useful as debugging tools.

|Command|Code|Description|
|-------|------|-------|
|svgShape|`svgShape(path_string)`|This command takes a svg path string as input and creates a polygon with the defined shape. Segmentation of curves are according $fn, $fa, $fs and $pb_spline.|
|svgPoints|`svgPoints(path_string)`|This command takes a svg path string as input and returns a 2D point list. Here you can do additional processing of your shape data.|
|svgTweenPath|`svgTweenPath(path1, path2, factor)`|This command takes two similar svg path strings as input and returns a in between path string based on the factor value between 0 and 1. This is ideal to create complex morphing between curves which then can be used to create complex 3D meshes in the upcoming meshBuilder. Tweens are only possible when both SVG paths have the same command count and sequence.|
|pb_tokenizeSvgPath|`pb_tokenizeSvgPath(path_string)`|Turns the path string into a list of unambiguous commands and returns this command_list. Useful for debugging.|
|pb_processCommands|`pb_processCommands(command_list)`|Executes the commands in the list and builds up a point list and a post processing list. These two lists are returned in a data list.|
|pb_postProcessPath|`pb_postProcessPath(data)`|Post processing involves applying fillets and chamfers now the main shape is known. A 2D point list is returned.

Checkout [pathbuilderdemo.scad](pathbuilderdemo.scad) demo 3 which shows a third way to interpret process the svg path string. Here three separate steps are taken to go from path string to 2D point list.
```
    pb_swoosh = "M68.56-4L18.4-25.36Q12.16-28 7.92-28q-4.8 0-6.96 3.36-1.36 2.16-.8 5.48t2.96 7.08q2 3.04 6.56 8-1.6-2.56-2.24-5.28-1.2-5.12 2.16-7.52Q11.2-18 14-18q2.24 0 5.04 .72z";
    cmds = pb_tokenizeSvgPath(pb_swoosh);
    data = pb_processCommands(cmds);
    pts_list = pb_postProcessPathLists(data);
    pts = pts_list[0];
    polygon(pts);
```
***
## SVG Commands:
The commands in this table should be fully compliant with the SVG path syntax.

|Command|Code|Description|
|-------|----|-------|
|[M or m](https://github.com/dinther/pathbuilder/wiki/Move-to)|`"m x y"` or `m(x,y)` or<br>`m([x,y,...])`|Move must be the first command and sets a start point.|
|L or l|`"l x y"` or `l(x,y)` or<br>`l([x,y,...])`|Line adds a point to the point path.|
|H or h|`"h x"` or `h(x)` or `h([x,...])`|horizontal line to x.|
|V or v|`"v y"` or `v(y)` or `v([y,...])`|vertical line to y.|
|C or c|`"c cx1 cy1 cx2 cy2 x2 y2"` or<br>`c(cx1,cy1,cx2,cy2,x2,y2)` or<br>`c([cx1,cy1,cx2,cy2,x2,y2,...])`|Draws a cubic spline to x2,y2 where cx1,cy1 controls the entry angle/shape and cx2,cy2 controls the exit angle/shape.|
|S or s|`"s cx cy x y"` or<br>`c(cx,cy,x,y)` or<br>`c([cx,cy,x,y,...])`|Draws a smooth cubic spline continuation to x,y where cx,cy controls the exit angle/shape. The entry control point comes from a prior cubic spline if there was one otherwise the entry angle/shape initially starts like a line to x,y.|
|Q or q|`"q cx, cy, x, y"` or<br>`q(cx,cy,x,y)` or<br>`q([cx,cy,x,y,...])`|Draws a quadratic spline to x,y. Control point cx,cy is shared between the current point and x,y.|
|T or t|`"t x y"` or `t(x,y)` or `t([x,y,...]`|Draws a smooth quadratic spline continuation to x,y using the control point from the previous quadratic spline. This sequence must start with a regular quadratic spline otherwise you get straight lines.|
|A or a<br>(not ready)|`"a rx ry a lf sf x y"` or<br>`a(rx,ry,a,lf,sf,x,y)` or <br>`a([rx,ry,a,lf,sf,x,y,...])`|Drawn an arc of a ellipse segment to x,y with radii rx and ry with the ellipse rotated to angle a. lf and sf flags select from 4 possible solutions. lf short way (0) or long way(1) and sf: cw (0) or ccw (1)|
***
![Image of right_arrow](images/ExtendToBoundary.png)<br>Example of using the forward command with a polyline boundary

## Extra path commands:
These are extra commands introduced by Pathbuilder. The command set is not settled yet. In fact, only fillet and chamfer are likely to remain as they are. angle, polar and forward could be rolled into a single command.
|Command|Code|Description|
|-------|----|-------|
|Angle or angle|`"angle a"` or `angle(a)`|Changes the currentexit angle from the last command.|
|Forward or forward|`"forward d ..."` or<br>`forward(d)` or<br>`forward([x1,y1,x2,y2...]`|Extends a point in the direction of the current exit angle. This point can be at distance d or until a polyline is intersected formed by x,y value pairs.|
|Polar or polar|`"polar d a"` or `polar(d,a)`|Draws a line to a point d distance away and angle a.|
|Segment or segment|`"segment x y r"` or `segment(x,y,r)` or `segment([x1,y1,x2,y2...],r)`|Draws the shortest circle segment between current point and x,y with radius r. Make r negative to change the curve from CW to CCW or vice versa. **depricated**|
|fillet|`"fillet r"` or `fillet(r)`| Replaces the current point with a circle segment of radius r. The curve is placed tangential to the entry and exit lines which must be long enough to accomodate the fillet curve. Flip the curve by making r negative.|
|chamfer|`"chamfer s"` or `chamfer(s)`|Replaces the current point with a symetrical chamfer of size s. The entry and exit lines must be long enough to accomodate the chamfer|

