# Compile with functional coverage enabled
#chnage what is before .sv to the top module name and the testbenchname
vlog FIFO.sv FIFO_top.sv +cover -covercells

# Start simulation with coverage enabled
#change what after work. to the name of the testbench top module
vsim work.FIFO_top -cover

# Save the coverage database when the simulation exits
coverage save -onexit code_coverage.ucdb

# Run the simulation
run -all

# Generate a text report
coverage report -details -output code_cov_report.txt

# (Optional) Generate a summary report
coverage report

