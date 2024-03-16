use <../common.scad>


$fs = $preview ? 0.5 : 0.1;
$fa = $preview ? 5 : 0.5;


// If the top should be rendered.
render_top = true;
// If the bottom should be rendered.
render_bottom = true;
// If a JST SH connector cutout should be added.
jst_cutout = true;
// JST cutout size.
jst_cutout_size = [6.4, 4.5, 3];
// Switch spacing.
spacing = [19.05, 19.05];
// Switch cutout size.
switch_cutout = [14, 14];
// Margin around the switches.
key_margin = 0.5;
// Key count.
key_count = [1, 2];
// Surround wall size (height and thickness).
surround_walls = [jst_cutout ? jst_cutout_size.y + 1 : 3, 3];
// Surround wall roundover.
surround_fillet = surround_walls.x / 4;
// Plate thickness.
plate_thickness = 1.6;
// Thickness for the bottom case.
bottom_thickness = 2.2;
// Housing cavity depth.
cavity_depth = 1.4;
// Worry stone depth (0 for none).
worry_depth = 1;
// Worry stone size.
worry_size = [1.1, 0.85];


// Calculated main size without fillet.
main_size = [
    spacing.x * key_count.x + (key_margin + surround_walls.x - surround_fillet) * 2,
    spacing.y * key_count.y + (key_margin + surround_walls.x - surround_fillet) * 2,
    surround_walls.y + plate_thickness + cavity_depth
];
// Calculated offsets for centering the cutouts.
cutout_offset = [
    (key_count.x - 1) * spacing.x / -2,
    (key_count.y - 1) * spacing.y / -2
];


module insert_negative(t = 0.05, extra = 0) {
    translate([0, 0, -extra])
        cylinder(h = 2.15 + extra, d = 3.5 + t);
    cylinder(h = 3 + t * 2, d = 3.1 + t);
}


module screw_negative() {
    translate([0, 0, -bottom_thickness]) {
        cylinder(h = bottom_thickness + 1, r = 1);
        cylinder(h = 1.6, r1 = 2.1, r2 = 0.9);
    }
}


module flat_carton(cutout = true) {
    difference() {
        polygon([
            [main_size.x / -2, main_size.y / -2],
            [main_size.x / -2, main_size.y / 2],
            [0, main_size.y / 2 + main_size.x / 2],
            [main_size.x / 2, main_size.y / 2],
            [main_size.x / 2, main_size.y / -2]
        ]);
        if (cutout) {
            square([
                spacing.x * key_count.x + (key_margin + surround_fillet) * 2,
                spacing.y * key_count.y + (key_margin + surround_fillet) * 2
            ], center = true);
        }
    }
}


module carton_positive() {
    union() {
        minkowski() {
            linear_extrude(main_size.z) flat_carton();
            difference() {
                sphere(r = surround_fillet);
                translate([0, 0, -surround_fillet - 0.5])
                    cube(surround_fillet * 2 + 1, center = true);
            }
        }
        difference() {
            translate([0, 0, cavity_depth + plate_thickness / 2])
                cube([
                    spacing.x * key_count.x + (key_margin + surround_fillet) * 2,
                    spacing.y * key_count.y + (key_margin + surround_fillet) * 2,
                    plate_thickness
                ], center = true);
        }
    }
}



module milk_top() {
    difference() {
        carton_positive();
        triangle_size = [
            spacing.x * key_count.x + (key_margin - surround_fillet) * 2,
            main_size.x / 2 - surround_walls.x,
            min(main_size.z - plate_thickness, main_size.x / 2)
        ];
        translate([
            0,
            main_size.y / 2 + surround_fillet / 2,
            main_size.z - triangle_size.z + surround_fillet
        ])
            polyhedron(points = [
                [triangle_size.x / -2, 0, triangle_size.z],
                [0, triangle_size.y, triangle_size.z],
                [triangle_size.x / 2, 0, triangle_size.z],
                [0, triangle_size.y, 0]
            ], faces = [
                [0, 1, 2],
                [0, 3, 1],
                [2, 1, 3],
                [2, 0, 3]
                
            ]);
        if (jst_cutout) {
            translate([0, main_size.y / -2, jst_cutout_size.z / 2])
                cube(jst_cutout_size, center = true);
            translate([0, main_size.y / -2 + surround_walls.x / 2, cavity_depth / 2])
                cube([jst_cutout_size.x, surround_walls.x, cavity_depth], center = true);
        }
        for (y = [0 : key_count.y - 1]) {
            for (x = [0 : key_count.x - 1]) {
                translate([
                    cutout_offset.x + spacing.x * x,
                    cutout_offset.y + spacing.y * y,
                    cavity_depth + plate_thickness / 2
                ])
                    cube(
                        [switch_cutout.x, switch_cutout.y, plate_thickness + 0.1],
                        center = true
                    );
            }
        }
        for (y = [-1, 0, 1]) {
            for (x = [-1, 1]) {
                translate([
                    (main_size.x - surround_walls.x / 2) / 2 * x,
                    (main_size.y - surround_walls.x / 2) / 2 * y,
                    0
                ])
                    insert_negative();
            }
        }
        translate([0, (main_size.y - surround_walls.x) / 2 + main_size.x / 2, 0])
            insert_negative();
    }
}


module milk_bottom() {
    difference() {
        minkowski() {
            translate([0, 0, surround_fillet - bottom_thickness])
                linear_extrude(bottom_thickness - surround_fillet)
                flat_carton(cutout = false);
            difference() {
                sphere(r = surround_fillet);
                translate([0, 0, surround_fillet + 0.5])
                    cube(surround_fillet * 2 + 1, center = true);
            }
        }
        translate([0, main_size.y / -2 + 0.5, -0.2])
            cube([jst_cutout_size.x, jst_cutout_size.y + 1, 0.4], center = true);
        for (y = [-1, 0, 1]) {
            for (x = [-1, 1]) {
                translate([
                    (main_size.x - surround_walls.x / 2) / 2 * x,
                    (main_size.y - surround_walls.x / 2) / 2 * y,
                    0
                ])
                    screw_negative();
            }
        }
        translate([0, (main_size.y - surround_walls.x) / 2 + main_size.x / 2, 0])
            screw_negative();
        if (worry_depth > 0) {
            for (y = [0 : key_count.y - 1]) {
                for (x = [0 : key_count.x - 1]) {
                    translate([
                        cutout_offset.x + spacing.x * x,
                        cutout_offset.y + spacing.y * y,
                        -bottom_thickness - worry_depth * 0.25
                    ])
                        scale([
                            spacing.x * worry_size.x / 2,
                            spacing.y * worry_size.y / 2,
                            worry_depth * 1.5
                        ])
                            sphere(r = 1);
                }
            }
        }
    }
}

if (render_top) milk_top();
if (render_bottom) milk_bottom();