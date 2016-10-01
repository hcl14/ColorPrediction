# K-Means Clusternig used over entire data (all years) to determine 10 colour clusters
# Then all colors that belong to clusters for each year are treated as cluster group
# Regression used to predict Hue pattern for color group
# For color group 1 evident pattern is found for seed 150
# Unfortunately, we need mess up with seed, as K-Means can be unseccessful

# sources: pantone.com, http://color2u.cocolog-nifty.com/color4u/2012/02/pantone-tpx-col.html

set.seed(2000)
#set.seed(3000)
#set.seed(2500)

data<-read.csv("/home/hcl/Downloads/Full_Pantone_TPX_RGB_Colours.csv",stringsAsFactors=FALSE,row.names = 1)

# function that converts "a b c" to numeric vector (a;b;c)
numvect<-function(x) as.numeric(unlist(strsplit(x,split=" ")))

# processing one column
rowtoarray<-function(y) data.frame(sapply(y,numvect))

# creating the array of numeric vectors
x<-as.array(apply(data, 1, rowtoarray))

# doing trivial coordinate-wise imputation to get rid of NAs
library(DMwR)
x[[1]]<-data.frame(round(t(knnImputation(t(x[[1]]),k=5))))
x[[2]]<-data.frame(round(t(knnImputation(t(x[[2]]),k=5))))


###################################################### K-Means Clustering

# Mixing all the dataset for all years into one

# rbind(sapply(x, data.frame) creates a matrix of numeric,3 vectors

x_all<-t(do.call(cbind,x))

# finding 10 cluster centers. They would be the palette
# x_centers<-round(kmeans(x_all,6)$centers)

library(pracma)

# k-means++ from https://stat.ethz.ch/pipermail/r-help/2012-January/300051.html
kmpp <- function(X, k) {
  n <- nrow(X)
  C <- numeric(k)
  C[1] <- sample(1:n, 1)
  
  for (i in 2:k) {
    dm <- distmat(X, X[C, ])
    pr <- apply(dm, 1, min); pr[C] <- 0
    C[i] <- sample(1:n, 1, prob = pr)
  }
  
  kmeans(X, X[C, ])
}

x_centers<-round(kmpp(x_all,6)$centers)

######################################################### rounding color data to cluster centers
# generating simplified dataset
mindist16<-function(y,palette) which.min(apply(palette, 1, function(z) dist(rbind(z,y),method = "euclidean")))
data16<-t(data.frame(lapply(x,function(datasubset) apply(datasubset,2,mindist16,x_centers))))
data16

library(grDevices)
rgb_to_hue_vector<-function(y) rgb2hsv(y[1],y[2],y[3])

####################################### Computing mean Hue for first color cluster 
# converting into HSV
meanhue_N2<-function(i){
  sp<-data.frame(t(apply(x[[i]],2,rgb_to_hue_vector)))
  # splitting into clusters (16 colors)
  split<-split(sp,data16[i,])
  # computing mean hue for each cluster
  meanhue<-data.frame(lapply(split, function(y) mean(y[,1])))
  if("X6" %in% colnames(meanhue))
  {
    meanhue$X6
  }
  else meanhue_N2(i-1) # omitting values
}

######################################################################
huedata_N2<-as.numeric(lapply(1:nrow(data16),meanhue_N2))

plot(huedata_N2,xlab="Years 2003-2016")
lines(huedata_N2)
######################################################################

# the last value was predicted

huedata_N2<-as.numeric(lapply(1:20,meanhue_N2))
library(zoo)
split2<-data.frame(rollapply(huedata_N2, 5, by = 1, c))
fit2<-glm(X5~X1+X2+X3+X4, data=split2)

huedata_N2<-as.numeric(lapply(1:28,meanhue_N2))
split2<-data.frame(rollapply(huedata_N2, 5, by = 1, c))

plot(split2$X5,ylab="value",xlab="Years 2003-2016",main="x[n]~x[n-1]+x[n-2]+x[n-3]+x[n-4]")
lines(split2$X5)
lines(predict(fit2,split2[,1:4]),col="green")
legend(x="bottomleft", c("Actual data","Prediction"),
       lty=c(1,1), col=c("black","green"),cex = 0.75)