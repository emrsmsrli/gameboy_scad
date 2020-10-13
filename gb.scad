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

floor_z = -13.01;
screw_z = -14;

rpi_base_x = -44.5;
rpi_base_y = 19;
rpi_h = 56;
rpi_w = 65;

// bottom right fillet
module br_filleted_cube(size, r=25) {
    difference() {
        cube(size, center=true);
        translate([size[0]/2, -size[1]/2, -2.5])
            interior_fillet(l=size[2]+5.2, r=r, orient=ORIENT_Z_90);
    }
}

module br_interior_filleted_cube(size, r=25, interior_fillet_r=2.5) {
    difference() {
        br_filleted_cube(size, r);
        translate([size[0]/2, size[1]/2])
            interior_fillet(l=size[2], r=interior_fillet_r, orient=ORIENT_Z_180);
        translate([-size[0]/2, -size[1]/2])
            interior_fillet(l=size[2], r=interior_fillet_r, orient=ORIENT_Z);
        translate([-size[0]/2, size[1]/2])
            interior_fillet(l=size[2], r=interior_fillet_r, orient=ORIENT_Z_270);
    }
}

module rounded_cube(size, diameter) {
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

module audio_jack() {
    rotate(90, [1, 0, 0])
        cylinder(d=6, h=4);
}

module typec_hole() {
    difference() {
        cube([4, 10, 4]);
        translate([2, 0, 0]) fillet_mask_x(l=4, r=1);
        translate([2, 10, 0]) fillet_mask_x(l=4, r=1);
        translate([2, 10, 4]) fillet_mask_x(l=4, r=1);
        translate([2, 0, 4]) fillet_mask_x(l=4, r=1);
    }
}

module bolt(size, x=0, y=0) {
    translate([x, y, screw_z])
    rotate(180, [1, 0, 0])
        cylinder(d=size, h=10, center=true);
        //#metric_bolt(headtype="round", size=size, details=false, coarse=false);
}

module bolt_stand(h, d, x=0, y=0) {
    translate([x, y, floor_z])
        cylinder(h=h + .01, d=d + 1);
}

module gb_base() {
    difference() {
        bottom_half(s=200)
        color("DarkSlateGray")
            rounded_cube([105, 170, 30], 7.5);

        // 2x2x2mm walls
        // 1x2mm additional interior walls
        br_interior_filleted_cube([101, 166, 26], r=27);
        br_interior_filleted_cube([103, 168, 4], r=28);
    }
}

difference() {
    union() {
        gb_base();

        rpi_pos = [rpi_base_x, rpi_base_y, floor_z];
        // rpi
        *%translate(rpi_pos)
            cube([rpi_w, rpi_h, 1]);
        // rpi+lcd
        *%translate(rpi_pos)
            cube([84, rpi_h, 25]);
        // battery
        *%translate([-48, -80, floor_z])
            cube([75, 23, 20]);

        // typec stand (5mm gap to wall)
        translate([30, -36, floor_z])
            cube([16, 12, 1]);

        // audio jack stand (originally 2 mm from floor)
        translate([26, 71, floor_z])
            cube([8, 10, 1]);

        // m2.5 stands 
        union() {
            bolt_stand(h=1, d=2.5, x=rpi_base_x + 3.5, y=rpi_base_y + 3.5);
            bolt_stand(h=1, d=2.5, x=rpi_base_x + 3.5, y=rpi_base_y - 3.5 + rpi_h);
            bolt_stand(h=1, d=2.5, x=rpi_base_x - 3.5 + rpi_w, y=rpi_base_y + 3.5);
            bolt_stand(h=1, d=2.5, x=rpi_base_x - 3.5 + rpi_w, y=rpi_base_y - 3.5 + rpi_h);
        }
    }

    translate([-50.5 + .01, -2, -9.5])
        onoffswitch_hole();

    translate([49.6, -35, -11.5])
        typec_hole();

    translate([30, 170 / 2 + .5, floor_z + 5])
        audio_jack();

    // m3 bolts 
    union() {
        bolt(size=3, x=-40, y=-10);
        bolt(size=3, x=40, y=-5);
        bolt(size=3, x=-40, y=-50);
        bolt(size=3, x=40, y=-55);
    }

    // m2.5 bolts 
    union() {            
        bolt(size=2.5, x=rpi_base_x + 3.5, y=rpi_base_y + 3.5);
        bolt(size=2.5, x=rpi_base_x + 3.5, y=rpi_base_y - 3.5 + rpi_h);
        bolt(size=2.5, x=rpi_base_x - 3.5 + rpi_w, y=rpi_base_y + 3.5);
        bolt(size=2.5, x=rpi_base_x - 3.5 + rpi_w, y=rpi_base_y - 3.5 + rpi_h);
    }
}

// todo on-off switch cover
// todo stands
//  - regulator
// todo button holders
// todo lcd screen hole
// todo button holes
// todo add back buttons


