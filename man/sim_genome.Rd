% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sim_genome.R
\name{sim_genome}
\alias{sim_genome}
\title{Create a simulated genome}
\usage{
sim_genome(len, n.mar, map, eq.spacing = FALSE, type = c("pbsim", "hypred"))
}
\arguments{
\item{len}{A vector specifying the chromosome lengths (in cM).}

\item{n.mar}{A vector specifying the umber of markers per chromosome.}

\item{map}{A list of marker positions (in cM), where each list element is a
named vector of marker positions. If \code{NULL} (default), marker positions
are drawn from a uniform distribution. See \code{\link[qtl]{sim.map}} for more
information.}

\item{eq.spacing}{If TRUE, markers will be equally spaced. See \code{\link[qtl]{sim.map}}.}

\item{type}{The type of genome output. If \code{"pbsim"}, the genome will include a 
map that is compatible with \code{\link[qtl]{qtl-package}}, and if \code{"hypred"},
the genome will be a list of genomes compatible with \code{\link[hypred]{hypred}}.}
}
\value{
Object of class "genome" with the length of each chromosome, the number of
markers per chromosome, and the genetic map.
}
\description{
Creates a list containing information on a simulated genome
}
\examples{
n.mar  <- c(505, 505, 505)
len <- c(120, 130, 140)

genome <- sim_genome(len, n.mar)

# Use a map instead
data("s2_snp_info")
map <- lapply(split(s2_snp_info, s2_snp_info$chrom), function(chr) structure(chr$cM_pos, names = chr$rs) )

genome <- sim_genome(map = map)

# Use 'hypred'
genome <- sim_genome(map = map, type = "hypred")

}
