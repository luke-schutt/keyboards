use <../common.scad>;
$fs = 2;


socket_dummy = false;


half_spec = [
    [0, [1, 1, 1, 1]],
];


rotate([0, 0, -90])
    difference() {
        translate([0, 0, 5.2 / 2])
            rounded_cubeoid([17 * 2 + 6, 18 * 4 + 6, 5.2], r = 2);
        columns(half_spec, spacing = [17, 18])
            translate([-8.5, 18 * 2, 0])
            rotate([0, 0, 90])
            choc_switch_negative(socket_dummy = socket_dummy);
        columns(half_spec, spacing = [17, 17])
            translate([8.5, 18 * 2 - 3.5, 0])
            rotate([0, 0, 90])
            choc_switch_negative(socket_dummy = socket_dummy);
        // Full column.
        translate([17, -37, -0.02])
            rotate([0, 0, 90])
            wire_channel(17 * 2, cap = true);
        // 18mm half columns.
        translate([-1, -19, -0.02])
            rotate([0, 0, 90])
            wire_channel(16, cap = true);
        translate([-1, -1, -0.02])
            rotate([0, 0, 90])
            wire_channel(16, cap = true);
        translate([-1, 17, -0.02])
            rotate([0, 0, 90])
            wire_channel(16, cap = true);
        // 17 mm half columns.
        translate([17, -20, -0.02])
            rotate([0, 0, 90])
            wire_channel(16, cap = true);
        translate([17, -3, -0.02])
            rotate([0, 0, 90])
            wire_channel(15, cap = true);
        translate([17, 14, -0.02])
            rotate([0, 0, 90])
            wire_channel(14, cap = true );
        // Column connections.
        translate([1, -20, -0.02])
            rotate([0, 0, 63])
            wire_channel(2);
        translate([2, -3, -0.02])
            rotate([0, 0, 54])
            wire_channel(3.4);
        translate([3, 14, -0.02])
            rotate([0, 0, 52])
            wire_channel(4.9);
        // Diode slots.
        columns(half_spec, spacing = [17, 18])
            translate([-8.5, 18 * 2, 0])
            rotate([0, 0, 90])
            choc_socket_diode();
        columns(half_spec, spacing = [17, 17])
            translate([8.5, 18 * 2 - 3.5, 0])
            rotate([0, 0, 90])
            choc_socket_diode();
        // Rows.
        translate([2, 18 * 2 + 5, 3])
            rotate([90, 0, 0])
            cylinder(h = 18 * 4 + 10, d = 1.5);
        translate([-15, 18 * 2 + 5, 3])
            rotate([90, 0, 0])
            cylinder(h = 18 * 4 + 10, d = 1.5);
    }