library(jsonlite)
##' Declares the generic as.json method.
##'
##' @param x the object to be marshalled to JSON
##' @param ... extra arguments to the actual function
##' @return a JSON representation of the consumed object.
##' @export
as.json = function (x, ...) {
  UseMethod("as.json")
}

##' Declares the as.json method for xts instances
##'
##' @param x the xts object to be marshalled to JSON
##' @param ... extra arguments to the data.frame
##' @return a JSON representation of the consumed xts object.
##' @export
as.json.xts = function (x, ...) {
  ## Prepare the data frame first:
  retval = data.frame(cbind(Index=as.character(index(x)), coredata(x)), ...)
  
  ## Remove the row names:
  rownames(retval) = NULL
  
  ## Done, return the JSON:
  return(toJSON(as.list(retval)))
}

##' Consumes a JSON string and returns an xts instance.
##'
##' @param x the JSON representation of the xts instance. The first
##' column is meant to be the index of the xts instance to be
##' constructed.
##' @param ... extra parameters to xts function.
##' @return the xts instance.
##' @export
xtsFromJSON = function (obj_TS_JSON, ...) {
  ## Get the list:
  retval = as.data.frame(obj_TS_JSON)
  
  ## Construct and return xts instance:
  return(xts(retval[,-1], order.by=as.POSIXct(retval[,1]), ...))
}