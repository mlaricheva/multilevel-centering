library(lme4)
library(simr)
library(MASS)
library(dplyr)
library(nlme)

source("functions.R")

ICC <- 0.3
corr <- 0.7
group_size <-10
num_groups <- 50
gamma<-rep(1,9)
names(gamma)<-c("gamma00", "gamma01", "gamma02", "gamma10","gamma11","gamma12","gamma20", "gamma21", "gamma22")

replicate(n = 3, rnorm(5, 0, 1) )


start.time <- Sys.time()
### preparing and saving raw data
raw.data<-generate_data(group_size, num_groups, ICC,corr,gamma)
suppressWarnings(write.table(raw.data, "/data/rawdata.csv", sep = ",", col.names = !file.exists("rawdata.csv"), append = T))

### raw model
raw.res<-raw_model(sample_data,gamma)
raw.coef<-raw.res[,1]
suppressWarnings(write.table(data.frame(t(raw.coef)), "/data/raw_coef.csv", sep = ",", col.names = !file.exists("raw_coef.csv"), append = T))
raw.se<-raw.res[,2]
suppressWarnings(write.table(data.frame(t(raw.se)), "/data/raw_se.csv", sep = ",", col.names = !file.exists("raw_se.csv"), append = T))

### cgm model
cgm.data<-cgm_cent(raw.data)
cgm.res<-cgm_model(cgm.data,gamma)
cgm.coef<-cgm.res[,1]
suppressWarnings(write.table(data.frame(t(cgm.coef)), "/data/cgm_coef.csv", sep = ",", col.names = !file.exists("cgm_coef.csv"), append = T))
cgm.se<-cgm.res[,2]
suppressWarnings(write.table(data.frame(t(cgm.se)), "/data/cgm_se.csv", sep = ",", col.names = !file.exists("cgm_se.csv"), append = T))

### cwc model
cwc.data<-cwc_cent(raw.data)
cwc.res<-cwc_model(cwc.data,gamma)
cwc.coef<-cwc.res[,1]
suppressWarnings(write.table(data.frame(t(cwc.coef)), "/data/cwc_coef.csv", sep = ",", col.names = !file.exists("cwc_coef.csv"), append = T))
cwc.se<-cwc.res[,2]
suppressWarnings(write.table(data.frame(t(cwc.se)), "/data/cwc_se.csv", sep = ",", col.names = !file.exists("cwc_se.csv"), append = T))

end.time <- Sys.time()
time.taken <- end.time - start.time
print("Simulation finished. Time taken: ", time.taken)

  