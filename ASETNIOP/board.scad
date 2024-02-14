use <../common.scad>


$fn = $preview ? 10 : 100;


// Keyboard size.
size = [215, 85, 11];
// Base case height.
base_height = 6;
// Corner radius.
corner_radius = 19;
// If the edgesh should be chamfered rather than rounded.
chamfer = true;
// Edge fillet radius.
fillet_radius = 4;
// Case wall thickness.
wall_thickness = 3;
// Key spacing.
key_spacing = [19, 19];
// Key margin.
key_margin = 1;
// Key fillet radius.
key_fillet = 2;


module half_array() {
    translate([key_spacing.x * 1.55, key_spacing.y * 0.74, 0]) rotate([0, 0, 12]) {
        translate([0, 0, 0]) children(0);
        translate([key_spacing.x, key_spacing.y * 0.25, 0]) children(0);
        translate([key_spacing.x * 2, 0, 0]) children(0);
        translate([key_spacing.x * 3, key_spacing.y * -0.75, 0])
            rotate([0, 0, -4])
            children(0);
        translate([key_spacing.x * -0.75, key_spacing.y * -2, 0])
            children($children > 1 ? 1 : 0);
    }
}

module case_block(size = size, r = corner_radius, fillet = fillet_radius) {
    minkowski() {
        translate([0, 0, (size.z - fillet) / 2])
            rounded_cubeoid(
                [
                    size.x - fillet * 2,
                    size.y - fillet * 2,
                    size.z - fillet
                ],
                r = r
            );
        if (fillet > 0) {
            if (chamfer) {
                cylinder(h = fillet, r1 = fillet, r2 = 0.01);
            } else {
                difference() {
                    sphere(r = fillet);
                    translate([0, 0, -fillet])
                    cylinder(r = fillet + 1, h = fillet);
                }
            }
        }
    }
}


module case_positive() {
    difference() {
        case_block();
        minkowski() {
            union() {
                half_array() {
                    translate([0, 0, size.z / 2]) cube([
                        key_spacing.x + key_margin * 2,
                        key_spacing.y + key_margin * 2,
                        size.z
                    ], center = true);
                    translate([0, -key_spacing.y / 2, size.z / 2]) cube([
                        key_spacing.x * 1.5,
                        key_spacing.y * 2,
                        size.z
                    ], center = true);
                }
                scale([-1, 1, 1]) half_array() {
                    translate([0, 0, size.z / 2]) cube([
                        key_spacing.x + key_margin * 2,
                        key_spacing.y + key_margin * 2,
                        size.z
                    ], center = true);
                    translate([0, -key_spacing.y / 2, size.z / 2]) cube([
                        key_spacing.x * 1.5,
                        key_spacing.y * 2,
                        size.z
                    ], center = true);
                }
            }
            union() {
                cylinder(r = key_margin, h = size.z);
                translate([0, 0, size.z - key_fillet])
                    if (chamfer) {
                        cylinder(
                            h = key_fillet,
                            r1 = key_margin,
                            r2 = key_margin + key_fillet
                        );
                    } else {
                        rotate_extrude()
                        difference() {
                            square([key_margin + key_fillet, key_fillet]);
                            translate([key_margin + key_fillet, 0])
                                circle(r = key_fillet);
                        }
                    }
            }
        }
    }
    case_block(
        size = [size.x, size.y, base_height],
        r = corner_radius + (fillet_radius - key_fillet),
        fillet = key_fillet
    );
}


module case_cutout() {
    difference() {
        case_block(
            size = [
                size.x - (wall_thickness) * 3,
                size.y - wall_thickness * 3,
                size.z - wall_thickness * 1.5
            ],
            fillet = 0
        );
        union() {
            half_array() {
                translate([0, 0, size.z / 2]) cube([
                    key_spacing.x + (key_margin + wall_thickness) * 3,
                    key_spacing.y + (key_margin + wall_thickness) * 3,
                    size.z
                ], center = true);
                translate([0, 0, size.z / 2]) cube([
                    key_spacing.x * 1.5 + (key_margin + wall_thickness) * 3,
                    key_spacing.y * 2 + (key_margin + wall_thickness) * 1.5,
                    size.z
                ], center = true);
            }
            scale([-1, 1, 1]) half_array() {
                translate([0, 0, size.z / 2]) cube([
                    key_spacing.x + (key_margin + wall_thickness) * 3,
                    key_spacing.y + (key_margin + wall_thickness) * 3,
                    size.z
                ], center = true);
                translate([0, 0, size.z / 2]) cube([
                    key_spacing.x * 1.5 + (key_margin + wall_thickness) * 3,
                    key_spacing.y * 2 + (key_margin + wall_thickness) * 1.5,
                    size.z
                ], center = true);
            }
        }
    }
}


module key_negative() {
    translate([5.5, 0, 0]) cylinder(d = 1.9, h = size.z);
    translate([-5.5, 0, 0]) cylinder(d = 1.9, h = size.z);
    cylinder(d = 3.3, h = size.z);
    translate([0, -5.9, 0]) cylinder(d = 3, h = size.z);
    translate([-5, -3.8, 0]) cylinder(d = 3, h = size.z);
    translate([0, 0, (size.z / 2) + base_height - 2.2])
        cube([14.1, 14.1, size.z], center = true);
    translate([0, 0, (0.9 / 2) + base_height - 2.2])
        cube([15, 14.1, 0.9], center = true);
}


module case() {
    difference() {
        case_positive();
        case_block(
                size = [
                size.x - wall_thickness * 2,
                size.y - wall_thickness * 2,
                base_height - 2.2 - 1.3
            ],
            r = corner_radius + (fillet_radius - wall_thickness),
            fillet = 0
        );
        half_array() key_negative();
        scale([-1, 1, 1]) half_array() { 
            scale([-1, 1, 1]) key_negative();
        }
        minkowski() {
            case_cutout();
            fillet = wall_thickness / 2;
            if (chamfer) {
                cylinder(h = fillet, r1 = fillet, r2 = 0.01);
            } else  {
                sphere(r = fillet);
            }
        }
    }
}


//intersection() {
case();
//    translate([-150, 0, 0]) cube([300, 300, 300], center = true);
//}