
################################################################
# This is a generated script based on design: embsys
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source embsys_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a100tcsg324-1
}


# CHANGE DESIGN NAME HERE
set design_name embsys

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -from 0 -to 0 -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 lmb_bram ]
  set_property -dict [ list \
CONFIG.Memory_Type {True_Dual_Port_RAM} \
CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set Pmod_out [ create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 Pmod_out ]
  set gpio_rtl [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 gpio_rtl ]
  set gpio_rtl_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 gpio_rtl_0 ]
  set gpio_rtl_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 gpio_rtl_1 ]
  set gpio_rtl_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 gpio_rtl_2 ]

  # Create ports
  set RGB1_Blue [ create_bd_port -dir O RGB1_Blue ]
  set RGB1_Green [ create_bd_port -dir O RGB1_Green ]
  set RGB1_Red [ create_bd_port -dir O RGB1_Red ]
  set RGB2_Blue [ create_bd_port -dir O RGB2_Blue ]
  set RGB2_Green [ create_bd_port -dir O RGB2_Green ]
  set RGB2_Red [ create_bd_port -dir O RGB2_Red ]
  set an [ create_bd_port -dir O -from 7 -to 0 an ]
  set btnC [ create_bd_port -dir I btnC ]
  set btnD [ create_bd_port -dir I btnD ]
  set btnL [ create_bd_port -dir I btnL ]
  set btnR [ create_bd_port -dir I btnR ]
  set btnU [ create_bd_port -dir I btnU ]
  set clockOut [ create_bd_port -dir O clockOut ]
  set clock_50MHz [ create_bd_port -dir O -type clk clock_50MHz ]
  set dir_out [ create_bd_port -dir O dir_out ]
  set dp [ create_bd_port -dir O dp ]
  set en [ create_bd_port -dir O en ]
  set led [ create_bd_port -dir O -from 15 -to 0 led ]
  set pmodENC_A [ create_bd_port -dir I pmodENC_A ]
  set pmodENC_B [ create_bd_port -dir I pmodENC_B ]
  set pmodENC_btn [ create_bd_port -dir I pmodENC_btn ]
  set pmodENC_sw [ create_bd_port -dir I pmodENC_sw ]
  set pwm_2 [ create_bd_port -dir O -from 3 -to 0 pwm_2 ]
  set sa [ create_bd_port -dir I sa ]
  set scl_i [ create_bd_port -dir I scl_i ]
  set scl_o [ create_bd_port -dir O scl_o ]
  set scl_t [ create_bd_port -dir O scl_t ]
  set sda_i [ create_bd_port -dir I sda_i ]
  set sda_o [ create_bd_port -dir O sda_o ]
  set sda_t [ create_bd_port -dir O sda_t ]
  set seg [ create_bd_port -dir O -from 6 -to 0 seg ]
  set sw [ create_bd_port -dir I -from 15 -to 0 sw ]
  set sysclk [ create_bd_port -dir I -type clk sysclk ]
  set sysreset_n [ create_bd_port -dir I -type rst sysreset_n ]
  set uart_rtl_rxd [ create_bd_port -dir I uart_rtl_rxd ]
  set uart_rtl_txd [ create_bd_port -dir O uart_rtl_txd ]

  # Create instance: PWM_0, and set properties
  set PWM_0 [ create_bd_cell -type ip -vlnv digilentinc.com:IP:PWM:2.0 PWM_0 ]
  set_property -dict [ list \
CONFIG.NUM_PWM {4} \
 ] $PWM_0

  # Create instance: PmodBT2_0, and set properties
  set PmodBT2_0 [ create_bd_cell -type ip -vlnv digilentinc.com:IP:PmodBT2:1.0 PmodBT2_0 ]

  # Create instance: PmodENC_0, and set properties
  set PmodENC_0 [ create_bd_cell -type ip -vlnv ece.pdx.edu:ece544:PmodENC:1.0 PmodENC_0 ]

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {1} \
CONFIG.C_ALL_INPUTS_2 {1} \
CONFIG.C_GPIO2_WIDTH {12} \
CONFIG.C_GPIO_WIDTH {12} \
CONFIG.C_INTERRUPT_PRESENT {0} \
CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_0

  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {1} \
