use <../common.scad>

$fs = $preview ? 1 : 0.5;
$fa = $preview ? 10 : 2;


// Known issues:
// - Plate height is added to cavity height.
// - Tenting angle may cause the center to gap.
// - plate thickness increases from edge margin on tented section.
// - Some key counts/positions are definitely broken due to fixed areas for fill.
// - Some key counts/positions may cause arrows to overlap other sections.


// If the plus-sized board should be rendered (~60% vs ~40%).
plus_size = false;
// If the inverted-T arrows should be added (overlaps with the bottom center pinky).
arrows = plus_size;
// If the keyboard should use stagger or be primalily ortho.
do_stagger = false;
// If thumb sockets should be rotated.
rotate_thumbs = true;
// If the keyboard should be split for vertical printing.
split_board = true;

// If the test "keys" should be rendered for preview.
test_keys = false;
// If the test pivit highlight should be rendered.
pivot_highlight = false;
// If the minkowski sums should be used. Disable to help with debugging the shape.
do_minkowski = true;

// Base key size (mm).
key_size = [19.05, 19.05];
// Key socket size (mm).
key_socket = [14, 14];
// Key brim size above the socket (mm).
key_brim = [15.5, 15.5];
// Key clip size (mm).
key_clip_size = [1, key_socket[1] - 2, 1.25];

// Mounting plate thickness (mm).
plate_thickness = 2.6;
// Cavity height below the mounting plate (mm).
cavity_height = 1;
// Minimum edge margin around keys, excluding chamfer (mm).
edge_margin = 1.75;
// Edge chamfer size (mm).
edge_chamfer = 1.5;

// Tenting angle for the main 3 fingers (deg).
tenting_angle = 8;
// Split angle per side (deg).
split_angle = 14;
// Additional pinky splay angle (deg).
pinky_splay = 4;
// Standard row count.
row_count = plus_size ? 4 : 3;
// Standard column count.
column_count = 4;
// Stagger relative to baseline for the columns  (pinky, ring, middle, index, index 2) (U).
// This must be the same length as `column_count + 1`.
column_stagger = do_stagger
    ? [3 / -4, 0, 1 / 8, 1 / -8, 1 / -4]
    : [3 / -4, 0, 0, 0, 0];
// Pinky column count (left, right).
pinky_columns = plus_size ? [2, 3] : [1, 1];
// Spacing between split halves.
center_spacing = 20;

// Thumb key count.
thumb_count = 3;
// Extra 1u thumb keys.
thumb_extras = plus_size ? 2 : 1;
// Thumb key size (U).
thumb_size = [1, 1.25];
// Additional splay per thumb key (deg).
thumb_splay = 8;
// Offset from the inner-most column and bottom-most row (U).
thumb_offset = [-0.5, 0.5];

// Stagger sum for the "main" matrix (U).
stagger_sum = max([for (i = [1 : column_count]) column_stagger[i]])
    - min([for (i = [1 : column_count]) column_stagger[i]]);
// Stagger sum for the pinky column (U).
pinky_stagger = min([for (i = [1 : column_count]) column_stagger[i]])
    - column_stagger[0];
// Size for the "main" matrix (mm).
main_matrix_size = [
    cos(tenting_angle) * key_size[0] * column_count,
    key_size[1] * (row_count + stagger_sum),
    sin(tenting_angle) * key_size[0] * column_count
];

// Pin spacing on the MCU (mm).
mcu_pin_spacing = 2.54;
// Pin count on the MCU per side.
mcu_pin_count = 13;
// Space between pin centers on each side, by inclusive pin count.
mcu_header_spacing = 7;
// MCU size, excluding protruding ports (mm).
mcu_size = [19, 34, 3];
// MCU header height (mm).
// Header size assumes matching pin spacing and count.
mcu_header_height = 8;
//mcu_header_height = 6;

