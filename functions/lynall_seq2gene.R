# Modification of ChIPseeker::seq2gene to add information on which peaks correspond to which genes + distance to TSS in the output

lynall_seq2gene <- function (seq, tssRegion, flankDistance, TxDb, sameStrand = FALSE) 
{
  
  ChIPseeker:::.ChIPseekerEnv(TxDb)
  ChIPseekerEnv <- get("ChIPseekerEnv", envir = .GlobalEnv)
  
  # EXONS
  if (exists("exonList", envir = ChIPseekerEnv, inherits = FALSE)) {
    exonList <- get("exonList", envir = ChIPseekerEnv)
  } else {
    exonList <- exonsBy(TxDb)
    assign("exonList", exonList, envir = ChIPseekerEnv)
  }
  exons <- ChIPseeker:::getGenomicAnnotation.internal(seq, exonList, type = "Exon", 
                                         sameStrand = sameStrand)

  if (!is.na(exons)){
    exons$gene <- gsub("ENST[0-9]+/","",exons$gene)
    exons$overlap_type <- rep("overlaps_exon", length(exons$queryIndex))
    exons$peak_location <- paste0(as.character(seqnames(seq)),"_",start(seq),"_",end(seq))[exons$queryIndex]
  } else {
    exons = data.frame(peak_location=character(),gene=character(),annotation=character(),overlap_type=character())
  }

  if (exists("intronList", envir = ChIPseekerEnv, inherits = FALSE)) {
    intronList <- get("intronList", envir = ChIPseekerEnv)
  } else {
    intronList <- intronsByTranscript(TxDb)
    assign("intronList", intronList, envir = ChIPseekerEnv)
  }
  introns <- ChIPseeker:::getGenomicAnnotation.internal(seq, intronList, 
                                           type = "Intron", sameStrand = sameStrand)

  if (!is.na(introns)){
    introns$gene <- gsub("ENST[0-9]+/","",introns$gene)
    introns$overlap_type <- rep("overlaps_intron", length(introns$queryIndex))
    introns$peak_location <- paste0(as.character(seqnames(seq)),"_",start(seq),"_",end(seq))[introns$queryIndex]
  } else {
    introns = data.frame(peak_location=character(),gene=character(),annotation=character(),overlap_type=character())
  }

  features <- ChIPseeker:::getGene(TxDb, by = "gene")
  
  idx.dist <- ChIPseeker:::getNearestFeatureIndicesAndDistances(seq, features, 
                                                   sameStrand = sameStrand)
  idx.dist$peak_location <- paste0(as.character(seqnames(idx.dist$peak)),"_",start(idx.dist$peak),"_",end(idx.dist$peak))
  idx.dist$gene <- features[idx.dist$index]$gene_id
  idx.dist$gene_biotype <- features[idx.dist$index]$gene_biotype
  idx.dist$gene_name <- features[idx.dist$index]$gene_name
  
  nearestFeatures <- features[idx.dist$index]
  distance <- idx.dist$distance
  pi <- distance > tssRegion[1] & distance < tssRegion[2]
  
  promoters <- mcols(nearestFeatures[pi])[["gene_id"]]
  nearest_genes <- mcols(nearestFeatures[!pi][abs(distance[!pi]) < 
                                                flankDistance])[["gene_id"]]
  
  idx.dist$overlap_type <- ifelse(pi, "overlaps_promoter", 
                                  ifelse(abs(distance)<flankDistance, "within_flank", NA))
  
  genes <- c(exons$gene, introns$gene, promoters, nearest_genes)
  df <- bind_rows(
    as.data.frame(exons) %>% dplyr::select(peak_location,gene,annotation,overlap_type),
    as.data.frame(introns) %>% dplyr::select(peak_location,gene,annotation,overlap_type),
    as.data.frame(idx.dist) %>% dplyr::filter(!is.na(overlap_type)) %>% dplyr::select(peak_location,gene,overlap_type, distance)
  ) %>% dplyr::arrange(peak_location)
  
  df$symbol <- AnnotationDbi::mapIds(org.Hs.eg.db,
                              keys=df$gene,
                              column="SYMBOL",
                              keytype="ENSEMBL",
                              multiVals="first")
  df %>% dplyr::filter(is.na(symbol))
  
  print(sprintf("%d unique genes identified",length(unique(genes))))
  return(list(unique_genes=unique(genes), full_dataframe=df))
}
