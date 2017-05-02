#' Extract the number of markers in the genome
#' 
#' @param genome An object of class \code{genome}.
#' @param by.chr Logical. Should the number of markers per chromosome be returned?
#' 
#' @return 
#' If \code{by.chr = TRUE}, a vector of markers per chromosomes. If \code{by.chr = FALSE},
#' a scalar of the total number of markers.
#' 
#' @import qtl
#' 
#' @export
#' 
nmar <- function(genome, by.chr = FALSE) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Create an empty cross object
  blank_cross <- qtl::sim.cross(map = genome$map, n.ind = 1)
  
  # Number of markers
  n_marker <- qtl::nmar(blank_cross)
  
  # If by.chr is true, give results by chromosome. If not, sum
  if (by.chr) {
    return(n_marker)
  } else{
    return(sum(n_marker))
  }
  
} # Close the function


#' Extract marker names
#' 
#' @param genome An object of class \code{genome}.
#' @param chr See \code{\link[qtl]{markernames}}.
#' @param include.qtl Logical. Should the names of QTL be returned?
#' 
#' @return 
#' A vector of character strings (the marker names).
#' 
#' @importFrom qtl sim.cross
#' @importFrom qtl markernames
#' @importFrom qtl chrnames
#' 
#' @export
#' 
markernames <- function(genome, chr, include.qtl = FALSE) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Create an empty cross object
  blank_cross <- qtl::sim.cross(map = genome$map, n.ind = 1)
  
  # If chr is missing, assume all chromosomes
  if (missing(chr)) {
    chr <- qtl::chrnames(blank_cross)
  }
  
  if (!include.qtl) {
    # Get marker names and return
    qtl::markernames(cross = blank_cross, chr = chr)
  
  } else {
    # Otherwise grab the names from the map
    locinames <- lapply(genome$map, names)
    # What chromosomes to return?
    structure(unlist(locinames[chr]), names = NULL)
    
  }
  
} # Close function
  

#' Extract the number of chromosomes in the genome
#' 
#' @param genome An object of class \code{genome}.
#' 
#' @return 
#' A scalar of the total number of chromosomes.
#' 
#' @importFrom qtl nchr
#' 
#' @export
#' 
nchr <- function(genome) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Extract and return chromosomes
  qtl::nchr(genome$map)
  
} # Close the function


#' Extract chromosome names
#' 
#' @param genome An object of class \code{genome}.
#' 
#' @return 
#' A vector of character strings (the chromosome names).
#' 
#' @importFrom qtl sim.cross
#' @importFrom qtl chrnames
#' 
#' @export
#' 
chrnames <- function(genome, chr) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Create an empty cross object
  blank_cross <- qtl::sim.cross(map = genome$map, n.ind = 1)
  
  qtl::chrnames(blank_cross)
  
} # Close function

#' Extract the QTL from a genome
#' 
#' @param genome An object of class \code{genome}.
#' @param unique Logical. Should information of only the unique QTL be returned?
#' 
#' @import dplyr
#' 
#' @export
#' 
pull_qtl <- function(genome, unique = TRUE) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Make sure there is a genetic model
  if (is.null(genome$gen_model))
    stop("No genetic model has been declared for the genome")
  
  # Unique qtl
  all_qtl <- genome$gen_model %>% 
    mapply(seq_along(.), FUN = function(qtlmod, traitn) 
      mutate(qtlmod, trait = traitn), SIMPLIFY = FALSE) %>%
    bind_rows() %>% 
    mutate(chr = factor(chr, levels = seq_along(genome$map)))
  
  if (unique) {
    return(distinct(all_qtl, chr, pos, .keep_all = TRUE))
  } else {
    return(all_qtl)
  }
  
} # Close the function

#' Extract the number of QTL in the genome
#' 
#' @param genome An object of class \code{genome}.
#' @param by.chr Logical. Should the number of QTL per chromosome be returned?
#' 
#' @details
#' Only unique QTL are counted. That is, pleiotropic QTL only count once.
#' 
#' @return 
#' If \code{by.chr = TRUE}, a vector of the QTL per chromosomes. If 
#' \code{by.chr = FALSE}, a scalar of the total number of QTL.
#' 
#' @import dplyr
#' 
#' @export
#' 
nqtl <- function(genome, by.chr = FALSE) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Make sure there is a genetic model
  if (is.null(genome$gen_model))
    stop("No genetic model has been declared for the genome")
  
  # Number of unique qtl per chromosome
  qtl_unique <- pull_qtl(genome = genome)
  
  qtl_count <- structure(table(qtl_unique$chr), names = names(genome$map))

  # If by.chr is true, give results by chromosome. If not, sum
  if (by.chr) {
    return(qtl_count)
  } else{
    return(sum(qtl_count))
  }
  
} # Close the function


