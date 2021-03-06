get.sem.coefs = function(modelList, data, standardized = FALSE, corr.errors = NULL) {
  
  names(modelList) = NULL
  
  if(standardized == FALSE) {
    ret = lapply(modelList, function(i) {
      
      if(all(class(i) %in% c("lm", "glm", "negbin", "glmerMod"))) {
        tab = summary(i)$coefficients
        data.frame(path = paste(Reduce(paste, deparse(formula(i)[[2]])), "<-", rownames(tab)[-1]),
                   estimate = round(tab[-1, 1], 3),
                   std.error = round(tab[-1, 2], 3),
                   p.value = round(tab[-1, 4], 3), 
                   row.names = NULL)
        
      } else if(all(class(i) %in% c("lme", "glmmPQL"))) {
        tab = summary(i)$tTable
        data.frame(path = paste(Reduce(paste, deparse(formula(i)[[2]])), "<-", rownames(tab)[-1]),
                   estimate = round(tab[-1, 1], 3),
                   std.error = round(tab[-1, 2], 3),
                   p.value = round(tab[-1, 5], 3), 
                   row.names = NULL)
        
      } else if(all(class(i) %in% c("lmerMod", "merModLmerTest"))) {
        tab = summary(as(i, "merModLmerTest"))$coefficients
        data.frame(path = paste(Reduce(paste, deparse(formula(i)[[2]])), "<-", rownames(tab)[-1]),
                   estimate = round(tab[-1, 1], 3),
                   std.error = round(tab[-1, 2], 3),
                   p.value = round(tab[-1, 5], 3), 
                   row.names = NULL) } } )
    
  } else if(standardized == TRUE) {
    
    ret = lapply(modelList, function(i) {
      
      vars.to.scale = if(all(class(i) %in% c("lm", "lme"))) rownames(attr(i$terms, "factors")) else
        if(any(class(i) %in% c("glm", "negbin", "glmmPQL"))) {
          message("Model is not gaussian: keeping response on original scale")
          rownames(attr(i$terms, "factors"))[-1] } else 
            if(all(class(i) %in% c("merModLmerTest")))
              rownames(attr(attr(i@frame, "terms"), "factors"))[!rownames(attr(attr(i@frame, "terms"), "factors")) %in% names(i@flist)] else
                if(all(class(i) %in% c("glmerMod"))) {
                  message("Reponse is not modeled to a gaussian distribution: keeping response on original scale")
                  rownames(attr(attr(i@frame, "terms"), "factors"))[!rownames(attr(attr(i@frame, "terms"), "factors")) %in% names(i@flist)][-1] }
      
      form = gsub(" ", "", unlist(strsplit(paste(format(formula(i)), collapse = ""), "\\+|\\~")))
      
      if(any(grepl("\\*|\\:", form))) {
        ints = strsplit(form[grepl("\\*|\\:", form)], "\\*")
        ints.scaled = lapply(ints, function(j) paste(paste("scale(",j,")"), collapse = "*"))
        form[grepl("\\*|\\:", form)] = unlist(ints.scaled)
        vars.to.scale=vars.to.scale[-match(unique(unlist(ints)),vars.to.scale)] }
      
      if(length(vars.to.scale) > 0) form[match(vars.to.scale, form)] = paste("scale(", form[match(vars.to.scale, form)], ")")
      
      form = if(length(form) > 2)
        paste(paste(form[1], "~", form[2], "+"), paste(form[-c(1:2)], collapse = "+")) else
          paste(paste(form[1], "~", form[2]))
      
      if(all(class(i) %in% c("lme", "glmmPQL")))
        model = update(i, fixed = formula(form)) else
          model = update(i, formula = form)
      
      if(class(model) == "lmerMod") model = as(model, "merModLmerTest")
      
      if(all(class(model) %in% c("lm", "glm", "negbin", "glmerMod"))) {
        tab = summary(model)$coefficients
        data.frame(path = paste(Reduce(paste, deparse(formula(model)[[2]])), "<-", rownames(tab)[-1]),
                   estimate = round(tab[-1, 1], 3),
                   std.error = round(tab[-1, 2], 3),
                   p.value = round(tab[-1, 4], 3), 
                   row.names = NULL)
        
      } else if(all(class(model) %in% c("lme", "glmmPQL"))) {
        tab = summary(model)$tTable
        data.frame(path = paste(Reduce(paste, deparse(formula(model)[[2]])), "<-", rownames(tab)[-1]),
                   estimate = round(tab[-1, 1], 3),
                   std.error = round(tab[-1, 2], 3),
                   p.value = round(tab[-1, 5], 3), 
                   row.names = NULL)
        
      } else if(all(class(model) %in% c("merModLmerTest"))) {
        tab = summary(model)$coefficients
        data.frame(path = paste(Reduce(paste, deparse(formula(model)[[2]])), "<-", rownames(tab)[-1]),
                   estimate = round(tab[-1, 1], 3),
                   std.error = round(tab[-1, 2], 3),
                   p.value = round(tab[-1, 5], 3), 
                   row.names = NULL) } 
    } )
  }

  if(!is.null(corr.errors)) {
    ret = append(ret, lapply(corr.errors, function(j) {
      
      corr.vars = gsub(" ", "", unlist(strsplit(j,"~~")))
      
#       if(all(corr.vars %in% unlist(lapply(modelList, function(i) as.character(formula(i)[2]))))) {
#         
#         resid.data = get.partial.resid(as.formula(paste(corr.vars[1], "~", corr.vars[2])), modelList)
#         
#         data.frame(
#           path = j,
#           estimate = round(cor(resid.data)[1,2], 3),
#           std.error = "",
#           p.value = round(1 - pt((cor(resid.data)[1, 2] * sqrt(nrow(resid.data) - 2))/(sqrt(1 - cor(resid.data)[1, 2]^2)),nrow(resid.data)-2), 3),
#           row.names = NULL) 
#         
#       } else {
        
        data.frame(
          path = j,
          estimate = round(cor(data[, corr.vars[1]], data[, corr.vars[2]], use = "complete.obs"), 3),
          std.error = "",
          p.value = round(1 - pt((cor(data[, corr.vars[1]], data[, corr.vars[2]], use = "complete.obs") * sqrt(nrow(data) - 2))/
                                   (sqrt(1 - cor(data[, corr.vars[1]], data[, corr.vars[2]], use = "complete.obs")^2)),nrow(data)-2), 3),
          row.names = NULL)
        
      } ) ) }

  ret = lapply(ret, function(i) { i = i[order(i$p.value),]; rownames(i) = NULL; return(i) } )

  return(ret)

}