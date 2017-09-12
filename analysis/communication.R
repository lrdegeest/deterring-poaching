library(ggplot2)
library(scales)
library(gridExtra)
library(foreign)
library(reshape2)
library(corrplot)
library(dplyr)
setwd("~/Desktop/notebook/research/dissertation/first_paper/analysis/data/")
source("~/Desktop/notebook/research/dissertation/first_paper/analysis/communication/communication_functions.R")

# load data
alldata <- load_data()
chats <- alldata$sandbox 
decisions <- data.table(read.dta("dp_data_R.dta"))
# add a chat dummy for odd periods: 1=chat, 0=no chat
decisions$chat <- with(decisions, ifelse(period %% 2 == 1, 1, 0))

## count instances a treatment talked about group 2
## apply function to sandbox
chats[, count_g2 := find_group2(text), by = .(treatment,session,period)]
chats[, count_g2_percent := round((count_g2 / messagecount)*100,2)]

# visuals with full chat data set -----------------------------------------

## message count time series
g1 <- ggplot(chats, aes(period,messagecount,group=treatment_factor,color=treatment_factor)) + 
  stat_summary(fun.y="mean", geom="line" ) + 
  xlab("Period") + ylab("Mean") + scale_color_discrete(name="") +
  scale_x_continuous(breaks=seq(1,15,2)) + 
  ggtitle("Total messages") + theme_classic()

g2 <- ggplot(chats, aes(period,count_g2,group=treatment_factor,color=treatment_factor)) + 
  stat_summary(fun.y="mean", geom="line" )+ 
  xlab("Period") + ylab("Mean") + ylab("Mean") + scale_color_discrete(name="") +
  scale_x_continuous(breaks=seq(1,15,2)) + 
  ggtitle("Messages about outsiders") + theme_classic()

### density
ggplot(chats, aes(count_g2,fill=treatment_factor)) + 
  geom_density(position="dodge",alpha=0.5) + 
  ggtitle("discussion of outsiders (density)")

# bar chart of totals -----------------------------------------------------
chats$treatment_factor <- plyr::mapvalues(chats$treatment_factor, c("1","2","3"),c("Zero", "Partial", "Full"))
g3 <- chats %>% 
  group_by(treatment_factor) %>% 
  select(messagecount) %>% 
  summarise(total = sum(unique(messagecount))) %>% 
  ggplot(., aes(treatment_factor,total, fill=treatment_factor)) + 
  geom_bar(stat="identity") + 
  xlab(" ") + ylab(" ") + 
  theme_classic() + theme(legend.position="none") + 
  ggtitle("Total messages")

g4 <- chats %>% 
  group_by(treatment_factor) %>% 
  select(count_g2) %>% 
  summarise(total = sum(unique(count_g2))) %>% 
  ggplot(., aes(treatment_factor,total, fill=treatment_factor)) + 
  geom_bar(stat="identity") + 
  xlab(" ") + ylab(" ") + 
  theme_classic() + theme(legend.position="none") + 
  ggtitle("Messages about outsiders")

g5 <- chats %>% 
  group_by(treatment_factor) %>% 
  select(messagecount, count_g2) %>% 
  summarise(total = (sum(unique(count_g2))/sum(unique(messagecount)))*100 ) %>% 
  ggplot(., aes(treatment,total)) + 
  geom_bar(stat="identity",color="black", fill=treatment_factor) + 
  xlab(" ") + ylab(" ") + 
  theme_classic() + 
  ggtitle("Messages about outsiders")

cowplot::plot_grid(g3, g4, g1, g2, labels = "AUTO", align = 'h', ncol=2, label_size = 12)

ggsave("~/Documents/DE_analysis_15/presentations/esa/images/chats.pdf", grid.arrange(g1,g2,ncol=2), width = 9, height = 4, family="serif") 

# messages and behavior ------------------------------------------
# summarize the chat data by treatment and time
chats_summary <- subset(chats, select = c("treatment","period","messagecount", "wordcount", "count_g2"))
chats_summary$treatment_factor <- plyr::mapvalues(chats$treatment, c("1","2","3"),c("Zero", "Partial", "Full"))
chats_summary <- unique(chats_summary)[, .(
  count_g2_avg = mean(count_g2)),
  by = .(treatment_factor,period)]

# summarize the decisions data set by treatment, and chat 
decisions_summary <- decisions[type=="Outsider" & chat == 0, .(
  h_avg = mean(h),
  s_avg = mean(s)),
  by=.(period, treatment)]

# remove period == 1
chats_summary <- subset(chats_summary, period > 1)
chats_summary$h_avg <- decisions_summary$h_avg
chats_summary$s_avg <- decisions_summary$s_avg
chats_summary.long <- melt(chats_summary, id=c("treatment_factor", "period"))

ggplot(chats_summary.long, aes(period, value, color=variable)) + 
  geom_line() + 
  facet_wrap(~treatment_factor)

# create merged summary data
summary <- merge(chats_summary,decisions_summary)
# correlation matrix for each treatment, using only the numeric data columns
corr_list <- list()
for(i in 1:3) corr_list[[i]] <- cor(summary[treatment == i, 3:5, with=F])
# correlation plot
for(i in 1:3) corrplot(corr_list[[i]],type="upper", diag = F)


