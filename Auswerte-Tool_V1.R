## User settings
path_wd <- "C:/Users/dallmann/Desktop/Projekte/Modelle/earthwormModel/Auswertung" # path of directory with FORESEE result files
name_res<-"lter_ernst2021"# name of results files, e.g. one of lter=L. terrestris or acal=A.caliginosa and scenario
num_MC <- 50 # number of MonteCarlo runs (3 at least)
start_Date <- as.Date("2016/11/01") # Start date of simulation
application_Dates <- as.Date(c("2017/04/24","2018/04/27")) # application dates to mark in graphs
exists_fielddata <- T # does a field data file exist? Yes (T) / No (F)
## if field data exist, define dates of field data samplings
c_dateField <- as.Date(c("2016-11-02","2017-03-15","2017-05-31","2017-10-09","2018-04-17","2018-05-22","2018-10-23","2019-05-06"))  

##############################################Automated skript############################################################
setwd(path_wd)
wd<-getwd()
Sys.setlocale("LC_ALL", "English")
num_observers <- 2
name_observers <- c("Abundance juveniles [#/m^2]","Abundance adults [#/m^2]")
name_statFiles <- c("Juveniles","Adults")

## Field data file
if (exists_fielddata){
  df_data <- read.table(file = choose.files(caption = "Select field data file"), header = T)
}

## Simulation data file(s)
## If control and treatment in separate files
# df_control <- read.csv(file = choose.files(caption = "Select control data file"), skip = 44)
# df_control <- df_control[,-1]
# df_treatment <- read.csv(file = choose.files(caption = "Select treatments data file"), skip = 44)
# df_treatment <- df_treatment[,-1]
# df_all_treatments<-df_treatment
# c_Date <- seq(from = start_Date,by=1,length.out=nrow(df_control))

## If control and treatment in one file
df <- read.csv(file = choose.files(caption = "Select model result data file"), skip = 28)
c_Date <- seq(from = start_Date,by=1,length.out=nrow(df))
df_control <- df[,2:(num_MC*num_observers+1)]
df_treatment <- df[,(num_MC*num_observers+2):ncol(df)]

## Berechnung statistischer Werte + Plots einzelner Observer
for (o in 1:num_observers){
  cols <- seq(o,ncol(df_control)-o,num_observers)
  
  df_subset <- df_control[,cols]
  mn<-apply(df_subset, 1, mean)
  sd<-apply(df_subset, 1, sd)
  min<-apply(df_subset, 1, min)
  max<-apply(df_subset, 1, max)
  median<-apply(df_subset, 1, median)
  percentiles<-t(apply(df_subset, 1, quantile, probs = c(0.025,0.975,0.1,0.9,0.05,0.95)))
  df_statistics <-cbind(c_Date,mn, median, sd, min, max, percentiles)
 
  df_subset <- df_treatment[,cols]
  mn<-apply(df_subset, 1, mean)
  sd<-apply(df_subset, 1, sd)
  min<-apply(df_subset, 1, min)
  max<-apply(df_subset, 1, max)
  median<-apply(df_subset, 1, median)
  percentiles<-t(apply(df_subset, 1, quantile, probs = c(0.025,0.975,0.1,0.9,0.05,0.95)))
  df_statistics <-cbind(df_statistics,mn, median, sd, min, max, percentiles)
  
  switch(o,
         {df_juv = df_statistics},
         {df_adu = df_statistics})
  write.csv(df_statistics, file = paste0(Sys.Date(),"_",name_res,"_",name_statFiles[o],"_statFile.csv"), row.names = F)
  
}

## Berechnung statistischer Werte + Plots vereinter Observer (jv+ad)
for (o in 1:(num_observers/2)){
  cols <- switch(o,seq(o,ncol(df_control)-o,num_observers),seq(3,ncol(df_control)-1,num_observers))
  
  df_subset <- (df_control[,cols]+df_control[,cols+1])
  mn<-apply(df_subset, 1, mean)
  sd<-apply(df_subset, 1, sd)
  min<-apply(df_subset, 1, min)
  max<-apply(df_subset, 1, max)
  median<-apply(df_subset, 1, median)
  percentiles<-t(apply(df_subset, 1, quantile, probs = c(0.025,0.975,0.1,0.9,0.05,0.95)))
  df_statistics <-cbind(c_Date,mn, median, sd, min, max, percentiles)
  
  df_subset <- df_treatment[,cols]+df_treatment[,cols+1]
  mn<-apply(df_subset, 1, mean)
  sd<-apply(df_subset, 1, sd)
  min<-apply(df_subset, 1, min)
  max<-apply(df_subset, 1, max)
  median<-apply(df_subset, 1, median)
  percentiles<-t(apply(df_subset, 1, quantile, probs = c(0.025,0.975,0.1,0.9,0.05,0.95)))
  df_statistics <-cbind(df_statistics,mn, median, sd, min, max, percentiles)
  
  switch(o,
         {df_total = df_statistics})
  write.csv(df_statistics, file = paste0(Sys.Date(),"_",name_res,"_total_statFile.csv"), row.names = F)
}