// USB plug size (mm, y and z swapped).
usb_plug_size = [8.75, 3, 6.65];
//usb_plug_size = [8.25, 2.4, 6.65];
// USB plug housing size (mm, y and z swapped).
usb_housing_size = [12.35, 6.5, 35];
// USB plug margin (mm).
usb_margin = 0.35;
// USB offset from the center, inside, bottom of the case (mm).
usb_offset = [
    0,
    0.5 + edge_chamfer,
    main_matrix_size[2] + cavity_height - usb_plug_size[1] / 2 - plate_thickness * 2
];

// Screw post size (radius, height) (mm).
post_size = [1.5, 3.25];
// Screw post wall thickness (mm).
post_walls = 2.5;


// Helper to calculate recursive thumb offset.
function splay(point, n = thumb_count) = n > 0
    ? splay(rotate_point2d(-thumb_splay, [point[0] + thumb_size[0], point[1]]), n - 1)
    : point;
// Calculated thumbs offsets (mm).
thumb_offsets = [for (thumb_index = [0 : thumb_count - 1])
    let(shift = splay([0, 0], n = thumb_index))
    rotate_point2d(-split_angle, [
        key_size[0] * (shift[0] + (column_count - 1) + thumb_offset[0]),
        key_size[1] * (shift[1] - thumb_offset[1] - thumb_size[1])
    ])
];

// Split X offset based on split angle (mm).
split_tenting_offset = key_size[0]
    * (-cos(split_angle) * column_count - sin(split_angle) * row_count)
    - (center_spacing / 2);
// Split X offset based on thumb positions (mm).
thumb_tenting_offset = -thumb_offsets[thumb_count - 1][0]
    - rotate_point2d(
        -(split_angle + thumb_splay * thumb_count),
        [thumb_size[0] * key_size[0], thumb_size[1] * key_size[1]]
    )[0];
// If the standard offset needs to be extended by instead using the thumb offset.
expand_offset = thumb_tenting_offset < split_tenting_offset;
// Offset to the tenting point (mm).
tenting_offset = [
    min(split_tenting_offset, thumb_tenting_offset) - (edge_margin / 2),
    key_size[1] * (sin(split_angle) * column_count - cos(split_angle) * row_count / 2)
];
// Calculated front inner Y edge at the center of the case (mm).
case_y_edge = tenting_offset[1] + rotate_point(
    [0, tenting_angle, -split_angle],
    [key_size[0] * column_count, key_size[1] * (row_count + stagger_sum), plate_thickness]
)[1];

// Partial calculations for screw post positions.
thumb_shift = rotate_point2d(
    -(split_angle + thumb_splay * thumb_count),
    [key_size[0] * thumb_size[0], 0]
);
top_offset = rotate_point([0, tenting_angle, -split_angle], [
    key_size[0] * (column_count - 1.5),
    main_matrix_size[1] - edge_chamfer,
    0
]);
inner_offset = rotate_point2d(
    split_angle,
    [key_size[0] * column_count - post_walls / 2, post_walls + post_size[0] * 2]
);
pinky_lb = rotate_point2d(
    -split_angle + pinky_splay,
    [
        key_size[0] * pinky_columns[0] + edge_chamfer - post_walls,
        key_size[1] * pinky_stagger + edge_chamfer - post_walls
    ]
);
pinky_lt = rotate_point2d(
    -split_angle + pinky_splay,
    [
        key_size[0] * pinky_columns[0] + edge_chamfer - post_walls,
        key_size[1] * (pinky_stagger - row_count) + edge_chamfer
    ]
);
pinky_rb = rotate_point2d(
    -split_angle + pinky_splay,
    [
        key_size[0] * (arrows ? ceil(pinky_columns[1] / 2) + 1 : pinky_columns[1])
            + edge_chamfer - post_walls,
        key_size[1] * ((arrows ? 1 : 0) + pinky_stagger) + edge_chamfer - post_walls
    ]
);
pinky_rt = rotate_point2d(
    -split_angle + pinky_splay,
    [
        key_size[0] * pinky_columns[1] + edge_chamfer - post_walls,
        key_size[1] * (pinky_stagger - row_count) + edge_chamfer
    ]
);
// Calculated screw postpositions.
screw_posts = [
    [0, tenting_offset[1] + thumb_offsets[thumb_count - 1][1] + thumb_shift[1] + post_walls, 0],
    [tenting_offset[0] + top_offset[0], tenting_offset[1] + top_offset[1], abs(top_offset[2])],
    [-tenting_offset[0] - top_offset[0], tenting_offset[1] + top_offset[1], abs(top_offset[2])],
    [-tenting_offset[0] - inner_offset[0], tenting_offset[1] - inner_offset[1], 0],
    [tenting_offset[0] + inner_offset[0], tenting_offset[1] - inner_offset[1], 0],
    [tenting_offset[0] - pinky_lb[0], tenting_offset[1] - pinky_lb[1], 0],
    [tenting_offset[0] - pinky_lt[0], tenting_offset[1] - pinky_lt[1], 0],
    [-tenting_offset[0] + pinky_rb[0], tenting_offset[1] - pinky_rb[1], 0],
    [-tenting_offset[0] + pinky_rt[0], tenting_offset[1] - pinky_rt[1], 0]
];


