library(lme4)
library(simr)
library(MASS)
library(dplyr)
library(nlme)
source("functions.R")

ICC <- 0.3
corr <- 0.7
gamma<-rep(1,9)
names(gamma)<-c("gamma00", "gamma01", "gamma02", "gamma10","gamma11","gamma12","gamma20", "gamma21", "gamma22")

sample_data<-generate_data(ICC,corr,gamma)
raw.res<-raw_model(sample_data,gamma)
cgm.sample_data<-cgm_cent(sample_data)
cgm.res<-cgm_model(cgm.sample_data,gamma)
cwc.sample_data<-cwc_cent(sample_data)
cwc.res<-cwc_model(cwc.sample_data,gamma)

for (i in 1:3):
  