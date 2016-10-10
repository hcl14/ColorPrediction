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

## Approach 3: Using the article in /theory
**gray.R** contains the actual implementation in R that loops through all the data (28-4 rows) with 5-row moving window and constructs predictions using manual euctidean clustering for HUE coordinate ang GM(1,1) model for prediction.

It seems that they did not use Fuzzy C-Means for their main result, just show the picture (or I need to read more carefully).  They think of Pantone 10 colors as clusters, and propose FCM to aggregate real-world data (from images,etc.) into similar n-color sequences. The clusternig was performed manually using euclidean metric.

I failed to exactly reproduce their vertical clusters, it seems that we have a little bit different RGB values (mine are taken generally from pantone.com). My clustering vs theirs (vertical sequences):
![Plot](/img/Clustering for 23-27.png?raw=true "GLM Prediction")

The following prediction was obtained (0-360 degrees, i.e. 328 and 4 are quite nearby):
```
> real  
205 218 6 104 31 53   4 1 181 249
> pred
203 222 2 117 25 58 328 1 119 225
```

I attempted pure RGB clustering using euclidean metric as well (**RGB_ordering.R**), however the results are not as good, maybe because I'm still using Hue as covariate (regression over RGB values is worth to try):
![Plot](/img/RGB clustering.png?raw=true "GLM Prediction")

```
> real
181 249 104   1 6 53 31 218 4 205
> pred
179   9  92 357 9 14  5 209 1 179
```

Also the general program tries to test all the 5-sequences in the data through a loop. The results are totally not that impressive (notice that prediction often resembles the shifted data):
![Plot](/img/N2-N7-N3.png?raw=true "GLM Prediction")

**RGB_ordering.R** Prediction for other two parameters (sat, val) wasn't successful. In order to construct some colors, prediction based on R,G,B components was used (R component shows good fit) and Hue is ther replaced with previous successful prediction. Residual correction proposed in the original article was also used:

hue:
```
> real
   X4  X3 X2 X10 X9 X5 X8 X1  X6  X7
h 205 218  6 104 31 53  4  1 181 249
> pred
 [1] 203 222   3 117  25  58 328   1 122 225
```
red:
```
> real_r
  X10  X6  X8  X7  X9 X4  X3  X1  X2  X5
1 113 152 220 152 177  3 145 247 247 251
> pred_r
 [1] 127 146 225 165 212   0 138 255 109  41
```
green:
```
> real_g
   X6  X9  X3  X7  X1  X8  X5 X10  X2 X4
1 152 177 145 152 247 220 251 113 247  3
> pred_g
 [1] 113 255  61 217 249  83  99 138  58 203
```

blue:
```
> real_b
   X5  X1  X3  X7 X4 X10  X6  X8  X9  X2
1 251 247 145 152  3 113 152 220 177 247
> pred_b
 [1] 255 107 178 255   2 203 159  49 147 205
```

Result (upper - real, lower - predicted):

![Plot](/img/rgb_hue_predict.png?raw=true "GLM Prediction")

The accuracy arcieved is somewhat ~50%. No idean how authors obtained their precise results.
For example, the results for H-S-V prediction (**hsv_color_predict.R**) are:

![Plot](/img/hue_sat_val_predict.png?raw=true "GLM Prediction")



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

The `glm` model was trained on the first 20 values (out of 28), the Hue dynamics for the last 8 (4 years) was approximately predicted.  The result shows that prediction can be possible, but K-Means result is very unstable for different seed, so it fails.

![Plot](/Fulldata_glm.png?raw=true "GLM Prediction, Full data")
