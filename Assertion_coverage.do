quit -sim

vlib work
vmap work work

# 1. Removed the invalid 'a'. 
# 'bcestf' covers Branch, Condition, Expression, Statement, Toggle, and FSM.
vlog +define+SIM axi4_if.sv axi4_assert.sv axi4.sv axi4_tb.sv \
     +cover=bcestf -covercells -assertdebug

# 2. Added -voptargs=+acc to ensure signals and assertions aren't optimized away
vsim -voptargs=+acc work.axi4_tb -coverage -assertdebug

view assertions

run -all

coverage save -assert -onexit axi4_cov.ucdb

coverage report -assert -details -output assertion_report.txt
coverage report -details -output coverage_report.txt