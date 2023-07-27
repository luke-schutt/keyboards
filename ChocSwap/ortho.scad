use <../common.scad>
$fs = 0.5;


/* [Stackup] */

// If the top and bottom should be stacked, this should be `false` for printing.
use_stack = false;
// If the top should be rendered when not stacked.
use_top = true;
// If the bottom should be rendered when not stacked.
use_bottom = true;


/* [Spacing and size] */

// Spacing per key in X and Y.
key_spacing = [18, 17];
// Keyboard switch grid size.
keyboard_size = [10, 4];

// Width for the thumb keys.
thumb_size = 1.5;
// Additional gap between sides.
sides_gap = 0.5;


/* [Key surround] */

// If the key surround should be added.
key_surround = false;
// Key surround height.
surround_height = 5.5;
// Gap between switches and the key surround.
surround_gap = 0.6;
// Extra padding for the case surround.
surround_padding = 1;


/* [Mounting plate] */

// Mounting hole size on the plate.
plate_hole = 14;
// Mounting plate lip (width and height).
plate_lip = [0.75, 1.3];
// Plate socket indents (width and depth).
plate_indent = [16, 3];
// Plate height above the switch base.
plate_height = 2;
// Base base plate height.
base_height = 1.4;


/* [Key pins] */

// If pins should be rendered.
use_pins = true;
// Pin sizes and positions [(r, x, y)] from the key' center.
pin_positions = [
    [1.75, 0, 0],
    [1, 5.5, 0],
    [1, -5.5, 0],
    [1.6, 0, -5.9],
    [1.6, -5, -3.8]
];


/* [Controller cutout] */

// If the controller cutout should be added.
controller_cutout = true;
// Controller size (excluding port).
controller_size = [21, 51, 3];
// Controller offset (from the top inside wall).
controller_offset = 0;
// Controller port cutout size.
controller_port_size = [9, 8, 4];
// Controller port offset (from the top-front of the controller).
controller_port_offset = [0, 4, -2];


/* [Screw inserts] */

// If inserts should be added.
threaded_inserts = true;
// Insert size (h, r1, r2, r3).
insert_size = [3.2, 1.8, 1.4, 1.2];
// Additional insert positions (relative to the top center edge inside the wall).
insert_positions = [
    [-5.7, -2],
    [5.7, -2],
    [-5.7, -49],
    [5.7, -49]
];


/* [Case] */

// Corner radius for the case.
case_radius = 2;
// Case wall thickness.
case_wall = 2;
// Case base thickness.
case_base = 1.5;
// Case hollow height.
case_hollow = 2.1 ;


/* [Calculated case sizes] */

// Calculated case padding around the switches.
case_padding = max(case_radius, case_wall)
    + surround_padding
    + (key_surround ? surround_gap + case_radius : 0);
// Calculated case gap between halves (excluding thumbs).
case_gap = (max(0, thumb_size - 1) * 2 + sides_gap) * key_spacing[0];
// Calculated size for the case.
case_size = [
    case_padding * 2 + case_gap + floor(keyboard_size[0] / 2) * 2 * key_spacing[0],
    case_padding * 2 + keyboard_size[1] * key_spacing[1],
    plate_height + base_height + case_base + case_hollow
        + (key_surround ? surround_height : 0)
];
echo("Case size:", case_size);
// Calculated default insert inset.
insert_inset = key_surround
    ? max(case_wall, case_padding - insert_size[1], case_padding / 2)
    : case_padding + key_spacing[0];
// Calculated alternate insert inset (for y without surround).
alt_inset = case_padding + key_spacing[1];
// Calculated case inserts.
case_inserts = concat(
    [for (pos = insert_positions) [pos[0], case_size[1] - case_wall + pos[1]]],
    key_surround ? [
        [case_size[0] / -2 + insert_inset, insert_inset],
        [case_size[0] / 2 - insert_inset, insert_inset],
        [case_size[0] / -2 + insert_inset, case_size[1] - insert_inset],
        [case_size[0] / 2 - insert_inset, case_size[1] - insert_inset],
        [0, insert_inset]
    ] : [
        [case_size[0] / -2 + insert_inset, case_size[1] - alt_inset],
        [case_size[0] / 2 - insert_inset, case_size[1] - alt_inset],
        [case_size[0] / -2 + insert_inset, alt_inset],
        [case_size[0] / 2 - insert_inset, alt_inset],
        [0, case_padding + key_spacing[1] / 2]
    ]
);


