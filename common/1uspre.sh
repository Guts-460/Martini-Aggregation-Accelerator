#!/bin/bash
source /opt/modules-4.7.1/init/${SHELL##*/}
module load GROMACS/2022.5
module load Python/2.7.18

##相应的文件在上级目录的common下，此脚本的作用是获得1us.tpr

gmx editconf -f F5A.pdb -o f5a.gro

# de Jong et al., J. Chem. Theory Comput., 2013, DOI:10.1021/ct300646g
python martinize.py -f f5a.gro -o fm0.top -x fm0.pdb -p backbone -ff martini22 -ss F5A.dssp

cp fm0.top box.top
sed -i 's/#include "martini.itp"/#include "martini_v2.2.itp"\n#include "martini_v2.0_ions.itp"/' box.top


#构建初始结构，分散相，需要保证多肽之间可以碰撞，所以盒子设置小一些，这里的初始边长为7nm。
#但是也不能太小，否则15个多肽不一定全部放得进去

#radius--指定的范德华半径，师兄用的是0.4，但是我的溶液浓度更低，nm级别的

gmx insert-molecules -box 7 7 7 -nmol 15 -ci fm0.pdb -radius 0.4 -o box.gro

sed -i 's/Protein_A 	 1/Protein_A 	 15/' box.top

gmx solvate -cp box.gro -cs water.gro -box 7 7 7 -radius 0.17 -o bw.gro

nwater=$(grep -c '[0-9]W' bw.gro)

printf "\nW  $(($nwater-175))\nWF    100\nCL     75\n" >> box.top
#printf "\nCL     75" >> box.top

#cp martini_v2.0_ions.itp ions.itp

#自定平衡电荷
#gmx grompp -f em.mdp -p box.top -c bw.gro -o ions.tpr
#gmx genion -s ions.tpr -neutral -pname NA -nname CL -p box.top -o bw_ions.gro <<EOF
#13
#EOF

gmx grompp -f em.mdp -c bw.gro -p box.top -o em.tpr -pp em -po em -maxwarn 1
gmx mdrun -v -deffnm em

gmx grompp -f 1us.mdp -c em.gro -p em.top -pp 1us -po 1us -o 1us
# gmx mdrun -v -deffnm 02-eq -rdd 2.0


gmx grompp -f 1us.mdp -c 02-eq.gro -p box.top -o 1us
#gmx mdrun -v -deffnm 03-md300ns -rdd 2.0







