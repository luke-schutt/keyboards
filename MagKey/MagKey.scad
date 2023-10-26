use <../common.scad>


$fs = $preview ? 1 : 0.1;
$fa = $preview ? 10 : 1;


/* [Main rendering options] */

// If the housing should be rendered.
render_housing = true;
// If the stem should be rendered.
render_stem = true;
// Split between housing and stem.
split = 0;


/* [Housing size] */

// Main switch housing size.
housing_size = 14;
// Switch housing corner radius.
housing_corner_radius = 1;
// Housing minimum target height.
housing_height = 4.5;
// Taper for the top of the housing.
housing_taper = 1;
// Taper height.
housing_taper_height = 1.5;
// Housing thickness (top and minimum walls).
housing_thickness = 1.5;
// Margins between the body and stem.
housing_margin = 0.25;


/* [Plate mounting] */

// Plate mount top.
plate_top = 2.2;
// Plate thickness to determine clip position.
plate_thickness = 1.3;
// Plate lip size.
plate_lip = 0.5;
// Plate lip thickness.
plate_lip_height = 0.8;
// If plate clips should be added.
plate_clips = true;
// Plate clip size.
plate_clip = 0.4;
// Plate clip width.
plate_clip_width = 3;
// Spacing between plate clips.
plate_clip_spacing = 4;


/* [Magnet sizing] */

// If the magnet is rectangular.
magnet_rectangular = true;
// Margin around the magnet.
magnet_margin = housing_margin * 0.5;
// Magnet size (radius & height or x/y, (y,) & z).
magnet_size = magnet_rectangular
    ? [1 / 8 * 25.4, 1 / 4 * 25.4, 1 / 32 * 25.4]
    : [3, 1];


/* [Switch stem sizing] */

// Offset for the stem half centers.
stem_spacing_offset = 0.6;
// Stem height extension.
stem_extension = 0.4;
// Stem stabilization slot size.
stem_stabilization = [2, 1];


/* [Keycap stem measurements] */

// Choc stem prong spacing (x).
choc_prong_spacing = 5.7;
// Choc stem prong width (x).
choc_prong_width = 1.2;
// Choc stem prong depth (y).
choc_prong_depth = 3;


/* [LED/diode cutout] */

// If the LED/diode cutout should be added.
diode_cutout = false;
// Size of the diode cutout.
diode_cutout_size = [5.3, 3.25, 2];
// Diode cutout offset.
diode_cutout_offset = 4.7;


//
// Build cube or cylinder for a magnet insert.
//
// - Parameters:
//   - size: 2 or 3 element array for magnet size.
//   - h: Magnet height override if > 0.
//   - rectangular: If the margent should be rectangular rather than cylindrical.
//   - margin: Margin around the magnet.
//
module magnet(
    size = magnet_size,
    h = 0,
    rectangular = magnet_rectangular,
    margin = magnet_margin * 2
) {
    if (!rectangular) {
        cylinder(
            h = max(h, size[1]) + margin,
            d = size[0] + margin
        );
    } else {
        cube_size = [
            size[0] + margin,
            size[len(size) > 2 ? 1 : 0] + margin,
            max(h, size[len(size) > 2 ? 2 : 1]) + margin
        ];
        translate([cube_size[0] * -0.5, cube_size[1] * -0.5, 0])
            cube(cube_size);
    }
}


//
// Build the housing shape.
//
// - Parameters:
//   - housing_height: Height for the switch housing.
//
module housing(housing_height = housing_height) {
    clip_height = plate_clip > 0 && plate_lip > 0 ? plate_top - plate_thickness : 0;
    bottom_taper = max(0.5, clip_height > 0 ? clip_height : (plate_top - plate_thickness) / 2);
    housing_main_height = housing_height - housing_taper_height - bottom_taper;
    translate([0, 0, housing_main_height / 2 + bottom_taper])
        rounded_cubeoid([housing_size, housing_size, housing_main_height], housing_corner_radius);
    if (housing_taper > 0 && housing_taper_height > 0) {
        taper = (housing_size - housing_taper * 2) / housing_size;
        translate([0, 0, housing_main_height + housing_taper_height / 2 + bottom_taper])
            rounded_cubeoid(
                [housing_size, housing_size, housing_taper_height],
                housing_corner_radius,
                scale = taper
            );
    }
    if (bottom_taper > 0) {
        taper_margin = max(plate_clip, housing_thickness * 0.5);
        clip_taper = (housing_size - taper_margin) / housing_size;
        translate([0, 0, bottom_taper * 0.5])
            rotate([180, 0, 0])
            rounded_cubeoid(
                [housing_size, housing_size, bottom_taper],
                housing_corner_radius,
                scale = clip_taper
            );
    }
    if (plate_lip > 0) {
        translate([0, 0, plate_top + plate_lip_height * 0.5])
            rounded_cubeoid(
                [housing_size + plate_lip * 2, housing_size + plate_lip * 2, plate_lip_height],
                housing_corner_radius + plate_lip
            );
    }
    if (plate_clips && clip_height > 0) {
        difference() {
            rotate([90, 0, 0])
                linear_extrude(plate_clip_width * 2 + plate_clip_spacing, center = true)
                polygon([
                    [housing_size * -0.5 + plate_clip * 0.5, 0],
                    [housing_size * -0.5 - plate_clip, clip_height * 0.75],
                    [housing_size * -0.5, clip_height],
                    [housing_size * 0.5, clip_height],
                    [housing_size * 0.5 + plate_clip, clip_height * 0.75],
                    [housing_size * 0.5 - plate_clip * 0.5, 0]
                ]);
            translate([0, 0, clip_height * 0.5 + 0.1])
                cube([
                    housing_size + plate_clip * 2 + 0.1,
                    plate_clip_spacing,
                    clip_height + 0.2
                ], center = true);
        }
    }
}


