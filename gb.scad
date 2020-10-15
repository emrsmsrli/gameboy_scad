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

button_holder_x_offset = 25.5;
button_holder_total_height = 21;

module cube_corner_mask(r) {
    difference() {
        cube(r, center=true);
        translate([r/2, 0, r/2]) ycyl(r=r,h=r);
        translate([0, r/2, r/2]) xcyl(r=r,h=r);
    }
}

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

module br_filleted_rounded_cube(size, diameter) {
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

module button_stand(x, y) {
    h = button_holder_total_height;
    d = 20;
    difference() {
        union() {
            translate([x, y, floor_z]) cylinder(d=d, h=h - 3);
            translate([x, y, floor_z + h - 3]) cylinder(h=2,d1=d,d2=d + 2);
            translate([x, y, floor_z + h - 1]) cylinder(h=1,d=d + 2);
        }
        translate([x, y, floor_z]) cylinder(h=h+.01,d=d - 2);
    }
}

module button_dpad() {
    union() {
        // pcb
        %translate([-35/2, -35/2]) cube([35, 35, 1]);

        // conductive cover
        %translate([0, 0, 1]) cylinder(d=30, h=2);
        %for(angle = [0:90:270]) {
            x = 35/4*cos(angle);
            y = 35/4*sin(angle);
            translate([x, y, 3])
                cylinder(d=5, h=1);
        }

        // button floor and buttons
        translate([0, 0, 4]) cylinder(d=26, h=1);
        translate([0, 0, 7]) cube([24, 8, 4], center=true);
        translate([0, 0, 7]) cube([8, 24, 4], center=true);
    }
}

module button_a_b() {
    module button(dir) {
        %translate([dir * 7.5, 0, 0]) cylinder(d=14, h=2);
        %translate([dir * 7.5, 0, 2]) cylinder(d=6, h=4);
        translate([dir * 7.5, 0, 3])
        union() {
            cylinder(d=11, h=5);
            rotate(-30, [0, 0, 1])
            translate([-7.5, -1])
                cube([15, 2, 1]);
        }
    }

    union() {
        // pcb
        %translate([-35/2, -35/2]) cube([35, 35, 1]);

        rotate(30, [0, 0, 1])
        translate([0, 0, 1])
        union() {
            button(-1);
            button(1);
        }
    }
}

module button_start_select() {
    module cyl_cube(size) {
        assert(size[0] > size[1]);
        hull() {
            translate([-size[0]/2+size[1]/2, 0, 0]) cylinder(d=size[1], h=size[2]);
            translate([size[0]/2-size[1]/2, 0, 0]) cylinder(d=size[1], h=size[2]);
        }
    }

    difference() {
        union() {
            // pcb
            %translate([-30/2, -20/2]) cube([30, 20, 1]);

            /* chasis */
            translate([0, 0, 1]) cyl_cube([33, 11, 1]);
            translate([-10.5, 5.5, 1]) cube([21, 2, 2]);
            translate([-10.5, -7.5, 1]) cube([21, 2, 2]);

            translate([0, 7, 1-.01]) cylinder(d=8, h=2);
            /* chasis */

            // buttons
            offs = 3;
            translate([-offs - 5, 0, 2-.01]) cyl_cube([10, 4, 8]);
            translate([offs + 5, 0, 2-.01]) cyl_cube([10, 4, 8]);
        }

        /* chasis */
        translate([0, 7, -.02]) cylinder(d=6, h=5);
        translate([-10.5, 2.5, 2.01]) cube([21, 3, 1]);
        /* chasis */
    }
}

module bolt(size, x=0, y=0) {
    translate([x, y, screw_z])
    rotate(180, [1, 0, 0])
        #screw(screwsize=size, screwlen=10, headlen=2, countersunk=false);
}

module bolt_stand(h, d, x=0, y=0) {
    translate([x, y, floor_z])
        cylinder(h=h + .01, d=d + 1);
}

module front_bolt_stand(x=0, y=0) {
    difference() {
        bolt_stand(h=11, d=4, x=x, y=y);
        #translate([x, y, -2]) screw(screwsize=3, screwlen=7, headlen=15, countersunk=false);
    }
}

module push_button(base=6, h=1) {
    rotate(270, [1, 0, 0])
    union() {
        translate([0, 0, 1.75]) cube([base, base, 3.5], center=true);
        translate([0, 0, 3.5]) cylinder(d=3, h=h);
    }
}

module push_button_socket(depth=3) {
    translate([-4, -4, -3]) cube([1, depth, 9]);
    translate([3, -4, -3]) cube([1, depth, 9]);
    translate([-4, -4, -3]) cube([8, depth, 1]);
}

module back_button() {
    h = 4;
    union() {
        difference() {
            union() {
                 translate([-10, 0, -4]) cube([20, 1, 8]);
                 translate([0, 3, 0]) cuboid([18, h, 8], fillet=1.5, edges=EDGES_BACK);
            }
            translate([-8, 0, -3]) cube([16, h, 6]);
        }
        difference() {
            rotate(90, [1, 0, 0]) translate([0, 0, -h]) cylinder(d=3, h=h);
            rotate(90, [1, 0, 0]) translate([0, 0, -h]) cylinder(d=1, h=h);
        }
    }
}

module back_button_holder() {
    *translate([0, 0, .5])
        union() {
            translate([-12, -4, 0]) %push_button(h=1.5);
            translate([12, -4, 0]) %push_button(h=1.5);
            translate([-12, 3, 0]) %back_button();
            translate([12, 3, 0]) %back_button();
        }