// Minkowski shape for edge chamfering.
module minkowski_shape(h, edge_margin, edge_chamfer) {
    r1 = edge_margin + edge_chamfer;
    r2 = edge_margin;
    translate([0, 0, -h + plate_thickness])
        if (edge_chamfer > 0) {
            cylinder(r = r1, h = h - edge_chamfer + 0.01);
            translate([0, 0, h - edge_chamfer])
                cylinder(r1 = r1, r2 = r2, h = edge_chamfer);
        } else {
            cylinder(r = r1, h = h);
        }
}


// Keyboard half positive.
module shell_half(right = false, cavity = false, do_minkowski = do_minkowski) {
    original_edges = edge_margin * 2 + edge_chamfer;
    edge_margin = (cavity ? 0 : edge_margin) + 0.1;
    edge_chamfer = (cavity ? 0 : edge_chamfer) + (edge_chamfer / 2);
    z_offset = (cavity ? 0 : plate_thickness) + cavity_height;
    h = cavity ? 100 : (plate_thickness + cavity_height);
    scale_if(right, [-1, 1, 1]) {
        translate(concat(tenting_offset, [z_offset])) {
            // Pivot highlight.
            if (pivot_highlight && !cavity) {
                translate([0, 0, -25]) cylinder(r = 0.5, h = 100);
            }
            // Tented matrix.
            minkowski_if(do_minkowski) {
                rotate([0, -tenting_angle, -split_angle])
                    translate([0, 0, -plate_thickness])
                        cube([
                            key_size[0] * column_count,
                            key_size[1] * (row_count + stagger_sum),
                            plate_thickness
                        ]);
                minkowski_shape(h, edge_margin, edge_chamfer);
            }
            // Pinky matrix.
            if (pinky_columns[right ? 1 : 0] > 0) {
                rotate([0, 0, -split_angle + pinky_splay])
                    minkowski_if(do_minkowski) {
                        translate([
                            -key_size[0] * pinky_columns[right ? 1 : 0],
                            -key_size[1] * pinky_stagger,
                            -plate_thickness
                        ])
                            cube([
                                key_size[0] * pinky_columns[right ? 1 : 0],
                                key_size[1] * row_count,
                                plate_thickness
                            ]);
                        minkowski_shape(h, edge_margin, edge_chamfer);
                    }
            }
            // Arrows.
            if (arrows && right) minkowski_if(do_minkowski) {
                pinky_offset = pinky_columns[1] > 0 ? ceil(pinky_columns[1] / 2) : -1;
                rotate([0, 0, -split_angle + pinky_splay])
                    translate([
                        -key_size[0] * (pinky_offset + 1),
                        -key_size[1] * ((pinky_columns[1] > 0 ? 1 : 2) + pinky_stagger),
                        -plate_thickness
                    ])
                    cube([key_size[0] * 3, key_size[1] * 2, plate_thickness]);
                minkowski_shape(h, edge_margin, edge_chamfer);
            }
            // Thumbs polyhedron.
            minkowski_if(do_minkowski) {
                last_thumb = thumb_offsets[thumb_count - 1];
                last_thumb_inner = [
                    last_thumb[0] + thumb_shift[0],
                    last_thumb[1] + thumb_shift[1]
                ];
                translate([0, 0, -plate_thickness])
                    linear_extrude(plate_thickness)
                    polygon(concat(
                        [
                            rotate_point2d(
                                -split_angle + pinky_splay,
                                [0, -key_size[1] * pinky_stagger]
                            ),
                            rotate_point2d(-split_angle, [main_matrix_size[0], 0]),
                            [
                                -tenting_offset[0],
                                rotate_point2d(-split_angle, [main_matrix_size[0], 0])[1]
                            ],
                            [-tenting_offset[0], last_thumb_inner[1]],
                            last_thumb_inner
                        ],
                        [for (i = [thumb_count - 1 : -1 : 0]) thumb_offsets[i]]
                    ));
                minkowski_shape(h, edge_margin, edge_chamfer);
            }
            // Extra thumb keys.
            if (thumb_extras > 0) {
                minkowski_if(do_minkowski) {
                    edge_offset = rotate_point2d(
                        split_angle,
                        [key_size[0] * thumb_extras, 0]
                    );
                    translate([0, 0, -plate_thickness])
                        linear_extrude(plate_thickness)
                        polygon(concat(
                            [
                                rotate_point2d(
                                    -split_angle + pinky_splay,
                                    [0, -key_size[1] * pinky_stagger]
                                ),
                                thumb_offsets[0],
                                [
                                    thumb_offsets[0][0] - edge_offset[0],
                                    thumb_offsets[0][1] + edge_offset[1],
                                ]
                            ],
                            right && arrows
                                ? [rotate_point2d(-split_angle + pinky_splay,
                                    [0, -key_size[1] * (1 + pinky_stagger)]
                                )] : []
                        ));
                    minkowski_shape(h, edge_margin, edge_chamfer);
                }
            }
            // Thumb fill.
            minkowski_if(do_minkowski) {
                splay_offset = rotate_point2d(
                    -split_angle - (thumb_count * thumb_splay),
                    [
                        key_size[0] + thumb_size[0],
                        key_size[1] * thumb_size[1]
                            + original_edges * 2
                    ]
                );
                last_thumb = thumb_offsets[thumb_count - 1];
                inner_point = [
                    min(-tenting_offset[0], last_thumb[0] + splay_offset[0]) - 0.1,
                    last_thumb[1] + splay_offset[1]
                ];
                top_point = rotate_point2d(-split_angle, [main_matrix_size[0], 0]);
                linear_extrude(main_matrix_size[2])
                    polygon(concat(
                        [
                            top_point,
                            [-tenting_offset[0], top_point[1]],
                            [-tenting_offset[0], inner_point[1]]
                        ],
                        expand_offset ? [] : [inner_point]
                    ));
                minkowski_shape(h, edge_margin, edge_chamfer);
            }
            // Gap fill polyhedrons.
            rotate([0, 0, -split_angle]) {
                // Pinky top fill.
                if (pinky_columns[right ? 1 : 0] > 0) {
                    minkowski_if(do_minkowski) {
                        translate([0, 0, -plate_thickness])
                            linear_extrude(plate_thickness)
                            polygon(concat(
                                pinky_splay > 0 ? [[0, 0]] : [],
                                [
                                    rotate_point2d(pinky_splay, [
                                        0,
                                        (row_count - pinky_stagger) * key_size[1]
                                    ]),
                                    rotate_point2d(pinky_splay, [
                                        -1 * key_size[0],
                                        (row_count - pinky_stagger) * key_size[1]
                                    ]),
                                    [0, main_matrix_size[1]]
                                ]
                            ));
                        minkowski_shape(h, edge_margin, edge_chamfer);
                    }
                }
                // Front tenting fill.
                minkowski_if(do_minkowski) {
                    union() {
                        translate([0, 0.1, -plate_thickness])
                            rotate([90, 0, 0])
                            linear_extrude(0.1)
                            polygon([
                                [0, 0],
                                [main_matrix_size[0], main_matrix_size[2]],
                                [main_matrix_size[0], 0]
                            ]);
                        translate([0, 0, -plate_thickness])
                            linear_extrude(plate_thickness)
                            polygon([
                                [0, 0],
                                [main_matrix_size[0], 0],
                                rotate_point2d(
                                    pinky_splay,
                                    [0, -key_size[1] * pinky_stagger]
                                )
                            ]);
                    }
                    minkowski_shape(h, edge_margin, edge_chamfer);
                }
            }
            // Center and back fill.
            offset_point = rotate_point2d(-split_angle, [
                key_size[0] * column_count,
                key_size[1] * (row_count + stagger_sum)
            ]);
            offset_diff = -tenting_offset[0] - offset_point[0] + edge_margin + edge_chamfer;
            rotate([0, 0, -split_angle])
                translate([
                    main_matrix_size[0],
                    main_matrix_size[1],
                    -plate_thickness
                ])
                rotate([0, 0, split_angle]) {
                    minkowski_if(do_minkowski) {
                        translate([0, -0.1, 0]) cube([offset_diff, 0.1, main_matrix_size[2]]);
                        minkowski_shape(h, edge_margin, edge_chamfer);
                    }
                    minkowski_if(do_minkowski) {
                        rotate([90, 0, -split_angle])
                            linear_extrude(0.1)
                            polygon([
                                [0.01, 0],
                                [0.01, main_matrix_size[2]],
                                [-main_matrix_size[0], 0]
                            ]);
                        minkowski_shape(h, edge_margin, edge_chamfer);
                    }
                    minkowski_if(do_minkowski) {
                        translate([0, 0, main_matrix_size[2] - 0.1])
                            linear_extrude(plate_thickness + 0.1)
                            polygon([
                                [0, 0],
                                rotate_point2d(-split_angle, [0, -main_matrix_size[1]]),
                                [
                                    offset_diff,
                                    cos(-split_angle) * -main_matrix_size[1]
                                ],
                                [offset_diff, 0]
                            ]);
                        minkowski_shape(h, edge_margin, edge_chamfer);
                    }
                }
        }
    }
}


