# script-pool

Assorted utility scripts

## ss usage

monitor.sh: run ss to collect TCP stats

parse_ss/plotting.py: process traces collected by ss

## Setup network emulation experiment

Example:

**Create two network namespace with 3 interfaces between them**

sudo ./netns.sh create test a b 3

**Execute bash inside environment a, ip 10.0.0.1**

sudo ./netns.sh exec test a bash

**Execute bash inside environment b, ip 10.0.0.2**

sudo ./netns.sh exec test b bash

**Trying pinging**

ping 10.0.0.1/2

## Setup tc rules

Example:

**In the server namespace, Set up tc qdiscs: netem, tbf**

./load-tc-rules.sh init

Check tc rules

tc qdisc show
