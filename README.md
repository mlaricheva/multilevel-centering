# Multicollinearity and Centering in Multilevel Models
Exploring effects of different centering methods in hierarchical linear models on bias and standard errors through Monte-Carlo simulation

## Introduction

The hierarchical linear model described as follows:  

Level-1:&nbsp;&nbsp;&nbsp;![equation](https://latex.codecogs.com/gif.latex?Y_%7Bij%7D%20%3D%20%5Cbeta_%7B0j%7D%20&plus;%20%5Cbeta_%7B1j%7DX_1_%7Bij%7D%20&plus;%20%5Cbeta_%7B2j%7DX_2_%7Bij%7D&plus;%5Cepsilon_%7Bij%7D). 

Level-2:&nbsp;&nbsp;&nbsp;![equation](https://latex.codecogs.com/gif.latex?%5C%5C%5Cbeta_%7B0j%7D%20%3D%20%5Cgamma_%7B00%7D&plus;%5Cgamma_%7B01%7DW_%7B1j%7D&plus;%5Cgamma_%7B02%7DW_%7B2j%7D%20%5C%5C%5Cbeta_%7B1j%7D%20%3D%20%5Cgamma_%7B10%7D&plus;%5Cgamma_%7B11%7DW_%7B1j%7D&plus;%5Cgamma_%7B12%7DW_%7B2j%7D%20%5C%5C%5Cbeta_%7B2j%7D%20%3D%20%5Cgamma_%7B20%7D&plus;%5Cgamma_%7B21%7DW_%7B1j%7D&plus;%5Cgamma_%7B22%7DW_%7B2j%7D). 

  
  
The models were fitted using *nlme* package. 
  

Two Level-1 predictors are generated randomly with means of 0.1 and 1.1 and variance of 1. Both Level-2 predictors have means of 1 and variance of 1.  

## Centering methods ##

* *RAW*: no centering &nbsp;&nbsp;&nbsp;![equation](https://latex.codecogs.com/gif.latex?X_%7Bij%7D)    
* *CGM*: centering grand mean &nbsp;&nbsp;&nbsp;![equation](https://latex.codecogs.com/gif.latex?X_%7Bij%7D%20-%20%5Coverline%7BX%7D). 
* *CWC*: centering within cluster &nbsp;&nbsp;&nbsp;![equation](https://latex.codecogs.com/gif.latex?X_%7Bij%7D%20-%20%5Coverline%7BX_%7Bj%7D%7D).  

## Documentation ##

The system is defined by ICC, number of groups, group size (all groups are assumed to have the same size), correlation between Level-1 predictors and list of gamma parameters.  
  
  
*Example*. If all fixed effects coefficients are set to be 1, e.g. &nbsp;&nbsp;&nbsp;![equation](https://latex.codecogs.com/gif.latex?%5Cgamma_%7B00%7D%3D%5Cgamma_%7B01%7D%3D%5Cgamma_%7B02%7D%3D%5Cgamma_%7B10%7D%3D%5Cgamma_%7B11%7D%3D%5Cgamma_%7B12%7D%3D%5Cgamma_%7B20%7D%3D%5Cgamma_%7B21%7D%3D%5Cgamma_%7B22%7D%3D1).  

``` r
raw.data <- generate_data(group_size=10, num_groups=50, ICC=0.3,corr=0.7,gamma=rep(1,9))
```
  
High correlation between predictors may cause non-convergence. By default, *generate_data* function checks if the system is singular.  
  
``` r
> set.seed(7)
> generate_data(group_size=10, num_groups=50, ICC=0.3,corr=0.7,gamma=rep(1,9))

[1] "Cgm model is not converging. Restarting simulation"
              y            x1            x2 g_id          g1         g2
1    1.47476276 -0.2105077036  1.2572240503    1 -0.37154303  0.1137519
2    0.54211697  0.2740988978  1.8217880838    1 -0.37154303  0.1137519
3    1.23471334 -1.2305253710  0.4158803929    1 -0.37154303  0.1137519
...
```

Convergence check can be also done using *conv_check* function. If function returns 0, then convergence is not met.  
  
``` r
> sample_data<-generate_data(group_size=10, num_groups=50, ICC=0.3,corr=0.7,gamma=rep(1,9))
> conv_check(sample_data)
[1] 1
```

### Centering ###
  
*cgm_cent(data)* and *cwc_cent(data)* perform grand mean centering group mean centering of Level-1 predictors respectively. *Note:* new columns with *cgm* and *cwc* preffixes are added to the existing data.  

``` r
> cwc_data<-cwc_cent(sample_data)
```
### Models ###

*raw_model(data), cgm_model(data) and cwc_model(data)* are used to get model objects. 
``` r
> raw_model<-raw_model(sample_data)
> cwc_model<-cwc_cent(sample_data)
```

