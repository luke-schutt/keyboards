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
jst_cutout_size = [6.3, 4.35, 3];
// Switch spacing.
spacing = [19.05, 19.05];
// Switch cutout size.
switch_cutout = [14, 14];
// Margin around the switches.
key_margin = 1;
// Key count.
key_count = [1, 2];
// Surround wall size (height and thickness).
surround_walls = [jst_cutout ? jst_cutout_size.y + 1 : 3, 3];
// Surround wall roundover.
surround_fillet = surround_walls.x / 3;
// Plate thickness.
plate_thickness = 1.6;
// Housing cavity depth.
cavity_depth = 1.4;
// Clip thickness.
clip_thickness = min(surround_walls.x / 3, 0.75);
// Cutout margin for the case clips.
clip_margin = 0.1;
// Extension for the clip.
clip_extend = 1;


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



module clip(margin = 0, extend = 0) {
    size = [main_size.z, min(main_size.z, spacing.y / 2), clip_thickness];
    adjusted = [ for (v = size) v + margin * 2 ];
    r = min(size.x, size.y) / 4;
    translate([-size.z, 0, 0])
        rotate([0, 90, 0])
        difference() {
            translate([-r - extend / 2, 0, size.z / 2])
                rounded_cubeoid(
                    [adjusted.x + extend, adjusted.y, adjusted.z],
                    r = r + margin
                );
            translate([size.x / -3, 0, -0.1 - margin])
                cylinder(h = size.z + margin * 2 + 0.2, r = r - margin);
            translate([size.x / -2 - r - extend - margin, 0, -margin])
                rotate([0, 45, 0])
                cube([adjusted.z * 1.4, adjusted.y, adjusted.z * 1.4], center = true);
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
        for (x = [-1, 1]) {
            for (y = [0 : key_count.y - 1]) {
                translate([
                    ((main_size.x) / 2 + surround_fillet) * x,
                    cutout_offset.y + spacing.y * y,
                    0
                ])
                    rotate([0, 0, x < 0 ? 180 : 0])
                    clip(margin = clip_margin, extend = clip_extend);
            }
        }
    }
}


module milk_bottom() {
    union() {
        translate([0, 0, -plate_thickness - clip_margin])
            minkowski() {
                linear_extrude(plate_thickness) flat_carton(cutout = false);
                difference() {
                    sphere(r = surround_fillet);
                    translate([0, 0, surround_fillet + 0.5])
                        cube(surround_fillet * 2 + 1, center = true);
                }
            }
        for (x = [-1, 1]) {
            for (y = [0 : key_count.y - 1]) {
                translate([
                    ((main_size.x) / 2 + surround_fillet) * x,
                    cutout_offset.y + spacing.y * y,
                    0
                ])
                    rotate([0, 0, x < 0 ? 180 : 0])
                    clip();
            }
        }
    }
}


if (render_top) milk_top();
if (render_bottom) milk_bottom();