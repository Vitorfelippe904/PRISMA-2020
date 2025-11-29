library(plumber)
library(jsonlite)

source("prisma_cli.R")

#* @apiTitle PRISMA 2020 API
#* @apiDescription Gera fluxogramas PRISMA 2020 em vários formatos (PNG, PDF, SVG, HTML, WEBP).

#* Health check
#* @get /health
#* @serializer json
function() {
  list(
    status = "ok",
    prisma2020_version = as.character(utils::packageVersion("PRISMA2020"))
  )
}

#* Gera diagrama PRISMA 2020
#* @post /generate
#* @serializer json
function(req, res) {

  body <- req$postBody

  if (is.null(body) || body == "") {
    res$status <- 400
    return(list(error = "Corpo vazio. Envie um JSON com pelo menos o campo 'overrides'."))
  }

  # parseia JSON como lista (sem simplificar vetores em data.frame)
  input_list <- jsonlite::fromJSON(body, simplifyVector = FALSE)

  result <- tryCatch(
    {
      generate_prisma(input_list)
    },
    error = function(e) {
      res$status <- 500
      list(error = paste("Erro ao gerar PRISMA:", e$message))
    }
  )

  # Se já for uma lista com campo "error", apenas retorna
  if (!is.null(result$error)) {
    return(result)
  }

  list(
    status   = "ok",
    format   = result$format,
    filename = result$filename,
    base64   = result$content
  )
}
