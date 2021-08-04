
# Make nongenic enhancers annotation bed file

setwd("/Users/mary/non_dropbox/exps/exp059_snp_to_sc/")
library(here)

# Function to choose a single IDEAS annotation to make a bed file for
create.IDEASv1.active.bed.singleannotation <- function(tissue.id, annotation){
  ideaspath <- here("data/tmp/ENCODE/IDEAS/")
  print(tissue.id)
  print(annotation)
  if (file.exists(paste0(ideaspath,tissue.id,".",annotation,".bed.gz"))) {	
    print("IDEAS active chromatin state file exists. Skipping awk...")
  } else {
    print("Getting state and printing to new bed...")
    system(paste0("gunzip -c ",ideaspath,tissue.id,".ideas.states.bed.gz | awk '$4 == \"",annotation,"\" {print $0}' > ",ideaspath,tissue.id,".",annotation,".bed"))
    system(paste0("gzip ", ideaspath, tissue.id,".",annotation,".bed"))
    }
}

tissues <- paste0("E",stringr::str_pad(c(1:59, 61:63, 65:129),3,pad="0"))
annotations <- c("4_Enh")

library(purrr)
for (i in annotations){
  ideasv1run <- purrr::map(tissues, possibly(create.IDEASv1.active.bed.singleannotation, NA),i)
}


