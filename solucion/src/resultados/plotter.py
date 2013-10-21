import numpy as np
import matplotlib.pyplot as plt

from subprocess import check_output

def autolabel(rects, ax):
	for rect in rects:
		height = rect.get_height()
		ax.text(rect.get_x()+rect.get_width()/2., 1.02*height, '%d'%int(height),ha='center', va='bottom')
   



class Plotter:
	bar_width = 0.8

	def __init__(self):
		self.filt = ""
		self.times = []
		self.codeLines = []

	def setFilter(self, filterName, sourcePathAsm, sourcePathC):
		self.filt = filterName

		resultados = str(check_output("ls"),"utf8")
		resultados = [i for i in resultados.split("\n") if filterName in i]
		for res in resultados:
			name = " ".join(res[:-4].split("_"))
			with open(res,"r",encoding = "utf8") as aFile:
				self.times.append( (name, eval(aFile.read())) )

		with open(sourcePathAsm,"r",encoding="utf8") as sourceFile:
			lines = 0
			for i in sourceFile:
				lines+=1
			self.codeLines.append( ("Ensamblador", lines) )

		with open(sourcePathC,"r",encoding="utf8") as sourceFile:
			lines = 0
			for i in sourceFile:
				lines+=1
			self.codeLines.append( ("C", lines) )


	def plotBarsTC(self, imgPath):
		plt.clf()
		fig = plt.figure(figsize = (15,8))

		ax = plt.subplot2grid( (3,1), (0,0), rowspan=2  )
		plt.suptitle(self.filt.capitalize())
		indexs = np.arange(len(self.times))
		times = [y for (x,y) in self.times]
		labels = [x for (x,y) in self.times]
		bars = plt.bar(indexs,times, self.bar_width,label="Tiempo en ciclos de clock")
		plt.xticks(indexs+self.bar_width/2, labels)
		plt.ylim(0,max(times)*1.2)
		autolabel(bars, ax)
		plt.ylabel("ciclos de cloc")
		plt.legend(loc=1)

		ax = plt.subplot(3,1,3)
		indexs = np.arange(len(self.codeLines))
		labels = [x for (x,y) in self.codeLines]
		lines = [y for (x,y) in self.codeLines]
		bars = plt.barh(indexs, lines, self.bar_width, color = "y", label = "Líneas de código")
		plt.yticks(indexs+self.bar_width/2,labels)
		plt.legend(loc=1)
		plt.xlabel("Línas de código")


		plt.savefig(imgPath)


	def plotBarsT(self,imgPath):
		plt.clf()
		fig = plt.figure(figsize = (15,8))
		
		ax = plt.subplot(1,1,1)
		indexs = np.arange(len(self.times))
		times = [y for (x,y) in self.times]
		labels = [x for (x,y) in self.times]
		bars = plt.bar(indexs,times, self.bar_width,label="Tiempo en ciclos de clock")
		plt.xticks(indexs+self.bar_width/2, labels)
		plt.ylim(0,max(times)*1.2)
		autolabel(bars, ax)
		plt.ylabel("ciclos de cloc")
		plt.legend(loc=1)

		plt.savefig(imgPath)

	
	def shuf(self):
		self.filt = ""
		self.times = []
		self.codeLines = []
		



if __name__ == '__main__':
	aPlotter = Plotter()
	aPlotter.setFilter("decode","../decode_asm.asm", "../decode_c.c")
	aPlotter.plotBarsTC("graficos/decode.png")
	aPlotter.shuf()
	aPlotter.setFilter("fcolor","../color_filter_asm.asm", "../color_filter_c.c")
	aPlotter.plotBarsTC("graficos/fcolor.png")
	aPlotter.shuf()
	aPlotter.setFilter("miniature","../miniature_asm.asm", "../miniature_c.c")
	aPlotter.plotBarsTC("graficos/miniature.png")
	aPlotter.shuf()
	aPlotter.setFilter("decodeOP","../decode_asm.asm", "../decode_c.c")
	aPlotter.plotBarsT("graficos/decodeOP.png")
