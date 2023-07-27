use <../common.scad>;
$fs = 1;


socket_dummy = false;
switch_surround = true;
chamfer_case = true;
route_wires = true;
round_wires = false;


spacing = [18, 17];
half_angle = 10;
half_spec = [
    [0, [1, 1, 1]],
    [0, [1, 1, 1]],
    [-0.25, [1, 1, 1]],
    [0.25, [1, 1, 1]],
    [0.25, [1, 1, 1]]
];
arrow_spec = [
    [0, [1]],
    [-1, [1, 1]],
    [1, [1]]
];
plate_height = 2.2 + 3.1;
surround_height = 4;
surround_chamfer = 2;
surround_radius = 1;
case_chamfer = 3;
case_size = [237, 105, plate_height + surround_height];
battery_size = [50, 34, 7];
switch_size = 14;
switch_spacing = (spacing[0] - switch_size);


module key_fill(size = 1) {
    if (switch_dummy) {
        rounded_cubeoid(
            [spacing[0] * size - 1, spacing[1] - 1, 14],
            r = chamfer_case ? 1 : 0
        );
    } else {
        choc_switch_negative(socket_dummy = socket_dummy);
        choc_socket_diode(rounded = round_wires);
        if (switch_surround) {
            width = spacing[0] * size + 2;
            height = spacing[1] + 2;
            translate([0, 0, plate_height - surround_height / 2 + 2])
                rounded_cubeoid(
                    [width, height, surround_height + 2],
                    r = chamfer_case ? surround_radius : 0
                );
            if (chamfer_case && surround_chamfer > 0) {
                chamfer_size = sqrt(pow(surround_chamfer, 2) / 2);
                translate([0, height / 2, surround_height + 2.2])
                    rotate([45, 0, 0])
                    cube([width - surround_radius, chamfer_size, chamfer_size], center = true);
                translate([0, height / -2, surround_height + 2.2])
                    rotate([45, 0, 0])
                    cube([width - surround_radius, chamfer_size, chamfer_size], center = true);
                translate([width / 2, 0, surround_height + 2.2])
                    rotate([0, 45, 0])
                    cube([chamfer_size, height - surround_radius, chamfer_size], center = true);
                translate([width / -2, 0, surround_height + 2.2])
                    rotate([0, 45, 0])
                    cube([chamfer_size, height - surround_radius, chamfer_size], center = true);
                for(position = [[-1, -1, 180], [-1, 1, 90], [1, 1, 0], [1, -1, 270]]) {
                    translate([
                        (width / 2 - surround_radius) * position[0],
                        (height / 2 - surround_radius) * position[1],
                        surround_height + 2.2
                    ])
                        rotate([0, 0, position[2]])
                        rotate_extrude(angle = 90)
                        translate([surround_radius, 0, 0])
                        rotate([0, 0, 45])
                        square(chamfer_size, center = true);
                }
            }
        }
    }
}


module row_wire_negative() {
    rotate([0, 180, 90])
        wire_channel(switch_size * 2 + switch_spacing * 2, rounded = round_wires);
    translate([-switch_size * 2 - switch_spacing * 2, 0, 0])
        rotate([0, 180, 0])
        wire_channel(spacing[1] * 0.25, rounded = round_wires, cap = true);
    translate([-switch_size * 2 - switch_spacing * 2, spacing[1] * 0.25, 0])
        rotate([0, 180, 90])
        wire_channel(switch_size, rounded = round_wires);
    translate([-switch_size * 3 - switch_spacing * 2, spacing[1] * 0.25, 0])
        rotate([0, 180, 180])
        wire_channel(spacing[1] * 0.25, rounded = round_wires, cap = true);
    translate([-switch_size * 3 - switch_spacing * 2, 0, 0])
        rotate([0, 180, 90])
        wire_channel(switch_size + switch_spacing, rounded = round_wires);    
    translate([-switch_size * 4 - switch_spacing * 3, 0, 0])
        rotate([0, 180, 180])
        wire_channel(spacing[1] * 0.25, rounded = round_wires, cap = true);
    translate([-switch_size * 4 - switch_spacing * 3, -spacing[1] * 0.25, 0])
        rotate([0, 180, 90])
        wire_channel(switch_size + switch_spacing, rounded = round_wires);    
}


module key_positive(flip = false) {
    render()
        difference() {
            translate([0, 0, plate_height / 2])
                cube([
                    spacing[0] + 0.02,
                    spacing[1] + 0.02,
                    plate_height
                ], center = true);
            translate([0, 0, 0])
                choc_switch_negative(socket_dummy = socket_dummy);
            if (route_wires) {
                choc_socket_diode(rounded = round_wires);
            }
        }
}


module half_hand(flip = false) {
    translate([0, spacing[1] * 1.5, 0])
        rotate([0, 0, half_angle * (flip ? 1 : -1)]) {
            scale_if(flip, [-1, 1, 1]) {
                translate([-spacing[0] / 2, 0, 0]) {
                    columns(half_spec, spacing = spacing)
                        scale_if(flip, [-1, 1, 1]) key_positive();
                }
                translate([spacing[1] * 1.5 - 1.25, spacing[0] * -3.75 + 3, 0])
                    rotate([0, 0, 270])
                    column([1, 1, 1], spacing = spacing[1])
                    scale_if(flip, [-1, 1, 1]) key_positive();
            }
        }
}


