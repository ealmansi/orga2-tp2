from scipy.stats import scoreatpercentile

class MeasurementParser:

	def __init__(self, filename, path):

		with open(path + filename) as f:
			content = f.readlines()
			
		self.filterType = content[3].split()[2]
		self.language = content[4].split()[2]
		self.description = content[0].split(':')[1]
		self.command = content[1]
		self.values = [int(line.rstrip(',\n')) for line in content if line.rstrip(',\n').isdigit()]
		self.removeOutliers()

	def removeOutliers(self):

		Q1 = scoreatpercentile(self.values, 25)
		Q3 = scoreatpercentile(self.values, 75)
		IQR = Q3 - Q1

		self.values = [x for x in self.values if ((Q1 - 1.5*IQR) <= x and x <= (Q3 + 1.5*IQR))]

if __name__ == "__main__":
	m = MeasurementParser("fcolor_asm_city_normal","../informe/filtro_color/mediciones/")
	resto = m.values
	m.removeOutliers()
	print([i for i in resto if i not in m.values])
	print(sum(m.values)/len(m.values))

