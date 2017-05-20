library(ggplot2)
library(reshape2)
setwd("~/Desktop/notebook/research/dissertation/first_paper/analysis/data")
df <- read.csv("qs_type.csv")
df <- df[c(1,3,2,4,5,6)]
df.types <- data.frame(apply(df[,3:6], 2, as.numeric))
df <- cbind(df[c(1:2)], df.types)

types <- c("fair", "fate", "trust")

df.long <- melt(df, id=c("treatment"))

df.long.types <- subset(df.long, variable %in% types)
df.long.types$value <- as.numeric(df.long.types$value)

ggplot(df.long.types, aes(value, fill=variable)) + 
  geom_histogram() + 
  facet_grid(variable~treatment)


