# Multicollinearity and Centering in Multilevel Models
Exploring effects of different centering methods in hierarchical linear models on bias and standard errors through Monte-Carlo simulation

## Introduction

The hierarchical linear model described as follows:  

Level-1:&nbsp;&nbsp;&nbsp;![equation](https://latex.codecogs.com/gif.latex?Y_%7Bij%7D%20%3D%20%5Cbeta_%7B0j%7D%20&plus;%20%5Cbeta_%7B1j%7DX_1_%7Bij%7D%20&plus;%20%5Cbeta_%7B2j%7DX_2_%7Bij%7D&plus;%5Cepsilon_%7Bij%7D). 

Level-2:&nbsp;&nbsp;&nbsp;![equation](https://latex.codecogs.com/gif.latex?%5C%5C%5Cbeta_%7B0j%7D%20%3D%20%5Cgamma_%7B00%7D&plus;%5Cgamma_%7B01%7DW_%7B1j%7D&plus;%5Cgamma_%7B02%7DW_%7B2j%7D%20%5C%5C%5Cbeta_%7B1j%7D%20%3D%20%5Cgamma_%7B10%7D&plus;%5Cgamma_%7B11%7DW_%7B1j%7D&plus;%5Cgamma_%7B12%7DW_%7B2j%7D%20%5C%5C%5Cbeta_%7B2j%7D%20%3D%20%5Cgamma_%7B20%7D&plus;%5Cgamma_%7B21%7DW_%7B1j%7D&plus;%5Cgamma_%7B22%7DW_%7B2j%7D). 

  
  
The models were fitted using *lme4* package. All fixed effects coefficients were set to be 1:  
  
  
![equation](https://latex.codecogs.com/gif.latex?%5Cgamma_%7B00%7D%3D%5Cgamma_%7B01%7D%3D%5Cgamma_%7B02%7D%3D%5Cgamma_%7B10%7D%3D%5Cgamma_%7B11%7D%3D%5Cgamma_%7B12%7D%3D%5Cgamma_%7B20%7D%3D%5Cgamma_%7B21%7D%3D%5Cgamma_%7B22%7D%3D1).  
  

Two Level-1 predictors are generated randomly with means of 0.1 and 1.1 and variance of 1. Both Level-2 predictors have means of 1 and variance of 1.  

## Centering methods ##


