import numpy as np
import matplotlib.pyplot as plt

#http://matplotlib.org/examples/pie_and_polar_charts/pie_demo_features.html
#constantes
bar_width = 0.4


def autolabel(rects, ax):
	# attach some text labels
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
		self.times = []
		self.lines = []
		self.fractions = []
		self.width = bar_width

	def agregarFiltro(self,nombreFiltro, detallesImplementacion, rutaTiempo, rutaCodigo):
		self.filtros.append(nombreFiltro+" "+ detallesImplementacion)
		f = open(rutaTiempo, "r")
		for i in range(4): f.readline()
		list = eval(f.readline().replace("]\b",""))
		time = 0
		for i in list:
			time = time + (i["despues"]-i["antes"])
			print(time) #sacar esto después
			if len(i)>2:
				size = len(i)
				size = size/3
				fractions = []
				for i in range(1,size+1):
					fractions[i["break_{0}_name".format(i)]]=i["break_{0}_after".format(i)]-i["break_{0}_before".format(i)]



		self.times.append(time)

		f = open(rutaCodigo, "r")
		lines = 0
		for i in f:
			lines+=1
		self.lines.append(lines)

	def plotBars(self, rutaSalida):
		fig = plt.figure()
		ax = fig.add_subplot(111)
		indexs = np.arange(len(self.filtros))
		barsTimes = ax.bar(indexs, self.times, self.width, color="g", label = "Tiempo de ejecución")
		plt.ylim(0,max(self.times)*1.2)
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
		pass
		



if __name__=="__main__":
	
	plotter = Plotter()
	plotter.agregarFiltro("Decode", "c básico", "../src/decode_c.c.salida", "../src/decode_c.c")
	plotter.agregarFiltro("Decode", "asm básico", "../src/decode_asm.asm.salida", "../src/decode_asm.asm")
	plotter.plotBars("ejemplo.png")
