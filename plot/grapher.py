# -*- coding: utf-8 -*-

import numpy as np;
import matplotlib.pyplot as plt;
plt.rcdefaults(); plt.rcParams.update({'font.size': 18})
from parser import *;


def main():

	graficosFiltroColor('../informe/filtro_color/mediciones/')
	# graficosFiltroMiniature('../informe/filtro_miniature/mediciones/')

def graficosFiltroColor(measumentsPath):

	fcolor_grapher = Grapher("../solucion/src/","../informe/filtro_color/graficos/")

	fcolor_c_city_normal = 					MeasurementParser('fcolor_c_city_normal', measumentsPath)
	fcolor_c_city_normalsinifsincuerpo = 	MeasurementParser('fcolor_c_city_normalsinifsincuerpo', measumentsPath)
	fcolor_c_city_normalsinifconcuerpo = 	MeasurementParser('fcolor_c_city_normalsinifconcuerpo', measumentsPath)
	fcolor_c_city_O1 = 						MeasurementParser('fcolor_c_city_O1', measumentsPath)
	fcolor_c_city_O2 = 						MeasurementParser('fcolor_c_city_O2', measumentsPath)
	fcolor_c_city_O3 = 						MeasurementParser('fcolor_c_city_O3', measumentsPath)
	fcolor_asm_city_normal = 				MeasurementParser('fcolor_asm_city_normal', measumentsPath)
	fcolor_asm_city_loopunrollingx2 = 		MeasurementParser('fcolor_asm_city_loopunrollingx2', measumentsPath)
	fcolor_asm_city_loopunrollingx4 = 		MeasurementParser('fcolor_asm_city_loopunrollingx4', measumentsPath)

	fcolor_grapher.addMeasurement(fcolor_c_city_normal)
	fcolor_grapher.addMeasurement(fcolor_c_city_O1)
	fcolor_grapher.addMeasurement(fcolor_c_city_O2)
	fcolor_grapher.addMeasurement(fcolor_c_city_O3)
	fcolor_grapher.plotLOCs("de_prueba")
	fcolor_grapher.flush()


	# fcolor_grapher.addMeasurement(fcolor_c_city_normal)
	# fcolor_grapher.addMeasurement(fcolor_asm_city_normal)
	# fcolor_grapher.plotPerformance("C_ASM_perf")
	# fcolor_grapher.plotLOCs("C_ASM_loc")
	# fcolor_grapher.flush()

	# fcolor_grapher.addMeasurement(fcolor_c_city_normal)
	# fcolor_grapher.addMeasurement(fcolor_c_city_O1)
	# fcolor_grapher.addMeasurement(fcolor_c_city_O2)
	# fcolor_grapher.addMeasurement(fcolor_c_city_O3)
	# fcolor_grapher.plotPerformance("C_normal_O1_O2_O3")
	# fcolor_grapher.flush()

	# fcolor_grapher.addMeasurement(fcolor_c_city_normal)
	# fcolor_grapher.addMeasurement(fcolor_c_city_normalsinifsincuerpo)
	# fcolor_grapher.addMeasurement(fcolor_c_city_normalsinifconcuerpo)
	# fcolor_grapher.plotPerformance("C_sinifsincuerpo_sinifconcuerpo")
	# fcolor_grapher.flush()
	
	# fcolor_grapher.addMeasurement(fcolor_asm_city_normal)
	# fcolor_grapher.addMeasurement(fcolor_asm_city_loopunrollingx2)
	# fcolor_grapher.addMeasurement(fcolor_asm_city_loopunrollingx4)
	# fcolor_grapher.plotPerformance("ASM_loopunrollingx2_loopunrollingx4")
	# fcolor_grapher.flush()

