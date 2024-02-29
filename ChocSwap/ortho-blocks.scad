use <../common.scad>


$fs = $preview ? 0.5 : 0.1;
$fa = $preview ? 5 : 0.5;


render_top = true;
render_bottom = false;
interconnect = true;
interconnect_punchout = true;
mirror = false;


mx_spacing = true;
spacing = mx_spacing ? [19.05, 19.05] : [18, 17];
u = [1, 1];


plate_base = 1.3;
plate_thickness = plate_base + 2.2;


matrixes = [
    [[0, 0], [1, 1], [3, 2], false],
    [[-2, -0.5], [1, 1], [1, 2], false],
    [[1.5, -1.5], [1.25, 1], [2, 1], true]
];


base_size = [5.25 * spacing.x + 2, 3 * spacing.y + 2, 6.2];


module key_negative(
    h = plate_thickness,
    base = plate_base,
    u = [spacing.x + 2, spacing.y + 2],
    chamfer_offset = 1.2,
    thumb = false
) {
    translate([5.5, 0, -h + 0.9]) cylinder(d = 1.9, h = h);
    translate([-5.5, 0, -h + 0.9]) cylinder(d = 1.9, h = h);
    translate([0, 0, -h + 0.9]) cylinder(d = 3.3, h = h);
    translate([0, -5.9, -h + 0.9]) cylinder(d = 3, h = h);
    translate([-5, -3.8, -h + 0.9]) cylinder(d = 3, h = h);
    translate([0, 0, h / 2]) cube([14.1, 14.1, h], center = true);
    translate([0, 0, 0.9 / 2]) cube([15, 14.6, 0.9], center = true);
    translate([0, 0, 6.1]) cube([16.5, 3.5, 12.2], center = true);
    thumb_y = u.y * (thumb ? 2 : 1);
    translate([0, thumb ? u.y / -2 : 0, 2.2 + 5])
        rounded_cubeoid([u.x, thumb_y, 10], r = 1.5);
    if (chamfer_offset > 0) {
        translate([0, thumb ? u.y / -2 : 0, 2.2 + (u.x / 2) + chamfer_offset])
            rounded_cubeoid(
                [u.x, thumb_y, u.x],
                r = 1.5,
                scale = 3
            );
    }
}


module key_array(size, u = u, spacing = spacing, thumbs = false) {
    translate([(size.x - 1) / -2 * u.x * spacing.x, (size.y - 1) / -2 * u.y * spacing.y, 0])
        for(y = [0 : size.y - 1]) {
            for (x = [0 : size.x - 1]) {
                translate([x * u.x * spacing.x, y * u.y * spacing.y, 0])
                    key_negative(
                        u = [spacing.x * u.x + 2.5, spacing.y * u.y + 2.5],
                        thumb = thumbs
                    );
            }
        }
}


module ws_rp2040_negative(cavity = 1) {
    translate([0, 0, cavity / -2])
        cube([18.2, 24.2, 1 + cavity], center = true);
    translate([0, 1, 0.5 + 4 / 2])
        cube([18 - 5, 24.2 - 3, 4], center = true);
    translate([0, -12.5 + 8, 0])
        cylinder(h = 12, r = 2.05);
    translate([-1.75 * 2.54, -12.2 + 7, 0])
        cylinder(h = 12, r = 0.65);
    translate([1.75 * 2.54, -12.1 + 7, 0])
        cylinder(h = 12, r = 0.65);
    translate([0, (24.2 - 5 * 2.54 + 20) / 2, 4.28 / 2])
        rotate([-90, 0, 0]) {
            rounded_cubeoid([9, 3.3, 20], r = 0.75);
            translate([0, 0, 4.5])
                rounded_cubeoid([13, 7.5, 14], r = 2);
        }
}


module insert_negative(t = 0.05, extra = 0) {
    translate([0, 0, -extra])
        cylinder(h = 2.15 + extra, d = 3.5 + t);
    cylinder(h = 3 + t * 2, d = 3.1 + t);
}


module interconnect_negative(extra = 0) {
    translate([0, (4.35 - extra) / -2, 1.5])
        cube([6.25, 4.35 + extra, 3], center = true);
    translate([0, -5.1, 0.5])
        cube([4, 1.5, 1], center = true);
}


