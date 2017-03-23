`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland State University
// Engineers: Francisco J Lopez Garibay, Shadman Samin
// Create Date: 02/16/2017 11:13:02 PM
// Module Name: DC_motor_controller
// Project Name:DC_motor_controller 
// Target Devices: Xilinx Artix-7 on Nexys4DDR board by Digilent 
// Tool Versions: Vivado 2016.2
// Description: DC motor controller (Permanent Magnet or Separately Excited Field Winding).
//              Brushed commutation. Packaged as IP AXI4-lite peripheral to interface w/
//              Microblaze processor on one side, and PmodHB3 H-bridge for motor control 
//              on the other. 
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module DC_motor_controller
#(
    parameter FREQ_WIDTH = 8,    // 8 bits for motor frequency value
    parameter DUTY_WIDTH = 15,  // 15 bits for PWM Duty 
    parameter CLK_FREQ_HZ = 100_000_000 
)
(
    input clk,  // system clk, AXI clk
    input clk_pwm,    // clk for PWM generation
    input reset,        // AXI reset
    // Microblaze side signals
    input dir_in,        // motor direction bit
    input [DUTY_WIDTH-1:0] duty,   // motor duty cycle
    output [FREQ_WIDTH-1:0] freq,    // motor freq measured
    
    //PmodHB3 H-bridge side signals
    input sa,            // Hall sensor shaft rotation
    input sb,             // second sensor, not used  
    output reg dir_out,       // motor direction bit, to PmodHB3 bridge  
    output en             // Voltage enable for PWM control signal 
    );
    
    // only change rotation direction while motor is stopped
    always @(posedge clk) begin
       if( freq==0)         
        dir_out <= dir_in;
    end 
    
    // instantiate PWM generator
    PWM_out #(
         .DUTY_WIDTH(DUTY_WIDTH) 
    )    PWM_out_inst
    (
        .clk(clk_pwm),
        .reset(reset),
        .duty(duty),
        .pwm_out(en)
    );
    // instantiate RPM detector (frequency detector)
    freq_det  #(
            .CLK_FREQ_HZ(CLK_FREQ_HZ), 
            .FREQ_WIDTH(FREQ_WIDTH)
     ) freq_det_inst
    (
        .clk(clk),
        .reset(reset),
        .in_sig(sa), // Hall sensor signal input from PmodHB3
        .freq(freq)  // output - Measured motor freq (Hz) from Hall sensor
                     // freq = RPM / 60
    );    
endmodule
