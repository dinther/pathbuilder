use <pathbuilder.scad>
use <meshbuilder.scad>
use <pointUtils.scad>

function rotateAroundZ(x, y, z, angle) = let (
    c = cos(angle),
    s = sin(angle),
    nx = (c * x) + (s * y),
    ny = (c * y) - (s * x)) [nx, ny, z];

module taperedScrew(startRadius = 5, endRadius = 2, angle = 0, pitch=2, threadHeightStart=1.5, threadHeightEnd=0.1){
    segmentsPerCircle = pb_segmentsPerCircle(startRadius);
    zStep = pitch / segmentsPerCircle;
    steps = angle / 360 * segmentsPerCircle;
    angleStep = angle / steps;
    radiusStep = (endRadius - startRadius) / steps;
    treadStep =  (threadHeightEnd - threadHeightStart) / steps;
    pl = [for (i=[0:steps])
        rotatePoints(pts=translatePoints(circlePoints(r=threadHeightStart+(i*treadStep), z=0, $fn=6),[startRadius+(i*radiusStep),0,0]), angles=[0,0,i * angleStep], z_offset = i * zStep)
    ];
    echo(pl[1]);
    union(){
        buildMeshFromPointLayers(pl, true, true,true, true, true);
        cylinder(h = steps * zStep, r1=startRadius, r2=endRadius);
    }
    
}

taperedScrew(startRadius=5, endRadius = 0.1, angle=360 * 10, pitch=4, threadHeightStart=1.0, threadHeightEnd=0.1, $fn=128);
