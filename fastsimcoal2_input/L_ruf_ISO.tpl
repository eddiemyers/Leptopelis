//Parameters for the coalescence simulation program : simcoal.exe
3 samples to simulate :
//Population effective sizes (number of genes)
sGab
nGab
Camer
//Samples sizes and samples age 
6
12
65
//Growth rates: negative growth implies population expansion
0
0
0
//Number of migration matrices : 0 implies no migration between demes
0
//historical event: time, source, sink, migrants, new deme size, growth rate, migr mat index
2 historical event
TDIV_Cam_N 2 1 1 ANC_Cam_N 0 0
TDIV_S 0 1 1 LEP_ANC 0 0
//Number of independent loci [chromosome] 
1 0
//Per chromosome: Number of contiguous linkage Block: a block is a set of contiguous loci
1
//per Block:data type, number of loci, per gen recomb and mut rates
FREQ 1 0 2.1e-8 OUTEXP
