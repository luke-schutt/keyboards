use <../common.scad>;
//$fs = 0.5;


use <../common.scad>;


use_minkowski = false;
basic_minkowski = false;


edge_radius = 2.5;
surround_height = 5.5;

spacing = [18, 17];
plate_hole = 14;
plate_height = 1.3;

row_count = 3;
key_margin = 0.5;

thumb_keys = 3;
thumb_width = 1.5;
thumb_offset = 1.5;

column_offsets = [0, 0, 0.35, -0.25, -0.6];

angle = 16;
side_spacing = 26;


offset_sums = [for (i = [0 : len(column_offsets) - 1])
    sum([for (j = [0: i]) column_offsets[j]])
];
offset_sum = offset_sums[len(offset_sums) - 1];
//edge_padding = key_margin * 2 + (edge_radius * (surround ? 2 : 1));
//x_min = rotate_point([
//    -spacing[0] * len(column_offsets),
//    (row_count * -spacing[1]) - (offset_sum * -spacing[1])
//], -angle)[0] - (side_spacing * 0.5) - edge_padding;
//x_max = -x_min;
//y_min = min([for (i = [0 : len(offset_sums) - 1])
//    rotate_point([
//        i * -spacing[0],
//        (row_count * -spacing[1]) + (offset_sums[i] * -spacing[1])
//    ], -angle)[1]
//]) - edge_padding;
//y_max = max([for (i = [0 : len(offset_sums) - 1])
//    rotate_point([
//        (i + 1) * -spacing[0],
//        offset_sums[i] * spacing[1]
//    ], -angle)[1]
//]) + edge_padding;

echo("offset sums", offset_sums);
echo("offset sum", offset_sum);
//echo("x-min, x-max", x_min, x_max);
//echo("y-min, y-max", y_min, y_max);


function rotate_point(point, angle) = [
    (cos(angle) * point[0]) + (cos(90 - angle) * -point[1]),
    (sin(90 - angle) * point[1]) + (sin(angle) * point[0])
];


module column(
    rows = row_count,
    spacing = spacing,
    margin = key_margin,
    height = plate_height,
    mounting = true
) {
    translate([
        -(spacing[0] + margin),
        -((spacing[1] * rows) + margin),
        0
    ]) difference() {
        cube([spacing[0] + (margin * 2), (spacing[1] * rows) + (margin * 2), height]);
        if (mounting) {
            for (index = [0 : rows - 1]) {
                translate([
                    spacing[0] * 0.5 + margin,
                    (index + 0.5) * spacing[1] + margin,
                    0
                ]) {
                    if($children > 0) {
                        children();
                    } else {
                        translate([0, 0, height / 2])
                            cube(
                                [plate_hole, plate_hole, height + 0.2],
                                center = true
                            );
                    }
                }
            }
        }
    }
}


module columns(hull_pairs = false) {
    for (index = [0 : len(column_offsets) - 1]) {
        x_offset = -index * spacing[0];
        y_offset = offset_sums[index] * spacing[1];
        translate([x_offset, y_offset, 0])
        if (index == 0 || !hull_pairs) {
            children();
        } else {
            hull() {
                translate([spacing[0], -column_offsets[index] * spacing[1], 0])
                    children();
                children();
            }
        }
    }
}


module half_hand(
    hull_pairs = false,
    margin = key_margin,
    height = plate_height,
    mounting = true
) {
    columns(hull_pairs) column(margin = margin, height = height, mounting = mounting);
    translate([
        spacing[1] * thumb_offset,
        (-spacing[1] * (row_count)) - (spacing[0] * thumb_width),
        0
    ])
        rotate([0, 0, -90])
            column(
                rows = thumb_keys,
                spacing = [spacing[0] * thumb_width, spacing[1]],
                margin = margin,
                height = height,
                mounting = mounting
            );
}


module hand(
    hull_pairs = false,
    margin = key_margin,
    height = plate_height,
    mounting = true
) {
    translate([side_spacing * -0.5, 0, 0])
        rotate([0, 0, -angle])
        half_hand(
            hull_pairs = hull_pairs,
            margin = margin,
            height = height,
            mounting = mounting
        );
    scale([-1, 1, 1])
        translate([side_spacing * -0.5, 0, 0])
        rotate([0, 0, -angle])
        half_hand(
            hull_pairs = hull_pairs,
            margin = margin,
            height = height,
            mounting = mounting
        );
}


union() {
    poly_side = side_spacing * 0.5 - edge_radius;
    poly_bottom = row_count * -spacing[1] - key_margin;
    difference() {
        if (use_minkowski) {
            minkowski() {
                difference() {
                    hand(
                        margin = key_margin * 3 + edge_radius,
                        mounting = false
                    );
                    hand(
                        margin = key_margin + edge_radius,
                        mounting = false
                    );
                }
                if (basic_minkowski) {
                    translate([-edge_radius, -edge_radius, 0])
                        cube([edge_radius * 2, edge_radius * 2, surround_height]);
                } else {
                    union() {
                        cylinder(
                            h = surround_height - edge_radius,
                            r = edge_radius
                        );
                        translate([0, 0, surround_height - edge_radius])
                            sphere(r = edge_radius);
                    }
                }
            }
        } else {
            difference() {
                hand(
                    margin = key_margin * 2 + edge_radius * 2,
                    height = plate_height + surround_height,
                    mounting = false
                );
                translate([0, 0, -0.1])
                    hand(
                        margin = key_margin,
                        height = plate_height + surround_height + 0.2,
                        mounting = false
                    );
            }
        }    }
    hand(margin = key_margin * 3);
    translate([0, 0, surround_height])
        linear_extrude(plate_height)
            polygon([
                rotate_point([-poly_side + key_margin * 2, key_margin * -0.5], -angle),
                rotate_point([poly_side - key_margin * 2, key_margin * -0.5], angle),
                rotate_point([poly_side - key_margin, poly_bottom], angle),
                [0, poly_bottom - key_margin * 4],
                rotate_point([-poly_side + key_margin, poly_bottom], -angle)
            ]);
}
/**/