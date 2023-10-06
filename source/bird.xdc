set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
set_property PACKAGE_PIN Y9 [get_ports {clk}]
create_clock -period 10 [get_ports clk]

set_property PACKAGE_PIN Y11 [get_ports {trigger}];
set_property PACKAGE_PIN AA11 [get_ports {hit}];
set_property IOSTANDARD LVCMOS33 [get_ports {trigger}];
set_property IOSTANDARD LVCMOS33 [get_ports {hit}];

#SSD
set_property PACKAGE_PIN AB11 [get_ports {ssd[6]}];
set_property PACKAGE_PIN AB10 [get_ports {ssd[5]}];
set_property PACKAGE_PIN AB9 [get_ports {ssd[4]}];
set_property PACKAGE_PIN AA8 [get_ports {ssd[3]}];
set_property PACKAGE_PIN V12 [get_ports {ssd[2]}];
set_property PACKAGE_PIN W10 [get_ports {ssd[1]}];
set_property PACKAGE_PIN V9 [get_ports {ssd[0]}];
set_property PACKAGE_PIN V8 [get_ports {sel}];
set_property IOSTANDARD LVCMOS33 [get_ports ssd];
set_property IOSTANDARD LVCMOS33 [get_ports sel];

#set_property PACKAGE_PIN P16 [get_ports {btnc}];
#set_property IOSTANDARD LVCMOS25 [get_ports btnc];

# ----------------------------------------------------------------------------
# VGA Output - Bank 33
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y21  [get_ports {blue[0]}];  # "VGA-B0"
set_property PACKAGE_PIN Y20  [get_ports {blue[1]}];  # "VGA-B1"
set_property PACKAGE_PIN AB20 [get_ports {blue[2]}];  # "VGA-B2"
set_property PACKAGE_PIN AB19 [get_ports {blue[3]}];  # "VGA-B3"
set_property PACKAGE_PIN AB22 [get_ports {green[0]}];  # "VGA-G0"
set_property PACKAGE_PIN AA22 [get_ports {green[1]}];  # "VGA-G1"
set_property PACKAGE_PIN AB21 [get_ports {green[2]}];  # "VGA-G2"
set_property PACKAGE_PIN AA21 [get_ports {green[3]}];  # "VGA-G3"
set_property PACKAGE_PIN V20  [get_ports {red[0]}];  # "VGA-R0"
set_property PACKAGE_PIN U20  [get_ports {red[1]}];  # "VGA-R1"
set_property PACKAGE_PIN V19  [get_ports {red[2]}];  # "VGA-R2"
set_property PACKAGE_PIN V18  [get_ports {red[3]}];  # "VGA-R3"
set_property PACKAGE_PIN AA19 [get_ports {hsync}];  # "VGA-HS"
set_property PACKAGE_PIN Y19  [get_ports {vsync}];  # "VGA-VS"
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];