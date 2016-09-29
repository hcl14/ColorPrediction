data<-read.csv("/home/hcl/Downloads/spring-Pantone_TPX_RGB_Colours.csv",stringsAsFactors=FALSE,row.names = 1)

# function that converts "a b c" to numeric vector (a;b;c)
numvect<-function(x) as.numeric(unlist(strsplit(x,split=" ")))

# processing one column
rowtoarray<-function(y) data.frame(sapply(y,numvect))

# creating the array of numeric vectors
x<-as.array(apply(data, 1, rowtoarray))

# doing trivial coordinate-wise imputation to get rid of NAs
library(DMwR)
x[[1]]<-data.frame(round(t(knnImputation(t(x[[1]]),k=5))))

# Now we have x as list (by year) of dataframes, each contains 10 3-dimensional vectors of RGB colours

# 16 colour palette (Yellow changed to Pantone Yellow)
vga16<-rbind(c(0,0,0),c(128, 128, 128),c(192, 192, 192),c(255, 255, 255),c(128, 0, 0),c(255, 0, 0),c(128, 128, 0),c(255, 220, 1),c(0, 128, 0),c(0, 255, 0),c(0, 128, 128),c(0, 255, 255),c(0, 0, 128),c(0, 0, 255),c(128, 0, 128),c(255, 0, 255))
# 3 colour palette
rgb<-rbind(c(255,0,0),c(0,255,0),c(0,0,255))



# computing distances to 16 colors and returning the number of the closest color
# http://www.december.com/html/spec/color16codes.html
mindist16<-function(y,palette) which.min(apply(palette, 1, function(z) dist(rbind(z,y),method = "euclidean")))
# mindist16<-function(y) vga16[which.min(apply(vga16, 1, function(z) dist(rbind(z,y),method = "euclidean"))),]

# generating simplified dataset
data16<-t(data.frame(lapply(x,function(datasubset) apply(datasubset,2,mindist16,vga16))))
data16

library(grDevices)
rgb_to_hue_vector<-function(y) rgb2hsv(y[1],y[2],y[3])

####################################### Computing mean Hue for second color cluster (128, 128, 128)
# converting into HSV
meanhue_N2<-function(i){
sp<-data.frame(t(apply(x[[i]],2,rgb_to_hue_vector)))
# splitting into clusters (16 colors)
split<-split(sp,data16[i,])
# computing mean hue for each cluster
meanhue<-data.frame(lapply(split, function(y) mean(y[,1])))
meanhue$X8
}

#Yellow (8) appears from 2007, which corresponds to the article
huedata_N2<-as.numeric(lapply(5:14,meanhue_N2))

plot(huedata_N2)
lines(huedata_N2)

# attempting to forecast

# splitting into overlapping windows

library(zoo)
split2<-data.frame(rollapply(huedata_N2, 3, by = 1, c))

set.seed(50)
# library(neuralnet)
# fit<-neuralnet(X3~X1+X2, split2, hidden=21,
#                    err.fct="sse", linear.output=FALSE, likelihood=TRUE)
# pred=compute(fit, split2[,1:2])$net.result

plot(split2$X3,ylab="value",xlab="Years 2009-2016",main="Pantone Yellow")
lines(split2$X3)
# lines(pred,col="red")

fit2<-glm(X3~X1+X2, data=split2)
lines(predict(fit2,split2[,1:2]),col="green")
legend(x="bottomleft", c("Actual data","Prediction"),
       lty=c(1,1), col=c("black","green"))