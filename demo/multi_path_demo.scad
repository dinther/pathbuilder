include <pathbuilder.scad>

//  This path command string will draw a magnifying glass.
//  It is made of two paths.
//  The first path outlines the entire magnifying glass Clockwize (CW)
//  The second path outlines the inner hole Counter Clockwize (CCW)

//  It does not matter if you start the first path Clockwize or Counter clockwize
//  But ever path after the first will be subtracted when it has an opposite winding
//  and added if it has the same winding.

svgShape("m20 0 40 40 -5 5 5 5a50 50 0 1 1 -10 10l-5-5-5 5-40-40m60 50a35 35 0 1 0 10 -10");



//  This path draws a square with patches cut out of it.
//  It is made of 5 paths.
//  The first path is a 200 x 200 square and the rest 5 x 5 squares.
//  Path 1 is Counter Clockwize (CCW)
//  Path 2 on the left edge, is Clockwize (CW) different from Path 1 and thus subtracted.
//  Path 3 on the right edge, is Clockwize (CW) different from Path 1 and thus subtracted.
//  Path 4 in top left quadrant, is is Clockwize (CW) different from Path 1 and thus subtracted.
//  Path 5 in the center is Counter Clockwize (CCW) the same as Path 1 and thus added.

//  However, subtraction and addition in SVG works different from the normal openSCAD
//  difference() and union commands. Implementation is complex and goes beyond the scope of Pathbuilder.
//
//  It does not matter if you start Clockwize or Counter clockwize with the firstpath.
//  However, subsequent paths are added when the winding matches the winding of the first path,
//  and subtracted when the winding does not patch the winding of the first path.
//  The order in which the paths appear after the first one matters when their windings differ.
//  Addition or subtration of a path is applied to all the paths before it.

//  You can also create multiple polygon shapes and apply the usual openSCAD operations.

translate([-250,0,0])
svgShape("m0 0h200v200h-200zM-25 75v50h50v-50zM175 75v50h50v-50zM100 100v50h50v-50zM75 75h50v50h-50");




















