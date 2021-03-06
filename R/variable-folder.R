folders <- function(x) {
    # This function exists because the generic rootFolder() for a dataset will
    # get the root project folder, i.e. the root for moving it.
    # This function gives you the root variable folder for a dataset or thing
    # contained in a dataset.
    # So maybe it should be called `rootVariableFolder`?
    if (!is.dataset(x)) {
        x <- ShojiEntity(crGET(datasetReference(x)))
    }
    return(VariableFolder(crGET(shojiURL(x, "catalogs", "folders"))))
}

#' @export
#' @rdname describe-catalog
setMethod("aliases", "VariableFolder", function(x) getIndexSlot(x, "alias"))

setMethod("folderExtraction", "VariableFolder", function(x, tuple) {
    ## "tuple" is a list of length 1, name is URL, contents is the actual tuple
    url <- names(tuple)
    tuple <- tuple[[1]]
    if (tuple$type == "folder") {
        return(VariableFolder(crGET(url)))
    } else {
        tup <- VariableTuple(entity_url = url, body = tuple, index_url = self(x))
        return(CrunchVariable(tup))
    }
})

setMethod("rootFolder", "CrunchVariable", folders)

## Get variable by alias, name, or URL
whichFolderEntry <- function(x, i) {
    ## First check URLs and names()
    out <- whichNameOrURL(x, i, names(x))
    ## Now check variable aliases, if any missing
    not_found <- is.na(out)
    if (any(not_found)) {
        out[not_found] <- match(i[not_found], aliases(x))
    }
    return(out)
}

setMethod(
    "whichCatalogEntry", "VariableFolder",
    function(x, i, ...) whichFolderEntry(x, i)
)
