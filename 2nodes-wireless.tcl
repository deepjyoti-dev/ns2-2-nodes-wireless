# Create a simulator instance
set ns [new Simulator]

# Define a trace file for logging simulation data
set tracefile [open out.tr w]
$ns trace-all $tracefile

# Create a nam file to visualize the simulation (optional)
set namfile [open out.nam w]
$ns namtrace-all-wireless $namfile 50 ;# 50 is the topography size

# Define the topology size (X and Y max)
set topoX 500
set topoY 500

# Create two mobile nodes with initial positions
set node1 [$ns node]
$node1 set X_ 100
$node1 set Y_ 100
$node1 set Z_ 0

set node2 [$ns node]
$node2 set X_ 400
$node2 set Y_ 400
$node2 set Z_ 0

# Set node parameters for wireless simulation
$ns node-config -adhocRouting AODV \
    -llType LL \
    -macType Mac/802_11 \
    -ifqType Queue/DropTail/PriQueue \
    -ifqLen 50 \
    -antType Antenna/OmniAntenna \
    -propType Propagation/TwoRayGround \
    -phyType Phy/WirelessPhy \
    -channelType Channel/WirelessChannel \
    -topoInstance $ns \
    -agentTrace ON \
    -routerTrace ON \
    -macTrace ON

# Enable wireless channel
set chan [new Channel/WirelessChannel]

# Attach nodes to the channel
$node1 set channel_ $chan
$node2 set channel_ $chan

# Create UDP agent on node1 and attach it to a CBR traffic source
set udp1 [new Agent/UDP]
$ns attach-agent $node1 $udp1

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.05
$cbr1 attach-agent $udp1

# Create Null agent on node2 to receive packets
set null2 [new Agent/Null]
$ns attach-agent $node2 $null2

# Connect UDP agent to Null agent
$ns connect $udp1 $null2

# Schedule events
$ns at 0.5 "$cbr1 start"
$ns at 4.5 "$cbr1 stop"
$ns at 5.0 "finish"

# Define finish procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exit 0
}

# Run the simulation
$ns run