module matrix_half(right = false) {
    scale_if(right, [-1, 1, 1]) {
        translate(concat(tenting_offset, [plate_thickness + cavity_height])) {
            // Main matrix.
            matrix_offset = min([for (i = [1 : column_count]) column_stagger[i]]);
            rotate([0, -tenting_angle, -split_angle])
                translate([0, 0, -plate_thickness])
                for (column = [1 : column_count]) {
                    translate([
                        (column - 1) * key_size[0],
                        (column_stagger[column] - matrix_offset) * key_size[1],
                        0
                    ])
                        for (row = [0 : row_count - 1]) {
                            translate([0, row * key_size[1], 0])
                                children(0);
                        }
                }
            // Pinky_matrix.
            if (pinky_columns[right ? 1 : 0] > 0) {
                rotate([0, 0, -split_angle + pinky_splay]) {
                    translate([
                        -key_size[0] * pinky_columns[right ? 1 : 0],
                        -key_size[1] * pinky_stagger,
                        -plate_thickness
                    ])
                    for (column = [0 : pinky_columns[right ? 1 : 0] - 1]) {
                        translate([column * key_size[0], 0, 0])
                            for (row = [0 : row_count - 1]) {
                                translate([0, row * key_size[1], 0])
                                    children(0);
                            }
                    }
                }
            }
            // Arrows.
            if (right && arrows) {
                pinky_offset = pinky_columns[1] > 0 ? ceil(pinky_columns[1] / 2) : -1;
                rotate([0, 0, -split_angle + pinky_splay])
                    translate([
                        -key_size[0] * (pinky_offset + 1),
                        -key_size[1] * ((pinky_columns[1] > 0 ? 1 : 2) + pinky_stagger),
                        -plate_thickness
                    ])
                        for (column = [0 : 2]) {
                            for (row = [0 : 1]) {
                                translate([key_size[0] * column, key_size[1] * row, 0])
                                    children(0);
                            }
                        }
            }
            // Thumbs.
            for (thumb_index = [1 : thumb_count]) {
                thumb_offset = thumb_offsets[thumb_index - 1];
                translate(concat(thumb_offset, [-plate_thickness]))
                    rotate([0, 0, -split_angle - thumb_index * thumb_splay])
                    children($children - 1);
            }
            // Extra thumb keys.
            if (thumb_extras > 0) {
                thumb_offset = thumb_offsets[0];
                splay_offset = rotate_point2d(
                    thumb_splay,
                    [0, thumb_size[1] - key_size[1]]
                );
                translate([
                    thumb_offset[0],// - splay_offset[0],
                    thumb_offset[1],// - splay_offset[1],
                    -plate_thickness
                ])
                    rotate([0, 0, -split_angle])
                    for (column = [1 : thumb_extras]) {
                        translate([key_size[0] * -column, 0, 0])
                            children(0);
                    }
            }
        }
    }
}


