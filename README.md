# ColorPrediction
Attempt to build color prediction model based on the Pantone data

According to the article http://onlinelibrary.wiley.com/doi/10.1002/col.22057/abstract
color prediction for industry is possible.

The method suggested in the article is clustering the colors from previous years and applying prediction model.

The same approaches are used in the following source:

Clustering ==> choosing parameter in the cluster (Hue for Yellow) ==> prediction using ANN:

http://www.cmnt.lv/upload-files/ns_39art95.pdf




The dataset **spring-Pantone_TPX_RGB_Colours.csv** contains Pantone palettes for spring season for years 2003-2016. Year 2003 contains 9 values, other years contain 10 values. For year 2015 Pantone released two color sets for Men and Women, the Women data is used.

The dataset **Full_Pantone_TPX_RGB_Colours.csv** contains all Pantone color reports in RGB, 2003-2016

## Approach 1: clustering to 4-bit uniform palette
**convert_to_16.R** contains the the first attempt that rounds the values to [16-color palette](http://www.december.com/html/spec/color16codes.html). For the missing value simple imputation was used.

The Yellow colour code was set afterwards to Pantone 13-0858 Yellow (255,220,1).

The **Yellow_hue_predict.R** does some reverse-engineering of the second article. The colors were clustered to the 4-bit palette, the code for Yellow (8) is present from the year 2007 (exactly as in the source article, where the palettes were taken beginning from 2007). After that, mean Hue for all the colors in the Yellow group was calculated and `glm` model (x[n] ~ x[n-1]+x[n-2]+x[n-3]) applied (if they found a precise relationship with ANN, then simple models should detect something as well). The result shows that indeed some link exists within Yellow cluster:

![Plot](/Rplot10.png?raw=true "GLM Prediction")

Two last states can be indeed predicted (i.e. the data for them can be not included during the training of the model), however the amount of data is insufficient to derive any conclusions.

## Approach 2: K-Means clustering

All the data from the entire history (i.e. all the colors ) were merged and K-means++ used to obtain 6 clusters. Then the values from each year are assigned to the corresponding clusters using euclidean metric:

```
       X1 X2 X3 X4 X5 X6 X7 X8 X9 X10
X2003s  4  4  1  6  2  5  5  3  5   5
X2003f  3  1  6  1  1  5  1  1  5   1
X2004s  2  2  2  3  4  5  4  5  5   6
X2004f  5  4  2  1  1  3  1  2  6   2
X2005s  3  6  2  3  5  6  4  5  5   5
X2005f  3  1  1  2  2  1  6  3  1   5
X2006s  4  4  4  4  4  4  5  3  1   6
X2006f  5  5  3  2  2  5  1  6  1   1
X2007s  4  5  5  3  1  3  5  3  3   5
X2007f  1  2  1  6  5  5  1  3  5   1
X2008s  3  5  2  4  3  3  3  3  6   4
X2008f  6  1  6  6  2  1  2  6  2   3
X2009s  2  3  6  5  3  3  4  6  5   4
X2009f  2  1  3  1  2  5  2  3  6   4
X2010s  5  2  3  5  5  3  6  4  1   5
X2010f  3  3  2  2  2  1  6  1  4   4
X2011s  2  2  5  3  4  1  6  6  4   4
X2011f  3  2  2  1  5  6  1  5  4   5
X2012s  2  3  2  5  6  4  4  5  5   5
X2012f  1  3  2  2  6  3  6  5  5   4
X2013s  6  5  5  3  3  5  4  6  2   3
X2013f  3  6  6  1  2  2  1  2  1   1
X2014s  5  5  5  5  3  3  2  2  5   6
X2014f  4  1  2  3  1  1  6  6  5   5
X2015s  4  6  5  6  4  3  3  4  1   4
X2015f  1  5  1  6  5  5  3  3  1   1
X2016s  4  3  5  6  3  4  5  2  3   5
X2016f  5  5  6  5  6  3  5  2  2   1
```

The target cluster is 6. If it is not present for a certain year, the previous value is used.

The `glm` model was trained on the first 20 values (out of 28), the Hue dynamics for the last 8 (4 years) was approximately predicted.  The result shows that prediction is possible.

![Plot](/Fulldata_glm.png?raw=true "GLM Prediction, Full data")
