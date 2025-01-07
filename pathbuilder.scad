//  pathbuilder
//
//  This libray is designed to create complex 2D shapes
//  It uses commands similar to the svg path syntax
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


//  Global values

//  $pb_spline
//  This value controls how many line segments are created for all types of spline curves.
$pb_spline = 10;

//  function svgPoints(s)
//
//  Processes a SVG path string and returns a 2D point list. This allows user point manipulation before the points are used.
//  path    (list)    String compliant with SVG path syntax plus the extra commands introduced in pathBuilder.
//  return  (list)    List of lists of 2D points that each outline the intended SVG path. Can be directly consumed by the polygon command.
function svgPoints(path, z=undef) = let(
    pointlists = pb_postProcessPathLists(pb_processCommands(pb_tokenizeSvgPath(path)))
) z==undef? pointlists : [for (pts=pointlists) pb_translate_pts(pts,[0,0,z])];

//  module svgShape(s)
//
//  Processes a SVG path string and returns a 2D polygon.
//  path       (list) String compliant with SVG path syntax plus the extra commands introduced in pathBuilder.
//  return  (polygon) polygon can be further handled by any openSCAD command.
module svgShape(path="", _i=-2, _p=undef, _first_CW=undef, $pb_spline=10){
    _p = _p==undef? svgPoints(path) : _p;
    l = len(_p);
    _first_CW = _i<-1? pb_is_CW(_p[0]) : _first_CW;
    _i = _i==-2? l-1 : _i;
    if (l>0){
        if (l==1) polygon(_p[0]);
        if (_i>=0){
            CW2 = pb_is_CW(_p[_i]);
            if (CW2 == _first_CW) union(){
                polygon(_p[_i]);
                svgShape(path, _i-1, _p, _first_CW);
            } else difference(){
                svgShape(path, _i-1, _p, _first_CW);
                polygon(_p[_i]);
            }
        }
    }
}



//  function svgTweenPath(s)
//
//  Processes two similar paths where the command sequence is identical but the parameters are different.
//  The return value is a path string that is either Path1, Path2 or somewhere in between depending on the factor value
//  which must be somewhere between 0 and 1. This function is great to create in between splines.
//  path1   (list)   String compliant with SVG path syntax plus the extra commands introduced in pathBuilder.
//  path2   (list)   String compliant with SVG path syntax plus the extra commands introduced in pathBuilder.
//  factor  (number) Number between 0 and 1 determining the path values of the return path.
//  return  (list) String compliant with SVG path syntax plus the extra commands introduced in pathBuilder.
function svgTweenPath(path1="", path2="", factor=0) = let(
    f = max(0, min(1, factor)),
    commandList1 = pb_tokenizeSvgPath(path1),
    commandList2 = pb_tokenizeSvgPath(path2),
    a = assert(len(commandList1) == len(commandList2), "path1 and path2 must have an equal number of commands."),
    commandList = [for (i=[0:1:len(commandList1)-1]) let(
        a = assert(commandList1[i][0] == commandList2[i][0], "Command mismatch. The command sequence of path1 and path2 must be identical.")
        ) [commandList1[i][0],
        len(commandList1[i][1])==0? [] : [for(j=[0:len(commandList1[i][1])-1]) let(
            v1 = commandList1[i][1][j],
            v2 = commandList2[i][1][j]
        ) v1 + ((v2-v1) * f)]]]
) pb_commandListToPath(commandList);



//  Helper functions:

//  function pb_angle(p1,p2)
//
//  Calculates the angle of line between vector v1 and v2
//  v1      (list)   2D vector with x and y value.
//  v1      (list)   2D vector with x and y value.
//  return  (number) Angle between the two vectors in degrees.
function pb_angle(v1, v2) = let(a = atan2(v2[0] - v1[0], v2[1] - v1[1])) a;

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

//  pb_reflectPntOn(p1, pc)
//
//  Rotates p1 180 degrees around pc. All points are absolute coordinates.
//  p1      (list)  List of two numbers representing the 2D point to be reflected.
//  pc      (list)  (default=[0,0])  List of two numbers representing the 2D center point around which p1 is rotated
//  return  (list)  List of two numbers representing the new rotated point.
function pb_reflectPntOn(p1=[], pc=[0,0]) = pc + (p1-pc)*-1;

//  pb_translate_pts(pts, translate)
//
//  translates points in point list.
//  pts        (list)  List of 2D or 3D points.
//  translate  (list)  List of three or two numbers representing the 3D vector to translate the points with
//  return  (list)  List of translated 3D points.
function pb_translate_pts(pts, translate=[0,0,0])= [for(p=pts)[p[0]+translate[0],p[1]? p[1]+translate[1] : translate[1], p[2]? p[2]+translate[2] : translate[2]]];


//  function  pb_segmentsPerCircle(r)
//
//  Calculates the number of segments used per circle (per 360 deg) based on circle radius and openSCAD $fn, $fa and $fs settings.
//  r       (number)  The circle radius for which the number of segments needs to be calculated.
//  return  (number)  The number of segments that would be used by openSCAD if it would draw the circle.
function pb_segmentsPerCircle(r=1) = $fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,abs(r)*2*PI/$fs),5));

//  function pb_last(pts)
//  
//  Returns last item from the list. If the list is empty it will return [0,0]
//  pts    (list)  List of zero or more 2D points.
//  return (list)  List of two numbers which is a 2D point.
function pb_last(pts) = let(l=is_list(pts)? len(pts) : 0) l==0? [0,0] : pts[l-1];
//  function pb_subList(list, start, end)
//
//  Returns subset of list defined by start and end which are indexes to the list. Indexes are zero based.
//  When indexes are negative they refer from the end of the list rather than the start.
//  list    (list)      List of arbitrary data.
//  start   (number)    (default = 0)                index from the start where items need to be included in the returned list. Negative numbers represent an index from the end of the list.
//  end     (number)    (default = list length - 1)  index from the start after which items no longer need to be included. Negative numbers represent an index from the end of the list.
//  return  (list)      sub list of items from the input list. Items can appear reversed when end references an index that is less than the start index.
//
//  examples:
//      pb_subList([0,1,2,3,4,5,6])        => [0,1,2,3,4,5,6] //  copies the list
//      pb_subList([0,1,2,3,4,5,6],3)      => [3,4,5,6]       //  starts at index 3 up to the end
//      pb_subList([0,1,2,3,4,5,6],3, 4)   => [3,4]           //  starts at index 3 up to end index 4
//      pb_subList([0,1,2,3,4,5,6],3, 2)   => [3,2]           //  starts at index 3 down to end index 2
//      pb_subList([0,1,2,3,4,5,6],-2)     => [5,6]           //  starts 2 before the end of the list up to the end
//      pb_subList([0,1,2,3,4,5,6],-3, -4) => [4,3]           //  starts 3 before the end of the list down to 4 before the end of the list
//      pb_subList([0,1,2,3,4,5,6],-1, 0)  => [6,5,4,3,2,1,0] //  Reverse list
function pb_subList(list, start=0, end) = let(l = len(list), s = start<0? l+start: start, e = end==undef? l-1 : end<0? l+end: end, sp=e<s? -1 : 1) [for(i=[s:sp:e]) list[i]];

//  function pb_valuesToString(s)
//
//  Converts list into a continuous string adding the seperator in between each item.
//  list        (list)   List of values.
//  separator   (string) Separator string that will be inserted between each item in the list.
//  return      (string) String containing all items from the list.
function pb_valuesToString(list, seperator=",", _i=0, _s="") = _i>len(list)-1? _s : pb_valuesToString(list, seperator, _i+1, str(_s, list[_i],_i==len(list)-1? "" : seperator));



