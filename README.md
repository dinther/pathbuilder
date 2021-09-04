# pathbuilder
Path builder library for use in openSCAD. It is designed to create 2D shapes that can them be extruded. Often relativly simple shapes are pretty hard to create in openSCAD while similar shapes are so easy in sgv for example.
This library brings some the SVG path syntax to openSCAD and a few extras such as fillet and chamfer. The command sequence is similar to how the old logo turtle worked. You just push it along step by step.

The commands are all single character to keep things short and chain together just like the familiar translate rotate and scale commands in openSCAD. Lower-case characters work with relative coordinates and upper-case commands work with absolute coordinates just like in SVG.
for now I have choosen to have the x and y values as separate values to keep things consistent because a lot of the commands only act on either x or y.

## install
copy pathbuilder.scad to your openSCAD library folder
put 
```
use <curves.scad>
```
at the top of your code unit and you are ready to go.

## example
The code below produces a left arrow using chamfers, curves and fillets.
```
linear_extrude(3) s(0,0, 32) f(2) h(20) c(8) v(10) r(10, 10, 10) h(10) f(2) v(-10) f(2) l(35,20) f(2) L(40,50) f(2) v(-10) h(-10) R(0,10,-30) draw();
```

Commands currently implemented:

```
s - start
initialises the pathbuilder at your first [x,y] point
s(10,0,$fn)
```
```
d - distance
Adds a point at distance d relative from the last point in the last direction.
This command assumes the direction angle is zero when less then two points are defined
d(100)
'''

