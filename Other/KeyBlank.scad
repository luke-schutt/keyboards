use <../common.scad>


$fs = $preview ? 1 : 0.1;
$fa = $preview ? 10 : 5;


// Main switch housing size.
housing_size = 13.75;
// Switch housing corner radius.
housing_corner_radius = 1.5;


// Plate mount top.
plate_top = 2.2;
// Plate thickness to determine clip position.
plate_thickness = 1.3;
// Plate lip size.
plate_lip = 0.75;
// Plate lip thickness.
plate_lip_height = 1.1;
// Plate taper height.
plate_taper_height = plate_lip_height / 2;
// Plate lip taper.
plate_lip_taper = plate_lip_height / 2;
// If plate clips should be added.
plate_clips = true;
// Plate clip size.
plate_clip = 0.25;


// Spacing between blanks.
blank_spacing = plate_lip * 2 + 2;
// Blank count with sprues.
blank_count = [1, 1];
// Sprue size between blanks.
sprue_size = 1.2;


module blank() {
    clip_height = plate_top - plate_thickness;
    lip_size = housing_size + plate_lip * 2;
    translate([0, 0, plate_top + (plate_lip_height - plate_taper_height) * 0.5])
        rounded_cubeoid(
            [lip_size, lip_size, plate_taper_height],
            housing_corner_radius + plate_lip
        );
    translate([0, 0, plate_top + plate_taper_height * 0.5 + plate_lip_height - plate_taper_height])
        rounded_cubeoid(
            [lip_size, lip_size, plate_taper_height],
            housing_corner_radius + plate_lip,
            scale = (lip_size - plate_lip_taper * 2) / lip_size
        );
    difference() {
        translate([0, 0, clip_height + plate_thickness / 2])
            rounded_cubeoid([housing_size, housing_size, plate_thickness], housing_corner_radius);
        translate([0, 0, (plate_top) * 0.5])
            rounded_cubeoid([housing_size - 2, housing_size - 2, plate_top + 0.1], housing_corner_radius - 1);
        translate([0, 0, (plate_top) * 0.5]) {
            cutout_offset = (housing_size - housing_corner_radius * 3 + plate_clip + 0.25) / 2;
            translate([0, -cutout_offset, 0])
                cube([housing_size + 1, 0.5, plate_top + 0.1], center = true);
            translate([0, cutout_offset, 0])
                cube([housing_size + 1, 0.5, plate_top + 0.1], center = true);
        }
    }
    difference() {
        rotate([90, 0, 0])
            linear_extrude(housing_size - housing_corner_radius * 3, center = true)
            polygon([
                [housing_size * -0.5 + plate_clip * 0.5, 0],
                [housing_size * -0.5 - plate_clip, clip_height * 0.75],
                [housing_size * -0.5, clip_height],
                [housing_size * 0.5, clip_height],
                [housing_size * 0.5 + plate_clip, clip_height * 0.75],
                [housing_size * 0.5 - plate_clip * 0.5, 0]
            ]);
        translate([0, 0, clip_height * 0.5])
            cube([
                housing_size + plate_clip * 2 + 0.1,
                housing_size / 2,
                clip_height + 0.2
            ], center = true);
        translate([0, 0, clip_height * 0.5])
            cube([housing_size - 2, housing_size + 2, clip_height + 0.2], center = true);
    }
}


for (y = [0 : blank_count[1] - 1]) {
    for (x = [0 : blank_count[0] - 1]) {
        if (sprue_size > 0 && x > 0) {
            translate([
                (x - blank_count[0] / 2) * (housing_size + blank_spacing),
                (y - (blank_count[1] - 1) / 2) * (housing_size + blank_spacing),
                sprue_size / 2
            ]) cube([
                blank_spacing + housing_corner_radius * 2.5,
                sprue_size,
                sprue_size
            ], center = true);
            if (y > 0) {
            translate([
                (x - blank_count[0] / 2) * (housing_size + blank_spacing),
                (y - blank_count[1] / 2) * (housing_size + blank_spacing),
                sprue_size / 2
            ]) cube([sprue_size, housing_size + blank_spacing + 0.1, sprue_size], center = true);
            }
        }
        translate([
            (x - (blank_count[0] - 1) / 2) * (housing_size + blank_spacing),
            (y - (blank_count[1] - 1) / 2) * (housing_size + blank_spacing),
            0
        ]) blank();
    }
}