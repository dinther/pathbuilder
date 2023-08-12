//  meshbuilder
//
//  This libray is designed to be used in conjuction with pathbuilder to create complex 3D shapes.
//  With pathbuilder (https://github.com/dinther/pathbuilder) it is easy to morph from one complex 2D shape
//  to another similar 2D shape. (See svgTweenPath command in pathbuilder for the limitations)
//
//  A mesh can be stiched by stacking multiple 2D shapes on top of each other.
//  kinda the reverse of how a slicer turns a 3D object in many outlines.
//  
//  The number of points on each stacked 2D shape need to match.
//
//  pointLayers is a list containing path lists with 3D points.
//  The module demo shows a simple rectangle that changes shape as it is moved up.
//  This shape can not be achieved with the twist parameter in linear_extrude.
//
//  Latest version here: https://github.com/dinther/pathbuilder
//
//  By: Paul van Dinther


//  TODO: aligning the start of the paths
//  TODO: learn about smarts to make better stiching decisions
//

//  buildMeshFromPointLayers(pointLayers, sides, bottom, top, closed, faces)
//
//  Generates a mesh based on a list of a list of points for each layer
//  pointLayers (list)   List of 3D points
//  sides       (bool)   Generate the sides of the mesh
//  bottom      (bool)   Generate the bottom of the mesh
//  top         (bool)   Generate the top of the mesh
//  closed      (bool)   Set to true if the side of the mesh should be closed
//  faces       (list)   User provided list of faces
//  return  (number) Angle between the two vectors in degrees.
module buildMeshFromPointLayers(pointLayers = [], sides = true, bottom=true, top=true, closed=true, faces=[]){
    n = len(pointLayers[0]);
    pts = [for (deck=[0:1:len(pointLayers)-1]) each pointLayers[deck]];
	side_faces = [for (d = [0:1:len(pointLayers)-2], p = [0:1:len(pointLayers[d])-(closed? 1 : 2)])	let(c = (n * d)+ p, last=p+1==len(pointLayers[d]) ) [c,last? d*n: c+1, last? c+1 : c+n+1, c+n]];
    bottom_faces = bottom? [[for(i=[n-1:-1:0]) i]] : [];
    top_faces = top? [[for(i=[len(pts) - n:len(pts)-1]) i]] : [];
	polyhedron(points = pts, faces = concat(side_faces, bottom_faces, top_faces, faces), convexity = 10);
}

function rotateAroundZ(x, y, z, angle) = let (
    c = cos(angle),
    s = sin(angle),
    nx = (c * x) + (s * y),
    ny = (c * y) - (s * x)) [nx, ny, z];


module demo(){
    steps = 40;
    l1 = 20;
    l2 = 5;
    ls = (l2-l1)/steps;
    w1 = 8;
    w2 = 0;
    ws = (w2-w1)/steps;
    h = 50;
    hs = h / steps;
    wh = w1 * 0.5;
    
    a = 90;
    as = a/steps;
    points = [[0,wh],[l1, wh],[l1,-wh],[0,-wh]];
    pl = [for (i=[0:steps])
        [rotateAroundZ(points[0][0], points[0][1], i*hs, i*as),
        rotateAroundZ(points[1][0]+i*ls, points[1][1]+ i*ws*0.5, i*hs, i*as),
        rotateAroundZ(points[2][0]+i*ls, points[2][1]- i*ws*0.5, i*hs, i*as),
        rotateAroundZ(points[3][0], points[3][1], i*hs, i*as)]
    ];
    
    buildMeshFromPointLayers(pl, true, true,true);
}

demo();