//  function pb_removeAdjacentDuplicates(s)
//
//  Removes adjacent duplicate points
//  pts             (list)    List of points.
//  testLastToFirst (boolean) Set to false if you want to skip testing last point to first point.
//  return          (string)  String containing all items from the list.
function pb_removeAdjacentDuplicates(pts=[], testLastToFirst=true, _i=0, _r=[]) = let(
    l = len(pts), _n = testLastToFirst? (_i==l-1? 0: _i+1) : _i+1
) _i<l? pb_removeAdjacentDuplicates(pts, testLastToFirst, _i+1, pts[_i] == pts[_n]? _r : concat(_r,[pts[_i]])) : _r;


//  string handling code from rColyer on Github
//  https://github.com/thehans/funcutils/blob/master/string.scad

function join(l,delimiter="") = let(s = len(l), d = delimiter,
      jb = function (b,e) let(s = e-b, m = floor(b+s/2)) // join binary
        s > 2 ? str(jb(b,m), jb(m,e)) : s == 2 ? str(l[b],l[b+1]) : l[b],
      jd = function (b,e) let(s = e-b, m = floor(b+s/2))  // join delimiter
        s > 2 ? str(jd(b,m), d, jd(m,e)) : s == 2 ? str(l[b],d,l[b+1]) : l[b])
  s > 0 ? (d=="" ? jb(0,s) : jd(0,s)) : "";

function substr(s,b,e) = let(e=is_undef(e) || e > len(s) ? len(s) : e) (b==e) ? "" : join([for(i=[b:1:e-1]) s[i] ]);

function split(s,separator=" ") = separator=="" ? [for(i=[0:1:len(s)-1]) s[i]] :
  let(t=separator, e=len(s), f=len(t),
    _s=function(b,c,d,r) b<e ?
      (s[b]==t[c] ?
        (c+1 == f ?
          _s(b+1,0,b+1,concat(r,substr(s,d,b-c))) : // full separator match, concat substr to result
          _s(b+1,c+1,d,r) ) : // separator match char, more to test
        _s(b-c+1,0,d,r) ) : // separator mismatch
      concat(r,substr(s,d,e))) // end of input string, return result
  _s(0,0,0,[]);

function replace(s, oldText, newText) = join(split(s, oldText),newText);

//  function pb_replacechar(s)
//  string      (string)  Source string
//  char        (char)    Character to be deleted from string
//  Returns sub string of string.
function pb_replacechar(string, findchar=" ", repchar="", _s=0) = _s < len(string) ?
str(string[_s]==findchar? repchar : string[_s], pb_replacechar(string, findchar, repchar, _s + 1)) : "";

//  function pb_substring(s)
//  string      (string)  Source string
//  start       (number)  Index to start character in string
//  end         (number)  Max number of character to return
//  Returns sub string of string.

function pb_substring(string, start, length) = start < length ?
str(string[start], pb_substring(string, start + 1, length)) : "";

//  function pb_groupsOf(n, list, skip, drop, only_groups)
//
//  After skipping skip values this function will group subsequent values in groups of n until the end of the list but minus drop values.
//  This is useful  to group values into point lists and handle left over values in a different way. Perfect to deal with SVG number sequences.
//  n           (number)  Define how many values go in a group. for example, n=3 to turn [x,y,z,x,y,z,x,y,z...] into [[x,y,z],[x,y,z],[x,y,z]...]
//  list        (list)    List containing the input data. This can be kind of data.
//  skip        (number)  Defines how many list values to skip before grouping starts.
//  drop        (number)  Defines how many list values at the end of the list should not be grouped.
//  only_groups (bool)    (default = true) Set to false if you want left-over values that can not be grouped and are not skipped or dropped to be included in the return data.
//  return      (list)    Returns list with three value sets.
//      return[0]         Skipped values.
//      return[1]         Grouped values.
//      return[2]         leftover values if only_groups==false. Followed by the dropped values.
function pb_groupsOf(n, list=[], skip=0, drop=0, only_groups=true) = list==[]? list : let(l=len(list), remain=((l-skip-drop) % n), 
    result = [skip<1? [] : [for(i=[0:skip-1]) list[i]],
    [for(j=[skip:n:l-drop-n]) [for(k=[0:n-1]) list[j+k]]],
    drop>0 || (remain>0&&!only_groups) ? [for(m=[l-remain-drop:l-1]) list[m]] : []] ) result;

//  function pb_is_CW(pts)
//
//  Tests if pts forms a Clock Wise (CW) or Counter Clock Wize (CCW) winding
//  pts     (list)  A list of 2D points assumed a closed polyline.
//  return  (bool)  true if pts is a wound Clock Wize otherwise false.
function pb_is_CW(pts=[], _i=0, _r=0) = _i==len(pts)? _r>0 : pb_is_CW(pts, _i+1, _r + cross(_i==len(pts)-1? pts[0] : pts[_i+1], pts[_i]));

//  function pb_is_2d(p)
//
//  Tests if the value p is a 2D point.
//  p       (list)  A list of two numbers representing a 2D point.
//  return  (bool)  true if p is a 2D point otherwise false.
function pb_is_2d(p=[]) = is_list(p) && len(p)==2 && is_num(p[0]) && is_num(p[1]);

//  function is_between(v1, v, v2)
//
//  Tests if value v is between or equal to v1 and v2. It does not matter if v1 is greater than v2 or vice versa.
//  v1  (number or list) Defines one of the two value boundaries. Value can be a number or a list representing a 2D point.
//  v   (number or list) Defines one value to be tested against v1 and v2. It does not matter
//  v2  (number or list) Defines one of the two value boundaries. Value can be a number or a list representing a 2D point.
//  return  (bool)
//      false if the value v is outside the boundaries v1 and v2.
//      true  if the value is inside the boundaries v1 and v2.
function pb_is_between(v1, v, v2) = let( p=is_num(v)? [v,0]: v, p1=is_num(v1)? [v1,0]: v1, p2=is_num(v2)? [v2,0]: v2, d = p2-p1,
    i=abs(d[0])>abs(d[1])? 0:1, a = p[i]>= min(p1[i],p2[i])&& p[i]<=max(p1[i],p2[i])) a;
    
