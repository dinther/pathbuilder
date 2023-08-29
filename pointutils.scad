//  pointutils.scad
//
//  This utility libray is designed to help with the generation of complex 3D point lists
//  Amazing results can be achieved when used in combination with Pathbuilder and MeshBuilder
//
//  Latest version here: https://github.com/dinther/pathbuilder
//
//  By: Paul van Dinther


 
//  function circlePoints(r=undef, d=undef, z=undef)
//
//  Generates a list of 2D points describing the requested circle. The number of points will depend
//  on the usual openSCAD $fa, $fs, $fn settings.
//  will be a 3D point.
//  The return value is a 3D points list
//  r        (number) Radius of the circle.
//  d        (number) Diameter of the circle.
//  z        (number) Z coordinate optional. Causes a 3D point list to be returned.
//  return   (list)   List of 2D or 3D points forming a circle.

function circlePoints(r=undef, d=undef, z=undef) = let(
    _r = r!=undef? r : d!=undef? d*0.5 : 1,
    _c = _pu_segmentsPerCircle(_r),
    _s = 360 / _c
) [for(i=[0:_c-1]) z==undef? [cos(i*_s) * _r, sin(i*_s) * _r,] : [cos(i*_s) * _r, sin(i*_s) * _r, z]];

    
//  function keep(dataList=[], indexes = [])
//
//  Takes any list of data and only returns the fields given by the indexes. This function is also perfect when you want to reorder data.
//  Turn 3D points lists into 2D point lists etc. A warning will be given when an index exceeds the number of data items.
//  
//  dataList (list)   List of any kind of data of any length. For example mixed 2D and 3D points.
//  indexes  (list)   List of indexes for the required fields.
//  return   (point)  Resulting organized list
//
//  Example  keep(dataList=[[0,0,3],[2,10,0],[12,10]], indexes=[1,0]); // Produces list with only y,x coodinates [[0, 0], [10, 2], [10, 12]]

function keep(dataList=[], indexes = [], _i=0, _data=[]) = let(
    a = assert(max(indexes) < len(dataList[_i]), str("Index ",max(indexes)," in indexes list is too large for given data ",dataList[_i])),
    d = [for(i=indexes) dataList[_i][i]],
    _data = concat(_data, [d])) _i<len(dataList)-1? keep(dataList, indexes, _i+1, _data) : _data;


//  function rotatePoint(pt, angle)
//
//  Rotates a 2D point around the z axis relative to the origin. Input can either be a 2D or 3D point.
//  will be a 3D point.
//  The return value is a 3D points list
//  pt       (point)  Array with X and Y value.
//  angle    (number) Angle around which the 2D point is rotated. Angle is in degrees.
//  return   (point)  Resulting rotated point.

function rotatePoint(pt, angle) = angle==0? [pt[0], pt[1]] : pt[2]==undef? [cos(angle) * pt[0] - sin(angle) * pt[1], sin(angle) * pt[0] + cos(angle) * pt[1]] : [cos(angle) * pt[0] - sin(angle) * pt[1], sin(angle) * pt[0] + cos(angle) * pt[1], pt[2]];


//  function rotatePoints(pts=[], angles=[0,0,0], z_offset=0)
//
//  Rotates a list of points around along   ONE, TWO OR three axis [x, y,z]. Although the input can be a 2D point, the output
//  will be a 3D point except when the input is a 2D point and rotation is only along the Z axis
//  The return value is a 3D points list
//  pts      (list)   List of zero or more 2D or 3D points.
//  angles   (list)   angles along X, Y and Z axis in that order. Angles in degrees.
//  z_offset (number) moves the final z value by Z-offset.
//  return   (list)   Rotated list of 3D points.

function rotatePoints(pts=[], angles=[0,0,0], z_offset=0, _i=0, _pts=[]) = let(
    z1 = pts[_i][2]==undef? z_offset :  pts[_i][2] + z_offset,
    ax = angles[0] == undef? 0 : angles[0],
    ay = angles[1] == undef? 0 : angles[1],
    az = angles[2] == undef? 0 : angles[2],
    npx = rotatePoint([pts[_i][1],0], ax),
    npx1 = [pts[_i][0],npx[0],npx[1]],
    npy = rotatePoint([npx1[0], npx1[2], npx1[1]], ay),
    npy1 = [npy[0], npx1[1],npy[1]],
    npz = rotatePoint([npy1[0], npy1[1], npy1[2]], az),
    npz1 = pts[_i][2]==undef && ax==0 && ay==0? [npz[0], npz[1]] : [npz[0], npz[1],npy1[2]+z1],
    _pts = concat(_pts, [npz1])
    ) _i<len(pts)-1? rotatePoints(pts, angles, z_offset, _i+1, _pts) : _pts;
    

//  translatePoints(pts, scale)
//
//  Translates points in point list. You can use 2D points on 3D translation vectors and vice versa.
//  pts       (list)  List of 2D or 3D points.
//  translate (list)  List of two or three numbers representing the vector to translate the points with
//  return    (list)  List of scales points.

function translatePoints(pts=[], translate=[0,0]) = [for(p=pts)[ for(j=[0:len(p)-1]) translate[j]!=undef? p[j]+translate[j] : p[j]]];

//  scalePoints(pts, scale)
//
//  Scales points in point list. You can use 2D points on 3D scale vectors and vice versa.
//  pts       (list)  List of 2D or 3D points.
//  scale     (list)  List of two or three numbers representing the vector to scale the points with
//  return    (list)  List of scales points.

