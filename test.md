just to try stuff


```openscad
//  function pb_angle(p1,p2)
//
//  Calculates the angle of the last line segment in the points list pts.
//  Returns 0 when the point list only has one value in it.
//  pts     (list)   List of 2D points.
//  angle   (number) Last known angle. Returned in case pts is empty
//  return  (number) Angle of the last line segment in the list.
function pb_calcExitAngle(pts=[],angle) = let(
    l = is_list(pts)? len(pts) : -1,
    p1=l>1? pts[l-2] : [0,0],
    p2=l>0? pts[l-1] : undef) p2==undef || p1==p2? angle==undef? 0 : angle : pb_angle(p1, p2);
```
