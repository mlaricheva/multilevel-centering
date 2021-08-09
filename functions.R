### GENERATING DATA ###

conv_check<-function(data){
  out_raw<-tryCatch(length(raw_model(data)), 
           error=function(c){
    print("Raw model is not converging. Restarting simulation")
    return(0)
  })
  out_cgm<-tryCatch(length(cgm_model(cgm_cent(data))), 
           error=function(c){
    print("Cgm model is not converging. Restarting simulation")
    return(0)
           })
  out_cwc<-tryCatch(length(cwc_model(cwc_cent(data))), 
           error=function(c){
    print("Cwc modelis not converging. Restarting simulation")
    return(0)
           })
  if (out_raw == 0 | out_cgm == 0 | out_cwc == 0){
    return(0)
  }
  else{
    return(1)
  }
}

generate_data<-function(group_size, num_groups,ICC,corr,gamma, checkConv=TRUE){
  names(gamma)<-c("gamma00", "gamma01", "gamma02", "gamma10","gamma11","gamma12","gamma20", "gamma21", "gamma22")
  meanx1<-0.1 #rnorm(1) variance is higher than mean
  meanx2<-1.1 #rnorm(1) variance is lower than mean
  sigma1 <- matrix(c(1,corr,corr,1),2,2) #generating cov matrix
  x1x2<-mvrnorm(n=group_size*num_groups, mu = c(meanx1,meanx2), Sigma=sigma1)
  x1<-x1x2[,1] # generating level 1 predictors
  x2<-x1x2[,2]
  cor(x1,x2)
  
  g01<-rnorm(num_groups) # generating level 2 predictors
  g02<-rnorm(num_groups)
  id<-rep(1:(group_size*num_groups)) # generating id
  g_id <- as.factor(rep(1:num_groups, each = group_size))
  g1<-rep(g01, each = group_size)
  g2<-rep(g02, each = group_size)
  X<-cbind(id,g_id,x1,x2,g1,g2) # generating matrix
  
  varL1 <- 1 # variances on levels 1 and 2
  varL2 <-ICC/(1-ICC)
  
  #cov = cor*sqrt(var1*var2) = cor*sqrt(var2^2) = cor*var2
  
  sigma_u <- rbind(c(varL2,0*varL2,0*varL2), c(0*varL2,varL2,0*varL2), c(0*varL2,0*varL2,varL2))
  u <- mvrnorm(n=num_groups, mu=c(0,0,0), Sigma = sigma_u)
  u0j<-u[,1]
  u1j<-u[,2]
  u2j<-u[,3]
  
  beta0j <- rep(gamma[["gamma00"]],num_groups) + gamma[["gamma01"]]*g01 + gamma[["gamma02"]]*g02 + u0j # betas
  beta1j <- rep(gamma[["gamma10"]],num_groups) + gamma[["gamma11"]]*g01 + gamma[["gamma12"]]*g02 + u1j
  beta2j <- rep(gamma[["gamma20"]],num_groups) + gamma[["gamma21"]]*g01 + gamma[["gamma22"]]*g02 + u2j
  
  eps<-rnorm(group_size*num_groups)
  
  y<-1+beta0j+beta1j*x1+beta2j*x2+eps
  
  data1 <- data.frame(y, x1, x2, g_id, g1, g2)
  
  # check convergence and rerun recursively if not met for one of the models
  if(conv_check(data1) == 0){
    repeat{
      data1<-generate_data(group_size, num_groups, ICC,corr,gamma)
      if(conv_check(data1)>0){
        break
      }
    }
  }
  
  return(data1)
}

### TESTING MODELS ###

get_coef_bias<-function(res,gamma){
  bias<-apply(apply(res, 1, function(x) x-gamma),1,function(x) mean(x))
  return(bias)
}

get_coef_mse<-function(res,gamma){
  mse<-apply(apply(res, 1, function(x) (x-gamma)^2),1,function(x) mean(x))
  return(mse)
}

get_rel_change<-function(raw, cent.data){
  for (param in names(raw)){
    rel.change[param]<-(cent.data[param]-raw[param])/raw[param]
  }
  return(rel.change)
}

mlm_model<-function(data1){
  model1 <- lme(y~1+x1*g1+x1*g2+x2*g1+x2*g2, random= ~ 1+x1+x2|g_id, data = data1,control=lmeControl(opt='optim',tolerance=1e-5,check.conv.singular = .makeCC(action = "ignore", tol=1e-5)))
  res1<-coef(summary(model1))
  return(res1)
} 

cgm_cent<-function(data1){
  data1$x1<-data1$x1-mean(data1$x1)
  data1$x2<-data1$x2-mean(data1$x2)
  data1$g1<-data1$g1-mean(data1$g1)
  data1$g2<-data1$g2-mean(data1$g2)
  return(data1)
} 

cwc_cent<-function(data1){
  data_cwc<-data1 %>%
    group_by(g_id) %>% 
    mutate(x1 = x1-mean(x1), x2 = x2-mean(x2))
  return(data_cwc)
}

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
