#SCRIPT TO PREPARE DATA FOR STATA. 
# 11/23: sanity check in light of weird -signrank- results. All code dealing with the
# sanity check follows comments titled "sanity check"

#==== SET UP ====
rm(list = ls())
library(foreign)
library(data.table)
setwd("/Users/LawrenceDeGeest/Documents/DE_analysis_15/Data")
d <- read.dta("dp_data_R.dta")
dt <- data.table(d)
n = 8


# BEST RESPONSE PATHS ====
#define 2 best response function for insiders
#In this script I only apply brIN
n_in = 5
n_out = 3
a = 31; c = 2; b = 0.4
br.in.c <- function(x){
  (a-c-b*(n_out*x))/(n_in*2*b)
}
br.in.nc <- function(x){
  (a-c-b*(n_out*x))/(b*(n_in+1))
}
#define outsider best reponse
br.out <- function(x){
  (a-c-b*(n_in*x))/(b*(n_out+1))
}

IN = subset(dt.mean, type == "Insider")
OUT = subset(dt.mean, type == "Outsider")
IN$br_c = brIN(OUT$mh)
IN$br_nc = brNC(OUT$mh)
OUT$br = brOUT(IN$mh)

dt = data.table(rbind(IN, OUT, fill = T))

#export dataframe with only best-response data
export_br = data.frame(dt)
names(export_br) = tolower(names(export_br))
library(foreign)
setwd("/Users/LawrenceDeGeest/Documents/DE_analysis_15/Data")
write.dta(export_br, "BestResponse.dta")



# UPDATE AUGUST 2016: BR for all observations (not just means) ====
n_in = 5
n_out = 3
a = 31; c = 2; b = 0.4
# insiders
dt.in <- subset(dt, type == 'Insider')
# outsiders
dt.out <- subset(dt, type == 'Outsider')

# aggregate br functions
br.agg.in.c <- function(x){
  # x is agg out harvest
  (a-c-b*(x))/(n_in*2*b)
}
br.agg.in.nc <- function(x){
  # x is agg out harvest
  (a-c-b*(x))/(b*(n_in+1))
}
#define outsider best reponse
br.agg.out <- function(x){
  # x is agg in harvest
  (a-c-b*(x))/(b*(n_out+1))
}

dt.in$br_in_c <- br.agg.in.c(dt.in$out_h)
dt.in$br_in_nc <- br.agg.in.nc(dt.in$out_h)
dt.out$br_out <- br.agg.out(dt.out$in_h)
dt.in.out = data.table(rbind(dt.in, dt.out, fill = T))
write.dta(dt.in.out, "BestResponse2.dta")




# EFFICIENCY ====

# object
dt.mean <-dt[,list(
  mh = mean(h),
  mip = mean(ip),
  mfp = mean(fp)),
  by=list(treatment,period,type)]

# sanity check
## this...
ggplot(dt.mean, aes(period, mh, group=type)) + 
  geom_line() + geom_point() + 
  facet_grid(type~treatment) + 
  scale_y_continuous(limits=c(0,12))
##...should be the same as this...
ggplot(dt, aes(period, h, group=type)) + 
  stat_summary(fun.y="mean", geom="line") +
  stat_summary(fun.y="mean", geom="point") +
  facet_grid(type~treatment) + 
  scale_y_continuous(limits=c(0,12))
# e = (x - Nash) / (Social - Nash)
# benchmarks from Table 2 in the paper
s = 178.40 # social optimum (n = 8)
ncnd = 138.90 # Nash (n = 8)
cnd = 200.40
cd = 217.93

# define insider efficiency (n = 5)
#   insider payoffs maximized at strategy {cd}
eIN <- function(x){
  (x - ncnd) / (cd - ncnd)
}
#define outsider efficiency (n = 3):
# outsider payoffs maximized at strateg {cnd}
eOUT <- function(x){
  (x - ncnd) / (cnd - ncnd)
}

# insider/outsider efficiency
#   calculate mean efficiency for initial profits
dt.mean[, e1 := ifelse(type == "Insider",  
                  eIN(mip),
                  eOUT(mip))]

#   calculate mean efficiency for final profits
dt.mean[, e := ifelse(type == "Insider", 
                 eIN(mfp),
                 eOUT(mfp))]


# sanity check: do efficiency for entire data set 
## initial efficiency
dt[, ei := ifelse(type == "Insider",  
                       eIN(ip),
                       eOUT(ip))]
## final efficiency
dt[, ef := ifelse(type == "Insider", 
                      eIN(fp),
                      eOUT(fp))]

dt.test <-dt[,list(
  mie = mean(ei),
  mfe = mean(ef)),
  by=list(treatment,first,type)]

# pooled 
#define pooled efficiency (n = 8)
ePOOLED <- function(x){
  (x - ncnd) / (s - ncnd)
}
dt.mean_pooled <- dt[,list(
  mh = mean(h),
  mp1 = mean(ip),
  mp = mean(fp)),
  by=list(treatment,period)]
#   calculate mean efficiency for initial profits
dt.mean_pooled[, e1_pooled := ePOOLED(mp1) ]
#   calculate mean efficiency for final profits
dt.mean_pooled[, e_pooled := ePOOLED(mp)]

# visualize ====
ggplot() + 
  geom_line(aes(period, e1, group=type),linetype="dashed", dt.mean) + 
  geom_line(aes(period, e, group=type), dt.mean) + 
  #geom_line(aes(period, e1_pooled), color="blue", linetype="dashed", dt.mean_pooled) + 
  #geom_line(aes(period, e_pooled),  color="blue",  dt.mean_pooled) + 
  facet_grid(type~treatment) + 
  scale_y_continuous(limits=c(-0.2,0.8)) + ylab("initial & final efficiencies")

# EXPORT ====
#order the data by insider and treatment
export = dt[with(dt,
        order(Insider, Treatment)),
   ]
#make column names lowercase
export = data.frame(export)
names(export) = tolower(names(export))
#outsider and insider columns 
library(plyr)
export = rename(export, c("insider" = "type"))
export$insider = with(export, 
                       ifelse(type == "Insiders", 1, 0))
export$outsider = with(export,
                       ifelse(type == "Outsiders",1,0))

setwd("/Users/LawrenceDeGeest/Documents/DE_analysis_15/Data")
write.dta(export, "HarvestEfficiency.dta")

# export full data set with efficiency scores
write.dta(dt, "dp_data_eff.dta")

# INSIDER INVESTIGATION ====

list.files()
dt.insiders <- read.dta("dp_insider_efficiency_groups.dta")
dt.insiders.first <- subset(dt.insiders, first == 'first')
dt.insiders.second <- subset(dt.insiders, first == 'second')
dt.joined <- data.frame("group" = dt.insiders.first$group, 
                        "ef_first" = dt.insiders.first$mef,
                        "ef_second" = dt.insiders.second$mef)
pex_change <- function(x,y) round((y - x)/x, 2)
dt.joined$change <- pex_change(dt.joined$ef_first, dt.joined$ef_second)

# Make data set of average group efficiency ====
dt <- data.table(read.dta("dp_data_eff.dta"))
dt.eff.group_means <- dt[, list(
  mei = mean(ei),
  mef = mean(ef)),
  by=list(treatment, period, group, type)
  ]
dt.eff.group_means[, first := ifelse(period < 8, 1,2)]  
write.dta(dt.eff.group_means, "eff.group_means.dta")