## Plot control field data vs model
# Control plots
# Total + adult + juvenile
plot(c_Date,df_total[,2], type = "l", lwd = 2, ylab = "Abundance [#/m^2]", xlab = "", ylim = c(0,1*max(df_total[,-1])))
polygon(x=c(c_Date,rev(c_Date)),y=c(df_total[,7],rev(df_total[,8])),col=rgb(0, 0, 0, max = 255, alpha = 125), lty=0)
polygon(x=c(c_Date,rev(c_Date)),y=c(df_juv[,7],rev(df_juv[,8])),col=rgb(245, 121, 58, max = 255, alpha = 125), lty=0)
lines(c_Date,df_juv[,2], lwd = 2, col = "#F5793A" )
polygon(x=c(c_Date,rev(c_Date)),y=c(df_adu[,7],rev(df_adu[,8])),col=rgb(169, 90, 161, max = 255, alpha = 125), lty=0)
lines(c_Date,df_adu[,2], lwd = 2, col = "#A95AA1")
if (exists_fielddata){
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,2], pch = 16)
  arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=df_data[,2]-df_data[,5], x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=df_data[,2]+df_data[,5], lwd=2,code=3, angle=90, length=0.07)
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,3], pch = 15, col = "#A95AA1")
  arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=df_data[,3]-df_data[,6], x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=df_data[,3]+df_data[,6], lwd=2,code=3, angle=90, length=0.07, col = "#A95AA1")
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,4], pch = 17, col = "#F5793A")
  arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=df_data[,4]-df_data[,7], x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=df_data[,4]+df_data[,7], lwd=2,code=3, angle=90, length=0.07, col = "#F5793A")
}
legend("topright", c("Total","Adults","Juveniles"), pch=c(16,15,17),lty=1, lwd=c(2,2,2),col = c("black", "#A95AA1","#F5793A"))#,"#A95AA1","#85C0F9","#0F2080"))
dev.print(png, paste0(Sys.Date(),"_",name_res,"_ctrl_abundance_tot+adu+juv.png"), width = 600)

# Adults+juveniles
plot(c_Date,df_juv[,2], type = "l", lwd = 2, ylab = "Abundance [#/m^2]", xlab = "", ylim = c(0,1*max(df_juv[,-1])), col = "#F5793A" )
polygon(x=c(c_Date,rev(c_Date)),y=c(df_juv[,7],rev(df_juv[,8])),col=rgb(245, 121, 58, max = 255, alpha = 125), lty=0)
lines(c_Date,df_juv[,2], lwd = 2, col = "#F5793A" )
polygon(x=c(c_Date,rev(c_Date)),y=c(df_adu[,7],rev(df_adu[,8])),col=rgb(169, 90, 161, max = 255, alpha = 125), lty=0)
lines(c_Date,df_adu[,2], lwd = 2, col = "#A95AA1")
if (exists_fielddata){
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,3], pch = 15, col = "#A95AA1")
  arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=df_data[,3]-df_data[,6], x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=df_data[,3]+df_data[,6], lwd=2,code=3, angle=90, length=0.07, col = "#A95AA1")
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,4], pch = 17, col = "#F5793A")
  arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=df_data[,4]-df_data[,7], x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=df_data[,4]+df_data[,7], lwd=2,code=3, angle=90, length=0.07, col = "#F5793A")
}
legend("topright", c("Adults","Juveniles"), pch=c(15,17),lty=1, lwd=2,col = c("#A95AA1","#F5793A"))#,"#A95AA1","#85C0F9","#0F2080"))
dev.print(png, paste0(Sys.Date(),"_",name_res,"_ctrl_abundance_adu+juv.png"), width = 600)

## Plots relative
# Total
plot(c_Date,df_total[,2]/df_total[,2]*100, type = "l", lwd = 2, ylab = "Relative total abundance [% of control]", xlab = "", ylim = c(0,150))
for (i in application_Dates){
  lines(x=c(i,i),y=c(-50,200), lwd = 1, lty = 2, col = "black")
}
polygon(x=c(c_Date,rev(c_Date)),y=c(df_total[,7]/df_total[,2]*100,rev(df_total[,8]/df_total[,2]*100)),col=rgb(0, 0, 0, max = 255, alpha = 125),lty=0)
polygon(x=c(c_Date,rev(c_Date)),y=c(df_total[,18]/df_total[,2]*100,rev(df_total[,19]/df_total[,2]*100)),col=rgb(245, 121, 58, max = 255, alpha = 125),lty=0)
lines(c_Date, df_total[,13]/df_total[,2]*100, col = "#F5793A", lwd = 2)
if (exists_fielddata){
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,2]/df_data[,2]*100, pch = 16)
  #arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=(df_data[,2]-df_data[,5])/df_data[,2]*100, x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=(df_data[,2]+df_data[,5])/df_data[,2]*100, lwd=2,code=3, angle=90, length=0.07)
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,8]/df_data[,2]*100, pch = 17, col = "#F5793A", cex = 1.2)
  arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=(df_data[,8]-df_data[,11])/df_data[,2]*100, x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=(df_data[,8]+df_data[,11])/df_data[,2]*100, lwd=2, col = "#F5793A",code=3, angle=90, length=0.07)
}
legend("topright", c("Control","Treatment"), lty=1, pch=c(16,17),lwd=2,col = c("black", "#F5793A"))
dev.print(png, paste0(Sys.Date(),"_",name_res,"_total.png"), width = 600)

