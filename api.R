# api.R - PRISMA 2020 API
library(plumber)
library(jsonlite)
library(base64enc)
library(PRISMA2020)

#* @apiTitle PRISMA 2020 API
#* @apiDescription API para geração de fluxogramas PRISMA 2020

#* Health check
#* @get /health
function() {
  list(status = "ok", timestamp = Sys.time())
}

#* Gera fluxograma PRISMA 2020
#* @param identified Registros identificados nas bases
#* @param duplicates Duplicatas removidas
#* @param screened Registros triados
#* @param excluded_screening Excluídos na triagem
#* @param sought_retrieval Buscados para recuperação
#* @param not_retrieved Não recuperados
#* @param assessed_eligibility Avaliados para elegibilidade
#* @param excluded_reasons Lista com motivos de exclusão (ex: {"Motivo 1": 10, "Motivo 2": 5})
#* @param included_studies Estudos incluídos na revisão
#* @param included_reports Relatos incluídos
#* @param format Formato de saída: png ou pdf
#* @post /generate-prisma
function(
  identified = 0,
  duplicates = 0,
  screened = 0,
  excluded_screening = 0,
  sought_retrieval = 0,
  not_retrieved = 0,
  assessed_eligibility = 0,
  excluded_reasons = NULL,
  included_studies = 0,
  included_reports = 0,
  format = "png"
) {
  
  tryCatch({
    
    # Processa motivos de exclusão
    if (is.null(excluded_reasons) || length(excluded_reasons) == 0) {
      exclusion_text <- ""
      total_excluded <- 0
    } else {
      if (is.character(excluded_reasons)) {
        excluded_reasons <- fromJSON(excluded_reasons)
      }
      exclusion_text <- paste(names(excluded_reasons), excluded_reasons, sep = " (n=", collapse = ")\n")
      exclusion_text <- paste0(exclusion_text, ")")
      total_excluded <- sum(unlist(excluded_reasons))
    }
    
    # Cria dados no formato PRISMA2020
    prisma_data <- PRISMA_data(
      identification = list(
        database_results = as.numeric(identified),
        register_results = 0,
        other_results = 0
      ),
      screening = list(
        duplicates = as.numeric(duplicates),
        records_screened = as.numeric(screened),
        records_excluded = as.numeric(excluded_screening)
      ),
      retrieval = list(
        sought_reports = as.numeric(sought_retrieval),
        not_retrieved = as.numeric(not_retrieved)
      ),
      eligibility = list(
        assessed = as.numeric(assessed_eligibility),
        excluded = total_excluded,
        exclusion_reasons = exclusion_text
      ),
      included = list(
        studies = as.numeric(included_studies),
        reports = as.numeric(included_reports)
      ),
      previous = NULL
    )
    
    # Gera o fluxograma
    plot_obj <- PRISMA_flowdiagram(prisma_data, interactive = FALSE)
    
    # Salva em arquivo temporário
    temp_file <- tempfile(fileext = paste0(".", format))
    
    if (format == "png") {
      PRISMA_save(plot_obj, filename = temp_file, filetype = "png")
    } else {
      PRISMA_save(plot_obj, filename = temp_file, filetype = "pdf")
    }
    
    # Converte para base64
    file_content <- readBin(temp_file, "raw", file.info(temp_file)$size)
    b64 <- base64encode(file_content)
    
    # Remove arquivo temporário
    unlink(temp_file)
    
    list(
      success = TRUE,
      base64 = b64,
      format = format,
      message = "Fluxograma PRISMA gerado com sucesso"
    )
    
  }, error = function(e) {
    list(
      success = FALSE,
      error = as.character(e$message),
      format = format
    )
  })
}

#* Gera PRISMA simplificado (versão fácil)
#* @param identified Total identificado
#* @param after_duplicates Após remover duplicatas
#* @param screened Triados
#* @param excluded Excluídos na triagem
#* @param full_text Texto completo avaliado
#* @param excluded_fulltext Excluídos após texto completo
#* @param studies_included Estudos incluídos
#* @param format png ou pdf
#* @post /generate-prisma-simple
function(
  identified = 0,
  after_duplicates = 0,
  screened = 0,
  excluded = 0,
  full_text = 0,
  excluded_fulltext = 0,
  studies_included = 0,
  format = "png"
) {
  
  tryCatch({
    
    duplicates <- as.numeric(identified) - as.numeric(after_duplicates)
    
    # Cria dados PRISMA
    prisma_data <- PRISMA_data(
      identification = list(
        database_results = as.numeric(identified),
        register_results = 0,
        other_results = 0
      ),
      screening = list(
        duplicates = duplicates,
        records_screened = as.numeric(screened),
        records_excluded = as.numeric(excluded)
      ),
      retrieval = list(
        sought_reports = as.numeric(full_text),
        not_retrieved = 0
      ),
      eligibility = list(
        assessed = as.numeric(full_text),
        excluded = as.numeric(excluded_fulltext),
        exclusion_reasons = ""
      ),
      included = list(
        studies = as.numeric(studies_included),
        reports = as.numeric(studies_included)
      ),
      previous = NULL
    )
    
    # Gera fluxograma
    plot_obj <- PRISMA_flowdiagram(prisma_data, interactive = FALSE)
    
    # Salva
    temp_file <- tempfile(fileext = paste0(".", format))
    PRISMA_save(plot_obj, filename = temp_file, filetype = format)
    
    # Base64
    file_content <- readBin(temp_file, "raw", file.info(temp_file)$size)
    b64 <- base64encode(file_content)
    unlink(temp_file)
    
    list(
      success = TRUE,
      base64 = b64,
      format = format,
      message = "Fluxograma PRISMA gerado com sucesso"
    )
    
  }, error = function(e) {
    list(
      success = FALSE,
      error = as.character(e$message),
      format = format
    )
  })
