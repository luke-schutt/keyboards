use <../common.scad>;
$fs = 0.25;


// TODO: Calculate board sizing and offsets based on key spec.
// TODO: Optional power switch cutout for Bluetooth.


/* [Options] */


// If the surround should be added around the keys.
add_surround = true;
// If the arrow keys should be added.
add_arrows = true;
// If board and surround edges should be chamfered.
chamfer = true;
// If the plate is solid, sans pin holes or square switch plate holes.
solid_plate = true;
// If mounting posts should be added.
add_mounting_posts = true;
// If microcontroller mounting posts should be added.
add_controller_posts = true;
// If the switch cutout should be added.
add_switch_cutout = true;


/* [Key specifications] */


// Key spec for each board half.
half_spec = [
    [0, [1, 1, 1]],
    [0, [1, 1, 1]],
    [-0.25, [1, 1, 1]],
    [0.25, [1, 1, 1]],
    [0.25, [1, 1, 1]]
];
// Key spec for thumbs on each half.
thumb_spec = [
    [0, [1, 1, 1]]
];
// Key spec for inverted-T arrows.
arrow_spec = [
    [0, [1]],
    [-1, [1, 1]],
    [1, [1]]
];


/* [Sizes] */


// Spacing between key centers.
spacing = [18, 17];
// Margin between the keys and surround.
margin = 1;
// Angle for each board half.
half_angle = 10;
// Gap size between halves.
gap_width = 35;

// Negative size for each key to be inserted.
key_size = 15.5;
// Negative size for each key to clip in.
clip_size = 14;
// Edge and surround chamfer size.
chamfer_size = chamfer ? 2 : 0;
// Total basic plate height.
plate_height = 2.2;
// Plate thickness where the keys clip in.
plate_thickness = 1.3;
// Additional plate thickness if the plate is solid.
plate_solid_height = 1.25;
// Margin around the plate for the component cavity.
plate_margin = margin * 2 + chamfer_size * 2 + 2;
// Z-height for the keyboard stem, if not using a solid plate.
stem_height = 3;
// Z-height for the main plate when using a solid plate.
socket_height = 3.1;
// Desired top thickness where the cavity is cutout.
top_thickness = 2;

// Offsets for positioning the halves.
half_offset = [
    (spacing[0] + gap_width) / 2,
    35.75
];
// Z-offset for positioning the plate.
plate_offset = solid_plate ? socket_height : stem_height;

// The base height for the full-bottom cavity and plate.
base_height = plate_offset + plate_height;
// Additional height for the key surround.
surround_height = 4;

// Total board width.
board_width = 244 + chamfer_size * (add_surround ? 4 : 2);
// Total board depth.
board_depth = 108 + chamfer_size * (add_surround ? 4 : 1);
// Total board height.
board_height = base_height + (add_surround ? surround_height : 0);
// Cavity cutout height.
board_cavity = board_height - top_thickness;
// Board margins before arrow keys.
board_margin = (chamfer ? 2 : 5) + chamfer_size * 2;
// Board corner radius.
board_radius = 3;

// Board insert post radius.
board_post_radius = 5;
// Board post positions.
board_post_positions = [
    [-0.5, -0.5, 1],
    [-0.5 / 3, -0.5, 1],
    [0.5 / 3, -0.5, 1],
    [0.5, -0.5, 0.42],
    [-0.5, 0.5, 1],
    [-0.5 / 3, 0.5, 1],
    [0.5 / 3, 0.5, 1],
    [0.5, 0.5, 1]
];


/* [Controller sizes] */


// Controller cutout width.
controller_cutout_size = 24;
// Controller cutout margin.
controller_cutout_margin = 0.3;
// Controller pin spacing.
pin_spacing = 2.54;

// TODO: Verify the height of a Pi Pico.
// Controller size in millimeters.
controller_size = [21, 51, 3.8];
// Controller port size.
controller_port_size = [8, 1.5, 3];
// Controller port radius.
controller_port_radius = 0.3;
// Controller mounting posts relative to the center.
controller_posts = [
    [5.7, 23.5],
    [5.7, -23.5],
    [-5.7, -23.5],
    [-5.7, 23.5]
];