module screw_post(
    inner = post_size[0],
    outer = post_size[0] + post_walls,
    taper = 0.25,
    depth = post_size[1],
    h
) {
    difference() {
        cylinder(r = outer, h = h);
        translate([0, 0, -0.1]) cylinder(r1 = inner + taper, r2 = inner, h = depth + 0.1);
    }
}


module switch_socket(key_size = key_size, key_socket = key_socket, thumbs = false) {
    translate([key_size[0] / 2, key_size[1] / 2, plate_thickness + 0.1]) {
        translate([key_socket[0] / -2, key_socket[1] / -2, -1])
            cube(concat(key_socket, [plate_thickness + 1.1]));
        translate([key_brim[0] / -2, key_brim[1] / -2, + plate_thickness])
            cube(concat(key_brim, [5]));
        translate([0, 0, -1])
            rotate([0, 0, thumbs ? 90 : 0])
            linear_extrude(key_clip_size[2] + 1)
            polygon([
                [key_socket[0] / -2, key_socket[1] / -2],
                [key_socket[0] / -2 - key_clip_size[0], key_clip_size[1] / -2],
                [key_socket[0] / -2 - key_clip_size[0], key_clip_size[1] / 2],
                [key_socket[0] / -2, key_socket[1] / 2],
                [key_socket[0] / 2, key_socket[1] / 2],
                [key_socket[0] / 2 + key_clip_size[0], key_clip_size[1] / 2],
                [key_socket[0] / 2 + key_clip_size[0], key_clip_size[1] / -2],
                [key_socket[0] / 2, key_socket[1] / -2]
            ]);
    }
}


