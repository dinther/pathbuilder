//  meshbuilder
//
//  This libray is designed to be used in conjuction with pathbuilder to create complex 3D shapes.
//  With pathbuilder (https://github.com/dinther/pathbuilder) it is easy to morph from one complex 2D shape
//  to another similar 2D shape. (See svgTweenPath command in pathbuilder for the limitations)
//
//  A mesh can be stiched by stacking multiple 2D shapes on top of each other.
//  kinda the reverse of how a slicer turns a 3D object in many outlines.
//  
//  The number of points on each stacked 2D shape don't need to match. buildMeshFromPointLayers will automatically
//  attempt to keep the face edge as close to vertical as possible which results in the optimum 3D mesh.
//
//  pointLayers is a list containing lists with 3D points. It is recommended to keep z for each point in a 2D shape the same
//  but it is not absolutely required. You do run a bigger risk of self intersecting triangles.
//
//  examples
//
//  in code:
//  linear_extrude(1) m(0,0) chamfer(10) h(20) fillet(2) v(10) segment(10, 10, 10) h(10) fillet(2) v(-10) fillet(2) l(35,20) fillet(2) L(40, 50) fillet(2) v(-10) h(-10) Segment(0,10,-30) draw();
//
//  or SVG path syntax:
//
//
//  The above statement creates a 2D right angle arrow that is then extruded
//  Lowercase commands are drawn relative to the last drawn point.
//  Uppercase commands are drawn as absolute coordinates.
//
//  Latest version here: https://github.com/dinther/pathbuilder
//
//  By: Paul van Dinther


//  TODO: aligning the start of the paths
//  TODO: learn about smarts to make better stiching decisions

module buildMeshFromPointLayers(pointLayers = [], sides = true, bottom=true, top=true){
    n = len(pointLayers[0]);
    pts = [for (deck=[0:1:len(pointLayers)-1]) each pointLayers[deck]];
	faces = [for (d = [0:1:len(pointLayers)-2], p = [0:1:len(pointLayers[d])-2])	let(c = (n * d)+ p) [c,c+1, c+n+1,c+n]];
    bottom_points = bottom? pointLayers[len(pointLayers)-1] : [];
    bottom_faces = bottom? [for(i=[len(bottom_points)-1:-1:0]) i] : [];
    top_points = top? pointLayers[0] : [];
    top_faces = top? [for(i=[len(pts) - len(top_points):len(pts)-1]) i] : [];
    with_top_faces = top? concat(sides? faces: [], [top_faces]) : sides? faces: [];
    all_faces = bottom? concat(with_top_faces, [bottom_faces]) : with_top_faces;
	polyhedron(points = pts, faces = all_faces, convexity = 10);
}

