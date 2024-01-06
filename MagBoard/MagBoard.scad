use <../common.scad>
use <../superellipse.scad>

$fs = $preview ? 1 : 0.25;
$fa = $preview ? 20 : 5;

stackup = true;
explode = true;
surround = true;
pressed = false;

matrix_size = [12, 5];
spacing = [19, 19];
cutout = 12;
cap_margin = 1;
edge_margin = 8;
ellipse_n = 16;
tolerance = explode ? 0.1 : 0.01;

top_cutouts = [
    [-93.5, -0.5, 52, 22, 4],
    [-120, 5.5, 12, 10, 5],
    [0, 3, spacing[0] * (matrix_size[0] - 0.5), 15, 1],
];

magnet_size = 3;
mount_hole = 3.5;
screw_hole = 2;
hole_offset = 6;
hole_spacing = 3;
center_holes = max(0, floor(matrix_size[0] / hole_spacing) - 1);
slot_height = cutout * 0.8;

top_margin = cap_margin + 2;
top_height = max([for (cutout = top_cutouts) cutout[3]]) + top_margin;

board_size = [
    matrix_size[0] * spacing[0] + edge_margin * 2,
    matrix_size[1] * spacing[1] + edge_margin * 2 + top_height
];

//layer_height = (1 / 16) * 25.4;
layer_height = 0.0777 * 25.4;
press_min = 0.6;
fill_layers = 3;
surround_layers = surround ? 1 : 0;
layer_count = 2 + fill_layers + surround_layers;
prong_height = (fill_layers + 1) * layer_height;

echo("layer_height", layer_height);
echo("board_size", concat(board_size, [layer_count * layer_height]));
echo("prong_height", prong_height);
echo("slot_height", slot_height);
echo("travel", (fill_layers - 1) * layer_height - press_min);

key_legends = [
    [
        ["~", "`"], ["!", "1"], ["@", "2"], ["#", "3"], ["$", "4"], ["%", "5"],
        ["^", "6"], ["&", "7"], ["*", "8"], ["(", "9"], [")", "0"], ["{", "["]
    ],
    [
        /*"⇥"*/"↹", ["\"", "'"], ["<", ","], [">", "."], "P", "Y",
        "F", "G", "C", "R", "L", ["/", "?"]
    ],
    ["⎋", "A", "O", "E", "U", "I", "D", "H", "T", "N", "S", ["_", "-"]],
    [/*"⇧"*/"⬆︎", [":", ";"], "Q", "J", "K", "X", "B", "M", "W", "V", "Z", ["+", "="]],
    ["fn", "⌃", "⌥", "⌘", /*"⇧"*/"⬆︎", "␣", "↩︎", "⌘", "⌥", "⌫"]
];

thumbs = [1, 1, 1.25, 1.25, 1.5, 1.5, 1, 1.25, 1, 1.25];


module keys() {
    for (y = [0 : matrix_size[1] - 1]) {
        is_thumbs = y == matrix_size[1] - 1;
        x_max = is_thumbs ? len(thumbs) : matrix_size[0];
        for (x = [0 : x_max - 1]) {
            cap_width = is_thumbs ? thumbs[x] : 1;
            cap_x = is_thumbs
                ? sum([for (i = [0 : x]) i == x ? (thumbs[i] - 1) / 2 : thumbs[i]])
                : x;
            translate([
                ((matrix_size[0] - 1) / -2 + cap_x) * spacing[0],
                ((matrix_size[1] - 1) / 2 - y) * spacing[1]
            ])
                if ($children > 0) {
                    children();
                } else {
                    superellipse(
                        n1 = ellipse_n * cap_width,
                        n2 = ellipse_n,
                        a = (cap_width * spacing[0] / 2) - cap_margin,
                        b = (spacing[1] / 2) - cap_margin
                    );
                }
        }
    }
}


module legends(size = spacing[1] / 4) {
    for (y = [0 : matrix_size[1] - 1]) {
        is_thumbs = y == matrix_size[1] - 1;
        x_max = is_thumbs ? len(thumbs) : matrix_size[0];
        for (x = [0 : x_max - 1]) {
            key_legend = key_legends[y][x];
            legend_list = is_list(key_legend) ? key_legend : [key_legend];
            legend_spacing = spacing[1] / (len(legend_list) + 1);
            legend_offset = -(spacing[1] / 2) + legend_spacing;
            cap_width = is_thumbs ? thumbs[x] : 1;
            cap_x = is_thumbs
                ? sum([for (i = [0 : x]) i == x ? (thumbs[i] - 1) / 2 : thumbs[i]])
                : x;
            translate([
                ((matrix_size[0] - 1) / -2 + cap_x) * spacing[0],
                ((matrix_size[1] - 1) / 2 - y) * spacing[1]
            ])
            for (legend_index = [0 : len(legend_list) - 1]) {
                legend = legend_list[legend_index];
                translate([0, -legend_offset - legend_index * legend_spacing])
                    minkowski() {
                        text(
                            legend,
                            size = size,
                            //font = ".SF Compact:style=Regular",
                            font = "Apple Symbols:style=Regular",
                            //font = "Lucida Grande:style=Regular",
                            //font = "Menlo:style=Regular",
                            halign = "center",
                            valign = "center"
                        );
                        circle(r = 0.1);
                    }
            }
        }
    }
}


module key_cutout(as_superellipse = false, do_margin = true) {
    margin = do_margin ? tolerance : 0;
    if (as_superellipse) {
        superellipse(n = ellipse_n, a = cutout / 2 + margin, b = cutout / 2 + margin);
    } else {
        square(cutout + margin * 2, center = true);
    }
}


