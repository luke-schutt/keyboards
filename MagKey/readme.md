# Magnetic key experiments

MagKey is my experiment in 3d printing a key switch using magnets. The intent is to have a switch similar to, but shorter than Kailh Choc switches, and with a small piece of conductive tape to bridge pads on a PCB similar to rubber dome switches on game or TV controllers.

I started by making a cardboard prototype. With a pair of magnets it produced a key with a satisfying tactile feel. The actuation force can be customized by using different size, strength, or spacing with the magnets.

So far I've done one test print at my public library at a few different orientations. The quality wasn't great but after spending some time on cleanup I had 1 mechanically functional key. This used my 45º test print with the stem rotated 180º from the housing. It uses two rectangular 1/4 x 1/8 x 1/32 inch magnets and fits a Choc keycap.

The [scad file](./MagKey.scad) is parametric allowing for a number of customizations. It's setup for the rectangular magnet I used in my first printed prototype, but can easily be switched to a 3 x 1 mm cylindrical magnet. Other parameters include housing size, height, margins (recommended if your printer is well calibrated), and more. The [main stl file](./MagKey.stl) will print the two parts side-by-side, or the [housing](./MagKey_housing.stl) and [stem](./MagKey_stem.stl) files can be printed individually.