//  pb_intersectLineWithPolyline(line, pts, mode, all, sort) returns list with points if any
//
//  calculates the intersections between a line and polyline.
//  line    (list) A list of two 2D points. eg [[0,0],[0,5]]
//  pts     (list) A list of one or more 2D points forming a polyline. Polyline does not self close. A a single point is converted into three points, forming one horizontal and one vertical line. 
//  all     (bool)
//      false (default) stops looking for intersections once a valid one is found. sort has no effect.
//      true  builds a list of all valid intersections. The result can be sorted.
//  sort    (list) (default = []) The intersection results will be sorted by distance to the 2D point that can be provided here.
//      false The list of valid intersections is returned in the order they were found.
//      true  (default)  The list of valid intersections is sorted based on proximity to the line end point. Nearest is at the top of the list.
//  on_line (bool)  On line result filter.
//      undef   (default) no intersections are filtered out.
//      false   only intersections that are not on line are returned.
//      true    only intersections that are on line are returned.
//  on_pts (bool)  On pts polyline result filter.
//      undef   (default) no intersections are filtered out.
//      false   only intersections that are not on the pts polyline are returned.
//      true    only intersections that are on the pts polyline are returned.
//  return  (list) A list of intersection results. Each item represents an intersection. An empty list is returned if there are no intersections.
//      return[n]  Data block representing one intersection
//          return[n][0]  (list)    A list of two numbers representing a 2D point where the intersection was found.
//          return[n][1]  (bool)    Intersection found on line. true when it was found on the line otherwise false.
//          return[n][2]  (bool)    Intersection found on polyline segment. true when it was found on a line segment, otherwise false.
//          return[n][3]  (number)  index of polyline segment if the intersection was found on a polyline otherwise -1.
//          return[n][4]  (number)  Distance from the the intersection to the sort point if one was provided. Otherwize value is -1. This value is used by the sort routine.
function pb_intersectLineWithPolyline(line=[], pts=[],all=false, sort=[], on_line=undef, on_pts=undef, _i=0, _r=[]) =
    (!all&&len(_r)>0) ||_i==len(pts)-1? pb_is_2d(sort)? _pb_intersect_sort(_r,3) : _r : let(
        da = line[0]-line[1], db = pts[_i] - pts[_i+1], the = cross(da,db),
        d = (the == 0)? [] : let( A = cross(line[0], line[1]), B = cross(pts[_i], pts[_i+1]),
            x=( A*db[0] - da[0]*B ) / the, y=( A*db[1] - da[1]*B ) / the, a=[x,y],
            ol = pb_is_between(line[0] ,[x,y] ,line[1]),
            op = pb_is_between(pts[_i], [x,y] ,pts[_i+1]),
            p = [a, ol, op, pb_is_2d(sort)? norm(a-sort):-1, op?_i:-1] ) p,
        a = pb_intersectLineWithPolyline(line, pts, all, sort, on_line, on_pts, _i+1, d==[]||d==pb_last(_r)? _r : concat(_r, [d]))
    ) [for(i=a) if ((on_line==undef || on_line==i[1]) && (on_pts==undef || on_pts==i[2])) i];
        
//  function _pb_intersect_sort(list)
//
//  Sorts intersection data produced by pb_intersectLineWithPolyline from near to far.
//  Function is used internally but can be used externally.
//  list    (list)  List of intersection data. See pb_intersectLineWithPolyline for structure details.
//  return  (list)  List of intersection data sorted from near to far
function _pb_intersect_sort(list, sort_idx=2) =
    len(list)<=1 ? list : let(
        pivot   = list[floor(len(list)/2)][sort_idx],
        lesser  = [ for (d = list) if (d[sort_idx] < pivot) d ],
        equal   = [ for (d = list) if (d[sort_idx] == pivot) d ],
        greater = [ for (d = list) if (d[sort_idx] > pivot) d ]        
    ) concat( _pb_intersect_sort(lesser, sort_idx), equal, _pb_intersect_sort(greater, sort_idx) );


//  function pb_parseNum(s)
//
//  Converts a string into a number. this can be an integer or a floating point variable.
//  The function can not handle hex notation.
//  s       (list)  String representing a number. Valid characters are +-0123456789e and .
//  return  (number)  Can be either integer positive or negative or floating point value positive or negative
function pb_parseNum(s, _i=0, _n=0, _d=0, _r1=0, _r2=0) = _i==len(s)? s[0]=="-"? -(_r1+_r2) : _r1+_r2 : let(
        o = ord(s[_i]), f = o==101? pb_parseNum(pb_substring(s, _i+1, len(s))) : 0, _n = o==45 || o==43? 1: _n,
        _d = o == 46? _i+1 : _d, c = (o>47 && o<58), _r1 = c&&_d==0? _r1*10+(o-48) : _r1, _r2 = c&&_d!=0? _r2+(o-48) * pow(10,-_i+_d-1) : _r2
    ) pb_parseNum(pb_replacechar(s), f==0? _i+1 : len(s), _n, _d, _r1, _r2) * pow(10,f);

//  function pb_commandListToPath(commandList)
//
//  Converts command list into a path string.
//  commandList (list)    List of SVG and Pathbuilder commands. Each item consists of a command identifier and a number list.
//  return      (string)  String compliant with SVG path syntax plus the extra commands introduced in pathBuilder.
function pb_commandListToPath(commandList = []) =
    pb_valuesToString([for(command = commandList) str(command[0],pb_valuesToString(command[1]))],"");
           
//  function pb_tokenizeSvgPath(s)
//
//  Parses a path string and turns it into a command list.
//  s       (list)  String compliant with SVG path syntax plus the extra commands introduced in pathBuilder.
//  return  (list)  Command list
//              command (string)    Command identifier
//              values  (list)      Values associated with the command
//                  value  (number) Value associated with the command   
function pb_tokenizeSvgPath(s, _i=0, _cmds=[], _cmd=[], _w = "", _d=0) = 
    _i>len(s)-1?  _cmds : let(
        l=len(s), c1 = s[_i], a1 = ord(c1), a2 = ord(s[min(l-1,_i+1)]), _d = a2==46? _d+1 : _d,
        //   0=number            1=sign                3=sep                 4=dot       5=exp                    2=char
        t1 = a1>47 && a1<58? 0 : a1==43 || a1==45? 1 : a1==32 || a1==44? 3 : a1==46? 4 : (a1==101 || a1==69)? 5 : 2,
        //   6=end        0=number            1=sign                3=sep                 4=dot         5=exp                    2=char
        t2 = _i==l-1? 6 : (a2>47 && a2<58)? 0 : a2==43 || a2==45? 1 : a2==32 || a2==44? 3 : a2==46? 4 : (a2==101 || a2==69)? 5 : 2,
        c =
        t1==2&&t2==0? 1 :           //  char to num   "m 0 0 cha
        t1==2&&t2==3? 2 :           //  char to sep
        t1==2&&t2==1? 3 :           //  char to sign
        t1==2&&t2==4? 4 :           //  char to dot
        t1==2&&t2==6? 5 :           //  char to end
        t1==0&&t2==2? 6 :           //  num to char
        t1==0&&t2==3? 7 :           //  num to sep
        t1==0&&t2==1? 8 :           //  num to sign
        t1==0&&t2==6? 9 :           //  num to end
        t1==0&&t2==4&&_d>1? 11 :    //  num to next dot
        t1==5&&t2==0? 0 :           //  exp to num
        t1==5&&t2==1? 0 :           //  exp to sign
        0,                          //  not important
        dc = c==6 || c==7 || c==8 || c==9? 0 : _d,
        //w = t1!=3&&(c1!="z" && c1!="Z)? str(_w,c1) : _w,
        w = t1!=3? str(_w,c1) : _w,
        //w = t1!=3? str(_w,c1) : _w,
        _cmd = c>0||t2==6? t1==2? [w,[]] : [_cmd[0],concat(_cmd[1],[pb_parseNum(w)])] : _cmd,
        _cmds = (t1==0 || t1==3 || t2==6) && (t2==2|| t2==6)? concat(_cmds, [_cmd]) : _cmds,
        _w = c>0? "" : w
    )pb_tokenizeSvgPath(s=s, _i=_i+1, _cmds=_cmds, _cmd=_cmd, _w=_w, _d=dc);


//  function checks command list and splits command list to multiple command lists for every m or M command
//  
function pb_splitCommandLists(cmds=[], _i=0, _p=[], _r=[]) = _i==len(cmds)? _r  : let(
    n = cmds[_i][0] =="m" || cmds[_i][0] =="M"? true : false,
    _r = n && _p!=[]? concat(_r, [_p]) : _r,
    _p = n? [cmds[_i]] : concat(_p,[cmds[_i]]),
    r = _i==len(cmds)-1? concat(_r, [_p]) : _r
) pb_splitCommandLists(cmds, _i+1, _p, r);

function pb_processCommandLists(cmds_list) = [for (cmds=cmds_list) pb_processCommands(cmds)];