#' Extract the pleiotropic QTL from the genome
#' 
#' @param genome An object of class \code{genome}.
#' 
#' @return 
#' A \code{data.frame} of the pleiotropic QTL per trait.
#'  
#' @import dplyr
#' 
#' @export
#' 
pull_plei_qtl <- function(genome) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Make sure there is a genetic model
  if (is.null(genome$gen_model))
    stop("No genetic model has been declared for the genome")
  
  # Combind genetic models for traits
  all_mods <- lapply(seq_along(genome$gen_model), FUN = function(i) 
    genome$gen_model[[i]] %>% mutate(trait = i) ) %>%
    bind_rows() %>%
    select(trait, chr:dom_eff)

  # Find duplications by finding the pairwise union
  dup_mod <- duplicated(subset(all_mods, select = c(chr, pos))) | 
    duplicated(subset(all_mods, select = c(chr, pos)), fromLast = TRUE)
  
  all_mods %>% 
    slice(which(dup_mod))
  
} # Close the function


#' Extract the perfect markers from the genome
#' 
#' @description 
#' Extract SNP markers that are also QTL
#' 
#' @param genome An object of class \code{genome}.
#' @param by.chr Logical. Should the number of perfect markers per chromosome be returned?
#' 
#' @return 
#' A \code{list} of the perfect QTL.
#' 
#' @examples
#' n.mar  <- c(3, 3, 3)
#' len <- c(120, 130, 140)
#' 
#' map <- lapply(X = seq(3), FUN = function(i) 
#'   structure(c(20, 50, 80), names = paste("C", i, "M", seq(3), sep = "")))
#' 
#' genome <- sim_genome(len, n.mar, map)
#' 
#' # Simulate genetic architecture with one perfect marker per chromosome
#' chromosome <- seq(3)
#' pos <- rep(50, 3)
#' a <- rep(1, 3)
#' d <- 0
#' 
#' qtl.model <- cbind(chromosome, pos, a, d)
#' 
#' genome <- sim_gen_model(genome, qtl.model)
#'  
#' @import dplyr
#' 
#' @export
#' 
pull_perf_mar <- function(genome, by.chr = FALSE) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Make sure there is a genetic model
  if (is.null(genome$gen_model))
    stop("No genetic model has been declared for the genome")
  
  # Pull out the unique QTL
  unique_qtl <- pull_qtl(genome = genome, unique = TRUE)
  
  qtl_ann <- unique_qtl %>% 
    rowwise() %>% 
    mutate(perf_mar = list(genome$map[[chr]] %in% pos)) %>%
    mutate(perf_mar = ifelse(any(perf_mar), names(genome$map[[chr]])[which(perf_mar)], NA)) %>%
    as.data.frame()
  
  # Reduce
  perf_count <- qtl_ann %>% 
    filter(!is.na(perf_mar))
    
  # Split by chromsome?
  if (by.chr) {
    split(perf_count, perf_count$chr)
  } else {
    return(perf_count)
  }
  
} # Close the function


#' Extract the total number of loci in the genome
#' 
#' @description 
#' Calculate the total number of loci (markers + QTL)
#' 
#' @param genome An object of class \code{genome}.
#' @param by.chr Logical. Should the number of loci per chromosome be returned?
#' 
#' 
nloci <- function(genome, by.chr = FALSE) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Number of markers
  n_marker <- nmar(genome = genome, by.chr = by.chr)
  
  # Number of unique QTL
  n_qtl <- nqtl(genome = genome, by.chr = by.chr)
  
  # Number of perfect markers
  perf_mar <- pull_perf_mar(genome = genome, by.chr = FALSE) %>%
    filter(!startsWith(perf_mar, "QTL"))
  nperf_mar <- table(perf_mar$chr)
  # Sum if prompted
  if (!by.chr)
    nperf_mar <- sum(nperf_mar)
  
  # Total number of loci is n_marker + n_qtl - nperf_mar
  n_loci <- n_marker + n_qtl - nperf_mar
  return(n_loci)
  
} # Close the function



#' Find the position of markers in the genome
#' 
#' @param genome An object of class \code{genome}.
#' @param chr See \code{\link[qtl]{find.markerpos}}.
#' 
#' @importFrom qtl sim.cross
#' @importFrom qtl find.markerpos
#' 
#' @export
#' 
find_markerpos <- function(genome, marker) {
  
  # Make sure genome inherits the class "genome."
  if (!inherits(genome, "genome"))
    stop("The input 'genome' must be of class 'genome.'")
  
  # Create a blank cross object
  blank_cross <- sim.cross(map = genome$map, n.ind = 1)
  
  # Return marker position
  qtl::find.markerpos(cross = blank_cross, marker = marker)
  
} # Close the function
  
  
  
  