//
// Generate a pair of stem prongs for positives or negatives.
//
// - Parameters:
//   - spacing: Spacing between prong centers.
//   - width: Prong width (x).
//   - depth: Prong depth (y).
//   - height: Prong height (z).
//   - margin: Margin around the prongs.
//
module prongs(
    spacing = choc_prong_spacing,
    width = choc_prong_width,
    depth = choc_prong_depth,
    height = 5,
    margin = 0
) {
    translate([spacing * -0.5, 0, height * 0.5])
        cube([width + margin * 2, depth + margin * 2, height], center = true);
    translate([spacing * 0.5, 0, height * 0.5])
        cube([width + margin * 2, depth + margin * 2, height], center = true);
}


//
// Edge slots to help guide the stem.
//
// - Parameters:
//   - height: Height of the housing.
//   - margin: Margin aronud the slots.
//
module stem_slots(height = housing_height, margin = housing_margin) {
    cutout_size = housing_size - (max(housing_thickness, housing_taper) + margin) * 2;
    if (len(stem_stabilization) > 0) {
        translate([
            (stem_stabilization[0] + margin * 2) * -0.5,
            cutout_size * -0.5 - margin - 0.1,
            0
        ])
            cube([
                stem_stabilization[0] + margin * 2,
                stem_stabilization[1] + margin + 0.1,
                height + 0.2
            ]);
        if (!diode_cutout) {
            translate([
                (stem_stabilization[0] + margin * 2) * -0.5,
                cutout_size * 0.5 - stem_stabilization[1],
                0
            ])
                cube([
                    stem_stabilization[0] + margin * 2,
                    stem_stabilization[1] + margin + 0.1,
                    height + 0.2
                ]);
        }
        translate([
            cutout_size * -0.5 - margin - 0.1,
            (stem_stabilization[0] + margin * 2) * -0.5,
            0
        ])
            cube([
                stem_stabilization[1] + margin + 0.1,
                stem_stabilization[0] + margin * 2,
                height + 0.2
            ]);
        translate([
            cutout_size * 0.5 - stem_stabilization[1],
            (stem_stabilization[0] + margin * 2) * -0.5,
            0
        ])
            cube([
                stem_stabilization[1] + margin + 0.1,
                stem_stabilization[0] + margin * 2,
                height + 0.2
            ]);
    }
}


//
// A rounded cubeoid box sized for the bottom body of the stem.
//
// - Parameters:
//   - height: The box height.
//   - margin: The margin between housing and stem.
//
module stem_box(height = housing_thickness, margin = housing_margin) {
    cutout_size = housing_size - (max(housing_thickness, housing_taper) + margin) * 2;
    difference() {
        translate([0, 0, height / 2])
            rounded_cubeoid(
                [cutout_size, cutout_size, height],
                max(0, (housing_corner_radius - margin) / 2)
            );
        translate([0, 0, -0.1]) stem_slots();
    }
}


// Render the housing as needed.
if (render_housing) {
    translate([-split, 0, 0])
    union() {
        difference() {
            housing();
            prongs(
                spacing = choc_prong_spacing + stem_spacing_offset,
                height = housing_height + 0.1,
                margin = housing_thickness + housing_margin
            );
            translate([0, 0, housing_height - magnet_size[len(magnet_size) - 1]])
                magnet();
            cutout_size = housing_size - max(housing_thickness, housing_taper) * 2;
            translate([0, 0, (housing_height - housing_thickness) / 2 - 0.05])
                rounded_cubeoid(
                    [cutout_size, cutout_size, housing_height - 1.1],
                    housing_corner_radius / 2
                );
            if (diode_cutout) {
                translate([0, diode_cutout_offset, diode_cutout_size[2] * 0.5 - 0.1])
                    cube(
                        [diode_cutout_size[0], diode_cutout_size[1], diode_cutout_size[2] + 0.2],
                        center = true
                    );
            }
        }
        stem_slots(height = housing_height - housing_thickness + 0.1, margin = 0);
    }
}


// Render the stem as needed.
if (render_stem) {
    translate([split, 0, 0])
    difference() {
        union() {
            difference() {
                prongs(
                    spacing = choc_prong_spacing + stem_spacing_offset,
                    height = housing_height + stem_extension,
                    margin = housing_thickness
                );
                translate([0, 0, housing_thickness])
                    magnet(h = housing_height + stem_extension, margin = magnet_margin * 2);
                translate([0, 0, -0.1]) stem_slots(height = housing_height + stem_extension + 0.2);
            }
            stem_box();
        }
        translate([0, 0, housing_thickness])
            prongs(height = housing_height + stem_extension + 0.1, margin = 0.25);
        translate([0, 0, -magnet_margin]) magnet();
        if (diode_cutout) {
            translate([0, diode_cutout_offset, diode_cutout_size[2] * 0.5 - 0.1])
                cube(
                    [diode_cutout_size[0], diode_cutout_size[1], diode_cutout_size[2] + 0.2],
                    center = true
                );
        }
    }
}