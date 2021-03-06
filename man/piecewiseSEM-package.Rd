\name{piecewiseSEM-package}
\alias{piecewiseSEM-package}
\alias{piecewiseSEM}
\docType{package}
\title{
Piecewise Structural Equation Modeling
}
\description{
Implements goodness-of-fit tests and coefficient extraction for piecewise structural equation modeling. Compared with traditional variance-covariance based SEM, piecewise SEM allows for fitting of models to different distributions and/or incorporates hierarchical/nested random structures.

Supported model classes include: \code{lm}, \code{glm}, \code{glm.nb}, \code{lme}, \code{glmmPQL}, \code{lmerMod}, and \code{merModLmerTest}.
}
\details{
\tabular{ll}{
Package: \tab piecewiseSEM\cr
Type: \tab Package\cr
Version: \tab 0.4.1\cr
Date: \tab 2014-11-20\cr
Depends: \tab R (>=3.1.0), ggm, lavaan, lmerTest\cr
Suggests: \tab MASS, lmerTest, nlme\cr
License: \tab MIT\cr
}
The primary functions in the package are \code{\link{get.sem.fit}} which performs goodness-of-fit tests, and \code{\link{get.sem.coefs}} which returns (standardized) path coefficients and standard errors.
}
\section{Warning}{
\strong{This package is still in beta!}
}
\author{
Jon Lefcheck <jslefche@vims.edu>
}
\references{
Shipley, Bill. "A new inferential test for path models based on directed acyclic graphs." Structural Equation Modeling 7.2 (2000): 206-218.

Shipley, Bill. Cause and correlation in biology: a user's guide to path analysis, structural equations and causal inference. Cambridge University Press, 2002.

Shipley, Bill. "Confirmatory path analysis in a generalized multilevel context." Ecology 90.2 (2009): 363-368.

Shipley, Bill. "The AIC model selection method applied to path analytic models compared using a d-separation test." Ecology 94.3 (2013): 560-564.
}
\keyword{ package }
\seealso{
\code{\link{shipley.test}}
\code{\link{get.sem.coefs}}
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

# Get goodness-of-fit and AIC
get.sem.fit(shipley2009.modlist, shipley2009)

# Get path coefficients
get.sem.coefs(shipley2009.modlist, shipley2009)

# Get variance-covariance SEM (calls on package::lavaan)
summary(get.lavaan.sem(shipley2009.modlist, shipley2009))

}