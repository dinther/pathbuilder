include <pathbuilder.scad>

//  laser cut bracket before folding
pb_yield ="m0 0fillet3v30fillet3h17a2.3 2.3 0 1 1 3 3v17fillet9h60fillet9v-17a2.3 2.3 0 1 1 3-3h60chamfer10V0chamfer10z";

$fa=6;                  //  new segment when angle reaches 6 degrees
$fs=0.4;                //  don't make a new segment when it is smaller than 0.4 units

//  Have a look and see what is going on inside.
//  normally you would just call: svgShape(pb_yield);
//  but here we pull the steps apart to show what goes on.

//  parse the command string and make sense of them.
cmds = pb_tokenizeSvgPath(pb_yield);

echo("************tokenized commands************");
for (c=cmds) echo(c);

//  process the commands into a list of shape data. Each shape consists of a point list and a list of post processing commands.
shape_list = pb_processCommands(cmds);
shape1 = shape_list[0];

echo("************post processing commands************");
for (p=shape1[1]){
    echo(p,
        p[0]==0? str("start   index:", p[1]) :
        p[0]==2? str("fillet  index:", p[1], " radius:", p[2]) :
        p[0]==3? str("chamfer index:", p[1], " size:", p[2]) :
        p[0]==4? str("end     index:", p[1]) : 
        str("error ",p[0]," unknown")
    );
}
//  This yellow shape is what we know before post processing.
//  Fillets and chamfers are not yet applied.
translate([0,0,-1]) color("yellow") linear_extrude(1) polygon(shape1[0]);

//  apply the post processing steps
pts = pb_postProcessPathLists(shape_list)[0];

//  The final result
color("red") linear_extrude(1) polygon(pts);