//  function pb_processCommands(cmds)
//
//  Processes all the commands in the command list and generates a preliminary 2D point list and a post process command list
//  When finished, the point list contains all points except fillet, chamfer and z. Those are applied in a seprate pb_postProcessPath command.
//  cmds    (list)  List of path commands
//  return  (list)  Intermediate 2D points list and post processing list
//      return[0]   (list)   List with 2D points.
//      return[1]   (list)   List with post process commands such as fillet and chamfer which are applied at the end.
//      return[2]   (number) current angle in degrees
//      return[3]   (list)   List containing 2 bezier spline control points. However, only one can be set at a time and the other should be empty.
//          return[3][0]    (list)  2D point representing the control point of the last command which must have been a quadratic spline type. Otherwise empty ([])
//          return[3][1]    (list)  2D point representing the control point of the last command which must have been a cubic spline type. Otherwise empty ([])

function pb_processCommands(cmds=[], _i=0, _r=[[],[],0,[[],[]]], _f=[]) = 
        assert(is_list(cmds) && len(cmds) > 0 && (cmds[0][0] == "m" || cmds[0][0] == "M"), str("cmds must be a list and start with a M (move) command but started with ",cmds[0][0]))
        _i==len(cmds)? concat(_f,[[_r[0],concat(_r[1],[[4,len(_r[0])-1]])]]) : let(
        cmd = cmds[_i],
        o = ord(cmd[0]),
        c = cmd[0],
        a = _r[2],
        ctl = _r[3],
        l = pb_last(_r[0]),
        d = c=="m"? _pb_line(_r[0], true,cmd[1],a,true) :
            c=="M"? _pb_line(_r[0], false, cmd[1],a,true) :
            c=="l"? _pb_line(_r[0], true, cmd[1], a, false) :
            c=="L"? _pb_line(_r[0], false, cmd[1], a, false) :
            c=="h"? _pb_horz(l, cmd[1], true, a) :
            c=="H"? _pb_horz(l, cmd[1], false, a) :
            c=="v"? _pb_vert(l, cmd[1], true, a) :
            c=="V"? _pb_vert(l, cmd[1], false, a) :
            c=="c"? _pb_cubic(l, cmd[1], true, a) :
            c=="C"? _pb_cubic(l, cmd[1], false, a) :
            c=="s"? _pb_smooth_cubic(l, cmd[1], true, a, ctl) :
            c=="S"? _pb_smooth_cubic(l, cmd[1], false, a, ctl) :
            c=="q"? _pb_quadratic(l, cmd[1], true, a) :
            c=="Q"? _pb_quadratic(l, cmd[1], false, a) :
            c=="t"? _pb_smooth_quadratic(l, cmd[1], true, a, ctl) :
            c=="T"? _pb_smooth_quadratic(l, cmd[1], false, a, ctl) :
            c=="a"? _pb_arc(l, cmd[1], true, a) :
            c=="A"? _pb_arc(l, cmd[1], false, a) :
            c=="z" || c=="Z"? _pb_close(_r[0], a) :
            c=="polar"? _pb_polar(_r[0], [cmd[1][0], cmd[1][1]+a]) :
            c=="Polar"? _pb_polar(_r[0], cmd[1]) :
            c=="forward"? _pb_forward(l, cmd[1], true, a) :
            c=="Forward"? _pb_forward(l, cmd[1], false, a) :
            c=="angle"? _pb_angle(cmd[1], false, a) :
            c=="Angle"? _pb_angle(cmd[1], true, a) :
            c=="segment"? _pb_segment(last=l, args=cmd[1], rel=true) :
            c=="Segment"? _pb_segment(last=l, args=cmd[1], rel=false) :
            c=="fillet"? _pb_fillet(_r[0], cmd[1], a) :
            c=="chamfer"? _pb_chamfer(_r[0], cmd[1], a) : [],
        _f = (c=="m" || c=="M") && _r[0]!=[]? concat(_f, [[_r[0],concat(_r[1],[[4,len(_r[0])-1]]),_r[2],_r[3]]]) : _f,
        r = c=="m" || c=="M"? d : d==[]? _r : [concat(_r[0], d[0]),concat(_r[1], d[1]), is_num(d[2])? d[2] : _r[2],d[3]]
    ) pb_processCommands(cmds, _i+1, c=="m" || c=="M"? d : d==[]? _r : [concat(_r[0], d[0]),concat(_r[1], d[1]), is_num(d[2])? d[2] : _r[2],is_list(d[3])? d[3]: [[],[]]], _f);


//  Applies fillets and chamfer commands to the raw point list
//  chamfer = 2
//  fillet  = 3
//  z       = 4

function pb_postProcessPathLists(data_list =[]) = [for (data=data_list)
    let(
        pts = pb_removeAdjacentDuplicates(data[0]),
        steps = data[1],
        l = len(steps),
        first_pt = steps[1][1]==0? [] : [pts[0]],
        last_pt = steps[l-2][1]==len(pts)-1? [] : [pts[len(pts)-1]],
        result = [for (i = [0: len(steps)-2]) let(
            step = data[1][i],
            next_step = data[1][i+1],
            start = step[1],
            end = next_step[1],
            fill = (step[0]==2)? pb_fillet(pts, step[1], step[2], step[3]) : [],
            chamf = (step[0]==3)? pb_chamfer(pts, step[1], step[2]) : [],
            post = start+1<=end-1?pb_subList(pts, start+1, end-1) : []
        ) for (p=concat(fill, chamf, post)) p],
        r = concat(first_pt, result, last_pt),
        rr = concat(r, len(steps)>0 && pb_last(steps)[0]==4? [r[0]] : [])
    ) rr];

    
//  Calculates tangent fillet for any given point in a closed points list. Flip the curve by setting the radius negative.    
//  pts     (list)     List of 2D points.
//  index   (number)   Index to the point for which a fillet is required.
//  radius  (number)   Radius for the requested fillet
//  segments(number)   Optional fixed number of segments to draw the fillet.        
//  return  (segments) List of points representing the fillet curve that can replace the given point by index.
function pb_fillet(pts, index, radius, segments=0) = let(
    a = index==0? pts[len(pts)-1] : pts[index-1],
    b = pts[index],
    c = index == len(pts)-1? pts[0]:pts[index+1],
    ba = a-b,
    bc = c-b,
    l1 = norm(ba),
    l2 = norm(bc),
    cos_angle = ba * bc / (l1 * l2),
    tan_half_angle = sqrt((1 - cos_angle) / (1 + cos_angle)),
    bf_length = abs(radius) / tan_half_angle,
    ba_u = ba/l1,
    bc_u = bc/l2,
    bf = ba_u*bf_length,
    bg = bc_u*bf_length,
    f = b + bf,
    g = b + bg,
    e1=assert(tan_half_angle!=0, "Fillet is not possible on angles of 0 degrees"),
    e2=assert(bf_length<l1 || bf_length<l2, str("Fillet can not be applied. Max radius is ",min(l1, l2))),
    sig = sign(ba[0] * bc[1] - ba[1] * bc[0]) * (radius<0? -1 : 1),
    ps = pb_curveBetweenPoints(f, g, abs(radius) * sig, segments)[0]
) ps;

//  Calculates a balanced symetrical chamfer for a given point  
//  pts     (list)   List of 2D points.
//  index   (number) Index to the point for which a chamfer is required.
//  size    (number) Size for the requested chamfer width
//  return  (list)   List of two points representing the chamfer line that can replace the given point by index.
//                   The original point is returned when size is zero or when either point adjacent to index
//                   sharing the same coordinates.
function pb_chamfer(pts, index, size) = let(
    a = index==0? pts[len(pts)-1] : pts[index-1],
    b = pts[index],
    c = index == len(pts)-1? pts[0]:pts[index+1],
    d = size/2,
    ba = a-b,
    bc = c-b,
    l1 = norm(ba),
    l2 = norm(bc),
    cos_angle = ba * bc / (l1 * l2),
    tan_half_angle = sqrt((1 - cos_angle) / (1 + cos_angle)),
    bf_length = sqrt(pow(d/tan_half_angle,2) + pow(d,2)),
    ba_u = ba/l1,
    bc_u = bc/l2,
    bf = ba_u*bf_length,
    bg = bc_u*bf_length,
    f = b + bf,
    g = b + bg
) (size<=0 || a==b || b==c)? [b] : [f, g];

