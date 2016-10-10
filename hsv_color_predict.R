
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

 x1<-x  
 x<-x1[23:27] # the example considered
 
 # Compute nearest angle, 
 # source: http://gamedev.stackexchange.com/questions/4467/comparing-angles-and-working-out-the-difference
 angle_btw_2 <- function(a1,a2) {180 - abs(abs(a1 - a2) - 180)}
 
 # function to convert RGB vectors to HSV
 # Hue is given as [0;1]*360
 library(grDevices)
 rgb_to_hue_vector<-function(y) rgb2hsv(y[1],y[2],y[3])
 
 # converting dataset to HSV
 x_hsv<-lapply(1:length(x),function(i) data.frame(apply(x[[i]],2,rgb_to_hue_vector),row.names=c("h","s","v")))
 
 
 
 
 
 
 
 ########################################## Clustering: Hue ########
 
 # (obsolete)
 # the function that returns the index from the vector "palette" of the element which is the closest to the certain element from y
 # the problem is that the color can be used twice
 mindist<-function(y,palette) which.min(apply(palette, 2, function(z) ifelse(is.na(z[1]),NA, (z[1]-y[1])^2)))
 
 # (obsolete)
 # The function returns the index of the element from the vector "palette" which is closest (min. angle) to the certain element y
 # minangle<-function(y,palette) which.min(apply(data.frame(palette)*360, 2, function(z) ifelse(is.na(z[1]),NA, angle_btw_2(y*360,z))))
 
 # the function computes distances for all pairs (x,y) from two vectors and finds indices for minimal one
 mindistvect<-function(x1,y1){
   dists<-matrix(NA, nrow = 10, ncol = 10)
   for (k in 1:10)
   {
     # there is no symmetry here
     # The first is their approach with squared difference
     # for (l in 1:10) {dists[k,l]<- ifelse((is.na(x1[1,k]) || is.na(y1[1,l])),NA, (x1[1,k]-y1[1,l])^2)}
     # My approach computes the angle
     for (l in 1:10) {dists[k,l]<- ifelse((is.na(x1[1,k]) || is.na(y1[1,l])),NA, (angle_btw_2(y1[1,l]*360,x1[1,k]*360)^2)/(360^2))}
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
     
     closest<-mindistvect(ordered,tmp)[1,] # find a current closest pair
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
 
 
 
 
 
 
 ########################################## Clustering: Saturation ########
 
 mindistvect_sat<-function(x1,y1){
   dists<-matrix(NA, nrow = 10, ncol = 10)
   for (k in 1:10)
   {
     # there is no symmetry here
     # The first is their approach with squared difference
     # for (l in 1:10) {dists[k,l]<- ifelse((is.na(x1[1,k]) || is.na(y1[1,l])),NA, (x1[1,k]-y1[1,l])^2)}
     # My approach computes the angle
     for (l in 1:10) {dists[k,l]<- ifelse((is.na(x1[1,k]) || is.na(y1[1,l])),NA, (y1[2,l]-x1[2,k])^2)}
   }
   which(dists==min(dists,na.rm = TRUE),arr.ind = TRUE)
 }
 
 
 seq_data_sat<-data.frame(1,2,3,4,5,6,7,8,9,10)
 x_sat_ordered<-data.frame(x_hsv[[1]][2,])
 
 for (i in 2:length(x_hsv))
 {
   # we will replace elements with NAs here
   tmp<-x_hsv[[i]]
   # previous row, ordered on the previous step
   ordered<-data.frame(x_hsv[[i-1]][,as.numeric(seq_data_sat[i-1,])])
   
   # ordering of the lower row
   ordered2<-c(1,2,3,4,5,6,7,8,9,10)
   
   for (j in 1:10)
   {
     #closest<-mindist(ordered[,j], tmp)
     #closest<-minangle(ordered[,j], tmp)
     
     closest<-mindistvect_sat(ordered,tmp)[1,] # find a current closest pair
     tmp[1,closest[2]]<-NA # on each turn we kick out the values (still on the forst row, what's the difference?)
     ordered[1,closest[1]]<-NA
     ordered2[as.numeric(closest[1])]<-as.numeric(closest[2]) # ordering the lower row according to the higher
   }
   
   # saving the order
   seq_data_sat<-rbind(seq_data_sat,as.numeric(ordered2))
   
   # crating Hue-ordered table
   x_sat_ordered<-rbind(x_sat_ordered, as.numeric(x_hsv[[i]][2,as.numeric(ordered2)]))
   
 }
 
 # vertical sequences data
 seq_data_sat
 
 # Preparing Hue prediction table
 x_sat_ordered
 
 
 
 
 ########################################## Clustering: Value ########
 
 
 mindistvect_val<-function(x1,y1){
   dists<-matrix(NA, nrow = 10, ncol = 10)
   for (k in 1:10)
   {
     # there is no symmetry here
     # The first is their approach with squared difference
     # for (l in 1:10) {dists[k,l]<- ifelse((is.na(x1[1,k]) || is.na(y1[1,l])),NA, (x1[1,k]-y1[1,l])^2)}
     # My approach computes the angle
     for (l in 1:10) {dists[k,l]<- ifelse((is.na(x1[1,k]) || is.na(y1[1,l])),NA, (y1[3,l]-x1[3,k])^2)}
   }
   which(dists==min(dists,na.rm = TRUE),arr.ind = TRUE)
 }
 
 
 seq_data_val<-data.frame(1,2,3,4,5,6,7,8,9,10)
 x_val_ordered<-data.frame(x_hsv[[1]][3,])
 
 
 for (i in 2:length(x_hsv))
 {
   # we will replace elements with NAs here
   tmp<-x_hsv[[i]]
   # previous row, ordered on the previous step
   ordered<-data.frame(x_hsv[[i-1]][,as.numeric(seq_data_sat[i-1,])])
   
   # ordering of the lower row
   ordered2<-c(1,2,3,4,5,6,7,8,9,10)
   
   for (j in 1:10)
   {
     #closest<-mindist(ordered[,j], tmp)
     #closest<-minangle(ordered[,j], tmp)
     
     closest<-mindistvect_val(ordered,tmp)[1,] # find a current closest pair
     tmp[1,closest[2]]<-NA # on each turn we kick out the values
     ordered[1,closest[1]]<-NA
     ordered2[as.numeric(closest[1])]<-as.numeric(closest[2]) # ordering the lower row according to the higher
   }
   
   # saving the order
   seq_data_val<-rbind(seq_data_val,as.numeric(ordered2))
   
   # crating Hue-ordered table
   x_val_ordered<-rbind(x_val_ordered, as.numeric(x_hsv[[i]][3,as.numeric(ordered2)]))
   
 }
 
 # vertical sequences data
 seq_data_val
 
 # Preparing Hue prediction table
 x_val_ordered
 
 ########################################## Performing GM(1,1) prediction for hue, sat ############
 
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
 
 
 # #Paint balls (obsolete)
 # plot(1, type="n", xlab="", ylab="", xlim=c(0, 25), ylim=c(0, 1))
 # for (j in 1:length(x)){
 #   x_order<-x[[j]][,as.numeric(seq_data[j,])]
 #   for (i in 1:10){
 #     points(i*2,0.8-(j)*0.1,pch=19,col=rgb(x_order[1,i]/255,x_order[2,i]/255,x_order[3,i]/255), cex=5)
 #   }
 # }
 
 ### Hue
 
 # real data for 5th observation
 real<-round(x_hsv[[5]][1,as.numeric(seq_data[5,])]*360)
 # obtaining predictions from 4 previous observations
 pred<-sapply(1:10, function(i) gm11(as.numeric(x_hue_ordered[1:4,i]),5))
 
 # residual sequence prediction
 res<-sapply(1:10,function(i) gm11(as.numeric( pred[1:4,i]-x_hue_ordered[1:4,i]),5)[5])
 pred<-round((pred[5,]-res)*360)%%360
 
 real
 pred
 
 ### Sat
 
 # real data for 5th observation
 real_sat<-x_hsv[[5]][2,as.numeric(seq_data_sat[5,])]
 # obtaining predictions from 4 previous observations
 
 pred_sat<-sapply(1:10, function(i) gm11(as.numeric(x_sat_ordered[1:4,i]),5))
 #pred_sat<-sapply(pred_sat, function(z) ifelse(z>1,1,z) )
 
 res<-sapply(1:10,function(i) gm11(as.numeric( pred_sat[1:4,i]-x_hue_ordered[1:4,i]),5)[5])
 pred_sat<-(pred_sat[5,]-res)
 
 pred_sat<-ifelse(pred_sat>1,1,pred_sat)
 pred_sat<-ifelse(pred_sat<0,0,pred_sat)
 
 real_sat
 pred_sat
 
 
 real_val<-x_hsv[[5]][3,as.numeric(seq_data_val[5,])]
 # obtaining predictions from 4 previous observations
 pred_val<-sapply(1:10, function(i) gm11(as.numeric(x_val_ordered[1:4,i]),5)[5])
 pred_val<-sapply(pred_val, function(z) ifelse(z>1,1,z) )
 
 real_val
 pred_val
 
 
 # constructing the colors according to the results. Different clustering for each time was taken into account
 
 # hue
 hsv_predict<-pred[match(c(1,2,3,4,5,6,7,8,9,10),seq_data[5,])]/360
 #hsv_predict<-real[match(c(1,2,3,4,5,6,7,8,9,10),seq_data[5,])]/360
 # sat
 
 #hsv_predict<-rbind(hsv_predict,real_sat[match(c(1,2,3,4,5,6,7,8,9,10),seq_data_sat[5,])])
 hsv_predict<-rbind(hsv_predict,pred_sat[match(c(1,2,3,4,5,6,7,8,9,10),seq_data_sat[5,])])
 # val
 #hsv_predict<-rbind(hsv_predict,real_val[match(c(1,2,3,4,5,6,7,8,9,10),seq_data_val[5,])])
 hsv_predict<-rbind(hsv_predict,pred_val[match(c(1,2,3,4,5,6,7,8,9,10),seq_data_val[5,])])
 
 #Paint balls
 plot(1, type="n", xlab="", ylab="", xlim=c(0, 25), ylim=c(0, 1))
 
 for (i in 1:10){
   # real color
   x_order<-x[[5]]
   points(i*2,0.8,pch=19,col=rgb(x_order[1,i],x_order[2,i],x_order[3,i],maxColorValue = 255), cex=5)
   # predicter color
   col<-hsv_predict[,i]
   points(i*2,0.4,pch=19,col=hsv(col[1],col[2],col[3]), cex=5)
 }
 

 