module keyboard() union() {
    difference() {
        // Shell.
        union() {
            shell_half();
            shell_half(right = true);
        }
        if (do_minkowski) {
            shell_half(cavity = true);
            shell_half(right = true, cavity = true);
        }//}{
        // Socket subtraction.
        matrix_half() {
            switch_socket();
            translate([
                key_size[0] * ((thumb_size[0] - 1) / 2),
                key_size[1] * (thumb_size[1] - 1) / 2,
                0
            ])
                switch_socket(thumbs = rotate_thumbs);
        }
        matrix_half(right = true) {
            switch_socket();
            translate([
                key_size[0] * ((thumb_size[0] - 1) / 2),
                key_size[1] * (thumb_size[1] - 1) / 2,
                0
            ])
                switch_socket(thumbs = rotate_thumbs);
        }
        // USB.
        usb_radius = usb_plug_size[1] / 2;
        translate([usb_offset[0], usb_offset[1] + case_y_edge, usb_offset[2]])
            rotate([90, 0, 0]) {
                translate([0, 0, usb_plug_size[2] / 2])
                    rounded_cubeoid([for (i = usb_plug_size) i + usb_margin], usb_radius);
                translate([0, 0, -usb_housing_size[2] / 2])
                    rounded_cubeoid([for (i = usb_housing_size) i + usb_margin], usb_radius);
            }
        // Cross-section slice.
        //translate([0, -200, -100]) cube([400, 400, 200]);
    }
    // MCU mount.
    mount_width = (mcu_header_spacing - 2) * mcu_pin_spacing;
    translate([
        0,
        case_y_edge - mcu_size[1] + edge_chamfer / 2 + 0.1,
        usb_offset[2] + usb_plug_size[1] / 2 + usb_margin / 2
    ]) {
        translate([mount_width / -2, 0, 0])
            cube([mount_width, mcu_size[1] + 0.1, mcu_header_height + 0.1]);
        translate([mount_width / -2, -2, -mcu_size[2]])
            difference() {
                cube([mount_width, 2.01, mcu_header_height + 0.1 + mcu_size[2]]);
                translate([mount_width / 2, 0, mcu_size[2] / 2])
                    rotate([0, 0, 45])
                    cube([mount_width / 2, mount_width / 2, mcu_size[2] + 1], center = true);
       }
    }
    // Screw posts.
    difference() {
        for (post_info = screw_posts) {
            h = cavity_height + plate_thickness + 0.1 + post_info[2];
            translate([post_info[0], post_info[1], 0]) screw_post(h = h);
        }
        // Socket subtraction.
        matrix_half() {
            switch_socket();
            translate([
                key_size[0] * ((thumb_size[0] - 1) / 2),
                key_size[1] * (thumb_size[1] - 1) / 2,
                0
            ])
                switch_socket(thumbs = rotate_thumbs);
        }
        matrix_half(right = true) {
            switch_socket();
            translate([
                key_size[0] * ((thumb_size[0] - 1) / 2),
                key_size[1] * (thumb_size[1] - 1) / 2,
                0
            ])
                switch_socket(thumbs = rotate_thumbs);
        }
     }
}


