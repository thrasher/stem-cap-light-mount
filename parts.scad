// all dimensions in millimeters

// see: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Other_Language_Features#$fa,_$fs_and_$fn
$fs = 2; // minimum size of a circle fragment, default=2, min=0.01
$fa = 15; // a circle has fragments = 360 divided by this number, default=12, min=0.01
$fn = $preview ? 24 : 80; // number of fragments in a circle, when non-zero $fs and $fa are ignored, default=0

use <fillets_and_rounds.scad>;

CAP_HEIGHT = 5; // cap above stem
CAP_DIA = 32; // dia of cap
MOUNT_DIA = 31.8; // dia of modern handelbar clamp area
MOUNT_HOLE = MOUNT_DIA - CAP_HEIGHT * 2;
LIP_D = 28.3;
LIP_H = 1;
INSIDE_STEM_D = 14.3; // diameter of material inside stem
INSIDE_STEM_H = 5 + LIP_H; // height of material inside stem
RISER_WIDTH = CAP_HEIGHT;
BOLT_H = 6.6; // stem bolt head height
BOLT_D = 6.6; // stem bolt thread dia
BOLT_HEAD_D = 10.6; // stem bolt head dia
MOUNT_HEIGHT = INSIDE_STEM_H + MOUNT_DIA*1.5;

module mount(DETAIL = false) {
	difference() {
		union() {
			if(DETAIL) {
				rounded();
			} else {
				main();
			}
			// inside stem, above steerer tube
			cylinder(d = INSIDE_STEM_D, h = INSIDE_STEM_H);
			translate([0, 0, INSIDE_STEM_H-LIP_H])
			cylinder(d = LIP_D, h = LIP_H);
		}
		cuts();
	}
}

module rounded() {
	// (1, 4, 200, "xyz", 6) => 1637.3 seconds
	// fillets_and_rounds(3, 4, 1000, "xyz", 7) main(); //fn=20 is very costly!
	fillets_and_rounds(1, 4, 200, "xyz", 12) main(); //fn=20 is very costly!
}

module main() {
	difference() {
		union() {
			// inside stem, above steerer tube
			//cylinder(d = INSIDE_STEM_D, h = INSIDE_STEM_H);

			hull() {
				// cap above stem
				translate([0, 0, INSIDE_STEM_H])
				cylinder(d = CAP_DIA, h = CAP_HEIGHT);

				junction();
			}
			hull() {
				translate([0, (CAP_DIA-RISER_WIDTH)/2, 0])
				move()
				cylinder(d = MOUNT_HOLE, h = RISER_WIDTH, center = true);
				junction();
			}

			// bar
			move()
			difference() {
				cylinder(d = MOUNT_DIA, h = CAP_DIA, center = true);
				bar_chamfer();
				mirror([0,0,1])
				bar_chamfer();
			}
		}
		// cuts();
	}
}

module bar_chamfer() {
		difference() {
			cylinder(d = MOUNT_DIA-2+CAP_DIA*2, h = CAP_DIA+1, center = true);
			cylinder(d1 = MOUNT_DIA-2, d2 = MOUNT_DIA-2+CAP_DIA*2, h = CAP_DIA, center = true);
		}
}

module cuts() {
		// hollow out mount
		move()
		cylinder(d = MOUNT_HOLE, h = CAP_DIA*2, center = true);

		translate([0, -CAP_DIA+1, 0])
		move()
		cylinder(d1 = MOUNT_HOLE, d2 = MOUNT_HOLE*3, h = CAP_DIA, center = true);
		mirror([0,1,0])
		translate([0, -CAP_DIA+1, 0])
		move()
		cylinder(d1 = MOUNT_HOLE, d2 = MOUNT_HOLE+CAP_DIA*2, h = CAP_DIA, center = true);

		stem_bolt_hole();

		// trim off corner near where knee might strike
		difference() {
			cylinder(d = CAP_DIA*2, h = MOUNT_HEIGHT - MOUNT_DIA/2);
			cylinder(d = CAP_DIA, h = MOUNT_HEIGHT);
			translate([0, -50, 0])
			cube([100, 100, 100]);
		}

}

module stem_bolt_hole() {
	// stem bolt hole
	cylinder(d = BOLT_D, h = 30, center = true);
	translate([0, 0, INSIDE_STEM_H + CAP_HEIGHT - BOLT_H])
	cylinder(d = BOLT_HEAD_D, h = BOLT_H + 20);
}


module junction() {
	EXTRA = 0;//(CAP_DIA-MOUNT_HOLE)/2;
	translate([EXTRA/2,0,0])
	translate([0, CAP_DIA/2-RISER_WIDTH/2, INSIDE_STEM_H + CAP_HEIGHT/2]) {
		cube([MOUNT_HOLE+EXTRA, RISER_WIDTH, CAP_HEIGHT], center = true);

		// rotate([0,90,0])
		// cylinder(d = RISER_WIDTH, h = MOUNT_HOLE, center = true);

		// translate([MOUNT_HOLE/2-CAP_HEIGHT/2, 0, 0])
		// sphere(d = CAP_HEIGHT, center = true);
		// translate([-(MOUNT_HOLE/2-CAP_HEIGHT/2), 0, 0])
		// sphere(d = CAP_HEIGHT, center = true);
	}
}

module move() {
	ALLEN_KEY_DIA = 6; // max diameter of stem allen key
	translate([CAP_DIA/2 + ALLEN_KEY_DIA/2, 0, MOUNT_HEIGHT])
	rotate([90,0,0])
	children();
}

module test() {
				// inside stem, above steerer tube
			cylinder(d = INSIDE_STEM_D, h = INSIDE_STEM_H);

			// cap above stem
			translate([0, 0, INSIDE_STEM_H])
			cylinder(d = CAP_DIA, h = CAP_HEIGHT);
}

PART = "all";
if (PART == "mount") {
	echo("render mount");
	mount(true);
} else {
	// render as assembly
	echo("render all parts");
	color("grey") mount(false);
}
