library(SpTe2M)

N1 <- 17524
N2 <- 17524
load("week_40_2016.RData")
y <- Mon$rate 
st <- Mon[,c('Lat', 'Long', 'time')]
type <- rep(c('IC1','IC2','Mnt'), c(N1, N2, N1))
st <- as.matrix(st)
EWSL <- sptemnt_ewsl(y, st, type, ht = .098, hs = 13.2, gt = 0.098, gs = 13.2, ARL0=50)