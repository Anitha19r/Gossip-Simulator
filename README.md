DISTRIBUTED OPERATING SYSTEM- GOSSIP SIMULATOR
Authors:
1)    Anitha Ranganathan - anitha19r - 76783421
2)    Sweta Thapliyal – Sthapliyal - 35436779

Requirements:
The following needs to be installed in the system:
1)    Elixir

Installation and Configuration:
1.    The mix.exs configuration.
2.    To install the project, just download the project folder ‘project2’ and then do build it using the commands:
a.    cd project2
b.    mix escript.build

Guide:
There are two types of algorithms which we have implemented --
1. Gossip algorithm
2. Push-sum algorithm

There are 3 topologies that we have considered --
The actual network topology plays a critical role in the dissemination speed of Gossip protocols. This project has simulators for various topologies. The topology determines who is considered a neighboor in the above algorithms.
1. Full Network: Every actor is a neighboor of all other actors. That is, every actor can talk directly to any other actor.
2. 2D Grid: Actors form a 2D grid. The actors can only talk to the grid neigboors.
3. Line: Actors are arranged in a line. Each actor has only 2 neighboors (one left and one right, unless you are the first or last actor).
4. Imperfect 2D Grid: Grid arrangement but one random other neighboor is selected from the list of all actors (4+1 neighboors).

Usage:
       ./project2 <number of nodes> <topology> <algorithm>
		<topology> = line, 2D, imp2D, full
		<algorithm> = gossip, push-sum
	Example: ./project2 1000 line push-sum

What is Working ?:
	1. Each permutation of (topology, algorithm) is working
	2. Checks are put in place to NOT increment self counter if message is received from self 
	   
What is the largest network we managed to deal with for each type of topology and algorithm ?:
   1. For Push-sum: 
   Line: 50,000
   2D: 10000
   Imperfect 2D:  100000
   Full: 50000

   2. For Gossip: 
   Line: 10,000
   2D: 100000
   Imperfect 2D:  50,000
   Full: 10000
	   