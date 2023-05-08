function sum(v, i = 0, n = 0) = i < len(v) ? sum(v, i = i + 1, n = n + v[i]) : n;

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
            column(heights[column]) children();
    }
}