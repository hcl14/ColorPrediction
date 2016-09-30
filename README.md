# ColorPrediction
Attempt to build color prediction model based on the Pantone data

According to the article http://onlinelibrary.wiley.com/doi/10.1002/col.22057/abstract
color prediction for industry is possible.

The method suggested in the article is clustering the colors from previous years and applying prediction model.

The same approaches are used in the following source:

Clustering ==> choosing parameter in the cluster (Hue for Yellow) ==> prediction using ANN:

http://www.cmnt.lv/upload-files/ns_39art95.pdf




The dataset **spring-Pantone_TPX_RGB_Colours.csv** contains Pantone palettes for spring season for years 2003-2016. Year 2003 contains 9 values, other years contain 10 values. For year 2015 Pantone released two color sets for Men and Women, the Women data is used.

**convert_to_16.R** contains the code that rounds the values to [16-color palette](http://www.december.com/html/spec/color16codes.html). For the missing value simple imputation was used.
Output:
```
      X1 X2 X3 X4 X5 X6 X7 X8 X9 X10
X2003  3  3  2 13  2  2  3  3  3   2
X2004  6  6  2  8  3  2  3  2  3   2
X2005  8  2  6  3  2  2  3  3  2   2
X2006  3  3  3  3  3  3  3  3  2  11
X2007  3  2  2  8 15  8  3  2  3   3
X2008  2  2 15  3  3  8  3  3 11   3
X2009 15  3 11  3  8  2  3  2  2   3
X2010  2 15  3  3  2  8  2  3  2   3
X2011  2  8  2  8  3  2  2 12  3   3
X2012  6  8 15  2 11  3  3  2  3   2
X2013 11  3  2  8  8  3  3 11  6   8
X2014  3  3  3  2  3  8  6  7  2  11
X2015  3 11  3 11  3  3  8  3  2   3
X2016  3  2  3 11  8  3  2  6  2   2
```

The Yellow colour code was set afterwards to Pantone 13-0858 Yellow (255,220,1).

The **Yellow_hue_predict.R** does some reverse-engineering of the second article. The colors were clustered to the 4-bit palette, the code for Yellow (8) is present from the year 2007 (exactly as in the source article, where the palettes were taken beginning from 2007).

After that, mean Hue for all the colors in the Yellow group was calculated and `glm` model (x[n] ~ x[n-1]+x[n-2]+x[n-3]) applied (if they found a precise relationship with ANN, then simple models should detect something as well). The result shows that indeed some link exists within Yellow cluster:

![Plot](/Rplot10.png?raw=true "GLM Prediction")

Two last states can be indeed predicted (i.e. the data for them can be not included during the training of the model):
```R
huedata_N2<-as.numeric(lapply(5:12,meanhue_N2))
library(zoo)
split2<-data.frame(rollapply(huedata_N2, 4, by = 1, c))
fit2<-glm(X4~X1+X2+X3, data=split2)

huedata_N2<-as.numeric(lapply(5:13,meanhue_N2))
split2<-data.frame(rollapply(huedata_N2, 4, by = 1, c))

plot(split2$X4,ylab="value",xlab="Years 2010-2016",main="x[n]~x[n-1]+x[n-2]+x[n-3]")
lines(split2$X4)
lines(predict(fit2,split2[,1:3]),col="green")
legend(x="bottomleft", c("Actual data","Prediction"),
       lty=c(1,1), col=c("black","green"))
```
(and the same for 5:13-5:14)

However the amount of the data is insufficient to derive any conclusions