//
// Create a cubeoid with all but bottom, and optionally top, edges rounded.
//
module case(size = case_size, r = case_radius, round_top = true) {
    edge_height = size[2] - (round_top ? r : 0);
    if (r > 0) {
        // Main cubes.
        translate([size[0] / -2, r, 0])
            cube([size[0], size[1] - r * 2, edge_height]);
        translate([size[0] / -2 + r, 0, 0])
            cube([size[0] - r * 2, size[1], edge_height]);
        translate([size[0] / -2 + r, r, 0])
            cube([size[0] - r * 2, size[1] - r * 2, size[2]]);
        // Corner rounding.
        translate([size[0] / -2 + r, r, 0]) {
            cylinder(edge_height, r = r);
            if (round_top) {
                translate([0, 0, size[2] - r]) sphere(r = r);
            }
        }
        translate([size[0] / 2 - r, r, 0]) {
            cylinder(edge_height, r = r);
            if (round_top) {
                translate([0, 0, size[2] - r]) sphere(r = r);
            }
        }
        translate([size[0] / 2 - r, size[1] - r, 0]) {
            cylinder(edge_height, r = r);
            if (round_top) {
                translate([0, 0, size[2] - r]) sphere(r = r);
            }
        }
        translate([size[0] / -2 + r, size[1] - r, 0]) {
            cylinder(edge_height, r = r);
            if (round_top) {
                translate([0, 0, size[2] - r]) sphere(r = r);
            }
        }
        // Edge rounding.
        if (round_top) {
            translate([0, r, edge_height])
                rotate([0, 90, 0])
                cylinder(size[0] - r * 2, r = r, center = true);
            translate([0, size[1] - r, edge_height])
                rotate([0, 90, 0])
                cylinder(size[0] - r * 2, r = r, center = true);
            translate([size[0] / -2 + r, r, edge_height])
                rotate([0, 90, 90])
                cylinder(size[1] - r * 2, r = r);
            translate([size[0] / 2 - r, r, edge_height])
                rotate([0, 90, 90])
                cylinder(size[1] - r * 2, r = r);
        }
    } else {
        translate([size[0] / -2, 0, 0]) cube(size);
    }
}


//
// Create an edge negative for subtractive rounding.
//
module edge_negative(h, r = case_radius, corners = false, tolerance = 0.02) {
    // Sub-module for inside corners.
    module corner(r) {
        translate([r, 0, 0])
            rotate([-90, 180, 0]) 
            rotate_extrude(angle = 90)
            translate([r, 0, 0])
            rotate([0, 0, 90])
            difference() {
                square(r);
                circle(r);
            }
    }
    difference() {
        translate([0, 0, tolerance / -2])
            cube([r + tolerance, r + tolerance, h + tolerance]);
        translate([0, 0, -0.1]) cylinder(h + 0.2, r = r);
    }
    if (corners) {
        scale([1, 1, -1]) corner(r);
        translate([0, 0, h]) corner(r);
    }
}


//
// Create an outside edge negative for subtractive rounding.
//
module corner_negative(h, r = case_radius, tolerance = 0.02) {
    difference() {
        cube([r + tolerance, r + tolerance, h]);
        cylinder(h - r, r = r);
        translate([0, 0, h - r]) sphere(r);
    }
}


//
// Build the negative for half the keyboard.
//
module half_negative() {
    size = [floor(keyboard_size[0] / 2), keyboard_size[1]];
    dimensions = [
        size[0] * key_spacing[0] + surround_gap * 2,
        size[1] * key_spacing[1] + surround_gap * 2
    ];
    // Surround negative.
    if (key_surround) {
        // Main negative.
        translate([-dimensions[0] + surround_gap, -surround_gap, 0])
            cube([dimensions[0], dimensions[1], surround_height + 0.1]);
        // Extra thumb negative.
        if (thumb_size > 1) {
            thumb_width = (thumb_size - 1) * key_spacing[0];
            translate([-0.1 - surround_gap, -surround_gap, 0])
                cube([
                    thumb_width + 0.1 + surround_gap * 2,
                    key_spacing[1] + surround_gap * 2,
                    surround_height + 0.1
                ]);
            // Thumb surround rounding.
            translate([0, -case_radius - surround_gap, surround_height - case_radius])
                rotate([90, 0, 90])
                edge_negative(thumb_width + surround_gap);
            translate([
                thumb_width + surround_gap,
                key_spacing[1] + case_radius + surround_gap,
                surround_height - case_radius
            ])
                rotate([90, 0, -90])
                edge_negative(thumb_width + surround_gap);
            translate([
                thumb_width + surround_gap + case_radius,
                -surround_gap,
                surround_height - case_radius
            ])
                rotate([90, 0, 180])
                edge_negative(key_spacing[1] + surround_gap * 2, corners = true);
            // Thumb surround corners.
            translate([
                case_radius + surround_gap,
                key_spacing[1] + case_radius + surround_gap,
                0
            ])
                rotate([0, 0, 180])
                corner_negative(surround_height);
        }
        // Surround rounding.
        translate([
            -dimensions[0] + surround_gap,
            -case_radius - surround_gap,
            surround_height - case_radius
        ])
            rotate([90, 0, 90])
            edge_negative(dimensions[0]);
        translate([
            surround_gap,
            dimensions[1] + case_radius - surround_gap,
            surround_height - case_radius
        ])
            rotate([90, 0, -90])
            edge_negative(dimensions[0]);
        translate([
            -dimensions[0] - case_radius + surround_gap,
            dimensions[1] - surround_gap,
            surround_height - case_radius
        ])
            rotate([90, 0, 0])
            edge_negative(dimensions[1], corners = true);
        translate([
            case_radius + surround_gap,
            -surround_gap,
            surround_height - case_radius
        ])
            rotate([90, 0, 180])
            edge_negative(dimensions[1], corners = true);
    }
    // Per-key negatives.
    for (y = [0 : size[1] - 1]) {
        y_offset = (size[1] - 0.5 - y) * key_spacing[1];
        for (x = [0 : size[0] - 1]) {
            x_offset = -dimensions[0] + surround_gap * 2 + (x
                + ((x == size[0] - 1 && y == size[1] - 1 && thumb_size > 1)
                    ? (thumb_size - 1) / 2
                    : 0
                ) + 0.5
            ) * key_spacing[0];
            // Key socket negative.
            translate([x_offset, y_offset, 0]) children();
        }
    }
}


