devtools::install_github("mabafaba/mergekobodata", build_opts=c())
library(mergekobodata)

merge_kobo_data("excercise_data/household_parts",
                        output_file = "output/households.csv")
hh_part1 <- read.csv("excercise_data/household_parts/hh_part1.csv")
hh_part2 <- read.csv("excercise_data/household_parts/hh_part2.csv")
households <- read.csv("output/households.csv")

devtools::install_github("mabafaba/koboloops", build_opts=c())
library(koboloops)

individual <- read.csv("excercise_data/individual.csv", stringsAsFactors = F)
merged <- add_parent_to_loop(individual, households, uuid.name.loop = "X_submission__uuid", 
                             uuid.name.parent = "X_uuid")