module stem_cutout(magnet = true, do_margin = true) {
    margin = do_margin ? tolerance : 0;
    translate([cutout * -0.45 + layer_height, 0])
        square([layer_height + margin, slot_height + margin], center = true);
    translate([cutout * 0.45 - layer_height, 0])
        square([layer_height + margin, slot_height + margin], center = true);
    if (magnet) {
        circle(d = magnet_size + margin);
    }
}


module border() {
    translate([0, top_height / 2])
        superellipse(
            n1 = ellipse_n * (board_size[0] / board_size[1])
                * (board_size[1] / spacing[0]),
            n2 = ellipse_n * (board_size[1] / spacing[1]),
            a = board_size[0] / 2,
            b = board_size[1] / 2
        );
}



module top_layer(render_keys = false, render_legends = false) {
    difference() {
        if (render_keys) {
            keys();
        } else {
            border();
        }
        if (render_keys) {
            if (render_legends) {
                legends();
            }
        } else {
            size = [
                matrix_size[0] * spacing[0] + cap_margin * 2,
                matrix_size[1] * spacing[1] + cap_margin * 2
            ];
            superellipse(
                n1 = ellipse_n * (size[0] / size[1]) * (size[1] / spacing[0]),
                n2 = ellipse_n * (size[1] / spacing[1]),
                a = size[0] / 2,
                b = size[1] / 2
            );
        }
    }
}


module layer(keys = true, cutouts = true, layer = 0, hole_size = mount_hole) {
    difference() {
        border();
        if (keys) {
            keys() 
                if ($children > 0 ) {
                    children();
                } else {
                    key_cutout();
                }
        }
        if (cutouts) {
            for (cutout = top_cutouts) {
                if (layer * layer_height < cutout[4] ) {
                    translate([
                        cutout[0],
                        (matrix_size[1] / 2 * spacing[1])
                            + top_height - (cutout[3] / 2) - cutout[1]
                    ])
                        square([cutout[2], cutout[3]], center = true);
                }
            }
        }
        if (hole_size > 0) {
            for (x = [-1, 0, 1]) {
                x_offset = x * ((board_size[0] / 2) - hole_offset);
                translate([x_offset, ((board_size[1] + top_height) / 2) - hole_offset])
                    circle(d = hole_size + tolerance);
                translate([x_offset, ((board_size[1] - top_height) / 2) - hole_offset])
                    circle(d = hole_size + tolerance);
                translate([x_offset, ((board_size[1] - top_height) / -2) + hole_offset])
                    circle(d = hole_size + tolerance);
            }
            for (x = [0 : center_holes - 1]) {
                translate([(x + ((center_holes - 1) / -2)) * spacing[0] * hole_spacing, 0])
                    circle(d = hole_size + tolerance);
            }
        }
    }
}


if (stackup) {
    stackup_height = (explode ? 12 : 1) * layer_height;
    color("#6030b0") linear_extrude(layer_height)
        layer(keys = false, cutouts = false, hole_size = screw_hole);
    color("#b060ff") translate([0, 0, stackup_height])
        linear_extrude(layer_height) layer(layer = 0, hole_size = screw_hole);
    color("#b060ff") translate([0, 0, stackup_height * 2])
        linear_extrude(layer_height) layer(layer = 1, hole_size = screw_hole);
    color("#b060ff") translate([0, 0, stackup_height * 3])
        linear_extrude(layer_height) layer(layer = 2);
    color("#d080ff") translate([0, 0, stackup_height * 4])
        linear_extrude(layer_height) layer(layer = 3) stem_cutout();

    stem_offset = stackup_height
        + (explode
            ? 0
            : (pressed ? press_min : ((fill_layers - 1) * layer_height))
        );
    color("#d080ff") translate([0, 0, stem_offset]) {
        linear_extrude(layer_height) keys() difference() {
            key_cutout(do_margin = false);
            stem_cutout(do_margin = false);
        }
        linear_extrude(prong_height)
            keys() stem_cutout(magnet = false, do_margin = false);
    }
        
    if (surround_layers > 0 )
        for (z = [0 : surround_layers - 1]) {
            color("#6030b0") translate([0, 0, stackup_height * (layer_count - 1 + z)])
                linear_extrude(layer_height) top_layer();
        }
    key_offset = (stackup_height * layer_count)
        + (explode
            ? 0
            : (pressed ? (fill_layers - 2) * -layer_height + press_min : layer_height)
        );
    translate([0, 0, key_offset]) {
        color("#8040d0") linear_extrude(layer_height)
            top_layer(render_keys = true, render_legends = true);
        color("#ffc0ff") linear_extrude(layer_height * 0.95) legends();
    }
} else {
    translate([-6 * 25.4, -6 * 25.4]) circle(1);
    translate([-6 * 25.4, 6 * 25.4]) circle(1);
    translate([6 * 25.4, -6 * 25.4]) circle(1);
    translate([6 * 25.4, 6 * 25.4]) circle(1);
    
    //keys() key_cutout();
    //layer(keys = false, cutouts = false, hole_size = screw_hole);
    //layer(layer = 0, hole_size = screw_hole);
    //layer(layer = 1, hole_size = screw_hole);
    //layer(layer = 2);
    layer(layer = 3) stem_cutout();
    //top_layer();
    //top_layer(render_keys = true);
    //keys() stem_cutout();
    //legends();
}