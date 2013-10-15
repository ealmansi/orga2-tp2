import sys
sys.path.insert(0,"../")
import plotter

aPlotter = plotter.Plotter()
aPlotter.setFilter("fcolor", "../../color_filter_asm.asm", "../../color_filter_c.c")
aPlotter.plotBarsT("zarasa.png")
