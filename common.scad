function flatten(v) = [for (a = v) for (b = a) b];


function sum(v, i = 0, n = 0) = i < len(v) ? sum(v, i = i + 1, n = n + v[i]) : n;


function rotate_point2d(angle, point) = [
    (cos(angle) * point[0]) + (cos(90 - angle) * -point[1]),
    (sin(90 - angle) * point[1]) + (sin(angle) * point[0])
];


function rotate_point(angles, point) = let(
    rotate_x = rotate_point2d(angles[0], [point[1], point[2]]), // [y, z]
    rotate_y = rotate_point2d(angles[1], [rotate_x[1], point[0]]), // [z, x]
    rotate_z = rotate_point2d(angles[2], [rotate_y[1], rotate_x[0]]) // [x, y]
) [
    rotate_z[0], rotate_z[1], rotate_y[0] // [x, y, z]
];


function rotate_points(angles, points) = [
    for (point = points) rotate_point(angles, point)
];


module scale_if(condition, scaling) {
    if (condition) {
        scale(scaling) children();
    } else {
        children();
    }
}


module minkowski_if(condition) {
    if (condition) {
        minkowski() {
            children(0);
            children(1);
        }
    } else {
        children(0);
    }
}


module basic_socket_negative(hole = 14, ledge = 1.65, lip = 1.25, taper = 0.75, thickness = 4) {
    half_hole = hole / 2;
    base_width = hole + ((lip + taper) * 2);
    lip_width = base_width - (taper * 2);
    union() {
        translate([-half_hole, -half_hole, thickness - ledge - 0.001])
            cube([hole, hole, ledge + 0.001]);
        linear_extrude(thickness - ledge, scale = lip_width / base_width)
            square(base_width, center = true);
    }
}


module choc_socket_negative(thickness = 1.9, path = "ChocSwap/socket-outline-expanded.svg") {
    union() {
        translate([0, 0, -0.05])
            linear_extrude(thickness)
            import(path, center = true);
        translate([-2.5, 1.1, 1.8])
            cylinder(h = 1.3, d = 3.1);
        translate([2.5, -1.1, 1.8])
            cylinder(h = 1.3, d = 3.1);
    }
}

module choc_socket_dummy() {
    union() {
        translate([4.8, -2.4, -0.05])
            cube([2.8, 2.4, 1.9]);
        translate([-7.6, 0, -0.05])
            cube([2.8, 2.4, 1.9]);
        translate([0, -3.5, -0.05])
            cube([5, 4.65, 1.9]);
        translate([-5, -1.3, -0.05])
            cube([5, 4.65, 1.9]);
        translate([-2.5, 1.1, 1.8])
            cylinder(h = 1.3, d = 3.1);
        translate([2.5, -1.1, 1.8])
            cylinder(h = 1.3, d = 3.1);
    }
}


module choc_switch_negative(tolerance = [0.1, 0.1, 0.01], socket_dummy = false) {
    union() {
        // Plate lip.
        translate([(14.5 + tolerance[0]) / -2, (13.8 + tolerance[1]) / -2, 3.1 - tolerance[2]])
            cube([14.5 + tolerance[0], 13.8 + tolerance[1], 0.9 + tolerance[2] * 2]);
        // Main plate hole.
        translate([(13.8 + tolerance[0]) / -2, (13.8 + tolerance[0]) / -2, 4])
            cube([13.8 + tolerance[0], 13.8 + tolerance[1], 1.3 + tolerance[2]]);
        // Hotswap cutout.
        translate([-8, -1.6, 3.1])
            cube([16, 3.2, 2.2]);
        // Switch center post.
        translate([0, 0, -0.02 + tolerance[2]])
            cylinder(h = 3.12 + tolerance[2] * 2, d = 3.4);
        // Alignment pins.
        translate([-5.22, 0, -0.02 + tolerance[2]])
            cylinder(h = 3.12 + tolerance[2] * 2, d = 2);
        translate([5.22, 0, -0.02 + tolerance[2]])
            cylinder(h = 3.12 + tolerance[2] * 2, d = 2);
        // Socket negative.
        translate([-2.5, -5.9 + 1.1, 0])
            if (socket_dummy) {
                choc_socket_dummy();
            } else {
                choc_socket_negative();
            }
    }
}


module choc_socket_diode(rounded = true) {
    union() {
        translate([3.5, -6.5, -0.5])
            rotate([0, 0, 0])
            wire_channel(3, width = 2, depth = 2, rounded = rounded, cap = true);
        translate([3, -3.25, -0.5])
            cylinder(h = 3.6, d = 1.5);
        translate([3, -3.24, 3.11])
            rotate([0, 180, 0])
            wire_channel(4.52, rounded = rounded);
        translate([0.75, 1.25, 3.11])
            rotate([0, 180, -90])
            wire_bend(r = 2.25, a = 90, rounded = rounded);
        translate([-3.75, 3.25, 3.11])
            rotate([0, 180, -90])
            wire_channel(length = 5, width = 2.5, depth = 2.5, rounded = rounded, cap = true);
        translate([-4.25, 5.5, 3.11])
            rotate([0, 180, 90])
            wire_bend(r = 2.25, a = 90, rounded = rounded);
        translate([-6.5, 6.25, 2.5])
            scale([1, 1, 0.75])
            if (rounded) {
                sphere(r = 1.5);
            } else {
                cylinder(h = 3, r = 1.5, center = true);
            }
    }
}


