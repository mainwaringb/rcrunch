#' Delete a Crunch object from the server
#'
#' These methods delete entities, notably Datasets and Variables within them,
#' from the server. This action is permanent and cannot be undone, so it
#' should not be done lightly. Consider instead using `archive`
#' for datasets and `hide` for variables.
#'
#' Deleting requires confirmation. In an interactive session, you will be asked
#' to confirm. To avoid that prompt, or to delete objects from a
#' non-interactive session, wrap the call in [with_consent()] to give
#' your permission to delete.
#'
#' @param x a Crunch object
#' @param ... additional arguments, generally ignored
#' @seealso [hide()] [deleteDataset()] [deleteVariables()] [deleteSubvariables()]
#' @name delete
#' @aliases delete
setGeneric("delete", function(x, ...) standardGeneric("delete"),
    signature = "x"
)

#' @rdname delete
#' @export
setMethod("delete", "CrunchDataset", function(x, ...) {
    invisible(delete(tuple(x), ...))
})

confirmDeleteEntity <- function(entity_name, entity_type = NULL) {
    prompt <- paste("Really delete", entity_type, dQuote(entity_name))
    if (!askForPermission(paste0(prompt, "?"))) {
        halt("Must confirm deleting ", entity_type)
    }
}

#' @rdname delete
#' @export
setMethod("delete", "DatasetTuple", function(x, ...) {
    confirmDeleteEntity(name(x), "dataset")
    invisible(crDELETE(self(x), drop = dropDatasetsCache()))
})

dropDatasetsCache <- function() {
    # A dataset or project has been deleted, and rather than guessing where it
    # appeared in the HTTP query cache, just drop wherever it could have been:
    # 1) All projects/folders
    dropCache(sessionURL("projects"))
    # 2) The datasets catalog
    dropOnly(sessionURL("datasets"))
    # 3) Search endpoints
    dropSearchCache()
}

dropSearchCache <- function() {
    # TODO: We should drop cache everywhere datasets or variables are modified?
    dropCache(paste0(sessionURL("datasets"), "by_name/"))
    dropCache(sessionURL("search", "views"))
}

#' @rdname delete
#' @export
setMethod("delete", "CrunchDeck", function(x, ...) {
    confirmDeleteEntity(name(x), "deck")
    invisible(crDELETE(self(x)))
})

#' @rdname delete
#' @export
setMethod("delete", "CrunchSlide", function(x, ...) {
    confirmDeleteEntity(title(x), "slide")
    u <- self(x)
    drop_where <- absoluteURL("../", u)
    invisible(crDELETE(u, drop = dropCache(drop_where)))
})

#' @rdname delete
#' @export
setMethod("delete", "Multitable", function(x, ...) {
    confirmDeleteEntity(name(x), "multitable")
    invisible(crDELETE(self(x)))
})

#' @rdname delete
#' @export
setMethod("delete", "CrunchTeam", function(x, ...) {
    confirmDeleteEntity(name(x), "team")
    u <- self(x)
    drop_where <- absoluteURL("../", u)
    invisible(crDELETE(u, drop = dropCache(drop_where)))
})

#' @rdname delete
#' @export
setMethod("delete", "CrunchVariable", function(x, ...) delete(tuple(x), ...))

#' @rdname delete
#' @export
setMethod("delete", "VariableTuple", function(x, ...) {
    confirmDeleteEntity(name(x), "variable")
    u <- self(x)
    drop_where <- absoluteURL("../", u)
    invisible(crDELETE(u, drop = dropCache(drop_where)))
})

#' @rdname delete
#' @export
setMethod("delete", "ShojiFolder", function(x, ...) {
    if (is.null(parentFolderURL(x))) {
        halt("Cannot delete root folder")
    }

    # count the variable/folder objects, and warn the user that they will be
    # summarily deleted as well. Projects must be empty to be deleted (which is
    # enforced on the server, so we only need to check VariableFolders) send as
    # a message before the prompt for test-ability, and so the prompt isn't lost
    # at then end of a long line.
    if (inherits(x, "VariableFolder")) {
        obj_names <- names(x)
        num_vars <- length(x)
        obj_word <- pluralize("object", num_vars)

        if (num_vars > 5) {
            obj_string <- serialPaste(dQuote(head(obj_names, 5)), "...")
        } else {
            obj_string <- serialPaste(dQuote(obj_names))
        }
        message(
            "This folder contains ", num_vars, " ", obj_word, ": ", obj_string,
            ". Deleting the folder will also delete these objects (including ",
            "their contents)."
        )
    }
    confirmDeleteEntity(name(x), "folder")
    invisible(crDELETE(self(x)))
})

#' @rdname delete
#' @export
setMethod("delete", "ShojiTuple", function(x, ...) {
    invisible(crDELETE(x@entity_url, drop = dropCache(x@index_url)))
})

