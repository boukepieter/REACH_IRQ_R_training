install.packages("devtools")
install.packages("knitr")
install.packages("dplyr")
install.packages("readxl")
devtools::install_github(
  "mabafaba/hypegrammaR", 
  ref = "master", 
  build_vignettes = TRUE
)
library(readxl)
library(hypegrammaR)
library(dplyr)

# step 1: Read in dataset (https://www.reachresourcecentre.info/country/iraq/cycle/651/?toip-group=data&toip=dataset-database#cycle-651)
mcna <- read_excel("input/awg_irq_dataset_mcna_vii_september2019_public.xlsx", sheet=4)

# step 2: Recoding your indicator(s)
mcna$fes <- mcna$food_exp / mcna$tot_expenditure

# step 3: define weighting function (simplified with weights column)
weight_fun<-function(df){
 df$weights
}

# step 4: prepare and read in the data analysis plan
analysisplan <- read.csv("input/dap_fes.csv", stringsAsFactors = F)

# step 5: run the analysis
result <- from_analysisplan_map_to_output(mcna, analysisplan = analysisplan,
                                          weighting = weight_fun, confidence_level = 0.9)

# step 6: postprocess result to get all the results in one table
summary <- bind_rows(lapply(result[[1]], function(x){x$summary.statistic}))
write.csv(summary, "output/fes.csv")

















name <- "msni_20190925_with_sub_pillars"
saveRDS(result,paste(sprintf("output/result_%s.RDS", name)))
#summary[which(summary$dependent.var == "g51a"),]

lookup_in_camp<-load_samplingframe("./input/sampling_frame_in_camp.csv")
names(lookup_in_camp)[which(names(lookup_in_camp) == "camp")] <- "name"
names(lookup_in_camp)[which(names(lookup_in_camp) == "camp.long.name")] <- "english"
names(lookup_in_camp)[which(names(lookup_in_camp) == "governorate")] <- "filter"

summary <- bind_rows(lapply(result[[1]], function(x){x$summary.statistic}))
write.csv(summary, sprintf("output/raw_results_%s.csv", name), row.names=F)
summary <- read.csv(sprintf("output/raw_results_%s.csv", name), stringsAsFactors = F)
summary <- correct.zeroes(summary)
summary <- summary %>% filter(dependent.var.value %in% c(NA,1))
write.csv(summary, sprintf("output/raw_results_%s_filtered.csv", name), row.names=F)
if(all(is.na(summary$independent.var.value))){summary$independent.var.value <- "all"}
groups <- unique(summary$independent.var.value)
groups <- groups[!is.na(groups)]
for (i in 1:length(groups)) {
  df <- pretty.output(summary, groups[i], analysisplan, cluster_lookup_table, lookup_table, severity = name == "severity", camp = F)
  write.csv(df, sprintf("output/summary_sorted_%s_%s.csv", name, groups[i]), row.names = F)
  if(i == 1){
    write.xlsx(df, file=sprintf("output/summary_sorted_%s.xlsx", name), sheetName=groups[i], row.names=FALSE)
  } else {
    write.xlsx(df, file=sprintf("output/summary_sorted_%s.xlsx", name), sheetName=groups[i], append=TRUE, row.names=FALSE)
  }
}