module half_hand_negative(flip = false) {
    translate([0, spacing[1] * 1.5, 0])
        rotate([0, 0, half_angle * (flip ? 1 : -1)]) {
            scale_if(flip, [-1, 1, 1]) {
                translate([-spacing[0], -spacing[1] / 2, -0.5]) {
                    columns(half_spec, spacing = spacing)
                        cube([spacing[0], spacing[1], plate_height + 1]);
                }
                translate([spacing[1] - 1.25, spacing[0] * -3.25 + 3, -0.5])
                    rotate([0, 0, 270])
                    column([1, 1, 1], spacing = spacing[1])
                        cube([spacing[0], spacing[1], plate_height + 1]);
            }
        }
}


union() {
    difference() {
        // Main positive.
        translate([0, 0, plate_height / 2])
            rounded_cubeoid(
                [case_size[0], case_size[1], plate_height],
                r = chamfer_case ? case_chamfer : 0
            );
        // Half hand cutouts.
        translate([-15, 8.5, 0])
            half_hand_negative();
        translate([15, 8.5, 0])
            half_hand_negative(flip = true);
        // Controller bay.
        translate([0, 20, plate_height / 2])
            rounded_cubeoid(
                [spacing[0] * 1.5 - 4, spacing[1] * 3.5, plate_height + 1],
                r = chamfer_case ? 1 : 0
            );
        // Battery bay.
        translate([
            (case_size[0] - battery_size[0]) / -2 + 6,
            (case_size[1] - battery_size[1]) / -2 + 6,
            battery_size[2] / 2 - 0.02
        ]) {
            rounded_cubeoid(battery_size, r = chamfer_case ? 1 : 0);
            translate([0, 0, (battery_size[2] - 2) / -2])
                rounded_cubeoid(
                    [battery_size[0] + 4, battery_size[1] + 4, 2],
                    r = chamfer_case ? 1.5 : 0
                );
            translate([0, 0, (battery_size[2] - 3) / -2])
                cube([battery_size[0] + 7, battery_size[1] / 2, 1], center = true);
        }
    }
    // Half hands.
    translate([-15, 8.5, 0])
        half_hand();
    translate([15, 8.5, 0])
        half_hand(flip = true);
}


/*
difference() {
    height = switch_surround ? case_size[2] : plate_height;
    // Main positive.
    translate([0, 0, height / 2])
            rounded_cubeoid(
                [case_size[0], case_size[1], height],
                r = chamfer_case ? case_chamfer : 0
            );
    // Case chamfering.
    if (chamfer_case) {
        chamfer_size = sqrt(pow(case_chamfer, 2) / 2);
        translate([0, case_size[1] / 2, height])
            rotate([45, 0, 0])
            cube([case_size[0], chamfer_size, chamfer_size], center = true);
        translate([0, case_size[1] / -2, height])
            rotate([45, 0, 0])
            cube([case_size[0], chamfer_size, chamfer_size], center = true);
        translate([case_size[0] / 2, 0, height])
            rotate([0, 45, 0])
            cube([chamfer_size, case_size[1], chamfer_size], center = true);
        translate([case_size[0] / -2, 0, height])
            rotate([0, 45, 0])
            cube([chamfer_size, case_size[1], chamfer_size], center = true);
        for(position = [[-1, -1, 180], [-1, 1, 90], [1, 1, 0], [1, -1, 270]]) {
            translate([
                (case_size[0] / 2 - case_chamfer) * position[0],
                (case_size[1] / 2 - case_chamfer) * position[1],
                height
            ])
                rotate([0, 0, position[2]])
                rotate_extrude(angle = 90)
                translate([case_chamfer, 0, 0])
                rotate([0, 0, 45])
                square(chamfer_size, center = true);
        }
    }
    // Hand halves.
    translate([-15, 8.5, -0.02])
        half_hand_negative();
    translate([15, 8.5, -0.02])
        half_hand_negative(flip = true);
    // Inverted-T arrows.
    translate([
        (case_size[0] - spacing[0]) / 2 - 5,
        (case_size[1] - spacing[1] * 2) / -2 + 5,
        3 - 0.02
    ])
        columns(arrow_spec, spacing = spacing) key_fill();
    // Controller bay.
    translate([5, 10, height / 2 - 2])
        rotate([0, 0, half_angle])
        rounded_cubeoid(
            [spacing[0] * 1.5 - 7, spacing[1] * 3, height],
            r = chamfer_case ? 1 : 0
        );
    translate([-5, 10, height / 2 - 2])
        rotate([0, 0, -half_angle])
        rounded_cubeoid(
            [spacing[0] * 1.5 - 7, spacing[1] * 3, height],
            r = chamfer_case ? 1 : 0
        );
    translate([0, 24, height / 2 - 2])
        rounded_cubeoid(
            [spacing[0] * 1.5 - 4, spacing[1] * 3, height],
            r = chamfer_case ? 1 : 0
        );
    // Battery bay.
    translate([
        (case_size[0] - battery_size[0]) / -2 + 6,
        (case_size[1] - battery_size[1]) / -2 + 6,
        battery_size[2] / 2 - 0.02
    ]) {
        rounded_cubeoid(battery_size, r = chamfer_case ? 1 : 0);
        translate([0, 0, (battery_size[2] - 2) / -2])
            rounded_cubeoid(
                [battery_size[0] + 4, battery_size[1] + 4, 2],
                r = chamfer_case ? 1.5 : 0
            );
        translate([0, 0, (battery_size[2] - 3) / -2])
            cube([battery_size[0] + 7, battery_size[1] / 2, 1], center = true);
    }
}*/