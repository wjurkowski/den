options(digits = 3, quote = F, scientific = F, stringsAsFactors = F)
library(igraph)
args <- commandArgs(trailingOnly = TRUE)
sink("OUTfile2", append=FALSE, split=FALSE)
#print (args[1])

#read data
#t = read.table(args[1], header = F, sep = "\t")
t = read.table(args[1], header = F, sep = "\t")
#t = read.table("333degs_entrez_currated-f.txt", header = F, sep = "\t")
kol=ncol(t)

for (i in 1:kol){
 pos = 0
 zer = 0
 x1 = 0
 y1 = 0
 x2 = 0
 y2 = 0

	v = as.matrix(t[,i])
 #print(v)
	for (k in 1:nrow(v)){
		value = v[k]
#print(v[1])
#print(i)
		if (value > 0){
			if (zer == 0){
				zer = 1
				x1 = k - 1
			}	
		}
		if (value > 0.5){
			if (pos == 0){
				pos = 1
				x2 <- k
				y2 <- v[k]
				chkp2 <- c(i, k, v[k]) 
 #print(chkp2)
			}
		}
	}		
 a = (y1 - y2) / (x1 - x2)
 b = y2 - (((y1 - y2)*x2)/(x1 - x2))
 chkp <- c(i, x1, y1, x2, y2, a, b)
 #print(chkp)
 x3 = (0.5-b)/a
 print (x3)
}

#rewire the network
#g = graph.edgelist(as.matrix(t[,1:2]))
#g2 <- rewire(g, niter=args[1])
#g3 <- rewire.edges(g,0.8)
#print(g)
#E(g2)

sink()
#sink.2()

#get plot
#plot.igraph(g2, layout = lfg)


