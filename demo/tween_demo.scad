include <pathbuilder.scad>

//  This demo takes two svg paths and morphs the path parameters to create a 3D mesh

$pb_spline = 20;

function scaleXYPoints(pts, pos_scale=[1,1,1], neg_scale=[1,1,1]) = [for(pt=pts) [pt[0]<0? pt[0]*neg_scale[0]: pt[0]*pos_scale[0],pt[1]<0? pt[1]*neg_scale[1]: pt[1]*pos_scale[1],pt[2]<0? pt[2]*neg_scale[2]: pt[2] * pos_scale[2]]];

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

//  Note that the path must be closed with Z. This is not strictly nessesary when used with polygons because
//  polygons are always closed

p1 = "M -1170 0 V -185 C -980 -336 -738 -305 -507 -305 H 300 C 668 -305 882 -124 1034 -66  C 1179 -8   1260 -13 1260 0Z";
p2 = "M -1200 0 V -250 C -922 -353 -738 -345 -507 -345 H 400 C 548 -345 815 -287 1034 -215 C 1241 -143 1400 -57 1400 0Z";

point_layers = [for (i=[0:0.05:1]) scaleXYPoints(svgPoints(svgTweenPath(p1, p2, i),(1-cos(i*90))*150)[0],[1-sin(i*140)*0.1,1,1],[1,1,1])];
buildMeshFromPointLayers(point_layers, sides=true, bottom=true, top=true);
mirror([0,1,0]) buildMeshFromPointLayers(point_layers, sides=true, bottom=true, top=true);
