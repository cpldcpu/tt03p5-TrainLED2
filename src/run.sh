
iverilog -o TrainLED.vvp TrainLED2.v TrainLED2_tb.v
vvp TrainLED.vvp
yosys synthtest.ys | grep -i 'Printing' -A 35
# gtkwave.exe TrainLED.vcd gtkwave_settings.gtkw
