COP5615 Project 2
Due Date: October 1st 2019 11:59PM 
Isabel Laurenceau 7393-5064
Anshika Saxena    9530-5566

What Is Working 
	We have implemented both the Gossip and Push Sum algorithms on all six topologies. To run our program:
Go to the main directory where mix.exs is located
Build using “mix escript.build”
Run using  “./project2 [numNodes] [Topology] [Algorithm]”
Where numNodes can be any integer number >=2. 
Where Topology can be: 
Full
Line
twoD
threeD
Honeycomb
Honeycomb_rand 
Where Algorithm can be: 
Gossip
Push


Gossip Largest Nodes: 
Full
Line - 2500
twoD - 5000
threeD - 5000
Honeycomb - 5000
Honeycomb_rand - 7000

Push Sum Largest Nodes: 
Full - 3000 
Line - 300
twoD - 3000
threeD - 5000
Honeycomb - 2000
Honeycomb_rand - 7000