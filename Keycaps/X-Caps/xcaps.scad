//$fn = $preview ? 25 : 150;
$fs = $preview ? 0.5 : 0.1;
$fa = $preview ? 5 : 1;


// Number of keys horizontally.
key_count_x = 2;
// Number of keys vertically.
key_count_y = 2;
// Spacing between keys.
key_spacing = 3;
// Support size.
key_sprue_diameter = 1.65;

// Width for 1U.
u_width = 19;
// Height for 1U.
u_height = 19;

// Spacing between keys.
cap_spacing = 1;
// Keycap width in U.
cap_u_width = 1;
// Keycap height in U.
cap_u_height = 1;
// Keycap width.
cap_width = cap_u_width * u_width - cap_spacing;
// Keycap depth.
cap_height = cap_u_height * u_height - cap_spacing;
// Keycap thickness
cap_thickness = 3;
// Keycap front/back rounding.
cap_rounding = 2.5;
// Keycap corner radius.
cap_radius = 1.6;
// Keycap thickness.
cap_cutout = 1;
// If the cutout should be basic.
cap_cutout_basic = true;
// Cap cutout depth for basic cutouts.
cap_cutout_depth_basic = 1;

// If the dish should be added.
dish_cap = true;
// Dish depth.
dish_depth = 0.8;
// Edge offset for the dish.
dish_offset = 2;
// Dish multiplier relative to cap height.
dish_multiplier = 1.5;

// Chamfer size.
chamfer_size = dish_offset + 0.15;
// Chamfer offset from the bottom.
chamfer_offset = 0.75;

// Homing bump?
homing_bump_enabled = false;
// Homing bump width.
homing_bump_width = u_width / 4;
// Homing bump radius.
homing_bump_radius = 0.75;
// Homing bump offset multiplier compared to U height.
homing_bump_offset = 0.65;

// Stem reduction.
stem_reduction = 0.1;


// Adjust the radius for the targeted depth (h) given a width (w).
function adjusted_radius(w, h) = (h * h + w * w) / (2 * h);


module edge_rounding(w, d) {
    translate([0, d - cap_rounding, d - cap_rounding])
    difference() {
        translate([-cap_width / 2 - 0.001, 0, 0])
            cube([w + 0.002, w, w]);
        rotate([0, 90, 0])
            cylinder(h = w + 0.002, r = cap_rounding, center = true);
    }
}


module base_shape(w, h, d, r, scale = 1) {
    linear_extrude(d, scale = scale) {
        square([w, h - (r * 2)], center = true);
        square([w - (r * 2), h], center = true);
        translate([(w / 2) - r, (h / 2) - r, 0])
            circle(r);
        translate([-(w / 2) + r, (h / 2) - r, 0])
            circle(r);
        translate([(w / 2) - r, -(h / 2) + r, 0])
            circle(r);
        translate([-(w / 2) + r, -(h / 2) + r, 0])
            circle(r);
    }
}


module homing_bump() {
    union() {
        rotate([0, 90, 0])
            cylinder(h = homing_bump_width, r = homing_bump_radius, center = true);
        translate([homing_bump_width / 2, 0, 0])
            sphere(r = homing_bump_radius);
        translate([-homing_bump_width / 2, 0, 0])
            sphere(r = homing_bump_radius);
    }
}


dish_radius = adjusted_radius(w = (cap_width - dish_offset * 2) / 2, h = dish_depth);
dish_depth_radius = adjusted_radius(w = cap_height * 0.8, h = dish_depth);

chamfer_thickness = sqrt(pow(cap_thickness - chamfer_offset, 2) + pow(chamfer_size, 2));
chamfer_angle = atan2(chamfer_size, cap_thickness - chamfer_offset);


module keycap_shape(w, h, d, r) {
    difference() {
        base_shape(w, h, d, r);
        translate([0, h / 2 - d])
            edge_rounding(w, d);
        translate([0, -h / 2 + d])
            rotate([0, 0, 180])
            edge_rounding(w, d);
        if (dish_cap) {
            translate([0, 0, dish_radius + d - dish_depth])
                scale([1, (h / w) * dish_multiplier, 1])
                sphere(r = dish_radius);
        }
        translate([-w / 2, 0, chamfer_offset])
            rotate([0, chamfer_angle, 0])
            translate([-chamfer_thickness, -h / 2 - 0.001, 0])
            cube([chamfer_thickness, h + 0.002, d * 2]);
        translate([w / 2, 0, chamfer_offset])
            rotate([0, chamfer_angle, 180])
            translate([-chamfer_thickness, -h / 2 - 0.001, 0])
            cube([chamfer_thickness, h + 0.002, d * 2]);
    }
}


module choc_prong() {
    prong_height = 3;
    prong_width = 1.2 - stem_reduction;
    prong_depth = 3 - stem_reduction;
    difference() {
        translate([0, 0, -prong_height / 2])
            cube([prong_width, 3, prong_height], center = true);
        translate([-0.95, 0, -prong_height / 2])
            cube([1, prong_width, prong_height + 0.002], center = true);
        translate([0.95, 0, -prong_height / 2])
            cube([1, prong_width, prong_height + 0.002], center = true);
        translate([0.7, 1.6, -prong_height / 2])
            rotate([0, 0, 45])
            cube([0.5, 0.5, prong_height + 0.002], center = true);
        translate([-0.7, 1.6, -prong_height / 2])
            rotate([0, 0, 45])
            cube([0.5, 0.5, prong_height + 0.002], center = true);
        translate([0.7, -1.6, -prong_height / 2])
            rotate([0, 0, 45])
            cube([0.5, 0.5, prong_height + 0.002], center = true);
        translate([-0.7, -1.6, -prong_height / 2])
            rotate([0, 0, 45])
            cube([0.5, 0.5, prong_height + 0.002], center = true);
        translate([0.7, 0, -prong_height - 0.1])
            rotate([0, 45, 0])
            cube([0.5, prong_depth + 0.002, 0.5], center = true);
        translate([-0.7, 0, -prong_height - 0.1])
            rotate([0, 45, 0])
            cube([0.5, prong_depth + 0.002, 0.5], center = true);
        translate([0, 1.6, -prong_height - 0.1])
            rotate([45, 0, 0])
            cube([prong_width + 0.002, 0.5, 0.5], center = true);
        translate([0, -1.6, -prong_height - 0.1])
            rotate([45, 0, 0])
            cube([prong_width + 0.002, 0.5, 0.5], center = true);
    }
}


