#!/bin/bash
source /opt/modules-4.7.1/init/${SHELL##*/}
module load GROMACS/2022.5
module load Python/2.7.18

gmx trjconv -f f5adrop.xtc -o f5a_movie.xtc -dt 10000 #每隔10ns输出一帧，制作聚集movie 
