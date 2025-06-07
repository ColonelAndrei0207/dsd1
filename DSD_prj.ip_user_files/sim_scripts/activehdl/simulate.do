transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+fpga  -L xil_defaultlib -L axi_lite_ipif_v3_0_4 -L lib_pkg_v1_0_4 -L lib_srl_fifo_v1_0_4 -L lib_cdc_v1_0_3 -L axi_uartlite_v2_0_37 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.fpga xil_defaultlib.glbl

do {fpga.udo}

run 1000ns

endsim

quit -force
