#!/bin/bash
source /opt/modules-4.7.1/init/${SHELL##*/}
module load GROMACS/2022.5
module load Python/2.7.18

gmx trjconv -s .././equi500/"12.5us.tpr" -f .././equi500/"12.5us.xtc" -o "12.5us_cluster.xtc" -pbc cluster -center << EOF
1
1
1
EOF

gmx trjconv -s .././equi500/"12.5us.tpr" -f "12.5us_cluster.xtc" -o "12.5us_mol.xtc" -pbc mol -center << EOF
1
1
EOF

rm "12.5us_cluster.xtc"

gmx trjconv -s .././equi500/"12.5us.tpr" -f "12.5us_mol.xtc" -o "12.5us.xtc" -fit rot+trans << EOF
1
1
EOF

rm "12.5us_mol.xtc"

gmx trjconv -s .././equi500/"12.5us.tpr" -f "12.5us.xtc" -o "12.5ust0.xtc" -t"0" 12000000 << EOF
1
EOF

rm "12.5us.xtc"

gmx trjcat -f f5adrop.xtc "12.5ust0.xtc" -o f5adrop_all.xtc
