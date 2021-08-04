# Convert IDEAS tracks to bed file of ranges for the active states in just promoters and genic enhancers

#set_here("/Users/mary/non_dropbox/exps/exp059_snp_to_sc/")
setwd("/Users/mary/non_dropbox/exps/exp059_snp_to_sc/")
library(here)

create.IDEASv1.active.bed.promoter <- function(tissue.id){
  ideaspath <- here("data/tmp/ENCODE/IDEAS/")
  print(tissue.id)
  if (file.exists(paste0(ideaspath,tissue.id,".promoter.bed.gz"))) {	
    print("IDEAS active chromatin state file exists. Skipping awk...")
  } else {
    print("Getting active states and printing to new bed...")
    system(paste0("gunzip -c ",ideaspath,tissue.id,".ideas.states.bed.gz | awk '$4 == \"8_TssAFlnk\" || $4 == \"10_TssA\" || $4 == \"14_TssWk\" {print $0}' > ",ideaspath,tissue.id,".promoter.bed"))
    system(paste0("gzip ", ideaspath, tissue.id, ".promoter.bed"))
    }
}

create.IDEASv1.active.bed.genicenhancer <- function(tissue.id){
    ideaspath <- here("data/tmp/ENCODE/IDEAS/")
    print(tissue.id)
    if (file.exists(paste0(ideaspath,tissue.id,".genicenhancer.bed.gz"))) {
      print("IDEAS active chromatin state file exists. Skipping awk...")
    } else {
      print("Getting active states and printing to new bed...")
      system(paste0("gunzip -c ",ideaspath,tissue.id,".ideas.states.bed.gz | awk '$4 == \"6_EnhG\" || $4 == \"17_EnhGA\" {print $0}' > ",ideaspath,tissue.id,".genicenhancer.bed"))
      system(paste0("gzip ", ideaspath, tissue.id, ".genicenhancer.bed"))
    }
  }

tissues <- paste0("E",stringr::str_pad(c(1:59, 61:63, 65:129),3,pad="0"))

library(purrr)
promoter_out <- map(tissues, possibly(create.IDEASv1.active.bed.promoter, NA))
genicenhancer_out <- map(tissues, possibly(create.IDEASv1.active.bed.genicenhancer, NA))
