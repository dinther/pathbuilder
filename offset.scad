//  openSCAD polyline offset routine retrieved from newgroup
//  https://forum.openscad.org/Polygon-Offset-Function-td17186.html

// given a polygon, offset each vertex using the corner offset method above
// note: this can produce self-intersections depending on the 'curvature' and offset
function offset_pts(pts, dist) = 
  _offset_poly(_iterative_remove_edges(pts, dist), dist);
  
  
module test(){
  pts1 =  [[35, -8], [35, 7], [20, 12], [-10, 60], [-25, 65], [-40, 60], [-30, 50], [-21, 18], [-21, -18], [-30, -50], [-40, -60], [-25, -65], [-10, -60], [20, -13]];
  pts2 = offset_pts(pts1, -0.5);
  difference(){
      translate([0,0,1]) color("red") polygon(pts1);
      polygon(pts2);
  }
  polygon(pts2);
}

test();
  
  
 
//  Helper functions

// given two points, a, b, find equation for line that is parallel to line 
// segment but offset to the right by offset dist
// equation is of the form c*x+d*y=e
// represented as array [ c, d, e ]
function _seg2eq(pa, pb, dist) = 
  let (ab = [pb[0]-pa[0], pb[1]-pa[1]])
  let (abl_un = [-ab[1], ab[0]])
  let (abl_len = sqrt(abl_un[0]*abl_un[0] + abl_un[1]*abl_un[1]))
  let (abl = [ abl_un[0]/abl_len, abl_un[1]/abl_len ])
  [ abl[0], abl[1], abl[0]*pa[0] + abl[1]*pa[1] - dist ];

// given two equations for lines, solve two equations to find intersection
function _solve2eq(eq1, eq2) = 
  let (a=eq1[0], b=eq1[1], c = eq1[2], d=eq2[0], e=eq2[1], f=eq2[2])
  let (det=a*e-b*d)
  [ (e*c-b*f)/det, (-d*c+a*f)/det ];

// given a corner as two line segments, AB and BC, find the new corner B' that results 
// when both line segments are offet.  Works by generating two equations and then solving
function _offset_corner(pa, pb, pc, dist) = 
  _solve2eq(_seg2eq(pa, pb, dist), _seg2eq(pb, pc, dist));

//echo(_ensurePathNotClosed([[1,2],[2,3],[3,4],[1,2]]));

// given a polygon, offset each vertex using the corner offset method above
// note: this can produce self-intersections depending on the 'curvature' and offset
function _offset_poly(p, dist) = 
  [ 
  for (i=[0:len(p)-1]) 
    i == 0 ? _offset_corner(p[len(p)-1], p[i], p[i+1], dist) :
    i == len(p)-1 ? _offset_corner(p[i-1], p[i], p[0], dist) :
    _offset_corner(p[i-1], p[i], p[i+1], dist)
  ];

// each segment of a polygon will 'vanish' at some offset value (unless adjacent 
// segments are parallel).  Compute the offset at which each segment vanishes 
// (produces 'nan' or plus or minus infinity when adjacent segments parallel)
function _offset_limit(p) = 
  let (N = len(p))
  let (offp = _offset_poly(p, 1))  // each vertex adjusted for unit of offset
  [ for (i=[0:N-1])  // for each segment
    // equations for segment for each vertex (angle bisector)
    let (eqv1 = _seg2eq(p[i], offp[i], 0),  eqv2 = _seg2eq(p[(i+1)%N], offp[(i+1)%N], 0))
    let (singv = _solve2eq(eqv1, eqv2))  // 'singular' vertex where edge vanishes
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
function _remove_edges(p, dist) = 
  let (N = len(p), offlim = _offset_limit(p))
  let (eqlist = [ for (i=[0:N-1])
    if (!(dist/offlim[i] > 1))
      _seg2eq(p[i], p[(i+1)%N], 0)
    ])
  let (N2 = len(eqlist))
  [ for (i=[0:N2-1])
    _solve2eq(eqlist[(i+N2-1)%N2], eqlist[i]) ];

function _iterative_remove_edges(p, dist) =
  let (cleaned = _remove_edges(p, dist))
  len(cleaned) == len(p) ? p : _iterative_remove_edges(cleaned, dist);

// given a polygon, offset each vertex using the corner offset method above
// note: this can produce self-intersections depending on the 'curvature' and offset
function offset_poly(pts, dist) = 
  _offset_poly(_iterative_remove_edges(pts, dist), dist);


  
  
  