def graficosFiltroMiniature(measumentsPath):

	miniature_grapher = Grapher("../solucion/src/","../informe/filtro_miniature/graficos/")

	miniature_c_city_normal = 				MeasurementParser('miniature_c_city_normal', measumentsPath)
	miniature_c_city_sinlecturaescritura = 	MeasurementParser('miniature_c_city_sinlecturaescritura', measumentsPath)
	miniature_asm_city_normal = 			MeasurementParser('miniature_asm_city_normal', measumentsPath)
	miniature_asm_city_sinmovdqu = 			MeasurementParser('miniature_asm_city_sinmovdqu', measumentsPath)
	miniature_asm_city_sinprocesardatos = 	MeasurementParser('miniature_asm_city_sinprocesardatos', measumentsPath)

	miniature_grapher.addMeasurement(miniature_c_city_normal)
	miniature_grapher.addMeasurement(miniature_asm_city_normal)
	miniature_grapher.plotPerformance("C_ASM_perf")
	miniature_grapher.plotLOCs("C_ASM_loc")
	miniature_grapher.flush()

	miniature_grapher.addMeasurement(miniature_c_city_normal)
	miniature_grapher.addMeasurement(miniature_c_city_sinlecturaescritura)
	miniature_grapher.plotPieChart("C_normal_sinlecturaescritura")
	miniature_grapher.flush()

	miniature_grapher.addMeasurement(miniature_asm_city_normal)
	miniature_grapher.addMeasurement(miniature_asm_city_sinmovdqu)
	miniature_grapher.addMeasurement(miniature_asm_city_sinprocesardatos)
	miniature_grapher.plotPieChart("ASM_normal_sinmovdqu_sinprocesardatos")
	miniature_grapher.flush()

class Grapher:

	def __init__(self, sourcePath, figureOutputPath):
		self.measuments = []
		self.sourcePath = sourcePath
		self.figureOutputPath = figureOutputPath
		self.initLOCs()

	
	def initLOCs(self):

		self.locs = {}
		with open('%scolor_filter_asm.asm' % self.sourcePath) as f:
			self.locs['fcolor_asm'] = len(f.readlines())

		with open('%scolor_filter_c.c' % self.sourcePath) as f:
			self.locs['fcolor_c'] = len(f.readlines())

		with open('%sminiature_asm.asm' % self.sourcePath) as f:
			self.locs['miniature_asm'] = len(f.readlines())

		with open('%sminiature_c.c' % self.sourcePath) as f:
			self.locs['miniature_c'] = len(f.readlines())

	
	def addMeasurement(self, measument):

		self.measuments.append(measument)

	
	def flush(self):

		self.measuments = []

	
	def getLOC(self, filterType, language):

		key = filterType.lower() + "_" + language.lower()

		return self.locs.get(key)

	
	def plotPerformance(self, filename):

		self.measuments.sort(key=lambda x: np.mean(x.values))

		labels = tuple([m.language.upper() + ": " + m.description for m in self.measuments])
		means = tuple([int(np.mean(m.values)/1000000.0) for m in self.measuments])

		plt.figure(figsize=(6*3.13,4*3.13))
		plt.title(unicode('Tiempo de ejecución segun implementación', 'utf-8'))
		plt.xlabel('segs')
		plt_ypos = np.arange(len(labels))
		plt.yticks(plt_ypos, labels)
		plt.barh(plt_ypos, means, align='center', alpha=0.4, color="g")

		self.writeFigToFile(filename)

	
	def plotLOCs(self, filename):

		self.measuments.sort(key=lambda x: self.getLOC(x.filterType, x.language))

		labels = tuple([m.language.upper() + ": " + m.description for m in self.measuments])
		locs = tuple([self.getLOC(m.filterType, m.language) for m in self.measuments])

		plt.figure(figsize=(6*3.13,4*3.13))
		plt.title(unicode('Cantidad de líneas de código según implementación', 'utf-8'))
		plt.xlabel('')
		plt_ypos = np.arange(len(labels))
		plt.yticks(plt_ypos, labels)
		plt.barh(plt_ypos, locs, align='center', alpha=0.4, color="r")

		self.writeFigToFile(filename)

	
	def plotPieChart(self, filename):

		self.measuments.sort(key=lambda x: np.mean(x.values))

		labels = tuple([m.language.upper() + ": " + m.description for m in self.measuments])
		sizes = tuple([int(np.mean(m.values)/1000000.0) for m in self.measuments])
		colors = [self.getColor(i) for i in range(len(self.measuments))]
		explode = tuple([0] * (len(self.measuments) - 1) + [0.1])

		plt.figure(figsize=(6*3.13,4*3.13))
		plt.pie(sizes, explode=explode, labels=labels, colors=colors, autopct='',
			shadow=True, startangle=70)
		plt.axis('equal')
		
		self.writeFigToFile(filename)

	
	def writeFigToFile(self, filename):

		mng = plt.get_current_fig_manager()
		mng.resize(*mng.window.maxsize())
		plt.savefig(self.figureOutputPath + filename + ".png")

	
	def getColor(self, index):

		colors = ['yellowgreen', 'gold', 'lightskyblue', 'lightcoral']
		index = index % len(colors)

		return colors[index]

if __name__=="__main__":
	main()