use <pathbuilder.scad>
use <offset.scad>

//  Examples
//
//  400mm vslot 4040 profile
//  vslot4040(400);
//
//  Cap
//  vslot4040Cap(4, centerHoleDiameter=10, insertLength=4, bolt_recess=2, $fn=32);
//
//  Internal slider

module vslot4040_outer(offset = 0, filletRadius = 1){
    fr = str(filletRadius);
    p = str("M-14.66955,20 l1.7,-1.7 v-0.61h -2.4 v-1.6l 2.37,-2.37 h5.99921 l2.37,2.37 v1.6 h-2.4 v0.61 l1.7,1.7 h10.6609 l1.7,-1.7 v-0.61 h-2.4 v-1.6 l2.37,-2.37 h5.99921 l2.37,2.37 v1.6 h-2.4 v0.61 l1.7,1.7 h5.33045 fillet ", fr, " v-5.33045 l-1.7,-1.7 h-0.61 v2.4 h-1.6 l-2.37,-2.37 v-5.99921 l2.37,-2.37 h1.6 v2.4 h0.61 l1.7,-1.7 v-10.6609 l-1.7,-1.7 h -0.61 v2.4 h-1.6 l-2.37,-2.37 v-5.99921 l2.37,-2.37 h1.6 v2.4 h0.61 l1.7,-1.7 v-5.33045 fillet ", fr, " h-5.33045 l-1.7,1.7 v0.61 h2.4 v1.6 l-2.37,2.37 h-5.99921 l-2.37,-2.37 v-1.6 h2.4 v-0.61 l-1.7,-1.7 h-10.6609 l-1.7,1.7 v0.61 h2.4 v1.6 l-2.37,2.37 h-5.99921 l-2.37,-2.37 v-1.6 h2.4 v-0.61 l-1.7,-1.7 h-5.33045 fillet ", fr, " v5.33045 l1.7,1.7 h0.61 v-2.4 h1.6 l2.37,2.37 v5.99921 l-2.37,2.37 h-1.6 v-2.4 h-0.61 l-1.7,1.7 v10.6609 l1.7,1.7 h0.61 v-2.4 h1.6 l 2.37,2.37 v5.99921 l-2.37,2.37 h-1.6 v-2.4 h-0.61 l-1.7,1.7 v5.33045 fillet ", fr);
    pts = svgPoints(p)[0];
    pts1 = (len(pts) > 1 && pts[0][0] == pts[len(pts)-1][0] && pts[0][1] == pts[len(pts)-1][1])? [for(i=[0:len(pts)-2]) pts[i]] : pts;
    pts2 = offset== 0? pts1 : offset_pts(pts1, -offset);
    polygon(pts2);
}

module vslot4040_inner(offset=0){
    p = "M-12.91,6.1 h6.91 chamfer1.2 v6.91 l3.58,3.58 h5.04 l3.58,-3.58 v-6.91 chamfer1.2 h6.91 l3.58,-3.58 v-5.04 l-3.58,-3.58 h-6.91 chamfer1.2 v-6.91 l-3.58,-3.58 h-5.04 l-3.58,3.58 v6.91 chamfer1.2 h-6.91 l-3.58,3.58 v5.04";
    pts = svgPoints(p)[0];
    pts1 = (len(pts) > 1 && pts[0][0] == pts[len(pts)-1][0] && pts[0][1] == pts[len(pts)-1][1])? [for(i=[0:len(pts)-2]) pts[i]] : pts;
    pts2 = offset== 0? pts1 : offset_pts(pts1, -offset);
    polygon(pts2);
}

module vslot4040(length, filletRadius = 1){
    linear_extrude(length)
    difference(){
        vslot4040_outer(filletRadius);
        vslot4040_inner(0);
        translate([10,10]) circle(d=4.6);
        translate([10,-10]) circle(d=4.6);
        translate([-10,10]) circle(d=4.6);
        translate([-10,-10]) circle(d=4.6);
    }
}

module vslot4040Cap(height, centerHoleDiameter = 0, insertLength=0, innerOffset=-0.2, bolt_recess=0, width = 40, length=40, filletRadius = 1){
    difference(){
        union(){
            linear_extrude(height)
            M(-width * 0.5, -length * 0.5)
            fillet(filletRadius)
            h(width)
            fillet(filletRadius)
            v(length)
            fillet(filletRadius)
            h(-width)
            fillet(filletRadius);
            if (insertLength > 0){
                translate([0,0,height]) linear_extrude(insertLength) vslot4040_inner(offset = innerOffset);
            }
        }
        
        //  bolt holes
        translate([-10,-10,-1]) cylinder(d=5.1, h=height+2);
        translate([10,-10,-1]) cylinder(d=5.1, h=height+2);
        translate([-10,10,-1]) cylinder(d=5.1, h=height+2);
        translate([10,10,-1]) cylinder(d=5.1, h=height+2);
        
        if (bolt_recess>0){
            translate([-10,-10,-1]) cylinder(d=9, h=bolt_recess+1);
            translate([10,-10,-1]) cylinder(d=9, h=bolt_recess+1);
            translate([-10,10,-1]) cylinder(d=9, h=bolt_recess+1);
            translate([10,10,-1]) cylinder(d=9, h=bolt_recess+1);
        }
        
        
        if (centerHoleDiameter> 0){
            translate([0,0,-1]) cylinder(d=centerHoleDiameter, h=height + insertLength+2);
        }

    }
}



