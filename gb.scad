include <BOSL/constants.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>
use <BOSL/masks.scad>
use <BOSL/constants.scad>
use <BOSL/metric_screws.scad>

// # debug draw
// * ignore
// ! isolate

$fa = 1;
// model resolution (lower the better)
$fs = .1;
// fragment resolution (higher the better)
$fn = 20;

// bottom right fillet
module br_filleted_cube(size, r=25) {
    difference() {
        cube(size, center=true);
        translate([size[0]/2, -size[1]/2, -2.5])
            interior_fillet(l=size[2]+5, r=r, orient=ORIENT_Z_90);
    }
}

module gb_corner_mask(target_size, diameter, center=true) {
    translate([
        -target_size[0] / 2, 
        -target_size[1] / 2])
    difference() {
        cube([diameter, diameter, target_size[2] + .02], center);
        translate([-diameter / 2, -diameter / 2, -target_size[2] / 2 - .02])
            cylinder(h=target_size[2] + .02 + .02, d=diameter);
    }
}

module rounded_cube(size, diameter, center=false) {
    minkowski() {
        br_filleted_cube([size[0] - diameter, size[1] - diameter, size[2] - diameter]);
        sphere(d=diameter);
    }
}

difference() {
    bottom_half(s=200)
    color("DarkSlateGray")
        rounded_cube([105, 170, 25], 7.5, center=true);
    // 3mm walls
    // 3x1mm interior wall
    br_filleted_cube([99, 164, 19]);
    br_filleted_cube([100, 165, 6]);
}



