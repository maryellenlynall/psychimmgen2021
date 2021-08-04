
# File to get IDEAS trackhubs and name roadmap samples

# Incorporating some script from varanker for download: https://github.com/ophiothrix/varRanker/blob/6000a3fba885da48e20a96c7c91feb30ede6c9aa/lib/download.ROADMAP.data.R

# Requires the UCSC utility bigBedtoBed
# conda install -c bioconda ucsc-bigbedtobed 

# IDEASv1 = 5 marks, 127 cells 
# Track hub definitions are here: http://bx.psu.edu/~yuzhang/Roadmap_ideas/trackDb_test.txt

#### Function to download IDEAS data for a specific tissue. Takes ROADMAP tissue id ####
# Partially adapted from varranker::download.ROADMAP.data https://github.com/ophiothrix/varRanker/blob/6000a3fba885da48e20a96c7c91feb30ede6c9aa/lib/download.ROADMAP.data.R
download.IDEASv1.data <- function(tissue.id) { # E.g. tissue.id="E001"
  require(GenomicRanges)
  require(data.table)
  require(curl)
  require(RCurl)

  ### Download IDEAS chromatin states
  dir.create(here("/data/tmp/ENCODE/IDEAS"), showWarnings = F, recursive = T)
  
  ideaspath <- here("data/tmp/ENCODE/IDEAS/")
  print(tissue.id)
  
  ## If doesn't already exist, generate tissue id to url mappings
  if (file.exists(paste0(ideaspath, tissue.id, ".ideas.states.bed.gz"))) {
    print("IDEAS chromatin state file exists. Skipping download...")
  } else {
    print("Downloading and converting IDEAS chromatin states file")
    if (!file.exists(paste0(ideaspath,"ideas.table.rds"))) {	
      meta.file <- getURLContent("http://bx.psu.edu/~yuzhang/Roadmap_ideas/trackDb_test.txt")
      meta.file <- unlist(strsplit(meta.file, "\n"))
      urls <- gsub("bigDataUrl ", "", grep("bigDataUrl", meta.file, value = T))
      
      tissues <- gsub("shortLabel ", "", grep("shortLabel", meta.file, value = T))
      tissue.ids <- gsub("^(E[0-9]+).*", "\\1", tissues)
      
      # Make table of tissue IDs (e.g. E001) and corresponding urls for the bigBed files
      ideas.table <- data.frame(tissue.id = tissue.ids, url = urls, stringsAsFactors = F)
    }
    
    ### Download and convert IDEAS states for a given tissue id
    ideas.table <- readRDS(here("/data/tmp/ENCODE/IDEAS/ideas.table.rds"))
    
    curl_download(url = ideas.table$url[ideas.table$tissue.id == tissue.id], destfile = paste0(here("data/tmp/ENCODE/IDEAS/"), tissue.id, ".ideas.states.bb"), quiet = F)
    ## Convert bigBed to bed file using UCSC tool compiled for the appropriate tissue
    ucsc.path <- "/Users/mary/anaconda3/envs/mypython3/bin/"
    #system(paste0(ucsc.path, "/bigBedToBed ./cache/ENCODE/IDEAS/", tissue.id, ".ideas.states.bb ./cache/ENCODE/IDEAS/", tissue.id, ".ideas.states.bed"))
    system(paste0(ucsc.path, "bigBedToBed ", ideaspath, tissue.id, ".ideas.states.bb ", ideaspath, tissue.id, ".ideas.states.bed"))
    # Compress
    system(paste0("gzip ", ideaspath, tissue.id, ".ideas.states.bed"))
    file.remove(paste0(ideaspath, tissue.id, ".ideas.states.bb"))
  } 
}

# Now get all the v1 IDEAS using the function above
# E001 to E127
library(here)
# NB. TISSUES ARE NOT JUST E001-E127 (goes to E129 as 60 and 64 are missing!)
tissues <- paste0("E",stringr::str_pad(c(1:59, 61:63, 65:129),3,pad="0"))
ideasv1run <- purrr::map(tissues, purrr::possibly(download.IDEASv1.data, NA))
table(unlist(ideasv1run)) 

# Generate improved metadata
roadmap_names <- read.delim(here("data/raw/roadmap/roadmap_sample_info.txt"), sep="\t", header=T)
unique(roadmap_names$group_name)
roadmap_names$group_name 

roadmap_names %>% dplyr::filter(group_name=="ENCODE2012")
roadmap_names$group <- roadmap_names$group_name 
roadmap_names$group[roadmap_names$group %in% c("Blood & T-cell", "HSC & B-cell")] <- "Immune"
roadmap_names$group[roadmap_names$group %in% c("Sm. Muscle", "Muscle")] <- "Muscle"

View(roadmap_names %>% dplyr::select(mnemonic, name, group))

roadmap_names$type <- str_extract(roadmap_names$mnemonic, "[^.]+")
roadmap_names$type <- factor(roadmap_names$type, levels=c(roadmap_names$type %>% unique %>% sort), ordered=T)

roadmap_names$type_mini <- as.character(roadmap_names$type)
roadmap_names$type_mini[roadmap_names$type %in% c("CRVX","OVRY","PLCNT","BRST")] <- "Reproductive system"
roadmap_names$type_mini[roadmap_names$type %in% c("HRT","VAS")] <- "Heart/vasculature"
roadmap_names$type_mini[roadmap_names$type %in% c("BLD","THYM","SPLN")] <- "Blood/immune"
roadmap_names$type_mini[roadmap_names$type %in% c("SKIN")] <- "Skin"
roadmap_names$type_mini[roadmap_names$type %in% c("BRN")] <- "Brain"
roadmap_names$type_mini[roadmap_names$type %in% c("MUS")] <- "Muscle"
roadmap_names$type_mini[roadmap_names$type %in% c("GI")] <- "Gastrointestinal"
roadmap_names$type_mini[roadmap_names$type %in% c("STRM")] <- "Stromal"
roadmap_names$type_mini[roadmap_names$type %in% c("ESC","ESDR","IPSC")] <- "IPSC / ESC / ESC-derived"
roadmap_names$type_mini[roadmap_names$type %in% c("ESC","ESDR")] <- "IPSC / ESC / ESC-derived"
roadmap_names$type_mini[roadmap_names$type %in% c("FAT")] <- "Fat"
roadmap_names$type_mini[roadmap_names$type %in% c("LNG","PANC","LIV","KID","ADRL","BONE")] <- "Other solid organ"

roadmap_names %>% select(name, type, type_mini)

# Now solve the problem that E038 and E039 have been given the same long name. "Primary T helper naive cells from peripheral blood"
roadmap_names$name[roadmap_names$EID=="E038"] <- "Primary T helper naive cells from peripheral blood 2"
roadmap_names$name[roadmap_names$EID=="E039"] <-  "Primary T helper naive cells from peripheral blood 1" 

save(roadmap_names, file = here("data/raw/roadmap/roadmap_sample_info_tidy.Rdata"))