CONFIG.C_ALL_INPUTS_2 {1} \
CONFIG.C_GPIO2_WIDTH {12} \
CONFIG.C_GPIO_WIDTH {12} \
CONFIG.C_INTERRUPT_PRESENT {0} \
CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_1

  # Create instance: axi_iic_0, and set properties
  set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 axi_iic_0 ]

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [ list \
CONFIG.C_BAUDRATE {115200} \
CONFIG.C_S_AXI_ACLK_FREQ_HZ {100000000} \
 ] $axi_uartlite_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.C_S_AXI_ACLK_FREQ_HZ.VALUE_SRC {DEFAULT} \
 ] $axi_uartlite_0

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.3 clk_wiz_1 ]
  set_property -dict [ list \
CONFIG.CLKOUT1_JITTER {130.958} \
CONFIG.CLKOUT1_PHASE_ERROR {98.575} \
CONFIG.CLKOUT2_JITTER {151.636} \
CONFIG.CLKOUT2_PHASE_ERROR {98.575} \
CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {50} \
CONFIG.CLKOUT2_USED {true} \
CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
CONFIG.MMCM_CLKIN1_PERIOD {10.0} \
CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000} \
CONFIG.MMCM_CLKOUT1_DIVIDE {20} \
CONFIG.MMCM_COMPENSATION {ZHOLD} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.NUM_OUT_CLKS {2} \
CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
CONFIG.USE_RESET {false} \
 ] $clk_wiz_1

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.CLKOUT1_JITTER.VALUE_SRC {DEFAULT} \
CONFIG.CLKOUT1_PHASE_ERROR.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKFBOUT_MULT_F.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKIN1_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKIN2_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_COMPENSATION.VALUE_SRC {DEFAULT} \
 ] $clk_wiz_1

  # Create instance: fit_timer_1, and set properties
  set fit_timer_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fit_timer:2.0 fit_timer_1 ]
  set_property -dict [ list \
CONFIG.C_NO_CLOCKS {50000} \
 ] $fit_timer_1

  # Create instance: fit_timer_2, and set properties
  set fit_timer_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fit_timer:2.0 fit_timer_2 ]
  set_property -dict [ list \
CONFIG.C_NO_CLOCKS {200000} \
 ] $fit_timer_2

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:9.6 microblaze_0 ]
  set_property -dict [ list \
CONFIG.C_DEBUG_ENABLED {1} \
CONFIG.C_D_AXI {1} \
CONFIG.C_D_LMB {1} \
CONFIG.C_I_LMB {1} \
 ] $microblaze_0

  # Create instance: microblaze_0_axi_intc, and set properties
  set microblaze_0_axi_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 microblaze_0_axi_intc ]
  set_property -dict [ list \
CONFIG.C_HAS_FAST {1} \
CONFIG.C_KIND_OF_INTR {0xFFFFFFFF} \
 ] $microblaze_0_axi_intc

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {12} \
 ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: microblaze_0_xlconcat, and set properties
  set microblaze_0_xlconcat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 microblaze_0_xlconcat ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {5} \
 ] $microblaze_0_xlconcat

  # Create instance: nexys4IO_0, and set properties
  set nexys4IO_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:nexys4IO:2.1 nexys4IO_0 ]

  # Create instance: rst_clk_wiz_1_100M, and set properties
  set rst_clk_wiz_1_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_1_100M ]

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
CONFIG.DIN_FROM {5} \
CONFIG.DIN_TO {5} \
CONFIG.DIN_WIDTH {6} \
CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_0

  # Create interface connections
  connect_bd_intf_net -intf_net PmodBT2_0_Pmod_out [get_bd_intf_ports Pmod_out] [get_bd_intf_pins PmodBT2_0/Pmod_out]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO [get_bd_intf_ports gpio_rtl] [get_bd_intf_pins axi_gpio_0/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO2 [get_bd_intf_ports gpio_rtl_0] [get_bd_intf_pins axi_gpio_0/GPIO2]
  connect_bd_intf_net -intf_net axi_gpio_1_GPIO [get_bd_intf_ports gpio_rtl_1] [get_bd_intf_pins axi_gpio_1/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_1_GPIO2 [get_bd_intf_ports gpio_rtl_2] [get_bd_intf_pins axi_gpio_1/GPIO2]
  connect_bd_intf_net -intf_net microblaze_0_axi_dp [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI] [get_bd_intf_pins nexys4IO_0/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins PmodENC_0/S00_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins PWM_0/PWM_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins axi_iic_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M05_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M07_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M08_AXI [get_bd_intf_pins axi_gpio_1/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M09_AXI [get_bd_intf_pins PmodBT2_0/AXI_LITE_UART] [get_bd_intf_pins microblaze_0_axi_periph/M09_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M10_AXI [get_bd_intf_pins PmodBT2_0/AXI_LITE_GPIO] [get_bd_intf_pins microblaze_0_axi_periph/M10_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]
  connect_bd_intf_net -intf_net microblaze_0_intc_axi [get_bd_intf_pins microblaze_0_axi_intc/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_interrupt [get_bd_intf_pins microblaze_0/INTERRUPT] [get_bd_intf_pins microblaze_0_axi_intc/interrupt]

  # Create port connections
  connect_bd_net -net PWM_0_pwm [get_bd_ports pwm_2] [get_bd_pins PWM_0/pwm]
  connect_bd_net -net PmodBT2_0_BT2_uart_interrupt [get_bd_pins PmodBT2_0/BT2_uart_interrupt] [get_bd_pins microblaze_0_xlconcat/In3]
  connect_bd_net -net axi_iic_0_iic2intc_irpt [get_bd_pins axi_iic_0/iic2intc_irpt] [get_bd_pins microblaze_0_xlconcat/In4]
  connect_bd_net -net axi_iic_0_scl_o [get_bd_ports scl_o] [get_bd_pins axi_iic_0/scl_o]
  connect_bd_net -net axi_iic_0_scl_t [get_bd_ports scl_t] [get_bd_pins axi_iic_0/scl_t]
  connect_bd_net -net axi_iic_0_sda_o [get_bd_ports sda_o] [get_bd_pins axi_iic_0/sda_o]
  connect_bd_net -net axi_iic_0_sda_t [get_bd_ports sda_t] [get_bd_pins axi_iic_0/sda_t]
  connect_bd_net -net axi_uartlite_0_tx [get_bd_ports uart_rtl_txd] [get_bd_pins axi_uartlite_0/tx]
  connect_bd_net -net btnC [get_bd_pins microblaze_0_xlconcat/In1] [get_bd_pins xlslice_0/Dout]
  connect_bd_net -net btnC_1 [get_bd_ports btnC] [get_bd_pins nexys4IO_0/btnC]
  connect_bd_net -net btnD_1 [get_bd_ports btnD] [get_bd_pins nexys4IO_0/btnD]
  connect_bd_net -net btnL_1 [get_bd_ports btnL] [get_bd_pins nexys4IO_0/btnL]
  connect_bd_net -net btnR_1 [get_bd_ports btnR] [get_bd_pins nexys4IO_0/btnR]
  connect_bd_net -net btnU_1 [get_bd_ports btnU] [get_bd_pins nexys4IO_0/btnU]
  connect_bd_net -net clk_in1_1 [get_bd_ports sysclk] [get_bd_pins clk_wiz_1/clk_in1]
  connect_bd_net -net clk_wiz_1_clk_out2 [get_bd_ports clock_50MHz] [get_bd_pins clk_wiz_1/clk_out2]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_clk_wiz_1_100M/dcm_locked]
  connect_bd_net -net ext_reset_in_1 [get_bd_ports sysreset_n] [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]
  connect_bd_net -net fit_timer_1_Interrupt [get_bd_pins fit_timer_1/Interrupt] [get_bd_pins microblaze_0_xlconcat/In0]
  connect_bd_net -net fit_timer_2_Interrupt [get_bd_pins fit_timer_2/Interrupt] [get_bd_pins microblaze_0_xlconcat/In2]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/mb_debug_sys_rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_ports clockOut] [get_bd_pins PWM_0/pwm_axi_aclk] [get_bd_pins PmodBT2_0/s_axi_aclk] [get_bd_pins PmodENC_0/s00_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins fit_timer_1/Clk] [get_bd_pins fit_timer_2/Clk] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_intc/processor_clk] [get_bd_pins microblaze_0_axi_intc/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins microblaze_0_axi_periph/M06_ACLK] [get_bd_pins microblaze_0_axi_periph/M07_ACLK] [get_bd_pins microblaze_0_axi_periph/M08_ACLK] [get_bd_pins microblaze_0_axi_periph/M09_ACLK] [get_bd_pins microblaze_0_axi_periph/M10_ACLK] [get_bd_pins microblaze_0_axi_periph/M11_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins nexys4IO_0/Clock] [get_bd_pins nexys4IO_0/s00_axi_aclk] [get_bd_pins rst_clk_wiz_1_100M/slowest_sync_clk]
  connect_bd_net -net microblaze_0_intr [get_bd_pins microblaze_0_axi_intc/intr] [get_bd_pins microblaze_0_xlconcat/dout]
  connect_bd_net -net nexys4IO_0_RGB1_Blue [get_bd_ports RGB1_Blue] [get_bd_pins nexys4IO_0/RGB1_Blue]
  connect_bd_net -net nexys4IO_0_RGB1_Green [get_bd_ports RGB1_Green] [get_bd_pins nexys4IO_0/RGB1_Green]
  connect_bd_net -net nexys4IO_0_RGB1_Red [get_bd_ports RGB1_Red] [get_bd_pins nexys4IO_0/RGB1_Red]
  connect_bd_net -net nexys4IO_0_RGB2_Blue [get_bd_ports RGB2_Blue] [get_bd_pins nexys4IO_0/RGB2_Blue]
  connect_bd_net -net nexys4IO_0_RGB2_Green [get_bd_ports RGB2_Green] [get_bd_pins nexys4IO_0/RGB2_Green]
  connect_bd_net -net nexys4IO_0_RGB2_Red [get_bd_ports RGB2_Red] [get_bd_pins nexys4IO_0/RGB2_Red]
  connect_bd_net -net nexys4IO_0_an [get_bd_ports an] [get_bd_pins nexys4IO_0/an]
  connect_bd_net -net nexys4IO_0_db_btns [get_bd_pins nexys4IO_0/db_btns] [get_bd_pins xlslice_0/Din]
  connect_bd_net -net nexys4IO_0_dp [get_bd_ports dp] [get_bd_pins nexys4IO_0/dp]
  connect_bd_net -net nexys4IO_0_led [get_bd_ports led] [get_bd_pins nexys4IO_0/led]
  connect_bd_net -net nexys4IO_0_seg [get_bd_ports seg] [get_bd_pins nexys4IO_0/seg]
  connect_bd_net -net pmodENC_A_1 [get_bd_ports pmodENC_A] [get_bd_pins PmodENC_0/pmodENC_A]
  connect_bd_net -net pmodENC_B_1 [get_bd_ports pmodENC_B] [get_bd_pins PmodENC_0/pmodENC_B]
  connect_bd_net -net pmodENC_btn_1 [get_bd_ports pmodENC_btn] [get_bd_pins PmodENC_0/pmodENC_btn]
  connect_bd_net -net pmodENC_sw_1 [get_bd_ports pmodENC_sw] [get_bd_pins PmodENC_0/pmodENC_sw]
  connect_bd_net -net rst_clk_wiz_1_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_interconnect_aresetn [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins rst_clk_wiz_1_100M/interconnect_aresetn]
  connect_bd_net -net rst_clk_wiz_1_100M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins microblaze_0_axi_intc/processor_rst] [get_bd_pins rst_clk_wiz_1_100M/mb_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins PWM_0/pwm_axi_aresetn] [get_bd_pins PmodBT2_0/s_axi_aresetn] [get_bd_pins PmodENC_0/s00_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_intc/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins microblaze_0_axi_periph/M06_ARESETN] [get_bd_pins microblaze_0_axi_periph/M07_ARESETN] [get_bd_pins microblaze_0_axi_periph/M08_ARESETN] [get_bd_pins microblaze_0_axi_periph/M09_ARESETN] [get_bd_pins microblaze_0_axi_periph/M10_ARESETN] [get_bd_pins microblaze_0_axi_periph/M11_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins nexys4IO_0/s00_axi_aresetn] [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_reset [get_bd_pins fit_timer_1/Rst] [get_bd_pins fit_timer_2/Rst] [get_bd_pins rst_clk_wiz_1_100M/peripheral_reset]
  connect_bd_net -net scl_i_1 [get_bd_ports scl_i] [get_bd_pins axi_iic_0/scl_i]
  connect_bd_net -net sda_i_1 [get_bd_ports sda_i] [get_bd_pins axi_iic_0/sda_i]
  connect_bd_net -net sw_1 [get_bd_ports sw] [get_bd_pins nexys4IO_0/sw]
  connect_bd_net -net uart_rtl_rxd_1 [get_bd_ports uart_rtl_rxd] [get_bd_pins axi_uartlite_0/rx]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x44A20000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs PWM_0/PWM_AXI/PWM_AXI_reg] SEG_PWM_0_PWM_AXI_reg
  create_bd_addr_seg -range 0x00002000 -offset 0x00020000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs PmodBT2_0/AXI_LITE_UART/Reg0] SEG_PmodBT2_0_Reg0
  create_bd_addr_seg -range 0x00001000 -offset 0x00030000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs PmodBT2_0/AXI_LITE_GPIO/Reg0] SEG_PmodBT2_0_Reg01
  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs PmodENC_0/S00_AXI/S00_AXI_reg] SEG_PmodENC_0_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40010000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_gpio_1/S_AXI/Reg] SEG_axi_gpio_1_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40800000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_iic_0/S_AXI/Reg] SEG_axi_iic_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00020000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00020000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_axi_intc/S_AXI/Reg] SEG_microblaze_0_axi_intc_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs nexys4IO_0/S00_AXI/S00_AXI_reg] SEG_nexys4IO_0_S00_AXI_reg

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.12  2016-01-29 bk=1.3547 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port sda_i -pg 1 -y 1630 -defaultsOSRD
preplace port Pmod_out -pg 1 -y 520 -defaultsOSRD
preplace port dir_out -pg 1 -y 370 -defaultsOSRD
preplace port btnL -pg 1 -y 130 -defaultsOSRD
preplace port pmodENC_sw -pg 1 -y 1030 -defaultsOSRD
preplace port pmodENC_A -pg 1 -y 970 -defaultsOSRD
preplace port pmodENC_B -pg 1 -y 990 -defaultsOSRD
preplace port gpio_rtl -pg 1 -y 670 -defaultsOSRD
preplace port scl_o -pg 1 -y 1460 -defaultsOSRD
preplace port RGB1_Blue -pg 1 -y 100 -defaultsOSRD
preplace port clock_50MHz -pg 1 -y 1350 -defaultsOSRD
preplace port btnC -pg 1 -y 150 -defaultsOSRD
preplace port sda_o -pg 1 -y 1520 -defaultsOSRD
preplace port sa -pg 1 -y 840 -defaultsOSRD
preplace port btnD -pg 1 -y 90 -defaultsOSRD
preplace port uart_rtl_txd -pg 1 -y 1280 -defaultsOSRD
preplace port dp -pg 1 -y 200 -defaultsOSRD
preplace port btnR -pg 1 -y 110 -defaultsOSRD
preplace port pmodENC_btn -pg 1 -y 1010 -defaultsOSRD
preplace port RGB2_Blue -pg 1 -y 160 -defaultsOSRD
preplace port sysclk -pg 1 -y 1410 -defaultsOSRD
preplace port scl_t -pg 1 -y 1480 -defaultsOSRD
preplace port en -pg 1 -y 390 -defaultsOSRD
preplace port RGB1_Red -pg 1 -y 60 -defaultsOSRD
preplace port uart_rtl_rxd -pg 1 -y 1260 -defaultsOSRD -right
preplace port sysreset_n -pg 1 -y 1290 -defaultsOSRD
preplace port gpio_rtl_0 -pg 1 -y 690 -defaultsOSRD
preplace port RGB2_Green -pg 1 -y 140 -defaultsOSRD
preplace port btnU -pg 1 -y 820 -defaultsOSRD
preplace port RGB2_Red -pg 1 -y 120 -defaultsOSRD
preplace port gpio_rtl_1 -pg 1 -y 790 -defaultsOSRD
preplace port sda_t -pg 1 -y 1540 -defaultsOSRD
preplace port scl_i -pg 1 -y 1430 -defaultsOSRD
preplace port gpio_rtl_2 -pg 1 -y 810 -defaultsOSRD
preplace port RGB1_Green -pg 1 -y 80 -defaultsOSRD
preplace port clockOut -pg 1 -y 1190 -defaultsOSRD
preplace portBus sw -pg 1 -y 950 -defaultsOSRD
preplace portBus an -pg 1 -y 220 -defaultsOSRD
preplace portBus led -pg 1 -y 40 -defaultsOSRD
preplace portBus seg -pg 1 -y 180 -defaultsOSRD
preplace portBus pwm_2 -pg 1 -y 1120 -defaultsOSRD
preplace inst axi_iic_0 -pg 1 -lvl 7 -y 1500 -defaultsOSRD
preplace inst xlslice_0 -pg 1 -lvl 2 -y 1080 -defaultsOSRD
preplace inst PmodBT2_0 -pg 1 -lvl 7 -y 530 -defaultsOSRD
preplace inst microblaze_0_axi_periph -pg 1 -lvl 6 -y 480 -defaultsOSRD
preplace inst axi_gpio_0 -pg 1 -lvl 7 -y 680 -defaultsOSRD
preplace inst fit_timer_1 -pg 1 -lvl 2 -y 1190 -defaultsOSRD
preplace inst microblaze_0_xlconcat -pg 1 -lvl 3 -y 1220 -defaultsOSRD
preplace inst axi_gpio_1 -pg 1 -lvl 7 -y 800 -defaultsOSRD
preplace inst fit_timer_2 -pg 1 -lvl 2 -y 1290 -defaultsOSRD
preplace inst PWM_0 -pg 1 -lvl 7 -y 1120 -defaultsOSRD
preplace inst mdm_1 -pg 1 -lvl 4 -y 1340 -defaultsOSRD
preplace inst microblaze_0_axi_intc -pg 1 -lvl 4 -y 1170 -defaultsOSRD
preplace inst nexys4IO_0 -pg 1 -lvl 7 -y 260 -defaultsOSRD
preplace inst axi_uartlite_0 -pg 1 -lvl 7 -y 1270 -defaultsOSRD
preplace inst microblaze_0 -pg 1 -lvl 5 -y 1200 -defaultsOSRD
preplace inst rst_clk_wiz_1_100M -pg 1 -lvl 1 -y 1310 -defaultsOSRD
preplace inst clk_wiz_1 -pg 1 -lvl 6 -y 1350 -defaultsOSRD
preplace inst microblaze_0_local_memory -pg 1 -lvl 6 -y 1210 -defaultsOSRD
preplace inst PmodENC_0 -pg 1 -lvl 7 -y 960 -defaultsOSRD
preplace netloc microblaze_0_axi_periph_M02_AXI 1 6 1 2010
preplace netloc pmodENC_B_1 1 0 7 NJ 940 NJ 940 NJ 940 NJ 940 NJ 940 NJ 940 NJ
preplace netloc nexys4IO_0_RGB2_Blue 1 7 2 NJ 160 NJ
preplace netloc axi_iic_0_sda_t 1 7 2 NJ 1540 NJ
preplace netloc microblaze_0_axi_periph_M03_AXI 1 6 1 1980
preplace netloc microblaze_0_axi_periph_M01_AXI 1 6 1 1980
preplace netloc nexys4IO_0_RGB2_Green 1 7 2 NJ 140 NJ
preplace netloc axi_uartlite_0_tx 1 7 2 NJ 1280 NJ
preplace netloc microblaze_0_dlmb_1 1 5 1 N
preplace netloc microblaze_0_intc_axi 1 3 4 880 120 NJ 120 NJ 120 1930
preplace netloc scl_i_1 1 0 8 NJ 1440 NJ 1440 NJ 1440 NJ 1440 NJ 1440 NJ 1440 NJ 1630 2390
preplace netloc rst_clk_wiz_1_100M_mb_reset 1 1 4 NJ 1350 NJ 1310 870 1270 NJ
preplace netloc axi_gpio_0_GPIO 1 7 2 NJ 670 NJ
preplace netloc nexys4IO_0_RGB2_Red 1 7 2 NJ 120 NJ
preplace netloc rst_clk_wiz_1_100M_bus_struct_reset 1 1 5 NJ 1360 NJ 1360 NJ 1280 NJ 1280 1600
preplace netloc axi_gpio_0_GPIO2 1 7 2 NJ 690 NJ
preplace netloc nexys4IO_0_RGB1_Green 1 7 2 NJ 80 NJ
preplace netloc PmodBT2_0_Pmod_out 1 7 2 NJ 520 NJ
preplace netloc pmodENC_btn_1 1 0 7 NJ 960 NJ 960 NJ 960 NJ 960 NJ 960 NJ 960 NJ
preplace netloc fit_timer_1_Interrupt 1 2 1 660
preplace netloc microblaze_0_ilmb_1 1 5 1 N
preplace netloc btnL_1 1 0 7 NJ 90 NJ 90 NJ 90 NJ 90 NJ 90 NJ 90 NJ
preplace netloc microblaze_0_axi_periph_M08_AXI 1 6 1 1950
preplace netloc microblaze_0_interrupt 1 4 1 N
preplace netloc mdm_1_debug_sys_rst 1 0 5 50 1420 NJ 1420 NJ 1420 NJ 1420 1120
preplace netloc axi_iic_0_iic2intc_irpt 1 2 6 680 1400 NJ 1400 NJ 1400 NJ 1420 NJ 1370 2450
preplace netloc nexys4IO_0_RGB1_Red 1 7 2 NJ 60 NJ
preplace netloc microblaze_0_Clk 1 0 9 50 1220 470 1130 NJ 1130 870 1070 1130 1070 1620 140 1960 1360 NJ 1190 NJ
preplace netloc nexys4IO_0_seg 1 7 2 NJ 180 NJ
preplace netloc sw_1 1 0 7 NJ 60 NJ 60 NJ 60 NJ 60 NJ 60 NJ 60 NJ
preplace netloc ext_reset_in_1 1 0 1 NJ
preplace netloc btnC_1 1 0 7 NJ 30 NJ 30 NJ 30 NJ 30 NJ 30 NJ 30 NJ
preplace netloc axi_gpio_1_GPIO2 1 7 2 NJ 810 NJ
preplace netloc nexys4IO_0_db_btns 1 1 7 470 50 NJ 50 NJ 50 NJ 50 NJ 50 NJ 50 2370
preplace netloc nexys4IO_0_led 1 7 2 NJ 40 NJ
preplace netloc nexys4IO_0_RGB1_Blue 1 7 2 NJ 100 NJ
preplace netloc clk_wiz_1_locked 1 0 7 90 1430 NJ 1430 NJ 1430 NJ 1430 NJ 1430 NJ 1430 1920
preplace netloc microblaze_0_axi_periph_M10_AXI 1 6 1 2040
preplace netloc microblaze_0_axi_periph_M09_AXI 1 6 1 2030
preplace netloc microblaze_0_debug 1 4 1 1120
preplace netloc PWM_0_pwm 1 7 2 NJ 1120 N
preplace netloc btnR_1 1 0 7 NJ 110 NJ 110 NJ 110 NJ 110 NJ 110 NJ 100 NJ
preplace netloc microblaze_0_axi_dp 1 5 1 1610
preplace netloc rst_clk_wiz_1_100M_peripheral_reset 1 1 1 460
preplace netloc PmodBT2_0_BT2_uart_interrupt 1 2 6 680 1060 NJ 1060 NJ 1060 NJ 1060 NJ 1190 2370
preplace netloc btnU_1 1 0 7 NJ 40 NJ 40 NJ 40 NJ 40 NJ 40 NJ 40 NJ
preplace netloc rst_clk_wiz_1_100M_interconnect_aresetn 1 1 5 NJ 240 NJ 240 NJ 240 NJ 240 NJ
preplace netloc sda_i_1 1 0 8 NJ 1640 NJ 1640 NJ 1640 NJ 1640 NJ 1640 NJ 1640 NJ 1640 2370
preplace netloc clk_wiz_1_clk_out2 1 6 3 NJ 1350 NJ 1350 NJ
preplace netloc pmodENC_A_1 1 0 7 NJ 920 NJ 920 NJ 920 NJ 920 NJ 920 NJ 920 NJ
preplace netloc btnC 1 2 1 NJ
preplace netloc btnD_1 1 0 7 NJ 80 NJ 80 NJ 80 NJ 80 NJ 80 NJ 80 NJ
preplace netloc microblaze_0_axi_periph_M04_AXI 1 6 1 1940
preplace netloc axi_iic_0_scl_o 1 7 2 NJ 1460 NJ
preplace netloc pmodENC_sw_1 1 0 7 NJ 980 NJ 980 NJ 980 NJ 980 NJ 980 NJ 980 NJ
preplace netloc axi_gpio_1_GPIO 1 7 2 NJ 790 NJ
preplace netloc nexys4IO_0_an 1 7 2 NJ 220 NJ
preplace netloc nexys4IO_0_dp 1 7 2 NJ 200 NJ
preplace netloc microblaze_0_axi_periph_M07_AXI 1 6 1 1930
preplace netloc clk_in1_1 1 0 6 NJ 1410 NJ 1410 NJ 1410 NJ 1410 NJ 1350 NJ
preplace netloc axi_iic_0_sda_o 1 7 2 NJ 1520 NJ
preplace netloc microblaze_0_intr 1 3 1 860
preplace netloc uart_rtl_rxd_1 1 7 2 NJ 1260 NJ
preplace netloc axi_iic_0_scl_t 1 7 2 NJ 1480 NJ
preplace netloc microblaze_0_axi_periph_M05_AXI 1 6 1 1990
preplace netloc rst_clk_wiz_1_100M_peripheral_aresetn 1 1 6 NJ 1030 NJ 1030 860 760 NJ 760 1600 110 1970
preplace netloc fit_timer_2_Interrupt 1 2 1 660
levelinfo -pg 1 -10 260 570 770 1010 1370 1770 2230 2600 2720 -top -80 -bot 1650
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


