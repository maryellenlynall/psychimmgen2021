# Convert IDEAS tracks to bed file of ranges for the active states

library(here)

create.IDEASv1.active.bed <- function(tissue.id){
  ideaspath <- here("data/tmp/ENCODE/IDEAS/")
  print(tissue.id)
  if (file.exists(paste0(ideaspath,tissue.id,".active.bed.gz"))) {	
    print("IDEAS active chromatin state file exists. Skipping awk...")
  } else {
    print("Getting active states and printing to new bed...")
    system(paste0("gunzip -c ",ideaspath,tissue.id,".ideas.states.bed.gz | awk '$4 == \"4_Enh\" || $4 == \"6_EnhG\" || $4 == \"8_TssAFlnk\" || $4 == \"10_TssA\" || $4 == \"14_TssWk\" || $4 == \"17_EnhGA\" {print $0}' > ",ideaspath,tissue.id,".active.bed"))
    system(paste0("gzip ", ideaspath, tissue.id, ".active.bed"))
    }
}

tissues <- paste0("E",stringr::str_pad(c(1:59, 61:63, 65:129),3,pad="0"))

library(purrr)
ideasv1run <- map(tissues, possibly(create.IDEASv1.active.bed, NA))