//  function pb_ellipseCenter(p1, p2, rx, ry, angle, long, ccw)
//
//  Calculates center of a ellipse rx, ry rotated to angle that runs through both p1 and p2.
//  p1          2D start point for the arc segment.
//  p2          2D end point of the arc segment.
//  rx          x radius for the ellipse when angle = 0
//  ry          y radius for the ellipse when angle = 0
//  angle       rotation angle of the ellipse around it's center point.
//  long        Two ways around the ellipse. Set to true to take the long way.
//  ccw         Set to true of you want the acr drawn following the ellipse counter clock wize.
//
//  return      List with two values.
//      return[0]   2D point list forming a polyline representing the ellipseArc.
//      return[1]   2D point which represents the position of the ellipse center point.
function pb_ellipseCenter(p1=[], p2=[], rx, ry, angle=0, long=false, ccw=false)= let(
P = [[cos(-angle), sin(-angle)], [-sin(-angle), cos(-angle)]] * ((p1-p2)*0.5),
x = P[0], y = P[1], a =  ((x * x) / (rx * rx) ) + ( (y * y) / (ry * ry) ),
rx = a > 1? (sqrt(a) * abs(rx)) : abs(rx), ry = a > 1? (sqrt(a) * abs(ry)) : abs(ry),
co = (long == ccw? 1 : -1) * sqrt(( (rx*rx*ry*ry) - (rx*rx*y*y) - (ry*ry*x*x) ) / ( (rx*rx*y*y) + (ry*ry*x*x) )),
C = ([[ cos(-angle), -sin(-angle)],[sin(-angle), cos(-angle)]] * [rx*y/ry, -ry*x/rx] * co) + ((p1+p2)*0.5)) C;


//  function pb_ellipseArc(p1, p2, rx, ry, angle, long, ccw)
//
//  Produces a list of 2D points that approximates the arc segment required to from p1 to p2.
//  p1          2D start point for the arc segment.
//  p2          2D end point of the arc segment.
//  rx          x radius for the ellipse when angle = 0
//  ry          y radius for the ellipse when angle = 0
//  angle       rotation angle of the ellipse around it's center point.
//  long        Two ways around the ellipse. Set to true to take the long way.
//  ccw         Set to true of you want the acr drawn following the ellipse counter clock wize.
//
//  return      List with two values.
//      return[0]   2D point list forming a polyline representing the ellipseArc.
//      return[1]   2D point which represents the position of the ellipse center point.
function pb_ellipseArc(p1=[], p2=[], rx, ry, angle=0, long=false, ccw=false, skip_first=false) = rx==0||ry==0? [p1,p2] : let(
    d = norm(p2-p1),
    e = assert(rx*2>=d, str("pb_ellipseArc - Radius:",rx," is too small for distance:",d)),
    pc = pb_ellipseCenter(p2,p1,rx,ry,angle, long, ccw),
    
    m = [[cos(angle), -sin(angle)],[sin(angle), cos(angle)]],
    nm = [[cos(-angle), -sin(-angle)],[sin(-angle), cos(-angle)]],
    v1 = (p1-pc) * nm, v2 = (p2-pc) * nm,
    a1 = (v1[1]<0? 180 : 0)+ atan2(v1[0]/v1[1],rx/ry),
    a2 = (v2[1]<0? 180 : 0)+ atan2(v2[0]/v2[1],rx/ry),
    da = abs(a2 - a1 % 360), das = da<=180? da : 360-da,
    cda = long? 360-das : das,
  
    s = pb_segmentsPerCircle((rx+ry)/2),

    steps = floor(abs(cda*s/360)),
    sa = ccw? -(cda/steps) : cda/steps,
    pts = steps<=2? [p2] : [for(i=[1:steps-1]) let(a = a1 + (sa * i)%360) pc+[sin(a) * rx , cos(a) * ry] * m, p2]
) [skip_first? pts : concat([p1],pts),concat(pc,0)];

//  function pb_curveBetweenPoints(p1, p2, radius)
//
//  Creates a curve made of line segments connecting the two points with the defined radius.
//  p1      (list)   List of two numbers representing a 2D point
//  p2      (list)   List of two numbers representing a 2D point
//  radius  (number) Required radius of the desired curve. Change the sign of the radius to mirror the curve. The radius value must be at least half the distance between p1 and p2.
//  return  (list)   List of the resulting curve data...
//      return[0]    (list)   List of the 2D point list describing the curve. The list includes p1 and p2.
//      return[1]    (number) Angle of the last line segment in the curve
//      return[2]    (list)   List of two numbers representing a 2D point. This point is the center of the circle segment drawn.
function pb_curveBetweenPoints(p1=[], p2=[], radius=0, segments=0) = radius==0? [p1,p2] : let(
    d = norm(p2-p1),
    r = abs(radius),
    e = assert(r*2>=d, str("Radius:",r," is too small for distance:",d)),
    x3 = (p1[0] + p2[0])/2,
    y3 = (p1[1] + p2[1])/2,
    base = sqrt(pow(r,2) - pow((d / 2),2)),
    basex = base * (p1[1] - p2[1]) / d,
    basey = base * (p2[0] - p1[0]) / d,
    pc = radius > 0? [x3 - basex, y3 - basey] : [x3 + basex, y3 + basey],
    a1 = atan2(p1[0]-pc[0], p1[1]-pc[1]),
    a2 = atan2(p2[0]-pc[0], p2[1]-pc[1]),
    da = a2 - a1 % 360,
    cda = da<-180? 360 + da : da>180? -360 + da : da,
    //steps = floor(abs(cda*($fn==0? 1/$fa : $fn/360))),
    steps = segments==0? floor(abs(cda * pb_segmentsPerCircle(radius) / 360)) : segments,
    sa = cda/steps,
    pts = steps<=2? [p1,p2] : [p1,for(i=[1:steps-1]) [sin(a1 + (sa * i)) * r + pc[0], cos(a1 + (sa * i)) * r + pc[1]],p2]
) [pts,sign(sa)*90+a1+cda, pc];



//  function pb_bezier_quadratic_curve(p0, c, p1, n)
//
//  Generates a Bezier quadratic curve from p0 to p1 using a single control point c. The curve is approximated by a 2D point list containing n points.
//  p0      (list)   List of two numbers representing the 2D start point of the curve.
//  c       (list)   List of two numbers representing a 2D control point shaping the curve and defines both entry and exit tangents.
//  p1      (list)   List of two numbers representing the 2D end point of the curve.
//  n       (number) The number of points that should be returned.
//  return  (list)   List of 2D points resembling the quadratic curve.
function pb_bezier_quadratic_curve(p0, c, p1, n = $pb_spline, skip_first=false) = [for(t = [skip_first? 1: 0 : n]) let(t0=t/n, t1=pow(1 - t0, 2), t2=pow(t0, 2)) [p0[0] * t1 + 2 * c[0] * t0 * (1 - t0) + p1[0] * t2, p0[1] * t1 + 2 * c[1] * t0 * (1 - t0) + p1[1] * t2]];

