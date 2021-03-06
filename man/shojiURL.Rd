% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shoji.R
\name{shojiURL}
\alias{shojiURL}
\title{Get a resource URL from a Shoji Object}
\usage{
shojiURL(
  x,
  collection = c("catalogs", "views", "fragments", "orders"),
  key,
  mustWork = TRUE
)
}
\arguments{
\item{x}{a shojiObject}

\item{collection}{one of c("catalogs", "views", "fragments", "orders")}

\item{key}{character name of the URL to get from \code{collection}}

\item{mustWork}{logical: error if the URL is not found? Default is \code{TRUE}}
}
\value{
The indicated URL, or if it does not exist and \code{mustWork} is not
\code{TRUE}, \code{NULL}.
}
\description{
Get a resource URL from a Shoji Object
}
\keyword{internal}
