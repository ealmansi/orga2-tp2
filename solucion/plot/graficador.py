import numpy as np
import matplotlib.pyplot as plt

#http://matplotlib.org/examples/pie_and_polar_charts/pie_demo_features.html
#constantes
bar_width = 0.4


def autolabel(rects, ax):
	for rect in rects:
		height = rect.get_height()
		ax.text(rect.get_x()+rect.get_width()/2., 1.02*height, '%d'%int(height),ha='center', va='bottom')




class Plotter:
	"""
	self.filtros : Nombres completos de los filtros, se usan como xticks
	self.
	"""
	def __init__(self):
		self.filtros = []
		self.lines = []
		self.fractions = []
		self.width = bar_width

	def agregarFiltro(self,nombreFiltro, detallesImplementacion, rutaTiempo, rutaCodigo):
		self.filtros.append(nombreFiltro+" "+ detallesImplementacion)
		f = open(rutaTiempo, "r")
		for i in range(4): f.readline()
		list = eval("["+f.readline().replace("]\b","")+"]")
		self.fractions.append({})

		for i in list[0].keys():
			self.fractions[-1][i.split("_")[0]]=0

		for i in list:
			for key in self.fractions[-1]:
				self.fractions[-1][key]+=(i[key+"_after"]-i[key+"_before"])

		f = open(rutaCodigo, "r")
		lines = 0
		for i in f:
			lines+=1
		self.lines.append(lines)



	def plotBars(self, rutaSalida):
		plt.clf()
		fig = plt.figure(figsize = (3.5*len(self.filtros),6))
		ax = fig.add_subplot(111)
		indexs = np.arange(len(self.filtros))
		times = [i["total"] for i in self.fractions]
		barsTimes = ax.bar(indexs, times, self.width, color="g", label = "Tiempo de ejecución")
		plt.ylim(0,max(times)*1.2)
		ax.set_ylabel( "Tiempo (ciclos de clock)")
		autolabel(barsTimes,ax)
		plt.legend(loc = 2)
		ax2=plt.twinx()
		barsLines = ax2.bar(indexs+self.width, self.lines, self.width, color = "r", label = "Líneas de código")
		plt.xlim(-0.2,len(self.filtros))
		plt.ylim(0,max(self.lines)*1.2)
		autolabel(barsLines, ax2)
		ax2.set_ylabel("Cantidad de líneas de código")
		plt.legend(loc = 1)
		plt.xticks(indexs+self.width, self.filtros)
		plt.savefig(rutaSalida)

	def plotPie(self, rutaSalida):
		plt.clf()
		fig = plt.figure(figsize = (5*len(self.fractions),5))
		pos = 0
		for dicc in self.fractions:
			plt.subplot(1,len(self.fractions),pos+1)
			labels = []
			sizes = []
			for i in self.fractions:
				keys = [t for t in i.keys()]
				total = i["total"]
				keys.remove("total")
				labels.append(keys)
				coso = []
				usado = 0
				for j in keys:
					coso.append(i[j])
					usado =+ i[j]
				keys.append("resto")
				coso.append(total-usado)
				sizes.append(coso)
			plt.pie(sizes[pos], labels = labels[pos], shadow= 'yes', startangle = 15,explode = [0.03 for i in range(len(sizes[pos]))] )
			pos += 1
		plt.savefig(rutaSalida)
		



if __name__=="__main__":
	
	plotter = Plotter()
	plotter.agregarFiltro("Decode", "c básico GCC", "../src/salidas/decode_c.c.salidaGCC", "../src/decode_c.c")
	plotter.agregarFiltro("Decode", "c GCC O3", "../src/salidas/decode_c.c.salidaGCCO3", "../src/decode_c.c")
	plotter.agregarFiltro("Decode", "c básico ICC", "../src/salidas/decode_c.c.salidaICC", "../src/decode_c.c")
	plotter.agregarFiltro("Decode", "c básico ICCO3", "../src/salidas/decode_c.c.salidaICCO3", "../src/decode_c.c")
	plotter.agregarFiltro("Decode", "asm básico", "../src/salidas/decode_asm.asm.salida", "../src/decode_asm.asm")
	print("Decode:",plotter.fractions)
	plotter.plotBars("decode.png")


	plotter2 = Plotter()
	plotter2.agregarFiltro("Color filter", "c básico", "../src/salidas/color_filter_c.c.salidaGCC", "../src/color_filter_c.c")
	plotter2.agregarFiltro("Color filter", "c compilado con ICC", "../src/salidas/color_filter_c.c.salidaICC", "../src/color_filter_c.c")
	plotter2.agregarFiltro("Color filter", "asm básico", "../src/salidas/color_filter_asm.asm.salida", "../src/color_filter_asm.asm")
	print("color filter:",plotter2.fractions)
	plotter2.plotBars("color filter.png")
