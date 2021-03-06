\name{get.fisher.c}
\alias{get.fisher.c}
\title{
Goodness-of-fit for piecewise SEM.
}
\description{
Evaluates independence claims for a piecewise structural equation model (SEM), and calculates Fisher's C and associated p-value to evaluate model fit.
}
\usage{
get.fisher.c(modelList, data, corr.errors = NULL, 
add.vars = NULL,grouping.var = NULL, 
top.level.vars = NULL, adjust.p = FALSE, 
basis.set = NULL, pvalues.df = NULL, 
disp.conditional = FALSE, model.control = NULL,
.progressBar = TRUE)
}
\arguments{
  \item{modelList}{
A \code{list} of regressions representing the structural equation model. 
}
\item{data}{
A \code{data.frame} used to construct the structured equations.
}
  \item{corr.errors}{
A vector of variables with correlated errors (separated by "~~").
}
  \item{add.vars}{
A vector of additional variables whose independence claims should be evaluated, but which do not appear in the model list.
}
\item{grouping.var}{
An optional variable that represents the highest level of a hierarchical dataset.
}
\item{top.level.vars}{
An optional \code{vector} of variables that are identical at the highest level of the hierarchy.
}
  \item{adjust.p}{
Whether p-values degrees of freedom should be adjusted.
}
  \item{basis.set}{
Provide an optional basis set.
}
  \item{pvalues.df}{
An optional \code{data.frame} corresponding to p-values for independence claims.
}
  \item{disp.conditional}{
Display conditional variables in reporting d-sep test results.
}
  \item{model.control}{
A \code{list} of model control arguments to be passed to d-sep models.
}
  \item{.progressBar}{
Enable optional text progress bar.
}
}
\details{
}
\value{
Returns a vector with the first entry corresponding to Fisher's C statistic, and the second corresponding to the associated p-value (derived from a Chi-squared distribution). 
}
\references{
Shipley, Bill. "Confirmatory path analysis in a generalized multilevel context." Ecology 90.2 (2009): 363-368.
}
\author{
Jon Lefcheck
}
\note{
}
\seealso{
}
\examples{
# Fit model from Shipley (2009)
data(shipley2009) 

# Load model packages
library(lmerTest)
library(nlme)

# Create list of models 
shipley2009.modlist = list(
  lme(DD~lat, random = ~1|site/tree, na.action = na.omit, 
  data = shipley2009),
  lme(Date~DD, random = ~1|site/tree, na.action = na.omit, 
  data = shipley2009),
  lme(Growth~Date, random = ~1|site/tree, na.action = na.omit, 
  data = shipley2009),
  glmer(Live~Growth+(1|site)+(1|tree), 
  family=binomial(link = "logit"), data = shipley2009) )

# Get goodness-of-fit statistics
get.fisher.c(shipley2009.modlist, shipley2009)
}