% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prediction.R
\name{pred_mar_eff}
\alias{pred_mar_eff}
\title{Predict marker effects in a training population#'}
\usage{
pred_mar_eff(genome, training.pop, method = "RRBLUP")
}
\arguments{
\item{genome}{An object of class \code{genome}.}

\item{training.pop}{An object of class \code{pop} with the elements \code{geno} and 
\code{pheno_val}. This is used as the training population.}

\item{method}{The statistical method to predict marker effects. Currently only
\code{"RRBLUP"} is supported.}
}
\value{
The \code{training.pop} with predicted marker effects.
}
\description{
Predict marker effects in a training population#'
}
\details{
The \code{training.pop} must have phenotypic values associated with each entry.
The mean phenotype is used as training data in the model. Genotypic data (excluding
QTL) are used to predict marker effects.

When solving the mixed model, if \code{method = "RRBLUP"}, marker effects are
predicted by REML.
}
\examples{

# Simulate a genome
n.mar  <- c(505, 505, 505)
len <- c(120, 130, 140)

genome <- sim_genome(len, n.mar)

# Simulate a quantitative trait influenced by 50 QTL
qtl.model <- matrix(NA, 50, 4)
genome <- sim_gen_model(genome = genome, qtl.model = qtl.model, 
                        add.dist = "geometric", max.qtl = 50)

# Simulate the genotypes of eight founders
founder_pop <- sim_founders(genome, n.str = 8)
founder_pop <- sim_phenoval(pop = founder_pop, h2 = 0.5)

ped <- sim_pedigree(n.ind = 100, n.selfgen = 2)

# Extract the founder names
parents <- indnames(founder_pop)

# Generate a crossing block with 5 crosses
cb <- sim_crossing_block(parents = parents, n.crosses = 5)

# Simulate the populations according to the crossing block
pop <- sim_family_cb(genome = genome, pedigree = ped, founder_pop = founder_pop, 
                     crossing_block = cb)
                     
# Use the founders as a training population for the progeny
# Predict marker effects
training.pop <- pred_mar_eff(genome = genome, training.pop = founder_pop)
                     
}
