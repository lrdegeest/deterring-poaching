clean_data <- function(treatmentString,sessionNumber){
  "
  Function that loads and cleans a chat data set based on a treatment string and session number
  "
  data <- paste0("chatlogs_",treatmentString,sessionNumber,".csv")
  dt <- data.table(read.csv(data, na.strings = c("", "NA")))
  dt <- na.omit(dt)
  setnames(dt, c("groupID", "text"))
  dt[, period := cumsum(grepl("G+", groupID))]
  dt[, period := ifelse(period > 1, period + (period - 1), period)]
  dt[,groupID:=droplevels(groupID)]
  dt <- dt[grepl("G+",groupID)==F]
  dt[, messagecount := .N, by = period]
  dt[, wordcount := sapply(strsplit(as.character(text), "\\S+"), length)]
  dt[, treatment := ifelse(treatmentString=="z",1,
                           ifelse(treatmentString=="p",2,
                                  ifelse(treatmentString=="f",3,
                                         NULL)))]
  dt[,treatment_factor := as.factor(treatment)]
  dt[, session := sessionNumber]
  setcolorder(dt, c("treatment", "treatment_factor", "session","period","groupID","text","messagecount","wordcount"))
  setkey(dt,treatment,session,period)
  return(dt)
}

load_data <- function(){
  "
  Loads and cleans chat logs as data frames per treatment and stores in a list,
  then creates a sandbox data frame with each treatment for analysis 
  "
  require(data.table)
  alldata <- list()
  for(i in c("z","p","f")) alldata[[i]] <- rbind(clean_data(i,1),clean_data(i,2))
  alldata[["sandbox"]] <- with(alldata, rbind(z,p,f))
  return(alldata)
}

find_group2 <- function(string_vector){
  "
  Take a vector of strings, match them to the pattern and extract, then rematch and count
  "
  pattern1 <- paste("12","22","21","25", sep="|")
  temp_text <-  gsub(pattern1,"",string_vector, ignore.case = T);
  pattern2 <-paste("2", "two","they","they've","unfair","fair", sep = "|");
  count_g2_true <- grepl(pattern2, temp_text, ignore.case = T);
  count_g2 <- sum(count_g2_true);
  return(count_g2)
}