//  function pb_bezier_cubic_curve(p0, c0, c1, p1, n)
//
//  Generates a Bezier cubic curve from p0 to p1 using two control points c0 and c1. The curve is approximated by a 2D point list containing n points.
//  p0      (list)   List of two numbers representing the 2D start point of the curve.
//  c0      (list)   List of two numbers representing a 2D control point shaping the curve and defining the entry tangent.
//  c1      (list)   List of two numbers representing a 2D control point shaping the curve and defining the exit tangent.
//  p1      (list)   List of two numbers representing the 2D end point of the curve.
//  n       (number) The number of points that should be returned.
//  return  (list)   List of 2D points resembling the cubic curve.
function pb_bezier_cubic_curve(p0, c0, c1, p1, n = $pb_spline, skip_first=false) = [for(t = [skip_first? 1: 0 : n]) let(t0=t/n, t1=pow((1 - t0), 3),t2=pow((1 - t0), 2),t3=pow(t0, 2) * (1 - t0), t4=pow(t0, 3)) [ p0[0] * t1 + 3 * c0[0] * t0 * t2 + 3 * c1[0] * t3 + p1[0] * t4, p0[1] * t1 + 3 * c0[1] * t0 * t2 + 3 * c1[1] * t3 + p1[1] * t4]];


//function pb_do_render($children, parent_module_name) = ($children == 0 || parent_module_name == "M" || parent_module_name == "m");
function pb_do_render(children, parent_module_name) = let(
    do_render = (children == 0)// || parent_module_name == "M" || parent_module_name == "m")
) do_render;

// module m(x,y,a)
//
//  Start and initialise the pathbuilder. The function initialises the global point list $pb_pts, global post processing instructions $pb_post and global angle $pb_angle.
//  x     (number)  x value of the 2D start point initialisation. Default to zero if not provided.
//  y     (number)  y value of the 2D start point initialisation. Default to zero if not provided.
//  a     (number)  angle of the path initialisation. Default to zero if not provided.
module m(x=0, y=0, a=0, $pb_spline=10){
    $pb_fn = $fn;
    $pb_fa=$fa;
    $pb_fs=$fs;
    data = _pb_line([],true, is_list(x)? x: [x,y],a,true);
    $pb_pts = data[0];
    $pb_post = data[1];
    $pb_angle = a;
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children(); 
}

// module M(x,y,a)
//
//  Start and initialise the pathbuilder. The function initialises the global point list $pb_pts, global post processing instructions $pb_post and global angle $pb_angle.
//  x     (number)  x value of the 2D start point initialisation. Default to zero if not provided.
//  y     (number)  y value of the 2D start point initialisation. Default to zero if not provided.
//  a     (number)  angle of the path initialisation. Default to zero if not provided.
module M(x=0, y=0, a=0, $pb_spline=10){
    if (pb_do_render($children, parent_module(0))){
        pb_draw();
    }
    children();
    $pb_fn = $fn;
    $pb_fa=$fa;
    $pb_fs=$fs;
    data = _pb_line([],false, is_list(x)? x : [x,y],a,true);
    $pb_pts = data[0];
    $pb_post = data[1];
    $pb_angle = a;
}

//  function _pb_horz(last, rel, args, angle)
//
//  Adds a point with the same y value as the last point but a new x value. No point is added if the new point is the same as the last point.
//  last    (list)   List of two numbers representing the last known 2D point.
//  args    (list)   Function specific parameters.
//      args[0]    (number)  x value for new 2D point. relative or absolute depending on rel value false or true.
//  rel     (bool)   Set to false when working with absolute coordinates. Set to true when coordinates are relative to the last point.
//  angle   (number) Last known angle. Returned when no new angle is created.
//  return  (list)   List of a command response alwas consisting of
//      return[0]  (list)    2D points list of the points generated by the command. The list is empty if not relevant.
//      return[1]  (list)    List representing a post processing command. The list is empty if not relevant.
//      return[2]  (number)  New current angle after the command completed. 
function _pb_horz(last=[], args=[], rel=false, angle) = let(x=rel? last[0] + args[0] : args[0]) x==last[0]? [[[]],[],angle,[[],[]]] : [[[x, last[1]]], [], x > last[0]? 90 : 270,[[],[]]];

//  module h(last, rel, args)
//
//  Adds a point with the same y value as the last point but a new x value relative from the last known point.
//  x       (number)  x value for new 2D point relative from the last known 2D point.
module h(x){
    data = _pb_horz(pb_last($pb_pts), [x], true, $pb_angle);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2]==undef? $pb_angle : data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();
}

//  module H(last, rel, args)
//
//  Adds a point with the same y value as the last point but a new absolute x value .
//  x       (number)  x value for new 2D point in absolute coordinates.
module H(x){
    data = _pb_horz(pb_last($pb_pts), [x], false, $pb_angle);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();      
}

//  function _pb_vert(last, rel, args, angle)
//
//  Adds a point vertically from the last point y units away.
//  pts     (list)  The point list being constructed.
//  args    (list)  Function specific parameters.
//      args[0]  (number)  Distance along y axis either relative or absolute
//  rel     (bool)  Set to false when working with relative values. Set to true when working with absolute values.
//  angle   (number)  Last known angle. Returned when no new angle is created.
//  return  (list)  List of a command response alwas consisting of
//      return[0]  (list)    2D points list of the points generated by the command. The list is empty if not relevant.
//      return[1]  (list)    List representing a post processing command. The list is empty if not relevant.
//      return[2]  (number)  New current angle after the command completed. 
function _pb_vert(last=[], args=[], rel=false, angle) = let(y=rel? last[1] + args[0] : args[0]) y==last[1]? [[[]],[],angle,[[],[]]] : [[[last[0],y]], [], y > last[0]? 0 : 180,[[],[]]];