# Adults
plot(c_Date,df_adu[,2]/df_adu[,2]*100, type = "l", lwd = 2, ylab = "Relative abundance adults [% of control]", xlab = "", ylim = c(0,150))
for (i in application_Dates){
  lines(x=c(i,i),y=c(-50,200), lwd = 1, lty = 2, col = "black")
}
polygon(x=c(c_Date,rev(c_Date)),y=c(df_adu[,7]/df_adu[,2]*100,rev(df_adu[,8]/df_adu[,2]*100)),col=rgb(0, 0, 0, max = 255, alpha = 125),lty=0)
polygon(x=c(c_Date,rev(c_Date)),y=c(df_adu[,18]/df_adu[,2]*100,rev(df_adu[,19]/df_adu[,2]*100)),col=rgb(245, 121, 58, max = 255, alpha = 125),lty=0)
lines(c_Date, df_adu[,13]/df_adu[,2]*100, col = "#F5793A", lwd = 2)
if (exists_fielddata){
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,3]/df_data[,3]*100, pch = 16)
  #arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=(df_data[,3]-df_data[,6])/df_data[,3]*100, x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=(df_data[,3]+df_data[,6])/df_data[,3]*100, lwd=2,code=3, angle=90, length=0.07)
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,9]/df_data[,3]*100, pch = 17, col = "#F5793A", cex = 1.2)
  arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=(df_data[,9]-df_data[,12])/df_data[,3]*100, x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=(df_data[,9]+df_data[,12])/df_data[,3]*100, lwd=2, col = "#F5793A",code=3, angle=90, length=0.07)
}
legend("topright", c("Control","Treatment"), lty=1, pch=c(16,17),lwd=2,col = c("black", "#F5793A"))
dev.print(png, paste0(Sys.Date(),"_",name_res,"_adult.png"), width = 600)

# Juveniles
plot(c_Date,df_juv[,2]/df_juv[,2]*100, type = "l", lwd = 2, ylab = "Relative abundance juveniles [% of control]", xlab = "", ylim = c(0,150))
for (i in application_Dates){
  lines(x=c(i,i),y=c(-50,200), lwd = 1, lty = 2, col = "black")
}
polygon(x=c(c_Date,rev(c_Date)),y=c(df_juv[,7]/df_juv[,2]*100,rev(df_juv[,8]/df_juv[,2]*100)),col=rgb(0, 0, 0, max = 255, alpha = 125),lty=0)
polygon(x=c(c_Date,rev(c_Date)),y=c(df_juv[,18]/df_juv[,2]*100,rev(df_juv[,19]/df_juv[,2]*100)),col=rgb(245, 121, 58, max = 255, alpha = 125),lty=0)
lines(c_Date, df_juv[,13]/df_juv[,2]*100, col = "#F5793A", lwd = 2)
if (exists_fielddata){
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,4]/df_data[,4]*100, pch = 16)
  #arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=(df_data[,4]-df_data[,7])/df_data[,4]*100, x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=(df_data[,4]+df_data[,7])/df_data[,4]*100, lwd=2,code=3, angle=90, length=0.07)
  points(as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")),df_data[,10]/df_data[,4]*100, pch = 17, col = "#F5793A", cex = 1.2)
  arrows(x0=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y0=(df_data[,10]-df_data[,13])/df_data[,4]*100, x1=as.Date(df_data[,1],tryFormats = c("%d.%m.%Y")), y1=(df_data[,10]+df_data[,13])/df_data[,4]*100, lwd=2, col = "#F5793A",code=3, angle=90, length=0.07)
}
legend("topright", c("Control","Treatment"), lty=1, pch=c(16,17),lwd=2,col = c("black", "#F5793A"))
dev.print(png, paste0(Sys.Date(),"_",name_res,"_juvenile.png"), width = 600)

## Tabelle %Effekt an Sampling Tagen
if (exists_fielddata){
  date_filter <- c_dateField
  df_sampling<-matrix(NA, nrow = length(date_filter), ncol = 4)
  colnames(df_sampling)<-c("Date","Total","Adult","Juvenile")
  df_sampling<-as.data.frame(df_sampling)
  df_sampling[,1]<-as.Date(date_filter)
  for (o in 1:3){
    switch(o,
           {df_statistics = df_total},
           {df_statistics = df_adu},
           {df_statistics = df_juv})
    
    df_statistics <- as.data.frame(df_statistics)
    df_statistics[,1]<-c_Date
    df_statistics<-df_statistics[df_statistics$c_Date %in% date_filter,]
    df_sampling[,(o+1)]<-df_statistics[,13]/df_statistics[,2]
  }
  write.csv(df_sampling, file = paste0(Sys.Date(),"_",name_res,"_summaryTable.csv"), row.names = F)
}
