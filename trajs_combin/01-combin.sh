#!/bin/bash
source /opt/modules-4.7.1/init/${SHELL##*/}
module load GROMACS/2022.5
module load Python/2.7.18


## 提取蛋白质的轨迹并重新设置起始帧
#timelis=(450 900 1500 2400 3000 3450 3900 4500 5100 5700 6300 6900 7500)
timett=("1 0" "2 1" "3 2" "4 3" "5 4" "6 5" "7 6" "8 7" "9 8" "10 9" "11 10" "12 11")

for item in "${timett[@]}"; do
  #echo $item
  ./01-getraj.sh $item
done

#timet0=(0 450 900 1500 2400 3000 3450 3900 4500 5100 5700 6300 6900)
#for item in "${timet0[@]}"; do
  #echo $item
#  ./01-t0.sh $item
#done
#timett=("450 0" "900 450" "1500 900" "2400 1500" "3000 2400" "3450 3000" "3900 3450" "4500 3900" "5100 4500" "5700 5100" "6300 5700" "6900 6300" "7500 6900")

gmx trjcat -f 1ust0.xtc 2ust0.xtc -o c1.xtc
gmx trjcat -f c1.xtc 3ust0.xtc -o c2.xtc
rm c1.xtc
gmx trjcat -f c2.xtc 4ust0.xtc -o c3.xtc
rm c2.xtc
gmx trjcat -f c3.xtc 5ust0.xtc -o c4.xtc
rm c3.xtc
gmx trjcat -f c4.xtc 6ust0.xtc -o c5.xtc
rm c4.xtc
gmx trjcat -f c5.xtc 7ust0.xtc -o c6.xtc
rm c5.xtc
gmx trjcat -f c6.xtc 8ust0.xtc -o c7.xtc
rm c6.xtc
gmx trjcat -f c7.xtc 9ust0.xtc -o c8.xtc
rm c7.xtc
gmx trjcat -f c8.xtc 10ust0.xtc -o c9.xtc
rm c8.xtc
gmx trjcat -f c9.xtc 11ust0.xtc -o c10.xtc
rm c9.xtc
gmx trjcat -f c10.xtc 12ust0.xtc -o f5adrop.xtc
rm c10.xtc