function scalePoints(pts=[], scale=[0,0]) = [for(p=pts)[ for(j=[0:len(p)-1]) scale[j]!=undef? p[j]*scale[j] : p[j]]];
 

//  openSCAD polyline offset routine retrieved from newgroup https://forum.openscad.org/Polygon-Offset-Function-td17186.html
//
//  Offsets a list of points around along three axis (x, y,z). Although the input can be a 2D point, the output
//  will be a 3D point.
//  The return value is a 3D points list
//  pts      (list)   List of zero or more 2D or 3D points.
//  angles   (list)   angles along X, Y and Z axis in that order. Angles in degrees.
//  z_offset (number) moves the final z value by Z-offset.
//  return   (list)   Rotated list of 3D points.
function offsetPoints(pts, dist) = 
  _os_offset_poly(_os_iterative_remove_edges(pts, dist), dist);
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
//  *********************************************************************************************************************************  
//  Helper functions


//  function  _pu_segmentsPerCircle(r)
//
//  Calculates the number of segments used per circle (per 360 deg) based on circle radius and openSCAD $fn, $fa and $fs settings.
//  r       (number)  The circle radius for which the number of segments needs to be calculated.
//  return  (number)  The number of segments that would be used by openSCAD if it would draw the circle.
function _pu_segmentsPerCircle(r=1) = $fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,abs(r)*2*PI/$fs),5));

// given two points, a, b, find equation for line that is parallel to line 
// segment but offset to the right by offset dist
// equation is of the form c*x+d*y=e
// represented as array [ c, d, e ]
function _os_seg2eq(pa, pb, dist) = 
  let (ab = [pb[0]-pa[0], pb[1]-pa[1]])
  let (abl_un = [-ab[1], ab[0]])
  let (abl_len = sqrt(abl_un[0]*abl_un[0] + abl_un[1]*abl_un[1]))
  let (abl = [ abl_un[0]/abl_len, abl_un[1]/abl_len ])
  [ abl[0], abl[1], abl[0]*pa[0] + abl[1]*pa[1] - dist ];

// given two equations for lines, solve two equations to find intersection
function _os_solve2eq(eq1, eq2) = 
  let (a=eq1[0], b=eq1[1], c = eq1[2], d=eq2[0], e=eq2[1], f=eq2[2])
  let (det=a*e-b*d)
  [ (e*c-b*f)/det, (-d*c+a*f)/det ];

// given a corner as two line segments, AB and BC, find the new corner B' that results 
// when both line segments are offet.  Works by generating two equations and then solving
function _os_offset_corner(pa, pb, pc, dist) = 
  _os_solve2eq(_os_seg2eq(pa, pb, dist), _os_seg2eq(pb, pc, dist));

// given a polygon, offset each vertex using the corner offset method above
// note: this can produce self-intersections depending on the 'curvature' and offset
function _os_offset_poly(p, dist) = [ 
  for (i=[0:len(p)-1]) 
    i == 0 ? _os_offset_corner(p[len(p)-1], p[i], p[i+1], dist) :
    i == len(p)-1 ? _os_offset_corner(p[i-1], p[i], p[0], dist) :
    _os_offset_corner(p[i-1], p[i], p[i+1], dist)
  ];

// each segment of a polygon will 'vanish' at some offset value (unless adjacent 
// segments are parallel).  Compute the offset at which each segment vanishes 
// (produces 'nan' or plus or minus infinity when adjacent segments parallel)
function _os_offset_limit(p) = 
  let (N = len(p))
  let (offp = _os_offset_poly(p, 1))  // each vertex adjusted for unit of offset
  [ for (i=[0:N-1])  // for each segment
    // equations for segment for each vertex (angle bisector)
    let (eqv1 = _os_seg2eq(p[i], offp[i], 0),  eqv2 = _os_seg2eq(p[(i+1)%N], offp[(i+1)%N], 0))
    let (singv = _os_solve2eq(eqv1, eqv2))  // 'singular' vertex where edge vanishes
    let (offv = offp[i]-p[i])  // vertex shifts this much per unit of offset
    let (targetv = singv - p[i])  // what offset produces this coordinate?
    // essentially quotient of lengths, but need to take into account negative offsets
    // use dot product to find cosine of angle, should be 1 or -1
    let (sgn = (offv[0]*targetv[0] + offv[1]*targetv[1])/(norm(offv)*norm(targetv)))
    sgn * norm(targetv)/norm(offv)
  ]
;
  
// transform polygon into sequence of edges as equations, skipping flipped edges
// and then transform back into vertices by solving adjacent equations
function _os_remove_edges(p, dist) = 
  let (N = len(p), offlim = _os_offset_limit(p))
  let (eqlist = [ for (i=[0:N-1])
    if (!(dist/offlim[i] > 1))
      _os_seg2eq(p[i], p[(i+1)%N], 0)
    ])
  let (N2 = len(eqlist))
  [ for (i=[0:N2-1])
    _os_solve2eq(eqlist[(i+N2-1)%N2], eqlist[i]) ];

function _os_iterative_remove_edges(p, dist) =
  let (cleaned = _os_remove_edges(p, dist))
  len(cleaned) == len(p) ? p : _os_iterative_remove_edges(cleaned, dist);

// given a polygon, offset each vertex using the corner offset method above
// note: this can produce self-intersections depending on the 'curvature' and offset
function offset_poly(pts, dist) = 
  _offset_poly(_iterative_remove_edges(pts, dist), dist);
