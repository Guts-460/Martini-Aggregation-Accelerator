#!/bin/bash
source /opt/modules-4.7.1/init/${SHELL##*/}
module load GROMACS/2022.5
module load Python/2.7.18 

t=14

inf=./12            # 最后一段压缩轨迹的时间，us
ouf=./equi2us   # 最后平衡2us

filename="12us.gro"
cp $inf/$inf"us".top $ouf
cp $inf/$filename $ouf

cp ./common/Protein* $ouf
cp ./common/2us.mdp $ouf
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

linecount=$(wc -l < $input_file)
echo "Number of W:"
echo $linecount



#ndel=$(($linecount/4))

#echo "$ndel W were deleted"

new_w="new_w.gro"

shuf w.gro | head -n $(($(wc -l < w.gro) * 4 / 5 + 1)) > $new_w

linecountnew=$(wc -l < $new_w)

echo "Number of W after deleting:"
echo $linecountnew

echo "Number of W deleted"
echo $(($linecount-$linecountnew))

# 生成一个随机数，用作种子来生成随机行号
#random_seed=$(date +%s)

# 删除指定数量的随机行
#sed -i -e "$(for i in $(seq 1 $ndel); do echo "$((RANDOM%$ndel+1))d"; done)" $input_file

cat pep.gro $new_w ion.gro > $out_file  

# 修改top的W数
sed -i "s/W  $linecount/W  $linecountnew/" $ouf/$inf"us".top
grep -v WF $ouf/$inf"us".top > $ouf"us".top

mv $ouf"us".top $ouf/$ouf"us".top

##获得总原子数,100是WF的个数
atom_old=$(awk 'NR==2' $ouf/$filename)
atom_new=$(($atom_old - $(($linecount-$linecountnew)) -100))
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

gmx grompp -f ./common/em.mdp -c $ouf/$out_file -p $ouf/$ouf"us".top -o $ouf/em -pp $ouf/em -po $ouf/em
gmx mdrun -s $ouf/em.tpr -v -deffnm $ouf/em

gmx grompp -f ./common/2us.mdp -c $ouf/em.gro -p $ouf/em.top -o $ouf/$t"us" -pp $ouf/$t"us" -po $ouf/$t"us" 
gmx mdrun -s $ouf/$t"us.tpr" -v -deffnm $ouf/$t"us" -rdd 2.0
