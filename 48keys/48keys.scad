use <../common.scad>;
$fn = 20;

render_case = true;
render_hull = false;
render_cutouts = true;
render_surround = true;
render_inserts = true;
render_dummies = false;
render_controller = false;

hole_size = 14.1;
socket_ledge = 1.5;
tenting_angle = 3;
half_spec = [
    [-3, [1, 1, 1]],
    [0, [1, 1, 1]],
    [-0.25, [1, 1, 1, 1]],
    [0.25, [1, 1, 1, 1]],
    [0.5, [1, 1, 1, 1]],
    [0.25, [1, 1, 1]]
];

pin_spacing = 2.54;
pins_per_side = 13;
pin_row_spacing = 6;
controller_board_thickness = 1.6;
usb_thickness = 3.2;
controller_size = [
    (pin_row_spacing + 1) * pin_spacing,
    pins_per_side * pin_spacing,
    controller_board_thickness + usb_thickness
];
battery_size = [40, 22, 7];

module half_hand_block() {
    columns(half_spec)
        translate([-15, -14, -10])
            difference() {
                cube([29, 28, 17]);
                translate([-2, -1, -1])
                    rotate([0, tenting_angle, 0])
                    cube([3, 30, 19]);
            }
}

module half_hand() {
    union() {
        // Matrix sockets.
        difference() {
            union() {
                columns(half_spec)
                    translate([-10.5, -10.5, 0]) cube([21, 21, 4]);
            }
            if (render_cutouts) {
                columns(half_spec)
                    translate([0, 0, -0.01])
                    basic_socket_negative(
                        hole = hole_size,
                        ledge = socket_ledge,
                        thickness = 4.02
                    );
            }
        }
        // Surround.
        if (render_surround) {
            difference() {
                if (render_hull) {
                    hull() half_hand_block();
                } else {
                    union() {
                        half_hand_block();
                        // Mounting insert positives.
                        if (render_inserts) {
                            translate([-89.7, -27.4, -10])
                                difference() {
                                    rotate([0, 0, 45]) cube([12, 12, 17]);
                                    translate([0, -4, -1])
                                        rotate([0, tenting_angle, 0])
                                        rotate([0, 0, 45])
                                        cube([3, 20, 20]);
                                }
                            translate([-81.98, 49.5, -10])
                                difference() {
                                    cube([12, 12, 17]);
                                    translate([-1, 0, -1])
                                        rotate([0, tenting_angle, 0])
                                        rotate([0, 0, 45])
                                        cube([20, 20, 20]);
                                }
                        }
                    }
                }
                columns(half_spec)
                    translate([-10.25, -10.25, -11]) cube([20.5, 20.5, 22]);
                translate([7, 0, -10.01]) cube([10, 19 * 3, 10.01]);
            }
        }
    }
    // Dummy switches.
    if (render_dummies) {
        columns(half_spec) switch_dummy();
    }
}

module thumbs() {
    thumb_spec = [
        [0, [1.5]],
        [0, [1.5]],
        [0, [1.5]]
    ];
    union() {
        // Thumb sockets.
        difference() {
            translate([0, 0, 2])
                cube([19 * 3 + 2, 19 * 1.5 + 2, 4], center = true);
            if (render_cutouts) {
                translate([19, 19 * 1.5 / 2, 0])
                    columns(thumb_spec)
                    translate([0, 0, -0.01])
                    basic_socket_negative(
                        hole = hole_size,
                        ledge = socket_ledge,
                        thickness = 4.02
                    );
            }
        }
        // Surround.
        if (render_surround) {
            difference() {
                union() {
                    cube([19 * 3 + 9, 19 * 1.5 + 9, 14], center = true);
                    if (render_hull) {
                        translate([19 * -1.5 - 42, -12.5, -2])
                            rotate([0, 0, -5])
                            cube([40, 19 * 1.5 + 6, 9]);
                    }
                }
                cube([19 * 3 + 1.5, 19 * 1.5 + 1.5, 15], center = true);
                translate([0, 19 * 0.75, -4])
                    cube([19 * 3, 10, 8], center = true);
                translate([19 * -1.5 - 42, -12.5, -3])
                    rotate([0, 0, 20])
                    cube([40, 19 * 1.5 + 6, 12]);
                translate([19 * -2 - 4, 3, -3])
                    cube([10, 20, 12]);
            }
        }
        // Dummy switches.
        if (render_dummies) {
            translate([19, 19 * 0.75, 0])
                columns(thumb_spec)
                switch_dummy(cap = [18.25, 19 * 1.5 - 0.75, 4]);
        }
    }
}

