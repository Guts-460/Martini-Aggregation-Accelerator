#!/bin/bash
source /opt/modules-4.7.1/init/${SHELL##*/}
module load GROMACS/2022.5
module load Python/2.7.18

##中间可能会跑错，找到对应的时间，然后续跑即可
#(1) 先跑1us，创建起点
mkdir 1
cp ./common/1us.tpr ./1
gmx mdrun -s ./1us.tpr -v -deffnm ./1/1us -rdd 2.0

mkdir {2..12}
tdrop=(2 3 4 5 6 7 8 9 10 11 12)
for ite in "${tdrop[@]}"; do
	./runsingle.sh $ite
done

mkdir equi2us
./runequi.sh
