library(PRISMA2020)
library(jsonlite)
library(base64enc)

`%||%` <- function(a, b) if (!is.null(a)) a else b

# input_list é uma lista R já parseada do JSON
generate_prisma <- function(input_list) {

  # --------- Parâmetros gerais ---------
  fmt        <- tolower(input_list$format %||% "png")
  interactive <- isTRUE(input_list$interactive)
  previous    <- if (is.null(input_list$previous)) TRUE else isTRUE(input_list$previous)
  other       <- if (is.null(input_list$other)) TRUE else isTRUE(input_list$other)
  fontsize    <- as.numeric(input_list$fontsize %||% 10)

  overrides   <- input_list$overrides

  # --------- Carrega template oficial ---------
  csvFile <- system.file("extdata", "PRISMA.csv", package = "PRISMA2020")
  if (csvFile == "") {
    stop("Não foi possível localizar o template PRISMA.csv do pacote PRISMA2020")
  }

  df <- read.csv(csvFile, stringsAsFactors = FALSE)

  # Espera que o template tenha uma coluna chamada "data" e outra "n"
  # (é exatamente assim no pacote oficial).
  if (!is.null(overrides)) {
    for (nm in names(overrides)) {
      idx <- which(df$data == nm)
      if (length(idx) == 1) {
        df[idx, "n"] <- as.character(overrides[[nm]])
      }
    }
  }

  # Converte para o formato esperado pelo pacote
  pdata <- PRISMA_data(df)

  plot <- PRISMA_flowdiagram(
    pdata,
    interactive = interactive,
    previous    = previous,
    other       = other,
    fontsize    = fontsize
  )

  # --------- Gera arquivo no formato pedido ---------
  fmt <- match.arg(fmt, c("png", "pdf", "svg", "html", "webp"))

  filetype <- toupper(ifelse(fmt == "html", "HTML", fmt))
  outfile  <- tempfile(fileext = paste0(".", fmt))

  PRISMA_save(
    plotobj  = plot,
    filename = outfile,
    filetype = filetype,
    overwrite = TRUE
  )

  raw  <- readBin(outfile, "raw", n = file.info(outfile)$size)
  b64  <- base64encode(raw)

  list(
    format   = fmt,
    filename = basename(outfile),
    content  = b64
  )
}
