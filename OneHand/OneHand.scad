use <../common.scad>

$fs = $preview ? 1 : 0.5;
$fa = $preview ? 10 : 2;

key_size = 19;
socket_size = 14;
lip_size = 1;
board_size = [6 + 3.25, 4];
plate_height = 1.2;
top_height = 2.5;
cavity_height = 3;
edge_radius = 2;
edge_padding = 2.5;

main_matrix = [6, 3];
thumb_row = [1.25, 1, 1.5, 1, 1.25];

post_size = [7, 3.4, 3, 3.5];

mcu = [51.2, 21.2, max(4.5, cavity_height + top_height - 1)];
mcu_pcb = 1.2;
mcu_offset = 0.8;


module minkowski_shape(h = top_height + cavity_height, r = edge_radius) {
    union() {
        difference() {
            translate([0, 0, h - r]) sphere(r);
            translate([0, 0, -r]) cylinder(r, r = r);
        }
        if (h - r > 0) {
            cylinder(h - r, r = r);
        }
    }
}


module socket_negative() {
    translate([0, 0, cavity_height + (top_height + 0.5) / 2])
        cube([socket_size, socket_size, top_height + 1], center = true);
    partial_height = top_height - plate_height;
    translate([0, 0, cavity_height + (partial_height + 0.1) / 2])
        cube(
            [socket_size + lip_size * 2, socket_size + lip_size * 2, partial_height + 0.2],
            center = true
        );
}


module post(positive = true) {
    if (positive) {
        cylinder(h = cavity_height + top_height / 2, d = post_size[0]);
    } else {
        cylinder(h = post_size[3], d1 = post_size[1], d2 = post_size[2]);
    }
}


module clip(width = 2.54 * 2, thickness = 2.54) {
    translate([width / -2, -thickness, 0]) cube([width, thickness, mcu[2] + 0.01]);
    translate([width / -2, 0, mcu_pcb + mcu_offset])
        cube([width, thickness, mcu[2] + 0.01 - mcu_pcb - mcu_offset]);
    translate([width / -2, 0, 0])
        cube([width, 0.75, mcu_offset]);
}


union() {
    difference() {
        minkowski() {
            translate([0, 0, 0.05]) cube([
                board_size[0] * key_size + edge_padding * 2,
                board_size[1] * key_size + edge_padding * 2,
                0.1
            ], center = true);
            minkowski_shape();
        }
        difference() {
            minkowski() {
                cube([
                    board_size[0] * key_size,
                    board_size[1] * key_size,
                    0.1
                ], center = true);
                minkowski_shape(h = cavity_height, r = 0.5);
            }
            for (p = [[-1, -1], [-1, 1], [1, -1], [1, 1]]) {
                x = p[0] * (board_size[0] * key_size / 2);
                y = p[1] * (board_size[1] * key_size / 2);
                translate([x, y, 0]) post();
            }
        }
        translate([board_size[0] * key_size / -2, board_size[1] * key_size / 2, 0])
            for (y = [0 : main_matrix[1] - 1]) {
                for (x = [0 : main_matrix[0] - 1]) {
                    translate([key_size * x + key_size / 2, key_size * -y - key_size / 2, 0])
                        socket_negative();
                }
            }
        translate([board_size[0] * key_size / -2, board_size[1] * key_size / -2, 0])
            for (x = [0 : len(thumb_row) - 1]) {
                x_offset = sum([for (ox = [0 : x]) key_size * (thumb_row[ox] - 1) / (ox == x ? 2 : 1)]);
                translate([key_size * x + key_size / 2 + x_offset, key_size / 2, 0])
                    socket_negative();
            }
        translate([board_size[0] * key_size / 2, board_size[1] * key_size / -2, 0])
            for (n = [0 : 3]) {
                x = n < 3 ? n : 1;
                y = n < 3 ? 0 : 1;
                translate([key_size * -x - key_size / 2, y * key_size + key_size / 2, 0])
                    socket_negative();
            }
        translate([
            board_size[0] * key_size / 2 - mcu[0] / 2 + edge_padding,
            board_size[1] * key_size / 2 - mcu[1] / 2 - post_size[0],
            mcu[2] / 2 - 0.1
        ]) {
            cube(mcu, center = true);
            translate([mcu[0] / 2, 0, 0])
                cube([(edge_padding * edge_radius) * 2, 8, mcu[2]], center = true);
        }
        for (p = [[-1, -1], [-1, 1], [1, -1], [1, 1]]) {
            x = p[0] * (board_size[0] * key_size / 2);
            y = p[1] * (board_size[1] * key_size / 2);
            translate([x, y, 0]) post(positive = false);
        }
    }
    translate([
        board_size[0] * key_size / 2 - mcu[0] / 2 + edge_padding,
        board_size[1] * key_size / 2 - mcu[1] / 2 - post_size[0],
        0
    ]) {
        translate([mcu[0] / 2 - 2.54 * 3, mcu[1] / -2, 0])
            clip();
        translate([mcu[0] / 2 - 2.54 * 3, mcu[1] / 2, 0])
            rotate([0, 0, 180]) clip();
        translate([mcu[0] / -2, 0, 0]) union() {
            rotate([0, 0, -90]) clip(width = 8);
            difference() {
                union() {
                    translate([-1.8, -5.7, mcu_pcb + mcu_offset])
                        cube([8, 11.4, mcu[2] - mcu_pcb - mcu_offset]);
                    translate([2.2, 11.4 / 2, mcu_pcb + mcu_offset])
                        cylinder(h = mcu[2] - mcu_pcb - mcu_offset, d = 8);
                    translate([2.2, 11.4 / -2, mcu_pcb + mcu_offset])
                        cylinder(h = mcu[2] - mcu_pcb - mcu_offset, d = 8);
                }
                translate([2.2, 11.4 / 2, mcu_pcb + mcu_offset - 0.1]) post(positive = false);
                translate([2.2, 11.4 / -2, mcu_pcb + mcu_offset - 0.1]) post(positive = false);
            }
        }
        translate([mcu[0] / 2 - 1.37 - 2.54 * 1.5, 5.7, mcu_pcb + mcu_offset]) difference() {
            cylinder(h = mcu[2] - mcu_pcb - mcu_offset, d = 6.5);
            translate([0, 0, -0.1])
                cylinder(h = mcu[2] - mcu_pcb - mcu_offset + 0.2, d = 4);
            translate([0, -5.7, -mcu_pcb - mcu_offset])
                cube([10, 9, mcu[0]], center = true);
        }
        translate([mcu[0] / 2 - 1.37 - 2.54 * 4.25, 4, mcu[2] - 0.24]) difference() {
            cube([5.2, 4.2, 0.5], center = true);
            translate([0.6, 0, 0]) cylinder(h = 1, r = 1.75, center = true);
            translate([-0.6, 0, 0]) cylinder(h = 1, r = 1.75, center = true);
            cube([1.2, 3.5, 1], center = true);
        }
    }
}