module insertless_case() {
    difference() {
        // Main positive.
        minkowski() {
            translate([0.25 * 0.5 * spacing.x, -0.5 * spacing.y, base_size.z * 0.5])
                rounded_cubeoid([base_size.x, base_size.y, base_size.z], r = 1);
            union() {
                cylinder(h = 0.2, r1 = 2.8, r2 = 3);
                translate([0, 0, 0.2]) cylinder(h = 0.8, r1 = 3, r2 = 2);
            }
        }
        // Primary cavity cutout.
        translate([0.25 * 0.5 * spacing.x, -0.5 * spacing.y, (3 - plate_base) / 2 - 0.5])
            rounded_cubeoid([base_size.x, base_size.y, 3 - plate_base + 1], r = 1);
        // Bottom pinky-edge cavity.
        translate([
            spacing.x * -0.625,
            spacing.y * -1.5 - 2.5,
            (base_size.z - 1) / 2
        ])
            rounded_cubeoid([spacing.x * 1.5, spacing.y - 3, base_size.z - 1], r = 1);
        translate([spacing.x * -1.5 - 2, spacing.y * -1.75 - 2, (base_size.z - 1) / 2])
            rounded_cubeoid([
                spacing.x * 2 - 2,
                spacing.y * 0.5 - 2,
                base_size.z - 1
            ], r = 1);
        // Top pinky-edge cavity.
        translate([spacing.x * -2 - 2, spacing.y * 0.75 + 2, (base_size.z - 1) / 2])
            rounded_cubeoid([spacing.x - 2, spacing.y * 0.5 - 2, base_size.z - 1], r = 1);
        // Below-controller cavity.
        translate([spacing.x * 2.125, spacing.y * -0.5 - 1.5, (base_size.z - 1) / 2])
            rounded_cubeoid([spacing.x, spacing.y * 0.75 - 3, base_size.z - 1], r = 1);
        // Key array cutouts.
        translate([0, 0, 3])
            for (matrix = matrixes) {
                matrix_offset = matrix[0];
                unit_size = matrix[1];
                size = matrix[2];
                thumbs = matrix[3];
                translate([spacing.x * matrix_offset.x, spacing.y * matrix_offset.y, 0])
                    scale([mirror ? -1 : 1, 1, 1])
                    key_array(size, u = unit_size, thumbs = thumbs);
            }
        // Contorller cavity.
        translate([spacing.x * (2 + 1 / 8), 7.5, 1.5])
            ws_rp2040_negative();
        // Interconnect cutouts.
        if (interconnect) {
            translate([
                2.8 + (base_size.x * 0.5) + (0.25 * 0.5 * spacing.x),
                7.5 - 12.1 + 8,
                (base_size.z - 3) * 0.5
            ])
                rotate([0, 0, -90])
                interconnect_negative(extra = 1);
        }
    }
}


module case_top() {
    translation = [
        0.25 * 0.5 * spacing.x,
        -0.5 * spacing.y,
        3 - plate_base
    ];
    difference() {
        // Main case positive.
        union() {
            // Main case.
            insertless_case();
            // Threaded insert cylinders.
            translate(translation)
                for (y = [-0.5, 0.5]) {
                    for (x = [-0.5, 0, 0.5]) {
                        translate([(base_size.x - 1) * x, (base_size.y - 1) * y, 0])
                            cylinder(h = 3.25, d = 4.5);
                    }
                }
            // Interconnect punchout.
            if (interconnect && interconnect_punchout) {
                translate([
                    (base_size.x * 0.5) + (0.25 * 0.5 * spacing.x) + 3,
                    7.5 - 12.1 + 8,
                    (base_size.z) * 0.5
                ]) {
                    translate([-0.75 / 2, 0, 0])
                        cube([0.75, 6.5, 2], center = true);
                    translate([0.3 - 0.75, 0, 0])
                        cube([0.3, 5.25, 3.6], center = true);
                }
            }
        }
        // Threaded insert cutouts.
        translate(translation)
            for (y = [-0.5, 0.5]) {
                for (x = [-0.5, 0, 0.5]) {
                    translate([(base_size.x - 1) * x, (base_size.y - 1) * y, 0])
                        insert_negative(extra = 3 - plate_base + 0.1);
                }
            }
    }
}


module case_bottom() {
    translation = [
        0.25 * 0.5 * spacing.x,
        -0.5 * spacing.y,
        0
    ];
    difference() {
        union() {
            minkowski() {
                translate([0.25 * 0.5 * spacing.x, -0.5 * spacing.y, 0.4])
                    rounded_cubeoid([base_size.x, base_size.y, 0.8], r = 1);
                union() {
                    cylinder(h = 0.5, r1 = 2.5, r2 = 3);
                    translate([0, 0, 0.5])
                        cylinder(h = 0.2, r1 = 3, r2 = 2.8);
                }
            }
            translate(translation)
                for (y = [-0.5, 0.5]) {
                    for (x = [-0.5, 0, 0.5]) {
                        translate([(base_size.x - 1) * x, (base_size.y - 1) * y, 0])
                            cylinder(h = 3, d = 3.4);
                    }
                }
        }
        translate(translation)
            for (y = [-0.5, 0.5]) {
                for (x = [-0.5, 0, 0.5]) {
                    translate([(base_size.x - 1) * x, (base_size.y - 1) * y, 0]) {
                        cylinder(h = 5, r = 1);
                        cylinder(h = 1.6, r1 = 2.2, r2 = 1);
                    }   
                }
            }
    }
}


scale([mirror ? -1 : 1, 1, 1]) {
    if (render_top) case_top();
    if (render_bottom) translate([0, 0, render_top ? -1.5 : 0]) case_bottom();
}