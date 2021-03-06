% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expressions.R
\name{which}
\alias{which}
\alias{which,CrunchLogicalExpr-method}
\title{"which" method for CrunchLogicalExpr}
\usage{
\S4method{which}{CrunchLogicalExpr}(x, arr.ind = FALSE, useNames = TRUE)
}
\arguments{
\item{x}{CrunchLogicalExpr}

\item{arr.ind}{Ignored}

\item{useNames}{Ignored}
}
\value{
Integer row indices where \code{x} is true. Note that this does not
return a Crunch expression. Use this when you need to translate to R values.
For filtering a Crunch expression by \code{x}, don't use \code{which}.
}
\description{
"which" method for CrunchLogicalExpr
}
