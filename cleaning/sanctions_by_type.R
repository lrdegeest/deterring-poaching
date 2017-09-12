library(data.table)
library(foreign)
setwd("~/Desktop/notebook/research/dissertation/first_paper/analysis/data/")
list.files()

# subjects data  
df <- read.dta("dp_data_R.dta")

# sanctions data 
s.zm <- read.csv("punishment_zm.csv"); s.zm$treatment = 1
s.pm <- read.csv("punishment_pm.csv"); s.pm$treatment = 2   
s.fm <- read.csv("punishment_fm.csv"); s.fm$treatment = 3
sanctions <- rbind(s.zm, s.pm, s.fm)
names(sanctions) <- tolower(names(sanctions))

# summarize: one column each for sanctions assigned to insiders and outsiders
setDT(sanctions)
sanctions_summary <- sanctions[order(treatment,group,sender,period), 
                  list("s_a_insider" = sum(points[type==1]), 
                       "s_a_outsider" = sum(points[type==2])), 
                  by=.(treatment,group,sender, period)]

# add the sanctions columns to the subjects data 
df <- cbind(df, sanctions_summary[,5:6, with=F])

# save to stata
write.dta(df, "dp_data_with_sanctions_breakdown.dta")