module half_array() {
    difference() {
        // main array.
        translate([19 * -2, 0, 8])
            rotate([0, -tenting_angle, -10])
            half_hand();
        // Cutout for thumbs.
        translate([19 * -2 + 1, 19 * -0.75 - 4.5, 0])
            rotate([0, 0, -10])
            union() {
                cube([19 * 3 + 0.2, 19 * 1.5, 34], center = true);
                translate([0, 19 * 0.75, -6])
                    cube([19 * 3, 10, 16], center = true);
            }
    }
    // Thumbs.
    translate([19 * -2 + 0.9, 19 * -0.75 - 4.45, 2])
        rotate([0, 0, -10])
        translate([0.75, -0.75, 0])
        thumbs();
}

if (render_case) {
    difference() {
        union() {
            half_array();
            scale([-1, 1, 1]) half_array();
            // Gap filling.
            difference() {
                // Main positive.
                translate([0, 6.6, 5])
                    cube([63, 102.1, 17], center = true);
                // Left and right thumb cutouts.
                translate([19 * -2, 19 * -1.25 - 0.65, 10])
                    rotate([0, 0, -10])
                    cube([19 * 3 + 3.75, 19 * 2 + 2, 30], center = true);
                translate([19 * 2, 19 * -1.25 - 0.65, 10])
                    rotate([0, 0, 10])
                    cube([19 * 3 + 3.75, 19 * 2 + 2, 30], center = true);
                // Thumb center cutout.
                translate([0, -27.7, 14])
                    cube([30, 36, 10], center = true);
                // Left and right side cutouts.
                rotate([0, 0, -10])
                    translate([19 * -2.5 + 1.5, 19 * 1.65, 10])
                    cube([19 * 2, 19 * 4, 20.02], center = true);
                rotate([0, 0, 10])
                    translate([19 * 2.5 - 1.5, 19 * 1.65, 10])
                    cube([19 * 2, 19 * 4, 20.02], center = true);
                translate([-8, -45.66, 8])
                    rotate([0, 0, -10])
                    cube([10, 4, 20], center = true);
                translate([8, -45.66, 8])
                    rotate([0, 0, 10])
                    cube([10, 4, 20], center = true);
                // Center cavity.
                translate([-35, -1.5, -1])
                    cube([70, 55.75, 12.5]);
                translate([-23, -5, -1])
                    cube([46, 20, 12.5]);
                translate([-35, -12, -1])
                    cube([70, 12, 3]);
                // MCU cavity.
                translate([controller_size[0] / -2 - 1, 19.25, 7])
                    cube([
                        controller_size[0] + 2,
                        controller_size[1] + 7,
                        controller_size[2] + 2.5
                    ]);
                translate([0, 54, 3])
                    cube([10, 3, 3], center = true);
            }
            // Left MCU socket bracket.
            translate([pin_row_spacing / -2 * pin_spacing, 37.6, 4])
                socket_rail(pin_spacing = pin_spacing);
            translate([pin_row_spacing / -2 * pin_spacing, 18, 8.75])
                cube([pin_spacing + 4, 2.5, 9.5], center = true);
            // Right MCU socket bracket.
            translate([pin_row_spacing / 2 * pin_spacing, 37.6, 4])
                socket_rail(pin_spacing = pin_spacing);
            translate([pin_row_spacing / 2 * pin_spacing, 18, 8.75])
                cube([pin_spacing + 4, 2.5, 9.5], center = true);
            // Center socket fill.
            translate([0, 32, 5.5])
                cube([
                    (pin_row_spacing - 1) * pin_spacing - 0.5,
                    (pins_per_side - 1) * pin_spacing,
                    3
                ], center = true);
        }
        // Mounting insert holes.
        if (render_inserts) {
            translate([130, -3, -0.1]) insert_hole();
            translate([-130, -3, -0.1]) insert_hole();
            translate([99, 64, -0.1]) insert_hole();
            translate([-99, 64, -0.1]) insert_hole();
            translate([0, -30, -0.1]) insert_hole();
        }
        // Flatten the bottom.
        translate([-150, -75, -20])
            cube([300, 150, 20]);
    }
}

if (render_controller) {
    translate([controller_size[0] / -2, 21, 9])
        cube(controller_size);
    translate([battery_size[0] / -2, -4, 3])
        cube(battery_size);
}