// Controller post height.
controller_post_height = controller_size[2] - 0.8;
// Controller post radius.
controller_post_radius = 2.4;
// Controller post insert radius.
controller_insert_radius = 1.5;


/* [Switch size] */

// Cutout position on the back edge.
switch_position = -0.8;
// Cutout size needed for the switch body and leads.
switch_size = [9, 5.8, 3.5];
// Cutout size needed for the switch lever, assuming the same height.
switch_lever = [7.5, 1.6];

// Switch cutout size.
switch_cutout_size = switch_size[0] + 4;
// Margin for the switch cutout.
switch_cutout_margin = 0.3;

// Switch post height.
switch_post_height = 1;
// Switch post radius.
switch_post_radius = 0.75;
// Switch post positions, relative to the body center.
switch_posts = [
    [3.4, 2.2],
    [-3.4, 2.2]
];

// Calculated switch body center.
switch_center = [
    board_width / 2 * switch_position,
    board_depth / 2 - switch_size[1] / 2,
    board_cavity - switch_post_radius - switch_size[2] / 2 - switch_cutout_margin
];


// --- Modules ---


//
// Create a mounting post.
//
module post(outer_r, inner_r, h) {
    difference() {
        cylinder(h, r = outer_r);
        cylinder(h + 0.2, r = inner_r);
    }
}


//
// Create a negative for corner rounded corner chamfers.
//
module corner_chamfer(inner = true) {
    size = sqrt(chamfer_size * chamfer_size / 2);
    rotate_extrude(angle = 90)
        translate([inner ? 0 : board_radius - size, 0, 0])
        polygon(points = inner ? [
                [0, 0.1],
                [size, 0],
                [0, -size]
            ] : [
                [-0.1, 0.1],
                [size + 0.1, 0.1],
                [size + 0.1, -size - 0.1]
            ]
        );
}


//
// Basic key cutout negative, including chamfers when enabled.
//
module key_cutout(width = 1) {
    union() {
        // Main cutout.
        translate([0, 0, (board_height) / 2])
            cube([
                spacing[0] * width + margin * 2,
                spacing[1] + margin * 2,
                board_height + 0.2
            ], center = true);
        // Cutout chamfering.
        if (chamfer && add_surround) {
            chamfer_spacing = [
                spacing[0] * width / 2 + margin,
                spacing[1] / 2 + margin
            ];
            // Edge chamfers.
            translate([0, chamfer_spacing[1], board_height])
                rotate([45, 0, 0])
                cube([
                    spacing[0] * width + margin * 2,
                    chamfer_size,
                    chamfer_size
                ], center = true);
            translate([0, -chamfer_spacing[1], board_height])
                rotate([45, 0, 0])
                cube([
                    spacing[0] * width + margin * 2,
                    chamfer_size,
                    chamfer_size
                ], center = true);
            translate([chamfer_spacing[0], 0, board_height])
                rotate([0, 45, 0])
                cube([
                    chamfer_size,
                    spacing[1] + margin * 2,
                    chamfer_size
                ], center = true);
            translate([-chamfer_spacing[0], 0, board_height])
                rotate([0, 45, 0])
                cube([
                    chamfer_size,
                    spacing[1] + margin * 2,
                    chamfer_size
                ], center = true);
            // Corner chamfers.
            translate([chamfer_spacing[0], chamfer_spacing[1], board_height])
                corner_chamfer();
            translate([chamfer_spacing[0], -chamfer_spacing[1], board_height])
                rotate([0, 0, 270]) corner_chamfer();
            translate([-chamfer_spacing[0], -chamfer_spacing[1], board_height])
                rotate([0, 0, 180]) corner_chamfer();
            translate([-chamfer_spacing[0], chamfer_spacing[1], board_height])
                rotate([0, 0, 90]) corner_chamfer();
        }
    }
}


