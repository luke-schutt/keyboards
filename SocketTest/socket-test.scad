include <../common.scad>;

spacing = [19, 19];
hole = 14;

slop = [0.8, 0.4, 0.2, 0.1, 0];
lip_slop = [0, -0.05, -0.15, -0.25, -0.5];
thickness = [1.2, 1.4, 1.5, 1.6, 1.65];
case_thickness = 10;
plate_thickness = 4;
lip = 1.25;
taper = 0.75;
inset = 2;

size = [spacing[0] * len(slop), spacing[1] * len(thickness)];

union() {
    difference() {
        translate([-8, 4, 5])
            cube([size[0] + 20, size[1] + 4 + 8, case_thickness], center = true);
        translate([-8, 4, case_thickness / 2 + 0.01])
            cube([size[0] + 16, size[1] + 8, case_thickness + 0.04], center = true);
    }
    difference() {
        translate([-8, 4, case_thickness - inset - (plate_thickness / 2)])
            cube([size[0] + 16.02, size[1] + 8.02, plate_thickness], center = true);
        for (thickness_index = [0 : len(thickness) - 1]) {
            for (slop_index = [0 : len(slop) - 1]) {
                translate([
                    (slop_index - (len(slop) - 1) / 2) * spacing[0],
                    (thickness_index - (len(thickness) - 1) / 2) * spacing[1],
                    case_thickness - inset - plate_thickness - 0.01
                ])
                    basic_socket_negative(
                        hole = hole + slop[slop_index],
                        ledge = thickness[thickness_index],
                        lip = lip + lip_slop[slop_index],
                        taper = max(0.34, taper - slop[slop_index]),
                        thickness = plate_thickness + 0.02
                   );
            }
        }
    }
    for (slop_index = [0 : len(slop) - 1]) {
        translate([
            (slop_index - (len(slop) - 1) / 2) * spacing[0],
            len(thickness) / 2 * spacing[1] + 1.0,
            case_thickness - inset - 0.01
        ])
            linear_extrude(1.25)
            text(
                str(hole + slop[slop_index]),
                font = "Helvetica",
                size = 5,
                halign = "center",
                valign = "baseline"
            );
    }
    for (thickness_index = [0 : len(thickness) - 1]) {
        translate([
            len(slop) / -2 * spacing[0] - 0.5,
            (thickness_index - (len(thickness) - 1) / 2) * spacing[1],
            case_thickness - inset - 0.01
        ])
            linear_extrude(1.25)
            text(
                str(thickness[thickness_index]),
                font = "Helvetica",
                size = 5,
                halign = "right",
                valign = "center"
            );
    }
}