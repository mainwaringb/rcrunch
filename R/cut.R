#' Cut a numeric Crunch variable
#'
#' `crunch::cut()` is equivalent to `base::cut()` except that it operates on
#' Crunch variables instead of in-memory R objects. The function takes a numeric
#' variable and derives a new categorical variable from it based on the `breaks`
#' argument. You can either break the variable into evenly spaced categories by
#' specifying the number of breaks, or specify a numeric vector identifying
#' the start and end point of each category. For example, specifying
#' `breaks = 5` will break the numeric data into five evenly spaced portions
#' while `breaks = c(1, 5, 10)` will recode the data into two groups based on
#' whether the numeric vector falls between 1 and 5 or 5 and 10.
#' @param x A Crunch `NumericVariable`
#' @param breaks Either a numeric vector of two or more unique cut points
#' or a single number giving the number of intervals into which `x` is to be
#' cut. If specifying cut points, values that are less than the smallest value
#' in `breaks` or greater than the largest value in `breaks` will be marked
#' missing in the resulting categorical variable.
#' @param labels A character vector representing the labels for the levels of
#' the resulting categories. The length of the labels argument should be the
#' same as the number of categories, which is one fewer than the number of
#' breaks. If not specified, labels are constructed using interval notation.
#' For example, `[1, 5)` indicates that the category goes from 1 to 5. The
#' bracket shape indicates whether the boundary value is included in the
#' category, i.e. whether it is "closed". `[1, 5)` indicates that the interval
#' includes (is closed on) 1 but does not include (is open on) 5.
#' If labels = FALSE, simple integer codes are returned instead of a factor.
#' @param name The name of the resulting Crunch variable as a character string.
#' @param include.lowest logical, indicating if an `x[i]` equal to the lowest
#' (or highest, for right = FALSE) `breaks` value should be included.
#' @param right logical, indicating if the intervals should be closed on the
#' right (and open on the left) or vice versa.
#' @param dig.lab integer which is used when labels are not given.
#' It determines the number of digits used in formatting the break numbers.
#' @param ordered_result	Ignored.
#' @param ... further arguments passed to [makeCaseVariable]
#' @return a Crunch [`VariableDefinition`]. Assign it into the dataset to create
#' it as a derived variable on the server.
#' @name crunch-cut
#' @aliases crunch-cut
#' @examples
#' \dontrun{
#' ds <- loadDataset("mtcars")
#' ds$cat_var <- cut(ds$mpg,
#'     breaks = c(10, 15, 20),
#'     labels = c("small", "medium"), name = "Fuel efficiency"
#' )
#' ds$age <- sample(1:100, 32)
#' ds$age4 <- cut(df$age, c(0, 30, 45, 65, 200),
#'     c("Youth", "Adult", "Middle-aged", "Elderly"),
#'     name = "Age (4 category)"
#' )
#' }
NULL

#' @rdname crunch-cut
#' @export
setMethod("cut", "NumericVariable", function(x,
                                             breaks,
                                             labels = NULL,
                                             name,
                                             include.lowest = FALSE,
                                             right = TRUE,
                                             dig.lab = 3,
                                             ordered_result = FALSE, ...) {
    if (missing(name)) {
        halt("Must provide the name for the new variable")
    }
    if (length(breaks) == 1L) {
        if (is.na(breaks) || breaks < 2L) {
            halt("invalid number of breaks")
        }
        nb <- as.integer(breaks + 1) # one more than the number of breaks
        rx <- c(min(x, na.rm = TRUE), max(x, na.rm = TRUE))
        dx <- diff(rx)
        if (dx == 0) {
            dx <- abs(rx[1L])
            breaks <- seq.int(rx[1L] - dx / 1000, rx[2L] + dx / 1000,
                length.out = nb
            )
        } else {
            breaks <- seq.int(rx[1L], rx[2L], length.out = nb)
            breaks[c(1L, nb)] <- c(rx[1L] - dx / 1000, rx[2L] + dx / 1000)
        }
    } else {
        breaks <- sort.int(as.double(breaks))
        nb <- length(breaks)
    }
    if (anyDuplicated(breaks)) {
        halt(sQuote("breaks"), " must be unique")
    }
    # Autogenerate labels if not supplied
    if (is.null(labels)) {
        labels <- generateCutLabels(dig.lab, breaks, nb, right, include.lowest)
    } else if (length(labels) != nb - 1L) {
        halt(
            "There are ",
            nb - 1,
            " resulting categories but you only supplied ",
            length(labels),
            " labels. Change number of breaks or the number of labels."
        )
    }
    if (right) {
        `%c1%` <- function(x, y) x <= y
        `%c2%` <- function(x, z) x > z
    } else {
        `%c1%` <- function(x, y) x < y
        `%c2%` <- function(x, z) x >= z
    }

    cases <- vector("list", length = length(breaks) - 1)

    for (i in 2:length(breaks)) {
        cases[[i - 1]] <- x %c2% breaks[i - 1] & x %c1% breaks[i]
    }
    case_list <- lapply(
        seq_along(cases),
        function(x) list(expression = cases[[x]], name = labels[x])
    )
    makeCaseVariable(cases = case_list, name = name, ...)
})


#' Generate Labels for the cut function
#'
#' A convenience function to generate labels for the cut function. This
#' function is extracted from [base::cut()] and is broken out to make it easier
#' to test. It is not meant to be called on its own.
#'
#' @param dig.lab see `cut()`
#' @param breaks see `cut()`
#' @param nb The number of breaks, equal to the small of 2 or the number of breaks
#' @param right  see `cut()`
#' @param include.lowest see`cut()`
#'
#' @return
#' A character vector of labels
#' @keywords internal
generateCutLabels <- function(dig.lab, breaks, nb, right, include.lowest) {
    for (dig in dig.lab:max(12L, dig.lab)) {
        ## 0+ avoids printing signed zeros as "-0"
        ch.br <- formatC(0 + breaks, digits = dig, width = 1L)
        ok <- all(ch.br[-1L] != ch.br[-nb])
        if (ok) break
    }
    labels <- if (ok) {
        paste0(
            ifelse(right, "(", "["),
            ch.br[-nb], ",", ch.br[-1L],
            ifelse(right, "]", ")")
        )
    } else {
        paste("Range", seq_len(nb - 1L), sep = "_")
    }
    if (ok && include.lowest) {
        if (right) {
            substr(labels[1L], 1L, 1L) <- "[" # was "("
        } else {
            substring(
                labels[nb - 1L],
                nchar(labels[nb - 1L], "c")
            ) <- "]" # was ")"
        }
    }
    return(labels)
}
