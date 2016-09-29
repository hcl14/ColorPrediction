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

# 16 colour palette
vga16<-rbind(c(0,0,0),c(128, 128, 128),c(192, 192, 192),c(255, 255, 255),c(128, 0, 0),c(255, 0, 0),c(128, 128, 0),c(255, 255, 0),c(0, 128, 0),c(0, 255, 0),c(0, 128, 128),c(0, 255, 255),c(0, 0, 128),c(0, 0, 255),c(128, 0, 128),c(255, 0, 255))

# computing distances to 16 colors and returning the number of the closest color
# http://www.december.com/html/spec/color16codes.html
mindist16<-function(y) which.min(apply(vga16, 1, function(z) dist(rbind(z,y),method = "euclidean")))
# mindist16<-function(y) vga16[which.min(apply(vga16, 1, function(z) dist(rbind(z,y),method = "euclidean"))),]

# generating simplified dataset
data16<-t(data.frame(lapply(x,function(datasubset) apply(datasubset,2,mindist16))))

# table of cluster centers
# centers<-lapply(x, function(y) kmeans(t(y),3)$centers)