//
// Key plate positive. Flip for the right-side.
//
module key_positive(width = 1, flip = false) {
    translate([0, 0, plate_height / 2])
        union() {
            difference() {
                cube([
                    spacing[0] * width + margin * 2 + 0.2,
                    spacing[1] + margin * 2 + 0.2,
                    plate_height
                ], center = true);
                cube([clip_size, clip_size, plate_height + 0.1], center = true);
                translate([0, 0, plate_thickness - plate_height])
                    cube([key_size, key_size, plate_thickness + 0.1], center = true);
            }
            if (solid_plate) {
                translate([0, 0, (plate_height + plate_solid_height) / -2 + 0.1])
                    difference() {
                        cube([
                            spacing[0] + 0.2,
                            spacing[1] + 0.2,
                            plate_solid_height
                        ], center = true);
                        // Center post.
                        cylinder(d = 3.4, plate_solid_height + 0.2, center = true);
                        // Algnment posts.
                        translate([-5.5, 0, 0])
                            cylinder(d = 2, plate_solid_height + 0.2, center = true);
                        translate([5.5, 0, 0])
                            cylinder(d = 2, plate_solid_height + 0.2, center = true);
                        // Socket holes.
                        translate([0, 5.9, 0])
                            cylinder(d = 3, plate_solid_height + 0.2, center = true);
                        translate([5 * (flip ? -1 : 1), 3.8, 0])
                            cylinder(d = 3, plate_solid_height + 0.2, center = true);
                    }
            }
    }
}


//
// Larger cutout negative for where the cavity should _not_ be added.
//
module cavity_key_cutout(width = 1) {
    translate([0, 0, board_cavity / 2 - 0.1])
        cube([
            spacing[0] * width + plate_margin,
            spacing[1] + plate_margin,
            board_cavity + 0.2
        ], center = true);
}


//
// Common left/right board half.
//
module half_board(cutout = false, cavity = false, flip = false) {
    rotate([0, 0, -half_angle]) {
        render() columns(half_spec, spacing = spacing) {
            if (cutout) {
                key_cutout();
            } else if (cavity) {
                cavity_key_cutout();
            } else {
                key_positive(flip = flip);
            }
        }
        translate([
            spacing[0] * 2,
            (spacing[1] * -3.75) + (spacing[1] - spacing[0]),
            0
        ])
            rotate([0, 0, -90])
            render() columns(thumb_spec, spacing = spacing) {
                if (cutout) {
                    key_cutout(1.5);
                } else if (cavity) {
                    cavity_key_cutout(1.5);
                } else {
                    render() key_positive(1.5, flip = flip);
                }
            }
    }
}


//
// Inverted-T arrows.
//
module arrows(cutout = false, cavity = false) {
    translate([spacing[0], 0, 0])
        columns(arrow_spec, spacing = spacing) {
            if (cutout) {
                key_cutout();
            } else if (cavity) {
                cavity_key_cutout();
            } else {
                key_positive();
            }
        }
}


// --- The keyboard! ---


