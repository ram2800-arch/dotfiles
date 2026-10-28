#cd /Volumes/Seagate\ Backup\ Plus\ Drive/pictures/2016-Nov-Spain/
alias getdirs='find . -maxdepth 1 -mindepth 1 -type d | cut -c 3-'
rep=""
slh="/"
fnd=""
#for dir in $(getdirs); 
#do 
  #echo $dir;
  a=0 
  #for file in $dir/*.jpeg
  for file in *.mov
  do
  let a=a+1 
  af=$(printf %03d $a)
  #fnd=${dir}${slh}
  fname=${file/$fnd/$rep}
  #echo  "$dir" - "$file"  - "$fname"
  cdate=$(stat -f "%Sm" -t "%Y-%m-%d-%H%M" "${file}")  
  #echo  $a - "$file"  -  "${cdate}-`echo ${fname} | cut -c12-40`"
  mv "$file" $cdate-$af.mov
done

#done
