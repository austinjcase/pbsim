% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/internal_functions.R
\name{recombine_hypred}
\alias{recombine_hypred}
\title{Simulate recombination using hypred}
\usage{
recombine_hypred(genome, haploids, mutate = FALSE, mutation.rate.snp = 0,
  mutation.rate.qtl = 0)
}
\arguments{
\item{genome}{An object of class \code{genome}.}

\item{haploids}{A list of length \code{n.chr}, the elements of which are matrices
of dimensions 2 x \code{n.loci} giving the haploid genotypes for a single individual
for a single chromosome.}

\item{mutate}{A logical as to generate random mutations when recombining.}

\item{mutation.rate.snp}{The per-base mutation rate of the SNPs.}

\item{mutation.rate.qtl}{The per-base mutation rate of the QTL.}
}
\value{
A list of recombined haploid gametes (of class \code{matrix}) per chromosome.
}
\description{
Internal function. Not generally to be called by the user.
}
