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

simulation_run<- function(){
  start.time <- Sys.time()
  ### preparing and saving raw data
  raw.data<-generate_data(group_size, num_groups, ICC,corr,gamma)
  suppressWarnings(write.table(data.frame(raw.data), "./data/rawdata.csv", sep = ",",row.names = FALSE, col.names = !file.exists("./data/rawdata.csv"), append = T))
  
  ### raw model
  raw.res<-mlm_model(raw.data)
  raw.coef<-raw.res[,1]
  suppressWarnings(write.table(data.frame(t(raw.coef)), "./data/raw_coef.csv",row.names = FALSE, sep = ",", col.names = !file.exists("./data/raw_coef.csv"), append = T))
  raw.se<-raw.res[,2]
  suppressWarnings(write.table(data.frame(t(raw.se)), "./data/raw_se.csv", sep = ",", row.names = FALSE,col.names = !file.exists("./data/raw_se.csv"), append = T))
  
  ### cgm model
  cgm.data<-cgm_cent(raw.data)
  cgm.res<-mlm_model(cgm.data)
  cgm.coef<-cgm.res[,1]
  suppressWarnings(write.table(data.frame(t(cgm.coef)), "./data/cgm_coef.csv", sep = ",", row.names = FALSE,col.names = !file.exists("./data/cgm_coef.csv"), append = T))
  cgm.se<-cgm.res[,2]
  suppressWarnings(write.table(data.frame(t(cgm.se)), "./data/cgm_se.csv", sep = ",",row.names = FALSE, col.names = !file.exists("./data/cgm_se.csv"), append = T))
  
  ### cwc model
  cwc.data<-cwc_cent(raw.data)
  cwc.res<-mlm_model(cwc.data)
  cwc.coef<-cwc.res[,1]
  suppressWarnings(write.table(data.frame(t(cwc.coef)), "./data/cwc_coef.csv", sep = ",", row.names = FALSE,col.names = !file.exists("./data/cwc_coef.csv"), append = T))
  cwc.se<-cwc.res[,2]
  suppressWarnings(write.table(data.frame(t(cwc.se)), "./data/cwc_se.csv", sep = ",",row.names = FALSE, col.names = !file.exists("./data/cwc_se.csv"), append = T))
  
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  print(paste0("Simulation finished. Time taken: ",round(time.taken,3), "s"))
  return(0)
}

for(i in 1:100){
  seed<-sample.int(100, 1)
  print(seed)
  set.seed(seed)
  simulation_run()
  print("New seed")
  seed<-sample.int(100, 1)
  print(seed)
}

### For testing purposes
set.seed(7)
generate_data(group_size=10, num_groups=50, ICC=0.3,corr=0.7,gamma=rep(1,9))

replicate(n = 100, simulation_run(),simplify = FALSE)

raw.data<-read.table("./data/rawdata.csv", sep = ",", header = T)  
raw.coef<-read.table("./data/raw_coef.csv", sep = ",", header = T) 
cgm.coef<-read.table("./data/cgm_coef.csv", sep = ",", header = T)  

coef.bias<-get_coef_bias(raw.coef,gamma) # getting avg bias of raw model
coef.mse<-get_coef_mse(raw.coef,gamma) # getting avg mse of raw model

names(raw.coef)
(cgm.coef["x1.cgm"]-raw.coef["x1"])/raw.coef["x1"]
