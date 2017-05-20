rm(list = ls())
setwd("/Users/LawrenceDeGeest/Documents/DE_analysis_15/Data")
library(foreign)
library(data.table)
options(scipen=999) # use options(scipen=0) to use scientific notation
d = read.dta("BestResponse2.dta")
d$first_n = with(d, 
               ifelse(period <= 8, 1, 2)
              )
d$treatment_n = with(d, 
                     ifelse(treatment == "ZERO", 1,
                            ifelse(treatment == "PARTIAL",2,
                                   ifelse(treatment == "FULL",3,
                                   NA)
                            )
                     )
)

dt <- data.table(d)
results_names <- c("W", "p-value")

# OLD approach ====

# === === === === 
# insiders
# === === === === 
In = subset(d, type == "Insider")

# compare to cooperative best-response
results_c <- matrix(ncol = 2, nrow = 3)
for(i in 1:3){
  test <- suppressWarnings(
    with(subset(In, treatment_n == i),
         wilcox.test(h, br)
         )
  )
  results_c[i,] <- cbind(round(as.numeric(test[1]),3), round(as.numeric(test[3]),3)) 
}
colnames(results_c) <- results_names
print(results_c)

# compare to cooperative best response with first-half/second-half breakdown
results_c_time <- matrix(ncol = 2, nrow = 6)
for(i in 1:3){
  for(j in 1:2){
  test <- suppressWarnings(
    with(subset(In, treatment_n == i & first_n == j),
         wilcox.test(h, br)
    )
  )
  results_c_time <- cbind(round(as.numeric(test[1]),3), round(as.numeric(test[3]),3)) 
  print(results_c_time)
  }
}


# === === === === 
# outsiders
# === === === === 
Out = subset(d, type == "Outsider")

# compare to noncooperative best-response
results_nc <- matrix(ncol = 2, nrow = 3)
for(i in 1:3){
  test <- suppressWarnings(
    with(subset(Out, treatment_n == i),
         wilcox.test(h, br)
    )
  )
  results_c[i,] <- cbind(round(as.numeric(test[1]),3), round(as.numeric(test[3]),3)) 
}
colnames(results_c) <- results_names
print(results_c)

# compare to noncooperative best response with first-half/second-half breakdown
results_nc_time <- matrix(ncol = 2, nrow = 6)
for(i in 1:3){
  for(j in 1:2){
    test <- suppressWarnings(
      with(subset(Out, treatment_n == i & first_n == j),
           wilcox.test(h, br)
      )
    )
    results_c_time <- cbind(round(as.numeric(test[1]),3), round(as.numeric(test[3]),3)) 
    print(results_c_time)
  }
}

# update 8 August ====
n_in = 5
n_out = 3


# Insiders
dt.in <- subset(dt, type == 'Insider')
dt.in[, agg_h := sum(h), by=.(treatment, period, group)]
dt.in[, m_agg_h := agg_h/n_in]

# cooperative BR
## no time
results_c <- matrix(ncol = 2, nrow = 3)
for(i in 1:3){
  test <- suppressWarnings(
    with(subset(dt.in, treatment_n == i),
         wilcox.test(m_agg_h, br_in_c)
    )
  )
  results_c[i,] <- cbind(round(as.numeric(test[1]),3), round(as.numeric(test[3]),3)) 
}
colnames(results_c) <- results_names
print(results_c)

## first-half/second-half breakdown
## drop period 15
dt.in.no15 <- subset(dt.in, period < 15)
for(i in 1:3){
  for(j in 1:2){
    test <- suppressWarnings(
      with(subset(dt.in.no15, treatment_n == i & first_n == j),
           wilcox.test(m_agg_h, br_in_c)
      )
    )
    results_c_time <- cbind(round(as.numeric(test[1]),3), round(as.numeric(test[3]),3)) 
    print(results_c_time)
  }
}

# Noncooperative BR
results_nc <- matrix(ncol = 2, nrow = 3)
for(i in 1:3){
  test <- suppressWarnings(
    with(subset(dt.in, treatment_n == i),
         wilcox.test(m_agg_h, br_in_nc)
    )
  )
  results_nc[i,] <- cbind(round(as.numeric(test[1]),3), round(as.numeric(test[3]),3)) 
}
colnames(results_nc) <- results_names
print(results_nc)


# Outsiders
dt.out <- subset(dt, type == 'Outsider')
dt.out[, agg_h := sum(h), by=.(treatment, period, group)]
dt.out[, m_agg_h := agg_h/n_out]

# Noncooperative BR
# no time
results_out <- matrix(ncol = 2, nrow = 3)
for(i in 1:3){
  test <- suppressWarnings(
    with(subset(dt.out, treatment_n == i),
         wilcox.test(m_agg_h, br_out)
    )
  )
  results_out[i,] <- cbind(round(as.numeric(test[1]),3), round(as.numeric(test[3]),3)) 
}
colnames(results_out) <- results_names
print(results_out)


# with time
dt.out.no15 <- subset(dt.out, period < 15)
for(i in 1:3){
  for(j in 1:2){
    test <- suppressWarnings(
      with(subset(dt.out.no15, treatment_n == i & first_n == j),
           wilcox.test(m_agg_h, br_out)
      )
    )
    results_out_time <- cbind(round(as.numeric(test[1]),3), round(as.numeric(test[3]),3)) 
    print(results_out_time)
  }
}