#' @rdname delete
#' @export
setMethod("delete", "ShojiObject", function(x, ...) invisible(crDELETE(self(x))))

#' @rdname delete
#' @export
setMethod("delete", "ANY", function(x, ...) {
    halt("'delete' only valid for Crunch objects")
})

#' Delete a dataset from the dataset list
#'
#' This function lets you delete a dataset without first loading it, which is
#' faster.
#'
#' The function also works on `CrunchDataset` objects, just like
#' [delete()], which may be useful if you have loaded another
#' package that masks the `crunch::delete()` method.
#' @param x The name (character) of a dataset, a path to a dataset, or a
#' `CrunchDataset`. Unless `x` is a parsed folder path, it can only be of
#' length 1--for your protection, this function is not vectorized.
#' @param ... additional parameters passed to [delete()]
#' @return (Invisibly) the API response from deleting the dataset
#' @seealso [delete()]; [cd()] for details of parsing and walking dataset
#' folder/project paths.
#' @export
deleteDataset <- function(x, ...) {
    if (is.dataset(x)) {
        return(delete(x, ...))
    }

    if (is.character(x)) {
        if (is.crunchURL(x)) {
            url <- datasetReference(x)
            if (is.null(url)) {
                halt(x, " is not a valid dataset URL")
            }
        } else {
            # Assume it is a path or name
            found <- lookupDataset(x)
            if (length(found) != 1) {
                halt(
                    dQuote(x), " identifies ", length(found),
                    " datasets. To delete, please identify the dataset ",
                    "uniquely by URL or path."
                )
            }
            ## We know there is just one now
            url <- urls(found)
        }
        ## Now, delete it
        confirmDeleteEntity(x, "dataset")
        invisible(crDELETE(url, drop = dropDatasetsCache()))
    } else {
        halt("deleteDataset requires either a Dataset, a unique dataset name, or a URL")
    }
}

#' Delete Variables Within a Dataset
#'
#' This function permanently deletes a variable from a dataset.
#'
#' In an interactive session, you will be prompted to confirm that you
#' wish to delete the variable. To avoid that prompt, or to delete variables from a
#' non-interactive session, wrap the call in [with_consent()] to give
#' your permission to delete.
#' @param dataset the Dataset to modify
#' @param variables aliases (following `crunch.namekey.dataset`) or indices
#' of variables to delete.
#' @return (invisibly) `dataset` with the specified variables deleted
#' @seealso [delete()]; [deleteSubvariable()]; For a non-destructive
#' alternative, see [hide()].
#' @export
deleteVariables <- function(dataset, variables) {
    to.delete <- allVariables(dataset[variables])
    if (length(to.delete) == 1) {
        prompt <- paste0("Really delete ", dQuote(names(to.delete)), "?")
    } else {
        prompt <- paste0(
            "Really delete these ", length(to.delete),
            " variables?"
        )
    }
    if (!askForPermission(prompt)) {
        halt("Must confirm deleting variable(s)")
    }
    lapply(unique(urls(to.delete)), crDELETE)
    dropCache(self(to.delete))
    return(invisible(refresh(dataset)))
}

#' @rdname deleteVariables
#' @export
deleteVariable <- deleteVariables

#' Delete subvariables from an array
#'
#' Deleting variables requires confirmation. In an interactive session, you will be asked
#' to confirm. To avoid that prompt, or to delete subvariables from a
#' non-interactive session, wrap the call in [with_consent()] to give
#' your permission to delete.
#'
#' To delete the subvariables the function unbinds the array, deletes the subvariable, and
#' then binds the remaining subvariables into a new array.
#' @param variable the array variable
#' @param to.delete aliases (following `crunch.namekey.dataset`) or indices
#' of variables to delete.
#' @return a new version of variable without the indicated subvariables
#' @export
#' @seealso [deleteVariable()] [delete()]
deleteSubvariables <- function(variable, to.delete) {
    ## Identify subvariable URLs
    delete.these <- urls(variable[, to.delete])

    if (length(delete.these) == 1) {
        subvars <- subvariables(variable)
        subvar.urls <- urls(subvars)
        subvar.names <- names(subvars)
        prompt <- paste0(
            "Really delete ",
            dQuote(subvar.names[match(delete.these, subvar.urls)]), "?"
        )
    } else {
        prompt <- paste0(
            "Really delete these ", length(delete.these),
            " variables?"
        )
    }
    if (!askForPermission(prompt)) {
        halt("Must confirm deleting subvariable(s)")
    }

    lapply(delete.these, crDELETE)
    invisible(refresh(variable))
}

#' @rdname deleteSubvariables
#' @export
deleteSubvariable <- deleteSubvariables