//projection()
if (split_board) {
    // Left half.
    translate([10, 0, 0])
        rotate([0, 90, 0])
        difference() {
            keyboard();
            translate([0, -200, -100]) cube([400, 400, 200]);
        }
    // Right half.
    translate([-10, 0, 0])
        rotate([0, -90, 0])
        difference() {
            keyboard();
            translate([-400, -200, -100]) cube([400, 400, 200]);
        }
} else {
    keyboard();
}


if (test_keys && !split_board) {
    color("grey")
    matrix_half() {
        translate([0.5, 0.5, 0])
            cube([key_size[0] - 1, key_size[1] - 1, plate_thickness + cavity_height + 7.5]);
        translate([0.5, 0.5, 0])
            cube([
                key_size[0] * thumb_size[0] - 1,
                key_size[1] * thumb_size[1] - 1,
                plate_thickness + cavity_height + 7.5
            ]);
    }
    color("grey")
    matrix_half(right = true) {
        translate([0.5, 0.5, 0])
            cube([key_size[0] - 1, key_size[1] - 1, plate_thickness + cavity_height + 7.5]);
        translate([0.5, 0.5, 0])
            cube([
                key_size[0] * thumb_size[0] - 1,
                key_size[1] * thumb_size[1] - 1,
                plate_thickness + cavity_height + 7.5
            ]);
    }
}