//
// Build the negative for a single socket.
//
module socket_negative() {
    // Main key negative.
    translate([0, 0, plate_height / -2 + 0.1])
        cube([plate_hole, plate_hole, plate_height + 0.1], center = true);
    // Plate lip negative.
    translate([0, 0, -plate_height + plate_lip[1] / 2])
        cube(
            [plate_hole + plate_lip[0], plate_hole, plate_lip[1] + 0.1],
            center = true
        );
    // Key-pulling notches.
    translate([0, 0, plate_height / -2 + 0.1])
        cube([plate_indent[0], plate_indent[1], plate_height + 0.1], center = true);
    // Add holes for pins.
    if (use_pins) {
        for (i = [0 : len(pin_positions) - 1]) {
            pin = pin_positions[i];
            translate([pin[1], pin[2], -base_height - plate_height - 0.1])
                cylinder(base_height + 0.2, r = pin[0]);
        }
    // Or use an extended main key negative below the key.
    } else {
        translate([0, 0, -plate_height - base_height / 2])
            cube([plate_hole, plate_hole, base_height + 0.2], center = true);
    }
}


module insert_negative() {
    translate([0, 0, case_base + case_hollow])
        cylinder(insert_size[0], r1 = insert_size[1], r2 = insert_size[2]);
    translate([0, 0, -0.1])
        cylinder(case_base + case_hollow + insert_size[0], r = insert_size[3]);
}


//
// Build the whole keyboard.
//
module keyboard() {
    difference() {
        // Main positive.
        case();
        // Cavity negative.
        translate([0, case_wall, case_base])
            case(
                size = [
                    case_size[0] - case_wall * 2,
                    case_size[1] - case_wall * 2,
                    case_hollow
                ],
                r = case_radius / 2,
                round_top = false
            );
        // Left half.
        translate([
            case_gap / -2,
            case_padding,
            case_size[2] - (key_surround ? surround_height : 0)
        ])
            half_negative() {
                socket_negative();
            }
        // Right half.
        translate([
            case_gap / 2,
            case_padding,
            case_size[2] - (key_surround ? surround_height : 0)
        ])
            scale([-1, 1, 1])
            half_negative() {
                scale([-1, 1, 1]) socket_negative();
            }
        // Controller cavity.
        if (controller_cutout) {
            translate([
                controller_size[0] / -2,
                case_size[1] - controller_size[1] - case_wall + controller_offset,
                case_base
            ]) {
                cube(controller_size);
                port_size = controller_port_size;
                translate([
                    (controller_size[0] - port_size[0]) / 2 + controller_port_offset[0],
                    controller_size[1] - port_size[1] + controller_port_offset[1],
                    controller_size[2] + controller_port_offset[2]
                ])
                    cube(port_size);
            }
        }
        // Threaded inserts.
        if (threaded_inserts) {
            for (i = [0 : len(case_inserts) - 1]) {
                insert = case_inserts[i];
                translate([insert[0], insert[1], 0]) insert_negative();
            }
        }
    }
}


// Full keyboard preview.
if (use_stack) {
    keyboard();
// Split keyboard for printing.
} else {
    bottom_height = case_base + case_hollow;
    top_height = case_size[2] - bottom_height;
    // Case bottom.
    if (use_bottom) {
        translate([0, -case_size[1] - 2, 0])
            intersection() {
                keyboard();
                translate([case_size[0] / -2, 0, 0])
                    cube([case_size[0], case_size[1], bottom_height - 0.05]);
            }
    }
    // Case top.
    if (use_top) {
        translate([0, 2, -bottom_height])
            intersection() {
                keyboard();
                translate([case_size[0] / -2, 0, bottom_height])
                    cube([case_size[0], case_size[1], top_height]);
            }
    }
}