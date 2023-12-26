# set the working dir, where all compiled verilog Goes
vlib work

# compile all verilog modules in mux.v to working dir
vlog lab8part1.v

vsim part1

#log all signals and add some signals to waveform window
log -r {/*}

# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {iClock} 0 0ns, 1 {5ns} -r 10ns



force iResetn 0
run 10ns

force iResetn 1
run 10000ns




















#force iResetn 0
#force xcord 8'd7
#force ycord 8'd6
#force blackclr 1'b0
#force 
#run 10ns
#force iResetn 1
#run 10ns
#force load 1
#run 10ns
#force load 0
#run 10ns
#force drawobject 1'b1
#run 400000ns