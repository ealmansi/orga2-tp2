from sys import argv
import os
import subprocess


def obtenerResultados(nombreFiltro, implementación, parametros, nota, veces):
	results = []

	for i in range(veces):
		print(i)
		out = subprocess.check_output(["../tp2", "-i", implementación, nombreFiltro]+parametros)
		out = str(out,"utf8").split("\n")
		tiempo = sum(eval(out[4])) # Los resultados vienene en la 4ta línea;
		results.append(tiempo)

	results.sort()
	limInf = int(len(results)/4)
	limSup = limInf*3
	results = results[limInf:limSup]
	finalResult = sum(results)/len(results)

	with open("../resultados/{}_{}_{}.out".format(nombreFiltro,implementación,nota),"w") as aFile:
		aFile.write("{}\n".format(finalResult))

def setDeMediciones(nombreFiltro, parametros, veces):
	for flag in ["gcc","gccOfast","icc", "iccOfast"]:
		os.system("cp ../Makefile.{} ../Makefile && make -C ../".format(flag))
		obtenerResultados(nombreFiltro,"c", parametros, flag, veces)
	
	os.system("cp ../Makefile.gcc ../Makefile")

	obtenerResultados(nombreFiltro, "asm", parametros, "final", veces)


if __name__ == '__main__':
	setDeMediciones("decode", ["../encoded.bmp"],100)
	setDeMediciones("fcolor", ["../ink.avi", "200", "200","200","100"], 100)
	setDeMediciones("miniature", ["../ink.avi","0.3","0.7", "20"], 20)
