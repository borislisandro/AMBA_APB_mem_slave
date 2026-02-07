transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/boris/Documents/QuartusPrime/amba_apb_slave {C:/Users/boris/Documents/QuartusPrime/amba_apb_slave/apb_mem_slave.sv}
vlog -sv -work work +incdir+C:/Users/boris/Documents/QuartusPrime/amba_apb_slave {C:/Users/boris/Documents/QuartusPrime/amba_apb_slave/mem_128x32.sv}
vlog -sv -work work +incdir+C:/Users/boris/Documents/QuartusPrime/amba_apb_slave {C:/Users/boris/Documents/QuartusPrime/amba_apb_slave/rtl_top.sv}

vlog -sv -work work +incdir+C:/Users/boris/Documents/QuartusPrime/amba_apb_slave {C:/Users/boris/Documents/QuartusPrime/amba_apb_slave/tb_top.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_top

add wave *
view structure
view signals
run -all