//  Adds point y units away from the last 
module v(y){
    data = _pb_vert(pb_last($pb_pts), [y], true, $pb_angle);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

//  Adds a point vertically from the last point to absolute coordinate y
module V(y){
    data = _pb_vert(pb_last($pb_pts), [y], false, $pb_angle);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();      
}

//  function _pb_close(pts, angle)
//
//  Closes points list if not already closed by adding the first point to the end of the list.
//  pts     (list)  The point list being constructed.
//  angle   (number)  Last known angle. Returned when no new angle is created.
//  return  (list)  List of a command response alwas consisting of
//      return[0]  (list)    2D points list of the points generated by the command. The list is empty if not relevant.
//      return[1]  (list)    List representing a post processing command. The list is empty if not relevant.
//      return[2]  (number)  New current angle after the command completed. 
function _pb_close(pts, angle) = [[], [], angle];

//  function _pb_line
//
//  Adds one or multiple points starting from last point x units away. Points are only added if the previous point is different.
//  pts     (list)  List of points created so far.
//  rel     (bool)  Set to false when working with relative values. Set to true when working with absolute values.
//  args    (list)  Flat list of numbers. Numbers are x,y value pairs. Should have 1 .. n value pairs.
//      args[0]    (number)  x value for the next point.
//      args[1]    (number)  y value for the next point.
//      args[...]  (number)  provide as many x,y value pairs as required like this U shape [0,5, 0,0, 5,0, 5,5]
//  angle   (number) Last known angle. Returned when no new angle is created.
//  return  (list)  List of a command response alwas consisting of
//      return[0]  (list)    2D points list of the points generated by the command. The list is empty if not relevant.
//      return[1]  (list)    List representing a post processing command. The list is empty if not relevant.
//      return[2]  (number)  New current angle after the command completed. 
function _pb_line(pts=[], rel=false, args=[], angle, move=false, _i=0, _g, _r=[]) = let(
    _l = _r==[]? pts==[]? [0,0] : pb_last(pts) : pb_last(_r),
    _g = _g==undef? pb_groupsOf(2,args)[1] : _g,
    np = rel? _l+_g[_i] : _g[_i],
    _r = np==_l&&pts!=[]&&_r!=[]? _r : concat(_r, [np])
    ) _i>=len(_g)-1? [_r,move?[[0,0,0]]:[],move? angle: pb_calcExitAngle(concat([_l],_r),angle),[[],[]]] : _pb_line(pts, rel, args, angle, move, _i+1, _g, _r);

//  module l
//
//  Adds one or multiple points relative from the last point
//  x       (list)    Flat list of numbers. Numbers are x,y value pairs. Should have 1 .. n value pairs or...
//  x       (number)  x value for the next point.
//  y       (number)  y value for the next point.
module l(x, y){
    args = is_list(x)? x : [x,y];
    data = _pb_line($pb_pts, true, args, $pb_angle, false);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();    
}

//  module L
//
//  Adds one or multiple points. Values are absolute coordinates.
//  x       (list)    Flat list of numbers. Numbers are x,y value pairs. Should have 1 .. n value pairs or...
//  x       (number)  x value for the next point.
//  y       (number)  y value for the next point.
module L(x, y){
    args = is_list(x)? x : [x,y];
    data = _pb_line($pb_pts, false, args, $pb_angle, false);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();   
}

//  function _pb_cubic(last, args, rel, angle)
//
//  Generates multiple points forming line segments approximating one or multiple discrete cubic Bezier curves.
//  
function _pb_cubic(last=[], args=[], rel=false, angle, _i=0, _g, _r=[]) = let(
    _g = _g==undef? pb_groupsOf(6, args)[1] : _g,
    b = _g[_i],
    p0 = last,
    c0 = rel? last + [b[0],b[1]] : [b[0],b[1]],
    c1 = rel? last + [b[2],b[3]] : [b[2],b[3]],
    p1 = rel? last + [b[4],b[5]] : [b[4],b[5]],
    _r = concat(_r, pb_bezier_cubic_curve(p0, c0, c1, p1, skip_first=true))) _i==len(_g)-1? [_r,[],pb_calcExitAngle(_r),[[],pb_reflectPntOn(c1, p1)]] : _pb_cubic(p1, args, rel, angle, _i+1, _g, _r);

module c(cx1, cy1, cx2, cy2, x, y){
    args = is_num(cx1)? [cx1, cy1, cx2, cy2, x, y] : cx1;
    data = _pb_cubic(pb_last($pb_pts), args, true, $pb_angle);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();    
}

module C(cx1, cy1, cx2, cy2, x, y){
    args = is_num(cx1)? [cx1, cy1, cx2, cy2, x, y] : cx1;
    data = _pb_cubic(pb_last($pb_pts), args, false, $pb_angle);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();     
}

//  function _pb_smooth_cubic(last, args, rel, angle)
//
//  Generates multiple points forming line segments approximating one or multiple discrete cubic Bezier curves.
//  
function _pb_smooth_cubic(last=[], args=[], rel=false, angle, ctrl_pts, _i=0, _g, _r=[]) = let(
    _g = _g==undef? pb_groupsOf(4, args)[1] : _g,
    b = _g[_i],
    p0 = last,
    c0 = len(ctrl_pts[1])==2? ctrl_pts[1] : p0,
    c1 = rel? last + [b[0],b[1]] : [b[0],b[1]],
    p1 = rel? last + [b[2],b[3]] : [b[2],b[3]],
    cn = pb_reflectPntOn(c1,p1),
    _r = concat(_r, pb_bezier_cubic_curve(p0, c0, c1, p1, skip_first=true))) _i==len(_g)-1? [_r,[], pb_calcExitAngle(_r),[[],cn]] : _pb_smooth_cubic(p1, args, rel, angle, [[],cn], _i+1, _g, _r);

module s(cx2, cy2, x, y, n=$pb_spline){
    args = is_num(cx2)? [cx2, cy2, x, y] : cx2;
    data = _pb_smooth_cubic(pb_last($pb_pts), args, true, $pb_angle, $pb_ctrl_pts,$pb_spline);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();     
}

module S(cx2, cy2, x, y, n=$pb_spline){
    args = is_num(cx2)? [cx2, cy2, x, y] : cx2;
    data = _pb_smooth_cubic(pb_last($pb_pts), args, false, $pb_angle, $pb_ctrl_pts,$pb_spline);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();     
}

//  function _pb_quadratic(last, args, rel, angle,ctrl_pt)
//
//  Generates multiple points forming line segments approximating one or multiple discrete cubic Bezier curves.
//  
function _pb_quadratic(last=[], args=[], rel=false, angle, _i=0, _g, _r=[]) = let(
    _g = _g==undef? pb_groupsOf(4, args)[1] : _g,
    b = _g[_i],
    p0 = last,
    c = rel? last + [b[0],b[1]] : [b[0],b[1]],
    p1 = rel? last + [b[2],b[3]] : [b[2],b[3]],
    _r = concat(_r, pb_bezier_quadratic_curve(p0, c, p1, skip_first=true))) _i==len(_g)-1? [_r,[],pb_calcExitAngle(_r),[pb_reflectPntOn(c,p1),[]]] : _pb_quadratic(p1, args, rel, angle, _i+1, _g, _r);

module q(cx, cy, x, y, n=$pb_spline){
    args = is_num(cx)? [cx, cy, x, y] : cx;
    data = _pb_quadratic(pb_last($pb_pts), args, true, $pb_angle);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();     
}

module Q(cx, cy, x, y, n=$pb_spline){
    args = is_num(cx)? [cx, cy, x, y] : cx;
    data = _pb_quadratic(pb_last($pb_pts), args, false, $pb_angle);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();     
}

//  function _pb_smooth_quadratic(last, args, rel, angle)
//
//  Generates multiple points forming line segments approximating one or multiple discrete cubic Bezier curves.
//  
function _pb_smooth_quadratic(last=[], args=[], rel=false, angle, ctrl_pts, _i=0, _g, _r=[]) = let(
    _g = _g==undef? pb_groupsOf(2, args)[1] : _g,
    b = _g[_i],
    p0 = last,
    c = len(ctrl_pts[0])==2? ctrl_pts[0] : p0,
    p1 = rel? last + [b[0],b[1]] : [b[0],b[1]],
    cn = pb_reflectPntOn(c, p1),
    _r = concat(_r, pb_bezier_quadratic_curve(p0, c, p1, skip_first=true))) _i==len(_g)-1? [_r,[],pb_calcExitAngle(_r),[cn,[]]] : _pb_smooth_quadratic(p1, args, rel, angle, [cn,[]], _i+1, _g, _r);

module t(x, y, n=$pb_spline){
    args = is_num(x)? [x, y] : x;
    data = _pb_smooth_quadratic(pb_last($pb_pts), args, true, $pb_angle, $pb_ctrl_pts);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();     
}

module T(x, y, n=$pb_spline){
    args = is_num(x)? [x, y] : x;
    data = _pb_smooth_quadratic(pb_last($pb_pts), args, false, $pb_angle, $pb_ctrl_pts);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();     
}

//  function _pb_arc(last, args, rel, angle)
//
//  Generates multiple points forming line segments approximating one or multiple discrete cubic Bezier curves.
//  
function _pb_arc(last=[], args=[], rel=false, angle, _i=0, _g, _r=[]) = let(
    _g = _g==undef? pb_groupsOf(7, args)[1] : _g,
    b = _g[_i],
    rx = b[0],
    ry = b[1],
    angle = b[2],
    long = b[3],
    sweep = b[4],
    p2 = rel? last + [b[5], b[6]] : [b[5], b[6]],
    d = pb_ellipseArc(last, p2, rx, ry, angle, long, sweep, true),
    _r = concat(_r, d[0])) _i==len(_g)-1? [_r, [], pb_calcExitAngle(d[0]),[[],[]]] : _pb_arc(p2, args, rel, angle, _i+1, _g, _r);

//  arc creates an ellipse according the x and y radius.
//
//  rx    (number)  Radius for the ellipse along the x axis.
//  ry    (number)  Radius for the ellipse along the y axis.
//  angle (number)  Degrees of rotation for the ellipse.
//  long  (bool)    Ensures arc will be greater than 180 degrees when true.
//  ccw   (bool)    Ensures arc will be drawn counter clockwize when true.
//  x     (number)  x value of the desired 2D end point.
//  y     (number)  y value of the desired 2D end point.

module a(rx, ry, angle, long, sweep, x, y){
    args = is_num(rx)? [rx, ry, angle, long, sweep, x, y] : rx;
    data = _pb_arc(pb_last($pb_pts), args, true, 0, 0, undef, []);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();    
}

module A(rx, ry, angle, long, sweep, x, y){
    args = is_num(rx)? [rx, ry, angle, long, sweep, x, y] : rx;
    data = _pb_arc(pb_last($pb_pts), args, false, 0, 0, undef, []);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();   
}

//  function _pb_polar(pts, args) 
//
//  Adds a point at distance d relative from the last point in the given direction
//  relative of absolute angle is handled by the caller. Here we assume absolute angle
//  pts  the point list being constructed
//  args     (list) Function specific parameters
//  args[0]  (number)  Distance along from the last point.
//  args[1]  (number)  Angle along which the new point is calculated.
//  return (list)  Data structure being [new_points_list, new_post_processing_instructions_list, new_angle].
function _pb_polar(pts=[], args=[]) = let(l= pb_last(pts))
    [len(args)<2? [] : [l+[sin(args[1])*args[0], cos(args[1])*args[0]]],[],args[1],[[],[]]];

module polar(d, a){
    data = _pb_polar($pb_pts, [d,$pb_angle+a]);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

module Polar(d, a){
    data = _pb_polar($pb_pts,[d,a]);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

//  function _pb_forward(last, args, rel, angle)
//
//  Adds a point some distance along in the same direction as the last line segment or last angle.
//  The distance depends on the arguments provided. Extends last line to intersect with one or multiple reference lines described by the provided parameters.
//  The function will not add points if the last line is parallel with the reference line(s) or when it doesn't satisfy the bounds_mode rules.
//  last    (list)  The point list being constructed.
//  rel     (bool)  Set to false when working with relative boundary values. Set to true when working with absolute boundary values.
//  args    (list)  Function specific parameters.
//      args[0]  If a single value is provided the last line segment is extended with that value.
//  angle   (number)  Last known angle.
//  If two values are provided the last line is extended to wich ever line is intersected with first either the line with the value x or reference lines are assumed to lie parallel with both x and y axis. Two values provide a reference line points are given the intersection with that line.
function _pb_forward(last=[0,0], args=[], rel=false, angle) = let(
        l = len(args), p1 = last, d = l==1? args[0] : 0.001, p2 = p1+[sin(angle)*d, cos(angle)*d],
        bds = [for(b=l==1? [] : l==2? [[args[0]-1,args[1]],[args[0],args[1]],[args[0],args[1]+1]] : pb_groupsOf(2, args)[1]) rel? last+b : b],
        pt = l==1? [[p2]] : l>1? pb_intersectLineWithPolyline([p1,p2],bds,true,true, false, l==2?undef:true) : [[[]]]) [len(pt)>0?[pt[0][0]]:[],[],angle,[[],[]]];

module forward(d){
    data = _pb_forward(pb_last($pb_pts), is_num(d)? [d] : d, true, $pb_angle);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

module Forward(d){
    data = _pb_forward(pb_last($pb_pts), is_num(d)? [d] : d, false, $pb_angle);
    $pb_pts = concat($pb_pts, data[0]);
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

//  Generates multiple points to form a circle segment from the last point to relative point x,y with given radius
//  An error is shown if the radius is less than half the distance between the two points.
//  You can flip the circle segment inside out by changing the radius to negative
function _pb_segment(last=[], args=[], rel=false, _i=0, _r=[]) = let(
    groups = pb_groupsOf(2,args,0,1,true),
    r = groups[2][0],
    $fn = len(groups[2])>1? groups[2][1] : $fn,
    pt2 = rel? last+groups[1][_i] : groups[1][_i],
    data = pb_curveBetweenPoints(last, pt2, r),
    _r = concat(_r, pb_subList(data[0], 1))
    ) _i==len(groups[1])-1? [_r,[],data[1],[[],[]]] : _pb_segment(last=pt2, args=args, rel, _i=_i+1, _r=_r);

module segment(x, y, r){
    l = pb_last($pb_pts);
    args = is_num(x)? [x,y,r] : is_num(r)? concat(x, r) : x;
    data = _pb_segment(l, args, true);
    $pb_pts = concat($pb_pts,data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    $fn = $pb_fn; $fa = $pb_fa; $fs = $pb_fs;
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

//  Adds multiple points to form a circle segment from the last point to absolute point x,y with given radius
//  An error is shown if the radius is less than half the distance between the two points.
//  You can flip the circle segment inside out by changing the radius to negative
module Segment(x, y, r){
    args = is_num(x)? [x,y,r] : is_num(r)? concat(x, r) : x;
    data = _pb_segment(pb_last($pb_pts), args, false);
    $pb_pts = concat($pb_pts,data[0]);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    $fn = $pb_fn; $fa = $pb_fa; $fs = $pb_fs;
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

function _pb_angle(args, rel=false, angle) = [[],[], rel? angle + args[0] : args[0],[[],[]]];

module angle(a){
    data =_pb_angle([a], true, $pb_angle);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

module Angle(a){
    data = _pb_angle([a],false, $pb_angle);
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

//  Inserts a fillet at the current point with the given radius and optional fixed number of segments. set radius to negative to turn the fillet outwards
function _pb_fillet(pts, args=[], angle) = [[],args[0]==0? [] : [[2, len(pts)-1, args[0], args[1]? args[1] : $fn]],angle];
module fillet(r, s){
    data = _pb_fillet($pb_pts, [r, s], $pb_angle);
    $pb_post = concat($pb_post, data[1]);  //  fillet tag
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

//  Inserts a chamfer with size s on this point
function _pb_chamfer(pts, args=[], angle) = [[],args[0]==0? [] : [[3,len(pts)-1, args[0]]],angle,[[],[]]];
module chamfer(s){
    data = _pb_chamfer($pb_pts, [s],$pb_angle);
    $pb_post = concat($pb_post, data[1]);  //  chamfer tag
    $pb_angle = data[2];
    $pb_ctrl_pts = data[3];
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();  
}

//  Draws the final shape of $pb_pts as a polygon
module pb_draw(){
    data1 = [$pb_pts, concat($pb_post, [[4,len($pb_pts)-1]])];
    points1 = pb_postProcessPathLists([data1]);
    polygon(points1[0]);
    //if (pb_do_render($children, parent_module(0))) pb_draw();
    children();      
}

module print(index = 0){
    data1 = [$pb_pts, concat($pb_post, [[4,len($pb_pts)-1]])];
    points1 = pb_postProcessPathLists([data1]);
    echo("**********************************");
    echo(str("print Points: ", points1[index]));
    echo("**********************************");
    if (pb_do_render($children, parent_module(0))) pb_draw();
    children();   
}

//  Draws the final shape of $pb_pts as a polygon
function points() = let(
        data1 = [$pb_pts, concat($pb_post, [[4,len($pb_pts)-1]])],
        points1 = pb_postProcessPathLists([data1])
    ) points1[0];
