% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{get-attr}
\alias{get-attr}
\alias{\%@\%}
\title{Infix attribute accessor}
\usage{
x \%@\% name
}
\arguments{
\item{x}{Object}

\item{name}{Attribute name}
}
\description{
Infix attribute accessor
}
\examples{
factor(1:3) \%@\% "levels"
mtcars \%@\% "class"
}
