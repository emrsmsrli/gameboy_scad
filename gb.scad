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

union() {
    difference() {
        bottom_half(s=200)
        color("DarkSlateGray")
            rounded_cube([105, 170, 25], 7.5, center=true);
        // 3.5 x 3.5 x 3mm walls
        // 1mm additional interior walls
        br_filleted_cube([98, 163, 19]);
        br_filleted_cube([100, 165, 6.5]);

        #translate([-50, 15, floor_z])
            onoffswitch_hole();
    }
}


