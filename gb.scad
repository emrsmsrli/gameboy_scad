include <BOSL/constants.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>
use <BOSL/masks.scad>
use <BOSL/constants.scad>
use <BOSL/metric_screws.scad>

// % render debug only
// # also debug render
// * ignore everything
// ! isolate and render

$fa = 1;
// model resolution (lower the better)
$fs = .1;
// fragment resolution (higher the better)
$fn = 20;

floor_z = -9.51;
screw_z = -11.5;

// bottom right fillet
module br_filleted_cube(size, r=25) {
    difference() {
        cube(size, center=true);
        translate([size[0]/2, -size[1]/2, -2.5])
            interior_fillet(l=size[2]+5.2, r=r, orient=ORIENT_Z_90);
    }
}

module rounded_cube(size, diameter, center=false) {
    minkowski() {
        br_filleted_cube([size[0] - diameter, size[1] - diameter, size[2] - diameter]);
        sphere(d=diameter);
    }
}

module onoffswitch_hole() {
    // z is actually 6mm
    // other side of the gb 
    // should pin the switch here
    cube([6, 13, 7]);
    translate([-6, 3, 1])
        cube([6, 7, 4]);
}

module bolt(size, x = 0, y = 0) {
    translate([x, y, screw_z])
    rotate(180, [1, 0, 0])
        metric_bolt(headtype="round", size=size, details=false, coarse=false);
}

union() {
    difference() {
        bottom_half(s=200)
        color("DarkSlateGray")
            rounded_cube([105, 170, 25], 7.5, center=true);
        // 3.5 x 3.5 x 3mm walls
        // 1mm additional interior walls
        br_filleted_cube([98, 163, 19]);
        br_filleted_cube([100, 165, 6.5]);

        #translate([-50, 0, floor_z])
            onoffswitch_hole();

        // m3 bolts 
        *union() {
            bolt(size=3, x=-40, y=-5);
            bolt(size=3, x=40, y=-5);
            bolt(size=3, x=-40, y=-55);
            bolt(size=3, x=40, y=-55);
        }

        // m2.5 bolts 
        *union() {
            bolt(size=2.5, x=-52.5 + 8 + 3.5, y=85 - 10 - 56 + 3.5);
            bolt(size=2.5, x=-52.5 + 8 + 3.5 + 58, y=85 - 10 - 56 + 3.5 + 49);
        }
    }

    // rpi
    %translate([-52.5 + 8, 85 - 10 - 56, floor_z])
        cube([65, 56, 1]);
    
    // todo on-off switch cover
    // todo stands 
    //  - 3.5mm jack
    //  - regulator
    //  - charger
    // todo button holders
}


