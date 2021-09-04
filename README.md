# pathbuilder
Path builder library for use in openSCAD. It is designed to create 2D shapes that can them be extruded. Often relativly simple shapes are pretty hard to create in openSCAD while similar shapes are so easy in sgv for example.
This library brings some the SVG path syntax to openSCAD and a few extras such as fillet and chamfer. The command sequence is similar to how the old logo turtle worked. You just push it along step by step.

The commands are all single character to keep things short and chain together just like the familiar translate rotate and scale commands in openSCAD. Lower-case characters work with relative coordinates and upper-case commands work with absolute coordinates just like in SVG.
for now I have choosen to have the x and y values as separate values to keep things consistent because a lot of the commands only act on either x or y.

## install
copy pathbuilder.scad to your openSCAD library folder
put 
```
use <pathbuilder.scad>
```
at the top of your code unit and you are ready to go.

## example
![Image of Yaktocat](https://github.com/dinther/pathbuilder/blob/main/images/pathbuilder_right%20arrow.png)
The code below produces this left arrow using chamfers, curves and fillets.
```
linear_extrude(3) s(0,0, 32) f(2) h(20) c(8) v(10) r(10, 10, 10) h(10) f(2) v(-10) f(2) l(35,20) f(2) L(40,50) f(2) v(-10) h(-10) R(0,10,-30) draw();
```
## rip and pillage
If a path builder like this isn't quite your thing but you do want a routine to calculate a chamfer or fillet for your own project. Go and rip it out.
Useful routines:

```
function curveBetweenPoints(pt1, pt2, radius, incl_start_pt = true, $fn=$fn)
```
Returns a list of points representing the shortest curve between two points with a given radius. There are always two solutions. Make the radius negative to get the other one.
Set incl_start_pt to false if you don't want the start point in the output list. This avoids doubling up on point coordinates when you build a sequence of curves. This routine will try to stay close to your $fn and $fa settings but it always divides the arc in equal parts.
```
function fillet(pts, index, radius, $fn=$fn)
```
Returns a list of points representing an arc with a given radius that is the tangent to pt1 and pt2 also known as a fillet.
Set the radius to negative if you want the arc to bulge outward.
```
function chamfer(pts, index, size)
```
Returns a list of two points for a balanced symetrical chamfer of size for the given point in point list pts defined by index.

## Commands
Commands currently implemented are:
```
s(x,y,$fn) - start
initialises the pathbuilder at your first [x,y] point
s(10,0,$fn)
```
```
d(d) - distance
Adds a point at distance d relative from the last point in the last direction.
This command assumes the direction angle is zero when less then two points are defined
d(100)
```
```
l(x,y) - line
Adds a point x,y relative from the last point
l(13,7)
```
```
l(x,y) - line
Adds a point with the given absolute coordinates x,y
l(13,7)
```
```
h(x) - horizontal
Adds a point relative from the last point along the horizontal x axis
h(5)
```
```
H(x) - Horizontal
Adds a point along the horizontal x axis at an absolute x coordinate.
H(8)
```
```
v(y) - vertical
Adds a point relative from the last point along the vertical y axis
v(6)
```
```
V(y) - Vertical
Adds a point along the vertical x axis at an absolute y coordinate.
V(28)
```
```
r(x,y,r) - round
Adds multiple points to form a circle segment from the last point to relative point x,y with given radius
An error is shown if the radius is less than half the distance between the two points.
You can flip the circle segment inside out by changing the radius to negative
r(x,y,r)
```
```
R(x,y,r) - Round
Adds multiple points to form a circle segment from the last point to absolute point x,y with given radius
An error is shown if the radius is less than half the distance between the two points.
You can flip the circle segment inside out by changing the radius to negative
R(x,y,r)
```
```
f(r, flip=false, $fn=$fn) - fillet
Creates a fillet at the current point with the given radius. set Flip=true to turn the fillet outwards.
The actual fillet is generated during the final draw command as both the incoming and outgoing line vector needs to be defined.
You can override the $fn value at this point.
V(28)
```
```
c(s) - chamfer
Inserts a balanced symetrical chamfer with size s on this point.
V(28)
```
```
draw() - draw
The final draw command executes the post processing step for the fillets and chamfers, builds the final point list
and generates a shape using the polygon command.
```