module wire_channel(length, width = 1.5, depth = 1.5, rounded = true, cap = false) {
    union() {
        height = rounded ? depth - width / 2 : depth;
        rotate([90, 0, 180])
            linear_extrude(length)
            union() {
                translate([width / -2, 0, 0])
                    square([width, height]);
                if (rounded) {
                    translate([0, depth - width / 2, 0])
                        circle(width / 2);
                }
            }
        /*
        translate([-width / 2, 0, 0])
            cube([width, length, depth - width / 2]);
        translate([0, 0, depth - width / 2])
            rotate([-90, 0, 0])
            cylinder(h = length, d = width);
        */
        if (cap) {
            cylinder(h = height, d = width);
            translate([0, length, 0])
                cylinder(h = height, d = width);
            if (rounded) {
                translate([0, 0, depth - width / 2])
                    sphere(d = width);
                translate([0, length, depth - width / 2])
                    sphere(d = width);
            }
        }
    }
}


module wire_bend(r, a, width = 1.5, depth = 1.5, rounded = true, cap = false) {
    union() {
        height = rounded ? depth - width / 2 : depth;
        rotate_extrude(angle = a)
            translate([r, 0, 0])
            union() {
                translate([width / -2, 0, 0])
                    square([width, height]);
                if (rounded) {
                    translate([0, depth - width / 2, 0])
                        circle(r = width / 2);
                }
            }
        if (cap) {
            translate([r, 0, 0])
                cylinder(h = height, d = width);
            rotate([0, 0, a])
                translate([r, 0, 0])
                cylinder(h = height, d = width);
            if (rounded) {
                translate([r, 0, depth - width / 2])
                    sphere(d = width);
                rotate([0, 0, a])
                    translate([r, 0, depth - width / 2])
                    sphere(d = width);
            }
        }
    }
}


module switch_dummy(
    size = [14, 14, 5.85],
    shift = 1.25 - 0.425,
    stem = [10, 6, 2],
    cap = [18.25, 18.25, 4]
) {
    y_offset = size[2] / 2 + shift;
    union() {
        translate([0, 0, y_offset])
            cube(size, center = true);
        translate([0, 0, y_offset + size[2] / 2 + stem[2]])
            cube(stem, center = true);
        translate([0, 0, y_offset + size[2] /  + stem[2]])
            difference() {
                linear_extrude(cap[2], scale = 0.85)
                    square([cap[0], cap[1]], center = true);
                linear_extrude(cap[2] - 1, scale = 0.85)
                    square([cap[0] - 2, cap[1] - 2], center = true);
            }
    }
}


module socket_rail(pin_spacing = 2.54, walls = 2, height = 3, pins = 13, slop = 0.1) {
    translate([0, 0, height / 2])
        difference() {
            cube([
                pin_spacing + walls * 2,
                pin_spacing * pins + walls * 2,
                height
            ], center = true);
            cube([
                pin_spacing + slop * 2,
                pin_spacing * pins + slop * 2,
                height + slop
            ], center = true);
        }
}


module rounded_cubeoid(size, r, center = true) {
    linear_extrude(size[2], center = center)
        if (r > 0) {
            union() {
                square([size[0], size[1] - r * 2], center = center);
                square([size[0] - r * 2, size[1]], center = center);
                for(position = [[-1, -1], [-1, 1], [1, 1], [1, -1]]) {
                    translate([
                        position[0] * (size[0] / 2 - r),
                        position[1] * (size[1] / 2 - r),
                        0
                    ])
                        circle(r = r);
                }
            }
        } else {
            square([size[0], size[1]], center = true);
        }
}


module insert_hole() {
    cylinder(h = 1, r1 = 4 / 2, r2 = 3 / 2);
    cylinder(h = 5, r = 3.2 / 2);
}


module column(heights, spacing = 19) {
    keys = len(heights);
    for(row = [0: keys - 1]) {
        height = heights[row];
        sum_heights = [for(i = 0; i <= row; i = i + 1) heights[i]];
        offset = sum(sum_heights) - height / 2;
        translate([0, offset * -spacing, 0])
            children();
    }
}


module columns(positioning, spacing = [19, 19], u = 1) {
    column_count = len(positioning);
    stagger = [for(i = 0; i < column_count; i = i + 1) positioning[i][0]];
    heights = [for(i = 0; i < column_count; i = i + 1) positioning[i][1]];
    for(column = [0: column_count - 1]) {
        offsets = [for(i = 0; i <= column; i = i + 1) stagger[i]];
        x = column * -spacing[0];
        y = sum(offsets) * -spacing[1];
        translate([x, y, 0])
            column(heights[column], spacing = spacing[1]) children();
    }
}