include <nutsnbolts/cyl_head_bolt.scad>;
/*
difference() {
        translate([-15, -15, 0]) cube([80, 30, 50]);
        rotate([180,0,0]) nutcatch_parallel("M5", l=5);
        translate([0, 0, 50]) hole_through(name="M5", l=50+5, cl=0.1, h=10, hcl=0.4);
        translate([55, 0, 9]) nutcatch_sidecut("M8", l=100, clk=0.1, clh=0.1, clsl=0.1);
        translate([55, 0, 50]) hole_through(name="M8", l=50+5, cl=0.1, h=10, hcl=0.4);
        translate([27.5, 0, 50]) hole_threaded(name="M5", l=60);
}
*/

module joint_body(horizontal_screw, vertical_screw, central_rod, h_inner_thickness, h_outer_thickness, v_thickness, total_height, center_radius, hole_height, nut_height, radius, center_screw_hole) {
    step_degrees = 1; // should be 1 in production


    // upper layer for nut
    if (nut_height > 0) {
        difference() {
            height = nut_height;
            cylinder(h=height, r=radius);
            cylinder(h=height, r=center_radius);
    
            for(angle = [30:step_degrees:150]) {
                rotate(a=[0, 0, angle], v=[0, 0, 0]) translate([0, center_screw_hole, 0]) cylinder(h = height, r = _get_head_dia(vertical_screw) / 2);
            }
    
            for(angle = [210:step_degrees:330]) {
                rotate(a=[0, 0, angle], v=[0, 0, 0]) translate([0, center_screw_hole, 0]) cylinder(h = height, r = _get_head_dia(vertical_screw) / 2);
            }
        }
    }

    // lower layer for screw hole
    translate([0, 0, -hole_height])
    difference() {
        height = hole_height;
        cylinder(h=height, r=radius);
        cylinder(h=height, r=center_radius);

        for(angle = [30:step_degrees:150]) {
            rotate(a=[0, 0, angle], v=[0, 0, 0]) translate([0, center_screw_hole, 0]) cylinder(h = height, r = _get_outer_dia(vertical_screw) / 2);
        }

        for(angle = [210:step_degrees:330]) {
            rotate(a=[0, 0, angle], v=[0, 0, 0]) translate([0, center_screw_hole, 0]) cylinder(h = height, r = _get_outer_dia(vertical_screw) / 2);
        }
    }
}

module screw_hole(screw, height) {
    for(x = [0:0.1:5]){
        translate([x, 0, 0])
        hole_through(screw, h=1.5);
    }
}

// screws = holes for screws else nuts
module joint_head(horizontal_screw="M3x5", vertical_screw="M3x5", central_rod="M8x25", screws=true) {
    // probably should be parameters
    h_inner_thickness = 2;
    h_outer_thickness = 2;
    v_thickness = 1;
    height = 1;

    min_height = _get_outer_dia(horizontal_screw) + 2 * v_thickness;
    total_height = max(height, min_height);
    center_radius = _get_outer_dia(central_rod) / 2;
    hole_height = _get_length(vertical_screw) / 2 - 2;  // so 2 can be joined
    nut_height = total_height - hole_height;
    radius = h_outer_thickness + _get_head_dia(vertical_screw) + h_inner_thickness + center_radius;
    center_screw_hole = center_radius + h_inner_thickness + _get_head_dia(vertical_screw) / 2;
    screw_cut_position_h = center_radius + h_inner_thickness + _get_head_dia(vertical_screw) * 0.75;
    screw_cut_position_v = _get_outer_dia(horizontal_screw) / 2 + v_thickness;

    difference() {
        joint_body(horizontal_screw, vertical_screw, central_rod, h_inner_thickness, h_outer_thickness, v_thickness, total_height, center_radius, hole_height, nut_height, radius, center_screw_hole);
  
        translate([ 0, -15, screw_cut_position_v])
        rotate([90, 0, 0])
        hole_through(name=horizontal_screw);
    translate([0, screw_cut_position_h, screw_cut_position_v])
    rotate([0, 270, 90])
    screw_hole("M2", 10); // "M3x5" isn't working here    
    };
};

joint_head();

