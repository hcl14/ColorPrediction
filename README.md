# ColorPrediction
Attempt to build color prediction model based on the Pantone data

According to the article http://onlinelibrary.wiley.com/doi/10.1002/col.22057/abstract
color prediction for industry is possible.

The method suggested in the article is clustering the colors from previous years and applying prediction model.


The dataset **spring-Pantone_TPX_RGB_Colours.csv** contains Pantone palettes for spring season for years 2003-2016. Year 2003 contains 9 values, other years contain 10 values. For year 2015 Pantone released two color sets for Men and Women, the Women data is used.

**convert_to_16.R** contains the code that rounds the values to [16-color palette](http://www.december.com/html/spec/color16codes.html). For missing value simple imputation is used.
Output:
```
      X1 X2 X3 X4 X5 X6 X7 X8 X9 X10
X2003  3  3  2 13  2  2  3  3  3   2
X2004  6  6  2  8  3  2  3  2  3   2
X2005  8  2  6  3  2  2  3  3  2   2
X2006  3  3  3  3  3  3  3  3  2  11
X2007  3  2  2  3 15  8  3  2  3   3
X2008  2  2 15  3  3  8  3  3 11   3
X2009 15  3 11  3  8  2  3  2  2   3
X2010  2 15  3  3  2  8  2  3  2   3
X2011  2  2  2  8  3  2  2 12  3   3
X2012  6  8 15  2 11  3  3  2  3   2
X2013 11  3  2  8  8  3  3 11  6   2
X2014  3  3  3  2  3  8  6  7  2  11
X2015  3 11  3 11  3  3  2  3  2   3
X2016  3  2  3 11  8  3  2  6  2   2
```

