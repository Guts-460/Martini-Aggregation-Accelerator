#!/bin/bash
source /opt/modules-4.7.1/init/${SHELL##*/}
module load GROMACS/2022.5
module load Python/2.7.18

gmx trjconv -s .././$1/"$1""us.tpr" -f .././$1/"$1""us.xtc" -o "$1""us_cluster.xtc" -pbc cluster -center << EOF
1
1
1
EOF

gmx trjconv -s .././$1/"$1""us.tpr" -f "$1""us_cluster.xtc" -o "$1""us_mol.xtc" -pbc mol -center << EOF
1
1
EOF

rm "$1""us_cluster.xtc"

gmx trjconv -s .././$1/"$1""us.tpr" -f "$1""us_mol.xtc" -o "$1""us.xtc" -fit rot+trans << EOF
1
1
EOF

rm "$1""us_mol.xtc"

gmx trjconv -s .././$1/"$1""us.tpr" -f "$1""us.xtc" -o "$1""ust0.xtc" -t"0" $(($2 * 1000000)) << EOF
1
EOF

rm "$1""us.xtc"

