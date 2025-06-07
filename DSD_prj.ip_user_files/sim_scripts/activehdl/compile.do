transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/axi_lite_ipif_v3_0_4
vlib activehdl/lib_pkg_v1_0_4
vlib activehdl/lib_srl_fifo_v1_0_4
vlib activehdl/lib_cdc_v1_0_3
vlib activehdl/axi_uartlite_v2_0_37
vlib activehdl/xil_defaultlib

vmap axi_lite_ipif_v3_0_4 activehdl/axi_lite_ipif_v3_0_4
vmap lib_pkg_v1_0_4 activehdl/lib_pkg_v1_0_4
vmap lib_srl_fifo_v1_0_4 activehdl/lib_srl_fifo_v1_0_4
vmap lib_cdc_v1_0_3 activehdl/lib_cdc_v1_0_3
vmap axi_uartlite_v2_0_37 activehdl/axi_uartlite_v2_0_37
vmap xil_defaultlib activehdl/xil_defaultlib

vcom -work axi_lite_ipif_v3_0_4 -93  \
"../../ipstatic/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work lib_pkg_v1_0_4 -93  \
"../../ipstatic/hdl/lib_pkg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_4 -93  \
"../../ipstatic/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work lib_cdc_v1_0_3 -93  \
"../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work axi_uartlite_v2_0_37 -93  \
"../../ipstatic/hdl/axi_uartlite_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../DSD_prj.gen/sources_1/ip/axi_uartlite_0/sim/axi_uartlite_0.vhd" \

vlog -work xil_defaultlib  -sv2k12 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l lib_cdc_v1_0_3 -l axi_uartlite_v2_0_37 -l xil_defaultlib \
"../../../DSD_prj.srcs/sources_1/new/defines.svh" \
"../../../DSD_prj.srcs/sources_1/new/axi_interface.sv" \
"../../../DSD_prj.srcs/sources_1/new/stage_execute_f.sv" \
"../../../DSD_prj.srcs/sources_1/new/alu.sv" \
"../../../DSD_prj.srcs/sources_1/new/stage_execute.sv" \
"../../../DSD_prj.srcs/sources_1/new/stage_fetch.sv" \
"../../../DSD_prj.srcs/sources_1/new/stage_write_back.sv" \
"../../../DSD_prj.srcs/sources_1/new/stage_read.sv" \
"../../../DSD_prj.srcs/sources_1/new/regs.sv" \
"../../../DSD_prj.srcs/sources_1/new/risc_core.sv" \
"../../../DSD_prj.srcs/sources_1/new/program_mem.sv" \
"../../../DSD_prj.srcs/sources_1/new/data_mem.sv" \
"../../../DSD_prj.srcs/sources_1/new/mem_ctrl.sv" \
"../../../DSD_prj.srcs/sources_1/new/fpga.sv" \
"../../../DSD_prj.srcs/sources_1/new/fsm.sv" \
"../../../DSD_prj.srcs/sources_1/new/i_o_mem.sv" \
"../../../DSD_prj.srcs/sources_1/new/i_o_axi.sv" \
"../../../DSD_prj.srcs/sim_1/new/tb.sv" \

vlog -work xil_defaultlib \
"glbl.v"

