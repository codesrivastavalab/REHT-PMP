#!/bin/bash

# REHT run

# run the first 1ns of production simulation without any exchange to equilibrate the replicas to corresponding replica temperature. 

# Equilibration
for cnt in {0..14}
do
    mkdir 1md${cnt}
    gmx_mpi grompp -f md${cnt}.mdp -p md${cnt}.top -c input.gro -n index.ndx -o 1md${cnt}/0md.tpr -maxwarn 1
done

mpirun -n $NPROCS gmx_mpi mdrun -v -multidir 1md{0..14} -deffnm 0md -s 0md.tpr -replex 500001 -hrex -plumed ../plumed.dat

# Production 1 - With exchange: 10 ns to check the exchange
for cnt in {0..14}
do
    gmx_mpi convert-tpr -s 1md${cnt}/0md.tpr -o 1md${cnt}/1md.tpr -extend 10000 
done

mpirun -n $NPROCS gmx_mpi mdrun -v -multidir 1md{0..14} -deffnm 1md -s 1md -cpi 0md.cpt -replex 500 -hrex -plumed ../plumed.dat -noappend

# Extension if the exchange is good
# Production 2
for cnt in {0..14}
do
    gmx_mpi convert-tpr -s 1md${cnt}/1md.tpr -o 1md${cnt}/2md.tpr -extend 90000 
done

mpirun -n $NPROCS gmx_mpi mdrun -v -multidir 1md{0..14} -deffnm 2md -s 2md -cpi 1md.cpt -replex 500 -hrex -plumed ../plumed.dat -noappend
