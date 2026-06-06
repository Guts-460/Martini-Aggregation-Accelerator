#!/bin/bash
source /opt/modules-4.7.1/init/${SHELL##*/}
module load GROMACS/2022.5
module load Python/2.7.18 
# 设置文件名
t=$1

inf=./$(($t - 1))  # 输入文件目录
ouf=./$t            # 输出文件目录

filename=$(($t-1))"us.gro"
cp $inf/box.top $ouf
cp $inf/$filename $ouf

cp ./common/Protein* $ouf   ##复制itp到ouf
cp ./common/1us.mdp $ouf
#filename="1us.gro"

grep W $ouf/$filename > wwf.gro
grep -v WF wwf.gro > w.gro
grep WF wwf.gro > wf.gro

grep -v W $ouf/$filename > now.gro
grep -v CL now.gro > pep.gro
sed -i '$d' pep.gro

grep CL $ouf/$filename > ion.gro

input_file="w.gro"
out_file="bw_next.gro"


##W的个数
linecount=$(wc -l < $input_file)
echo "Number of W:"
echo $linecount



#ndel=$(($linecount/4))

#echo "$ndel W were deleted"

new_w="new_w.gro"

#随机删除部分W
shuf w.gro | head -n $(($(wc -l < w.gro) * 4 / 5 + 1)) > $new_w

linecountnew=$(wc -l < $new_w)

echo "Number of W after deleting:"
echo $linecountnew

echo "Number of W deleted"
echo $(($linecount-$linecountnew))

#获得新的gro
cat pep.gro $new_w wf.gro ion.gro > $out_file  

# 修改top的W数
sed -i "s/W  $linecount/W  $linecountnew/" $ouf/box.top

##获得总原子数
atom_old=$(awk 'NR==2' $ouf/$filename)
atom_new=$(($atom_old - $(($linecount-$linecountnew))))
echo "New Atoms:"
echo $atom_new

## 修改bw_next.gro
awk "NR==2{print "$atom_new"} NR>2{print}" $out_file > bw_n2.gro
awk "NR==1{print}" $out_file > bw_n1.gro
cat bw_n1.gro bw_n2.gro > bw_new.gro
sed -i '2s/^/ /' bw_new.gro
mv bw_new.gro $out_file
mv $out_file $ouf/$out_file
#mv bw.gro $out_file
rm bw_n2.gro
rm bw_n1.gro

rm pep.gro
rm $new_w
rm ion.gro
rm w.gro
rm now.gro
rm wf.gro
rm wwf.gro

# 能量最小化和1us MD
gmx grompp -f $ouf/em.mdp -c $ouf/$out_file -p $ouf/box.top -o $ouf/em -pp $ouf/em -po $ouf/em
gmx mdrun -s $ouf/em.tpr -v -deffnm $ouf/em

gmx grompp -f $ouf/1us.mdp -c $ouf/em.gro -p $ouf/em.top -o $ouf/$t"us" -pp $ouf/$t"us" -po $ouf/$t"us"
gmx mdrun -s $ouf/$t"us.tpr" -v -deffnm $ouf/$t"us" -rdd 2.0