    union() {
        difference() {
            cuboid([50, 10, 12], fillet=2, edges=EDGES_BOTTOM + EDGES_Z_ALL);
            translate([0, 0, 2.5])
                cuboid([44, 8, 12], fillet=0);

            translate([-12, 4.5, .75]) cube([18.5, 3, 8.5], center=true);
            translate([12, 4.5, .75]) cube([18.5, 3, 8.5], center=true);
        }

        translate([12, 0, -.5]) push_button_socket();
        translate([-12, 0, -.5]) push_button_socket();
        translate([1, 2, -3.5]) cube([1, 2, 9]);
        translate([-2, 2, -3.5]) cube([1, 2, 9]);
    }
}

module gb_base(is_bottom) {
    difference() {
        union() {
            bottom_half(s=200)
            color("DarkSlateGray")
                br_filleted_rounded_cube([105, 170, 30], 7.5);

            if(!is_bottom) {
                br_interior_filleted_cube([103, 168, 3], r=28);
            }
        }

        // 2x2x2mm walls
        // 1x2mm additional interior walls
        br_filleted_rounded_cube([101, 166, 26], 2.5);
        if(is_bottom) {
            br_interior_filleted_cube([103, 168, 4], r=28);
        }
    }
}

translate([55, 0, 27])
difference() {
    union() {
        gb_base(true);

        rpi_pos = [rpi_base_x, rpi_base_y, floor_z + 1];
        // rpi
        *%translate(rpi_pos)
            cube([rpi_w, rpi_h, 1]);
        // rpi+lcd
        *%translate(rpi_pos)
            cube([84, rpi_h, 25]);
        // battery
        *%translate([-48, -80, floor_z])
            cube([75, 23, 20]);
        // ceiling
        *%translate([-105/2, -170/2, floor_z + 26])
            cube([105, 170, 1]);

        translate([0, 9, -20.99])
            back_button_holder();

        // on-off holder
        translate([-50.5, -4, -9.5]) cube([6, 2, 7]);
        translate([-50.5, 11, -9.5]) cube([6, 2, 7]);
        translate([-44.5, 13, -9.5]) rotate(90, [1,0,0]) right_triangle([2, 7, 3]);
        translate([-44.5, -4, -2.5]) rotate(270, [1,0,0]) right_triangle([2, 7, 3]);
        translate([-50.5, -4, floor_z]) cube([1, 17, 3.51]);
        translate([-47.5, -4, floor_z]) cube([1, 17, 3.51]);
        translate([-44.5, -4, floor_z]) cube([1, 17, 3.5]);

        // buttons & holders
        union() {
            // buttons
            y = -10;
            *union() {
                translate([-button_holder_x_offset, y, floor_z + button_holder_total_height])
                    button_dpad();

                translate([button_holder_x_offset, y, floor_z + button_holder_total_height])
                    button_a_b();

                translate([0, y - 33, floor_z + button_holder_total_height])
                    button_start_select();
            }

            button_stand(-button_holder_x_offset, y);
            button_stand(button_holder_x_offset, y);
            button_stand(0, y - 33);
        }

        // stands
        union() {
            // typec stand (5mm gap to wall)
            translate([30, -36, floor_z])
                cube([16, 12, 1]);

            // audio jack stand (originally 2 mm from floor)
            translate([26, 71, floor_z])
                cube([8, 10, 1]);

            // regulator stand
            translate([-27, -43, floor_z])
            rotate(30, [0, 0, 1])
                cube([30, 14, 1]);
        }

        // m2.5 stands 
        union() {
            bolt_stand(h=2, d=2.5, x=rpi_base_x + 3.5, y=rpi_base_y + 3.5);
            bolt_stand(h=1, d=2.5, x=rpi_base_x + 3.5, y=rpi_base_y - 3.5 + rpi_h);
            bolt_stand(h=2, d=2.5, x=rpi_base_x - 3.5 + rpi_w, y=rpi_base_y + 3.5);
            bolt_stand(h=1, d=2.5, x=rpi_base_x - 3.5 + rpi_w, y=rpi_base_y - 3.5 + rpi_h);
        }
    }

    translate([-50.5 + .01, -2, -9.5])
        onoffswitch_hole();

    translate([49.6, -35, -11.5])
        typec_hole();

    // back button holder hole
    translate([0, 9, -14])
        cube([44, 8, 4], center=true);

    translate([30, 170 / 2 + .5, floor_z + 5])
        audio_jack();

    // m3 bolts 
    union() {
        bolt(size=3, x=-46, y=79);
        bolt(size=3, x=46, y=79);
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


translate([-55, 0, 15])
difference() {
    union() {
        mirror([1, 0, 0])
            gb_base(false);

        // a-b
        translate([-button_holder_x_offset, -10, floor_z])
        rotate(-30, [0, 0, 1])
        union() {
            translate([7.5, 0, 0]) cylinder(d=13, h=2);
            translate([-7.5, 0, 0]) cylinder(d=13, h=2);
        }

        // dpad
        translate([button_holder_x_offset, -10, floor_z]) cylinder(d=28, h=2);

        // start-select
        translate([0, -48, floor_z + 1.5]) cube([22, 1, 3], center=true);
        translate([0, -38, floor_z + 1.5]) cube([22, 1, 3], center=true);

        // m3 bolts 
        union() {
            front_bolt_stand(x=-46, y=79);
            front_bolt_stand(x=46, y=79);
            mirror([1, 0, 0]) front_bolt_stand(x=-40, y=-50);
            mirror([1, 0, 0]) front_bolt_stand(x=40, y=-55);
        }
    }

    union() {
        // buttons
        y = -10;
        rotate(180, [0, 1, 0])
        union() {
            scale([1, 1, 2])
            translate([-button_holder_x_offset, y, floor_z + button_holder_total_height - 6.5])
                #button_dpad();

            scale([1, 1, 2])
            translate([button_holder_x_offset, y, floor_z + button_holder_total_height - 6.5])
                #button_a_b();

            translate([0, y - 33, floor_z + button_holder_total_height])
                #button_start_select();
        }
    }

    // screen hole
    union() {
        translate([0, 75 - 55 / 2, floor_z]) cube([79, 55, 4], center=true);

        translate([0, 75 - 55, floor_z - 2]) fillet_mask_x(l=79, r=2);
        translate([0, 75, floor_z - 2]) fillet_mask_x(l=79, r=2);
        translate([79 / 2, 75 - 55 / 2, floor_z - 2]) fillet_mask_y(l=55, r=2);
        translate([-79 / 2, 75 - 55 / 2, floor_z - 2]) fillet_mask_y(l=55, r=2);
        
        translate([-79 / 2 - 1, 75 - 55 - 1, floor_z - 1])
        rotate(180, [0, 0, 1])
            cube_corner_mask(2);

        translate([+79 / 2 + 1, 75 - 55 - 1, floor_z - 1])
        rotate(270, [0, 0, 1])
            cube_corner_mask(2);

        translate([+79 / 2 + 1, 75 + 1, floor_z - 1])
        rotate(0, [0, 0, 1])
            cube_corner_mask(2);

        translate([-79 / 2 - 1, 75 + 1, floor_z - 1])
        rotate(90, [0, 0, 1])
            cube_corner_mask(2);
    }
}

translate([-15, 95, 5]) rotate(270, [1, 0, 0]) back_button();
translate([15, 95, 5]) rotate(270, [1, 0, 0]) back_button();
