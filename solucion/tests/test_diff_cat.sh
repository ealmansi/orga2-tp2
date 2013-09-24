#!/bin/sh

DIFF=../bin/tp2diff
DIFFFLAGS=""
TESTINDIR=../data/test-in
VIDEODIR=../data/base
TESTIMGCATEDRA=../../imagenes-ejemplo
BINFILE=../bin/tp2
TMPFOLDER=/tmp/orga2/output
FILE=encoded.bmp

OKDIFF=1

echo 'Iniciando test de diferencias contra la catedra...'

#file=$TESTINDIR/"lena.512x512.bmp"
runTest() {
    local archivo=$1

    while read FILTRO VIDEO PARAMS
    do
        rm $TMPFOLDER/asm/*.bmp
        echo "$BINFILE $FILTRO -i asm --frames $TMPFOLDER/asm $VIDEODIR/$VIDEO $PARAMS"
        $BINFILE $FILTRO -i asm --frames $TMPFOLDER/asm $VIDEODIR/$VIDEO $PARAMS
        echo "Buscando diferencias entre frames"
        for frame in $TMPFOLDER/extracted/*.bmp
        do
            echo "Procesando.. $frame"
            FILENAME=$(basename $frame)
            CATFILE=$TMPFOLDER/extracted/$FILENAME
            ASMFILE=$TMPFOLDER/asm/$FILENAME
            $DIFF $DIFFFLAGS $CATFILE $ASMFILE 16
           if [ $? != "0" ]; then
                echo "ERROR EN $FILENAME"
                exit
                OKDIFF=0
            fi
        done
    done < $archivo
}

#echo '\nProcesando archivo: ' $file '\n'
mkdir -p $TMPFOLDER/asm
mkdir -p $TMPFOLDER/extracted
for tgz in $TESTINDIR/*.tar.gz
do
    echo "Procesando archivo: " $tgz
    cp $tgz $TMPFOLDER/extracted/test.tar.gz
    echo "Extrayendo archivos...."
    tar -xzf $TMPFOLDER/extracted/test.tar.gz -C $TMPFOLDER/extracted/
    runTest $TMPFOLDER/extracted/command
    rm $TMPFOLDER/extracted/*
done

echo "Test de filtros finalizados correctamente"

# echo "Test de decode"
# $BINFILE decode -i c $VIDEODIR/$FILE
# $BINFILE decode -i asm $VIDEODIR/$FILE
# echo 1018945f9c16fa236d21f76a0f8bedd9\ \ $VIDEODIR/$FILE.mensaje.c.txt > check
# echo 1018945f9c16fa236d21f76a0f8bedd9\ \ $VIDEODIR/$FILE.mensaje.asm.txt >> check
# md5sum -c check
# rm check