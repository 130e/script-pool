# script-pool
Assorted utility scripts

## Setup network emulation experiment
Example:

**Create two network namespace**

sudo ./netns.sh create test a b 1

**Execute bash inside environment a, ip 10.0.0.1**

sudo ./netns.sh exec test a bash

**Execute bash inside environment b, ip 10.0.0.2**

sudo ./netns.sh exec test b bash

**Trying pinging**

ping 10.0.0.1/2

## Setup tc rules
Example:

**In the server namespace, Set up tc qdiscs: netem, tbf**

./load-tc-buffer.sh load