union() {
    difference() {
        // Main positive.
        translate([0, 0, board_height / 2])
            rounded_cubeoid([board_width, board_depth, board_height], r = board_radius);
        // Main chamfering.
        if (chamfer) {
            // Edge chamfers.
            translate([0, board_depth / 2, board_height])
                rotate([45, 0, 0])
                cube([board_width, chamfer_size, chamfer_size], center = true);
            translate([0, board_depth / -2, board_height])
                rotate([45, 0, 0])
                cube([board_width, chamfer_size, chamfer_size], center = true);
            translate([board_width / 2, 0, board_height])
                rotate([0, 45, 0])
                cube([chamfer_size, board_depth, chamfer_size], center = true);
            translate([board_width / -2, 0, board_height])
                rotate([0, 45, 0])
                cube([chamfer_size, board_depth, chamfer_size], center = true);
            // Corner chamfers.
            chamfer_spacing = [
                board_width / 2 - board_radius,
                board_depth / 2 - board_radius
            ];
            translate([chamfer_spacing[0], chamfer_spacing[1], board_height])
                corner_chamfer(inner = false);
            translate([chamfer_spacing[0], -chamfer_spacing[1], board_height])
                rotate([0, 0, 270]) corner_chamfer(inner = false);
            translate([-chamfer_spacing[0], -chamfer_spacing[1], board_height])
                rotate([0, 0, 180]) corner_chamfer(inner = false);
            translate([-chamfer_spacing[0], chamfer_spacing[1], board_height])
                rotate([0, 0, 90]) corner_chamfer(inner = false);
        }
        // Board half cutouts.
        translate([-half_offset[0], half_offset[1], 0])
            half_board(cutout = true);
        translate([half_offset[0], half_offset[1], 0])
            scale([-1, 1, 1])
            half_board(cutout = true);
        // Arrows cutout.
        if (add_arrows) {
            translate([
                board_width / 2 - spacing[0] * 1.5 - board_margin - 1,
                board_depth / -2 + spacing[1] + board_margin + 1,
                0
            ])
                arrows(cutout = true);
        }
        // Main bottom cutout.
        translate([0, 0, plate_offset / 2])
            rounded_cubeoid([
                board_width - board_margin * 2,
                board_depth - board_margin * 2,
                plate_offset + 0.1
            ], max(1, board_radius - board_margin / 2));
        // Thumb split cleanup.
        if (add_surround) {
        translate([0, -31.35, base_height])
            rotate([0, 0, half_angle])
            rotate_extrude(angle = 180 - half_angle * 2)
                translate([0.75, 0, 0])
                square([8, surround_height + 0.1]);
        }
        // Cavity clearout.
        difference() {
            translate([0, 0, board_cavity / 2 - 0.1])
                rounded_cubeoid([
                    board_width - board_margin * 2,
                    board_depth - board_margin * 2,
                    board_cavity + 0.2
                ], max(1, board_radius - board_margin / 2));
            translate([-half_offset[0], half_offset[1], plate_offset])
                half_board(cavity = true);
            translate([half_offset[0], half_offset[1], plate_offset])
                scale([-1, 1, 1])
                half_board(flip = true, cavity = true);
            // Arrows cutout.
            if (add_arrows) {
                translate([
                    board_width / 2 - spacing[0] * 1.5 - board_margin - 1,
                    board_depth / -2 + spacing[1] + board_margin + 1,
                    0
                ])
                    arrows(cavity = true);
            }
        }
        // Board post cutouts.
        if (add_mounting_posts) {
            for (position = board_post_positions) {
                translate([
                    (board_width - board_post_radius * 2) * position[0],
                    (board_depth - board_post_radius * 2) * position[1],
                    0
                ])
                    cylinder(
                        h = board_cavity * position[2] + 0.1,
                        r = controller_insert_radius + 0.2
                    );
            }
        }
        // Controller port cutout.
        translate([0, (board_depth - board_margin) / 2, board_cavity / 2 - 0.1])
            cube([
                controller_cutout_size + controller_cutout_margin * 2,
                board_margin + 1,
                board_cavity + 0.2
            ], center = true);
        translate([0, (board_depth - board_margin) / 2, board_cavity / 2 - 0.1])
            cube([
                controller_cutout_size + controller_cutout_margin * 2 + 6,
                board_margin / 4 + 1,
                board_cavity + 0.2
            ], center = true);
        // Switch cutout.
        if (add_switch_cutout) {
            translate([
                switch_center[0],
                switch_center[1],
                (board_cavity - switch_post_height) / 2 - 0.1
            ])
                union() {
                    cube([
                        switch_cutout_size + switch_cutout_margin * 2,
                        board_margin + 1,
                        board_cavity - switch_post_height + 0.1
                    ], center = true);
                    cube([
                        switch_cutout_size + switch_cutout_margin * 2 + 6,
                        board_margin / 4 + 1,
                        board_cavity - switch_post_height + 0.1
                    ], center = true);
                    for (position = switch_posts) {
                        translate([
                            position[0],
                            switch_size[1] / -2 + position[1],
                            (board_cavity - switch_post_height) / 2
                        ])
                            cylinder(h = switch_post_height, r = switch_post_radius);
                    }
                }
        }
    }
    // Board half positives.
    translate([-half_offset[0], half_offset[1], plate_offset])
        half_board();
    translate([half_offset[0], half_offset[1], plate_offset])
        scale([-1, 1, 1])
        half_board(flip = true);
    // Arrows positive.
    if (add_arrows) {
        translate([
            board_width / 2 - spacing[0] * 1.5 - board_margin - 1,
            board_depth / -2 + spacing[1] + board_margin + 1,
            plate_offset
        ])
            arrows();
    }
    // Board post positives.
    if (add_mounting_posts) {
        for (position = board_post_positions) {
            translate([
                (board_width - board_post_radius * 2) * position[0],
                (board_depth - board_post_radius * 2) * position[1],
                0
            ])
                post(
                    outer_r = board_post_radius,
                    inner_r = controller_insert_radius,
                    h = board_cavity * position[2]
                );
        }
    }
    // Controller port positive.
    post_offset = [
        0,
        (board_depth - controller_size[1]) / 2 - controller_port_size[1],
        board_cavity - controller_post_height
    ];
    difference() {
        union() {
            translate([
                0,
                (board_depth - board_margin) / 2,
                (board_cavity - controller_cutout_margin) / 2
            ])
                cube([
                    controller_cutout_size,
                    board_margin,
                    board_cavity - controller_cutout_margin
                ], center = true);
            translate([
                0,
                (board_depth - board_margin) / 2,
                (board_cavity - controller_cutout_margin) / 2
            ])
                cube([
                    controller_cutout_size + 6,
                    board_margin / 4 + 0.5,
                    board_cavity - controller_cutout_margin
                ], center = true);
        }
        // Controller port cutouts.
        translate([
            0,
            (board_depth - controller_size[1]) / 2 - controller_port_size[1],
            board_cavity - (controller_size[2] + controller_cutout_margin) / 2
        ])
            cube([
                controller_size[0] + controller_cutout_margin,
                controller_size[1],
                controller_size[2] + controller_cutout_margin
            ], center = true);
        translate([
            0,
            (board_depth - controller_port_size[1]) / 2,
            board_cavity - (controller_port_size[2] + controller_cutout_margin) / 2
        ])
            rotate([90, 0, 0])
            rounded_cubeoid([
                controller_port_size[0] + controller_cutout_margin,
                controller_port_size[2] + controller_cutout_margin,
                controller_port_size[1] + controller_cutout_margin,
            ], r = controller_port_radius, center = true);
        if (add_controller_posts) {
            for (position = controller_posts) {
                translate([
                    position[0] + post_offset[0],
                    position[1] + post_offset[1],
                    0
                ])
                    cylinder(board_cavity + 0.02, r = 1.1);
            }
        }
    }
    if (add_controller_posts) {
        for (position = controller_posts) {
            translate([
                position[0] + post_offset[0],
                position[1] + post_offset[1],
                post_offset[2]
            ])
                post(
                    outer_r = controller_post_radius,
                    inner_r = controller_insert_radius,
                    h = controller_post_height
                );
        }
    }
    // Switch mount positive.
    if (add_switch_cutout) {
        translate([
            switch_center[0],
            switch_center[1],
            (board_cavity - switch_post_height - switch_cutout_margin) / 2
        ]) {
            difference() {
                union() {
                    cube([
                        switch_cutout_size,
                        board_margin,
                        board_cavity - switch_post_height - switch_cutout_margin
                    ], center = true);
                    cube([
                        switch_cutout_size + 6,
                        board_margin / 4 + 1 - switch_cutout_margin * 2,
                        board_cavity - switch_post_height - switch_cutout_margin
                    ], center = true);
                }
                translate([
                    0,
                    -switch_lever[1],
                    (board_cavity - switch_post_height - switch_cutout_margin) / 2
                        - switch_size[2] / 2 + 0.1
                ])
                    union() {
                        cube([
                            switch_size[0] + switch_cutout_margin * 2,
                            switch_size[1] + switch_cutout_margin,
                            switch_size[2]
                        ], center = true);
                        translate([0, (switch_size[1] + switch_lever[1]) / 2 + 0.5, 0])
                            cube([
                                switch_lever[0],
                                switch_lever[1] + 1,
                                switch_size[2]
                            ], center = true);
                    }
            }
            translate([
                0,
                board_margin / 3,
                (board_cavity - switch_post_height - switch_cutout_margin * 0.75) / 2
                    - switch_size[2] / 2 + 0.1
            ]) {
                cube([
                    switch_lever[0] - switch_cutout_margin * 2,
                    board_margin / 3,
                    switch_size[2] - switch_cutout_margin
                ], center = true);
                cube([
                    1,
                    board_margin / 3,
                    switch_size[2] + switch_cutout_margin * 1.5
                ], center = true);
            }
        }
    }
}
/**/