module choc_stem() {
    union() {
        cube([7.1, 3.2, 0.4], center = true);
        translate([-2.85, 0, 0])
            choc_prong();
        translate([2.85, 0, 0])
            choc_prong();
    }
}


module x_stem() {
    x_centers = 10.35;
    y_centers = 10.53;
    base_shape(
        w = x_centers + 2.25,
        h = y_centers + 2,
        d = 0.2,
        r = 0.2
    );
    translate([x_centers / 2 + 0.375, -y_centers / 2, 0]) x_stem_clip();
    translate([-x_centers / 2 - 0.375, -y_centers / 2, 0]) x_stem_clip();
    translate([x_centers / 2 + 0.375, y_centers / 2, 0]) scale([-1, 1, 1]) x_stem_slot();
    translate([-x_centers / 2 - 0.375, y_centers / 2, 0]) x_stem_slot(l = true);
}


module x_stem_clip() {
    x_stem_height = 1.2;
    difference() {
        translate([0, 0, -(x_stem_height / 2)])
            cube([0.75, 2.2, x_stem_height + 0.002], center = true);
        translate([0, 0, -0.43])
            rotate([0, 90, 0])
            cylinder(h = 1, r = 0.43, center = true);
        translate([0, 0, -(x_stem_height / 2)])
            cube([1, 0.65, x_stem_height + 0.004], center = true);
        translate([0, 0, -x_stem_height])
            rotate([45, 0, 0])
            cube([1, 0.75, 0.75], center = true);
    }
}


module x_stem_slot(l = true) {
    slot_base_width = 0.75;
    slot_additional_width = 0.5;
    slot_width = slot_base_width + slot_additional_width;
    slot_height = 1.26;
    slot_shift = (slot_additional_width / 4) + slot_base_width / 2;
    difference() {
        translate([0, -0.1, -slot_height / 2])
            cube([slot_width, 1.5, slot_height + 0.002], center = true);
        translate([0, 0.101, -0.45])
            cube([slot_base_width, 1.1002, 0.861], center = true);
        translate([slot_shift, 0, -0.3])
            cube([(slot_additional_width / 2) + 0.002, 2.5, 2.5], center = true);
    }
}


module keycap() {
    union() {
        difference() {
            union() {
                keycap_shape(
                    w = cap_width,
                    h = cap_height,
                    d = cap_thickness,
                    r = cap_radius
                );
                if (homing_bump_enabled) {
                    translate(
                        [
                            0,
                            -(cap_height / 2) * homing_bump_offset,
                            cap_thickness
                                - (dish_cap ? dish_depth : homing_bump_radius / 3)
                        ])
                        homing_bump();
                }
            }
            if (cap_cutout_basic) {
                translate([0, 0, -0.002])
                    base_shape(
                        w = cap_width - cap_cutout * 2,
                        h = cap_height - cap_cutout * 2,
                        d = cap_cutout_depth_basic + 0.001,
                        r = cap_radius / 2,
                        scale = 0.9
                    );
            } else {
                translate([0, 0, -cap_cutout])
                    keycap_shape(
                        w = cap_width - cap_cutout,
                        h = cap_height - cap_cutout,
                        d = cap_thickness,
                        r = cap_radius
                    );
            }
        }
        if (cap_cutout_basic) {
            translate([0, 0, cap_cutout_depth_basic])
                children();
        } else {
            translate([0, 0, cap_thickness - dish_depth - cap_cutout / 2])
                children();
        }
    }
}


keycap() x_stem();


/*
key_spacing_x = u_width + key_spacing;
key_spacing_y = u_height + key_spacing;
key_spread_x = key_spacing_x * key_count_x - key_spacing;
key_spread_y = key_spacing_y * key_count_y - key_spacing;
translate([u_width / 2, u_width / 2, 0.2])
union() {
    for (x = [1:key_count_x]) {
        for (y = [1:key_count_y]) {
            translate([(x - 1) * key_spacing_x, (y - 1) * key_spacing_y, 0])
                keycap();
        }
    }
    for (x = [2:key_count_x]) {
        for (y = [1:key_count_y]) {
            translate([
                (x - 2) * key_spacing_x + key_spacing_x / 2,
                (y - 1) * key_spacing_y,
                key_sprue_diameter / 2
            ])
                cube([key_spacing + 2, key_sprue_diameter, key_sprue_diameter], center = true);
        }
    }
    for (x = [1:key_count_x]) {
        for (y = [2:key_count_y]) {
            translate([
                (x - 1) * key_spacing_x,
                (y - 2) * key_spacing_y + key_spacing_y / 2,
                key_sprue_diameter / 2
            ])
                cube([key_sprue_diameter, key_spacing + 2, key_sprue_diameter], center = true);

        }
    }
}
/**/