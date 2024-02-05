use <pathbuilder.scad>
use <meshbuilder.scad>
use <pointUtils.scad>

$fn=8;

module taperedScrew(startRadius = 5, endRadius = 2, angle = 0, pitch=2, threadDepthStart=1.5, threadDepthEnd=0.1, threadShapeRatio=0.5){
    segmentsPerCircle = pb_segmentsPerCircle(startRadius);
    zStep = pitch / segmentsPerCircle;
    steps = angle / 360 * segmentsPerCircle;
    angleStep = angle / steps;
    radiusStep = (endRadius - startRadius) / steps;
    threadDepthStep =  (threadDepthEnd - threadDepthStart) / steps;
    pl = [for (i=[0:steps]) let(h=threadDepthStart+(i*threadDepthStep))
        rotatePoints(pts=translatePoints([[0, 0, 0], [radiusStep*segmentsPerCircle, 0, h*threadShapeRatio], [h, 0, h*threadShapeRatio*0.5], [0, 0, 0]],[startRadius+(i*radiusStep),0,0]), angles=[0,0,i * angleStep], z_offset = i * zStep)
    ];
    echo(pl[1]);
    union(){
        buildMeshFromPointLayers(pl, true, true,true, true, true);
        cylinder(h = steps * zStep, r1=startRadius, r2=endRadius);
    }
    
}

taperedScrew(startRadius=5, endRadius = 0.5, angle=360 * 10, pitch=4, threadDepthStart=1.0, threadDepthEnd=0.0, threadShapeRatio=1, $fn=8);
