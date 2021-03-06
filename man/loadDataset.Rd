% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get-datasets.R
\name{loadDataset}
\alias{loadDataset}
\title{Load a Crunch Dataset}
\usage{
loadDataset(
  dataset,
  kind = c("active", "all", "archived"),
  project = NULL,
  refresh = FALSE
)
}
\arguments{
\item{dataset}{character, the name or path to a Crunch dataset to load, or a
dataset URL. If \code{dataset} is a path to a dataset in a project, the path will
be be parsed and walked, relative to \code{project} if specified, and the
function will look for the dataset inside that project. If no path is
specified and no \code{project} provided, the function will call a search API to
do an exact string match on dataset names.}

\item{kind}{character specifying whether to look in active, archived, or all
datasets. Default is "active", i.e. non-archived.}

\item{project}{\code{ProjectFolder} entity, character name (path) to a project, or
\code{NULL}, the default. If a Project entity or reference is supplied, either
here or as a path in \code{dataset}, the dataset lookup will be limited to that
project only.}

\item{refresh}{logical: should the function check the Crunch API for new
datasets? Default is \code{FALSE}.}
}
\value{
An object of class \code{CrunchDataset}.
}
\description{
This function gives you a Dataset object, which refers to a dataset hosted on
the Crunch platform. With this Dataset, you can perform lots of data cleaning
and analysis as if the dataset were fully resident on your computer, without
having to pull data locally.
}
\details{
You can specify a dataset to load by its human-friendly "name", possibly also
by indicating a project (folder) to find it in. This makes code more
readable, but it does mean that if the dataset is renamed or moved to a
different folder, your code may no longer work. The fastest, most reliable
way to use \code{loadDataset()} is to provide a URL to the dataset--the dataset's
URL will never change.
}
\examples{
\dontrun{
ds <- loadDatasets("A special dataset")
ds2 <- loadDatasets("~/My dataset")
ds3 <- loadDataset("My dataset", project = "~") # Same as ds2
ds4 <- loadDataset("https://app.crunch.io/api/datasets/bd3ad2/")
}
}
\seealso{
See \code{\link[=cd]{cd()}} for details of parsing and walking dataset folder/project
paths.
}
