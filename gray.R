# First approach to construct Gray model for HSV prediction from the article Shih-Wen Hsiao et. al.
# They did not use Fuzzy C-Means at all. No, they didn't. They think of Pantone 10 colors as clusters, and just propose FCM to aggregate
# real-world data (from images,etc.) into similar n-color sequences

########################################## Reading the data ############

# sources: pantone.com, http://color2u.cocolog-nifty.com/color4u/2012/02/pantone-tpx-col.html

set.seed(299)

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


########################################## The clusternig should be done separately for every 5 values. 
##If we are building long vertical sequences, the results become complete(?) garbage - at least doesn't correspond to theirs

x1<-x
res<-c() # the dataframe of our predictions
clustdat<-c() # the dataframe of the corresponding true rearranged colors 
              # (they are very different for different clustering, actually it's just order statistic in some sense)

for (gen_loop in 1:24) # Main loop
{
  x<-x1[gen_loop : (4+gen_loop)]
  
x<-x1[23:27] # the example considered
########################################## Organizing vertical sequences ############

# Imagine we have 2-D table. Horizontal axis is 10 pantone colors for each season.
# Vertical axis is 28 seasons.

# Let's leave the first row intact, but start to rearrange the rows below according to
# the minimal euclidean distance (authors call it MSE) from the colors above, to obtain vertical sequences.
# One important diference: they operate in HSV, so the task is to find the nearest angle 0-360

# (obsolete)
# Compute nearest angle, 
# source: http://gamedev.stackexchange.com/questions/4467/comparing-angles-and-working-out-the-difference
angle_btw_2 <- function(a1,a2) {180 - abs(abs(a1 - a2) - 180)}

# function to convert RGB vectors to HSV
# Hue is given as [0;1]*360
library(grDevices)
rgb_to_hue_vector<-function(y) rgb2hsv(y[1],y[2],y[3])

# converting dataset to HSV
x_hsv<-lapply(1:length(x),function(i) data.frame(apply(x[[i]],2,rgb_to_hue_vector),row.names=c("h","s","v")))


# (obsolete)
# the function that returns the index from the vector "palette" of the element which is the closest to the certain element from y
# the problem is that the color can be used twice
mindist<-function(y,palette) which.min(apply(palette, 2, function(z) ifelse(is.na(z[1]),NA, (z[1]-y[1])^2)))

# (obsolete)
# The function returns the index of the element from the vector "palette" which is closest (min. angle) to the certain element y
minangle<-function(y,palette) which.min(apply(data.frame(palette)*360, 2, function(z) ifelse(is.na(z[1]),NA, angle_btw_2(y*360,z))))

# the function computes distances for all pairs (x,y) from two vectors and finds indices for minimal one
mindistvect<-function(x1,y1){
  dists<-matrix(NA, nrow = 10, ncol = 10)
  for (k in 1:10)
  {
    # there is no symmetry here
    for (l in 1:10) {dists[k,l]<- ifelse((is.na(x1[1,k]) || is.na(y1[1,l])),NA, (x1[1,k]-y1[1,l])^2)}
  }
  which(dists==min(dists,na.rm = TRUE),arr.ind = TRUE)
}

seq_data<-data.frame(1,2,3,4,5,6,7,8,9,10)
x_hue_ordered<-data.frame(x_hsv[[1]][1,])

# The following subroutine places the closest element from the lower row under the corresponding element from higher row
# constructing vertical sequences.
# The order is saved
# Already used values are replaced with NAs to avoid repeating
# Unfortunately, 'apply' methods wouldn't work there, as they are copied into the memory and executed simultaneously

for (i in 2:length(x_hsv))
{
  # we will replace elements with NAs here
  tmp<-x_hsv[[i]]
  # previous row, ordered on the previous step
  ordered<-data.frame(x_hsv[[i-1]][,as.numeric(seq_data[i-1,])])
  
  # ordering of the lower row
  ordered2<-c(1,2,3,4,5,6,7,8,9,10)
  
  for (j in 1:10)
  {
    #closest<-mindist(ordered[,j], tmp)
    #closest<-minangle(ordered[,j], tmp)
    
    closest<-mindistvect(ordered,tmp) # find a current closest pair
    tmp[1,closest[2]]<-NA # on each turn we kick out the values
    ordered[1,closest[1]]<-NA
    ordered2[as.numeric(closest[1])]<-as.numeric(closest[2]) # ordering the lower row according to the higher
  }
  
  # saving the order
  seq_data<-rbind(seq_data,as.numeric(ordered2))
  
  # crating Hue-ordered table
  x_hue_ordered<-rbind(x_hue_ordered, as.numeric(x_hsv[[i]][1,as.numeric(ordered2)]))

}

# vertical sequences data
seq_data

# Preparing Hue prediction table
x_hue_ordered


########################################## Performing GM(1,1) prediction for hue ############

# GM(1,1) model
# http://www.programgo.com/article/149368757/

gm11<-function(x,k)  
{  
  n<-length(x)  
  x1<-numeric(n);  
  for(i in 1:n)   
  {  
    x1[i]<-sum(x[1:i]);  
  }  
  b<-numeric(n)  
  m<-n-1  
  for(j in 1:m)  
  {  
    b[j+1]<-(0.5*x1[j+1]+0.5*x1[j])  
  }  
  Yn=t(t(x[2:n]))                   
  B<-matrix(1,nrow=n-1,ncol=2)        
  B[,1]<-t(t(-b[2:n]))             
  A<-solve(t(B)%*%B)%*%t(B)%*%Yn;   
  a<-A[1];  
  u<-A[2];  
  x2<-numeric(k);  
  x2[1]<-x[1];  
  for(i in 1:k-1)  
  {  
    x2[1+i]=(x[1]-u/a)*exp(-a*i)+u/a;  
  }  
  x2=c(0,x2);  
  y=diff(x2);                   
  y  
}  


## Paint balls (obsolete)
# plot(1, type="n", xlab="", ylab="", xlim=c(0, 25), ylim=c(0, 1))
# for (j in 1:length(x)){
#   x_order<-x[[j]][,as.numeric(seq_data[j,])]
#   for (i in 1:10){
#     points(i*2,0.8-(j)*0.1,pch=19,col=rgb(x_order[1,i]/255,x_order[2,i]/255,x_order[3,i]/255), cex=5)
#   }
# }


# real data for 5th observation
real<-round(x_hsv[[5]][1,as.numeric(seq_data[5,])]*360)
# obtaining predictions from 4 previous observations
pred<-round(sapply(1:10, function(i) gm11(as.numeric(x_hue_ordered[1:4,i]),5)[5]*360) %% 360)

# storing results
clustdat<-rbind(clustdat,real)
res<-rbind(res,pred)

} ## Main loop


# plotting results for 10th statistic
plot(clustdat[,10],ylab="value",xlab="Years 2003-2016",main="x[n]~x[n-1]+x[n-2]+x[n-3]+x[n-4]")
lines(clustdat[,10])
lines(res[,10],col="green")





