//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
//Date        : Sat Mar 18 22:24:08 2017
//Host        : DESKTOP-9GRO23T running 64-bit major release  (build 9200)
//Command     : generate_target embsys_wrapper.bd
//Design      : embsys_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module embsys_wrapper
   (RGB1_Blue,
    RGB1_Green,
    RGB1_Red,
    RGB2_Blue,
    RGB2_Green,
    RGB2_Red,
    an,
    btnC,
    btnD,
    btnL,
    btnR,
    btnU,
    clockOut,
    clock_50MHz,
    dir_out,
    dp,
    en,
    gpio_rtl_0_tri_i,
    gpio_rtl_1_tri_i,
    gpio_rtl_2_tri_i,
    gpio_rtl_tri_i,
    led,
    pmodENC_A,
    pmodENC_B,
    pmodENC_btn,
    pmodENC_sw,
    pmod_out_pin10_io,
    pmod_out_pin1_io,
    pmod_out_pin2_io,
    pmod_out_pin3_io,
    pmod_out_pin4_io,
    pmod_out_pin7_io,
    pmod_out_pin8_io,
    pmod_out_pin9_io,
    pwm_2,
    sa,
    scl_i,
    scl_o,
    scl_t,
    sda_i,
    sda_o,
    sda_t,
    seg,
    sw,
    sysclk,
    sysreset_n,
    uart_rtl_rxd,
    uart_rtl_txd);
  output RGB1_Blue;
  output RGB1_Green;
  output RGB1_Red;
  output RGB2_Blue;
  output RGB2_Green;
  output RGB2_Red;
  output [7:0]an;
  input btnC;
  input btnD;
  input btnL;
  input btnR;
  input btnU;
  output clockOut;
  output clock_50MHz;
  output dir_out;
  output dp;
  output en;
  input [11:0]gpio_rtl_0_tri_i;
  input [11:0]gpio_rtl_1_tri_i;
  input [11:0]gpio_rtl_2_tri_i;
  input [11:0]gpio_rtl_tri_i;
  output [15:0]led;
  input pmodENC_A;
  input pmodENC_B;
  input pmodENC_btn;
  input pmodENC_sw;
  inout pmod_out_pin10_io;
  inout pmod_out_pin1_io;
  inout pmod_out_pin2_io;
  inout pmod_out_pin3_io;
  inout pmod_out_pin4_io;
  inout pmod_out_pin7_io;
  inout pmod_out_pin8_io;
  inout pmod_out_pin9_io;
  output [3:0]pwm_2;
  input sa;
  input scl_i;
  output scl_o;
  output scl_t;
  input sda_i;
  output sda_o;
  output sda_t;
  output [6:0]seg;
  input [15:0]sw;
  input sysclk;
  input sysreset_n;
  input uart_rtl_rxd;
  output uart_rtl_txd;

  wire RGB1_Blue;
  wire RGB1_Green;
  wire RGB1_Red;
  wire RGB2_Blue;
  wire RGB2_Green;
  wire RGB2_Red;
  wire [7:0]an;
  wire btnC;
  wire btnD;
  wire btnL;
  wire btnR;
  wire btnU;
  wire clockOut;
  wire clock_50MHz;
  wire dir_out;
  wire dp;
  wire en;
  wire [11:0]gpio_rtl_0_tri_i;
  wire [11:0]gpio_rtl_1_tri_i;
  wire [11:0]gpio_rtl_2_tri_i;
  wire [11:0]gpio_rtl_tri_i;
  wire [15:0]led;
  wire pmodENC_A;
  wire pmodENC_B;
  wire pmodENC_btn;
  wire pmodENC_sw;
  wire pmod_out_pin10_i;
  wire pmod_out_pin10_io;
  wire pmod_out_pin10_o;
  wire pmod_out_pin10_t;
  wire pmod_out_pin1_i;
  wire pmod_out_pin1_io;
  wire pmod_out_pin1_o;
  wire pmod_out_pin1_t;
  wire pmod_out_pin2_i;
  wire pmod_out_pin2_io;
  wire pmod_out_pin2_o;
  wire pmod_out_pin2_t;
  wire pmod_out_pin3_i;
  wire pmod_out_pin3_io;
  wire pmod_out_pin3_o;
  wire pmod_out_pin3_t;
  wire pmod_out_pin4_i;
  wire pmod_out_pin4_io;
  wire pmod_out_pin4_o;
  wire pmod_out_pin4_t;
  wire pmod_out_pin7_i;
  wire pmod_out_pin7_io;
  wire pmod_out_pin7_o;
  wire pmod_out_pin7_t;
  wire pmod_out_pin8_i;
  wire pmod_out_pin8_io;
  wire pmod_out_pin8_o;
  wire pmod_out_pin8_t;
  wire pmod_out_pin9_i;
  wire pmod_out_pin9_io;
  wire pmod_out_pin9_o;
  wire pmod_out_pin9_t;
  wire [3:0]pwm_2;
  wire sa;
  wire scl_i;
  wire scl_o;
  wire scl_t;
  wire sda_i;
  wire sda_o;
  wire sda_t;
  wire [6:0]seg;
  wire [15:0]sw;
  wire sysclk;
  wire sysreset_n;
  wire uart_rtl_rxd;
  wire uart_rtl_txd;

  embsys embsys_i
       (.Pmod_out_pin10_i(pmod_out_pin10_i),
        .Pmod_out_pin10_o(pmod_out_pin10_o),
        .Pmod_out_pin10_t(pmod_out_pin10_t),
        .Pmod_out_pin1_i(pmod_out_pin1_i),
        .Pmod_out_pin1_o(pmod_out_pin1_o),
        .Pmod_out_pin1_t(pmod_out_pin1_t),
        .Pmod_out_pin2_i(pmod_out_pin2_i),
        .Pmod_out_pin2_o(pmod_out_pin2_o),
        .Pmod_out_pin2_t(pmod_out_pin2_t),
        .Pmod_out_pin3_i(pmod_out_pin3_i),
        .Pmod_out_pin3_o(pmod_out_pin3_o),
        .Pmod_out_pin3_t(pmod_out_pin3_t),
        .Pmod_out_pin4_i(pmod_out_pin4_i),
        .Pmod_out_pin4_o(pmod_out_pin4_o),
        .Pmod_out_pin4_t(pmod_out_pin4_t),
        .Pmod_out_pin7_i(pmod_out_pin7_i),
        .Pmod_out_pin7_o(pmod_out_pin7_o),
        .Pmod_out_pin7_t(pmod_out_pin7_t),
        .Pmod_out_pin8_i(pmod_out_pin8_i),
        .Pmod_out_pin8_o(pmod_out_pin8_o),
        .Pmod_out_pin8_t(pmod_out_pin8_t),
        .Pmod_out_pin9_i(pmod_out_pin9_i),
        .Pmod_out_pin9_o(pmod_out_pin9_o),
        .Pmod_out_pin9_t(pmod_out_pin9_t),
        .RGB1_Blue(RGB1_Blue),
        .RGB1_Green(RGB1_Green),
        .RGB1_Red(RGB1_Red),
        .RGB2_Blue(RGB2_Blue),
        .RGB2_Green(RGB2_Green),
        .RGB2_Red(RGB2_Red),
        .an(an),
        .btnC(btnC),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .btnU(btnU),
        .clockOut(clockOut),
        .clock_50MHz(clock_50MHz),
        .dir_out(dir_out),
        .dp(dp),
        .en(en),
        .gpio_rtl_0_tri_i(gpio_rtl_0_tri_i),
        .gpio_rtl_1_tri_i(gpio_rtl_1_tri_i),
        .gpio_rtl_2_tri_i(gpio_rtl_2_tri_i),
        .gpio_rtl_tri_i(gpio_rtl_tri_i),
        .led(led),
        .pmodENC_A(pmodENC_A),
        .pmodENC_B(pmodENC_B),
        .pmodENC_btn(pmodENC_btn),
        .pmodENC_sw(pmodENC_sw),
        .pwm_2(pwm_2),
        .sa(sa),
        .scl_i(scl_i),
        .scl_o(scl_o),
        .scl_t(scl_t),
        .sda_i(sda_i),
        .sda_o(sda_o),
        .sda_t(sda_t),
        .seg(seg),
        .sw(sw),
        .sysclk(sysclk),
        .sysreset_n(sysreset_n),
        .uart_rtl_rxd(uart_rtl_rxd),
        .uart_rtl_txd(uart_rtl_txd));
  IOBUF pmod_out_pin10_iobuf
       (.I(pmod_out_pin10_o),
        .IO(pmod_out_pin10_io),
        .O(pmod_out_pin10_i),
        .T(pmod_out_pin10_t));
  IOBUF pmod_out_pin1_iobuf
       (.I(pmod_out_pin1_o),
        .IO(pmod_out_pin1_io),
        .O(pmod_out_pin1_i),
        .T(pmod_out_pin1_t));
  IOBUF pmod_out_pin2_iobuf
       (.I(pmod_out_pin2_o),
        .IO(pmod_out_pin2_io),
        .O(pmod_out_pin2_i),
        .T(pmod_out_pin2_t));
  IOBUF pmod_out_pin3_iobuf
       (.I(pmod_out_pin3_o),
        .IO(pmod_out_pin3_io),
        .O(pmod_out_pin3_i),
        .T(pmod_out_pin3_t));
  IOBUF pmod_out_pin4_iobuf
       (.I(pmod_out_pin4_o),
        .IO(pmod_out_pin4_io),
        .O(pmod_out_pin4_i),
        .T(pmod_out_pin4_t));
  IOBUF pmod_out_pin7_iobuf
       (.I(pmod_out_pin7_o),
        .IO(pmod_out_pin7_io),
        .O(pmod_out_pin7_i),
        .T(pmod_out_pin7_t));
  IOBUF pmod_out_pin8_iobuf
       (.I(pmod_out_pin8_o),
        .IO(pmod_out_pin8_io),
        .O(pmod_out_pin8_i),
        .T(pmod_out_pin8_t));
  IOBUF pmod_out_pin9_iobuf
       (.I(pmod_out_pin9_o),
        .IO(pmod_out_pin9_io),
        .O(pmod_out_pin9_i),
        .T(pmod_out_pin9_t));
endmodule
