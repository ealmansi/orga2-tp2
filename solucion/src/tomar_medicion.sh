# ./tomar_medicion directorio_output/ 'comentario sobre que mido' ./tp2 decode -i c ../data/base/encoded.bmp
# directorio_output/ con barra al final!

fname=$(basename $7)
fname="${fname%.*}"

for i in `seq 1 5`
do
	echo "Descripcion: ${2}" >> $1$4_$6_"$fname"_"${2// /}"
	echo ${@:3} >> $1$4_$6_"$fname"_"${2// /}"
	${@:3} >> $1$4_$6_"$fname"_"${2// /}"
done