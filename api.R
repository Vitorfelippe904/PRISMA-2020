# api.R - PRISMA 2020 API
library(plumber)
library(jsonlite)
library(base64enc)
library(PRISMA2020)

#* @apiTitle PRISMA 2020 API
#* @apiDescription API para geração de fluxogramas PRISMA 2020 oficiais

#* Health check
#* @get /health
function() {
  list(status = "ok", timestamp = as.character(Sys.time()))
}

#* Gera PRISMA simplificado (versão fácil)
#* @param identified Total identificado nas bases
#* @param after_duplicates Após remover duplicatas
#* @param screened Triados
#* @param excluded Excluídos na triagem
#* @param full_text Texto completo avaliado
#* @param excluded_fulltext Excluídos após texto completo
#* @param studies_included Estudos incluídos
#* @param format png, pdf ou svg
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
    
    # Converte para numérico
    identified <- as.numeric(identified)
    after_duplicates <- as.numeric(after_duplicates)
    screened <- as.numeric(screened)
    excluded <- as.numeric(excluded)
    full_text <- as.numeric(full_text)
    excluded_fulltext <- as.numeric(excluded_fulltext)
    studies_included <- as.numeric(studies_included)
    
    # Calcula duplicatas
    duplicates <- identified - after_duplicates
    
    # Usa PRISMA_data para criar os dados
    data <- PRISMA_data(
      database = identified,
      register = 0,
      other = 0,
      duplicates = duplicates,
      excluded_automatic = 0,
      excluded_other = 0,
      records_screened = screened,
      records_excluded = excluded,
      dbr_sought = full_text,
      dbr_notretrieved = 0,
      other_sought = 0,
      other_notretrieved = 0,
      dbr_assessed = full_text,
      dbr_excluded = list(
        reason1 = excluded_fulltext
      ),
      other_assessed = 0,
      other_excluded = list(),
      new_studies = studies_included,
      new_reports = studies_included,
      previous_studies = 0,
      previous_reports = 0
    )
    
    # Gera o fluxograma
    plot <- PRISMA_flowdiagram(
      data,
      interactive = FALSE,
      previous = FALSE,
      other = FALSE
    )
    
    # Salva em arquivo temporário
    temp_file <- tempfile(fileext = paste0(".", format))
    
    PRISMA_save(
      plot,
      filename = temp_file,
      filetype = toupper(format)
    )
    
    # Lê e converte para base64
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
      trace = as.character(e)
    )
  })
}

#* Gera PRISMA completo com todos os campos
#* @param database Registros de bases de dados
#* @param register Registros de registros
#* @param other Outras fontes
#* @param duplicates Duplicatas removidas
#* @param excluded_automatic Excluídos automaticamente
#* @param excluded_other Excluídos por outros motivos
#* @param records_screened Registros triados
#* @param records_excluded Excluídos na triagem
#* @param dbr_sought Relatórios buscados (bases+registros)
#* @param dbr_notretrieved Não recuperados
#* @param dbr_assessed Avaliados para elegibilidade
#* @param exclusion_reasons JSON com motivos {"motivo1": n1, "motivo2": n2}
#* @param new_studies Estudos incluídos
#* @param new_reports Relatórios incluídos
#* @param previous_studies Estudos de revisões anteriores
#* @param previous_reports Relatórios de revisões anteriores
#* @param show_previous Mostrar braço de estudos anteriores
#* @param show_other Mostrar braço de outras fontes
#* @param format png, pdf ou svg
#* @post /generate-prisma
function(
  database = 0,
  register = 0,
  other = 0,
  duplicates = 0,
  excluded_automatic = 0,
  excluded_other = 0,
  records_screened = 0,
  records_excluded = 0,
  dbr_sought = 0,
  dbr_notretrieved = 0,
  dbr_assessed = 0,
  exclusion_reasons = "{}",
  new_studies = 0,
  new_reports = 0,
  previous_studies = 0,
  previous_reports = 0,
  show_previous = FALSE,
  show_other = FALSE,
  format = "png"
) {
  
  tryCatch({
    
    # Processa motivos de exclusão
    if (is.character(exclusion_reasons)) {
      reasons <- fromJSON(exclusion_reasons)
    } else {
      reasons <- exclusion_reasons
    }
    
    # Converte para lista nomeada
    if (length(reasons) > 0) {
      dbr_excluded <- as.list(reasons)
    } else {
      dbr_excluded <- list()
    }
    
    # Cria dados PRISMA
    data <- PRISMA_data(
      database = as.numeric(database),
      register = as.numeric(register),
      other = as.numeric(other),
      duplicates = as.numeric(duplicates),
      excluded_automatic = as.numeric(excluded_automatic),
      excluded_other = as.numeric(excluded_other),
      records_screened = as.numeric(records_screened),
      records_excluded = as.numeric(records_excluded),
      dbr_sought = as.numeric(dbr_sought),
      dbr_notretrieved = as.numeric(dbr_notretrieved),
      other_sought = 0,
      other_notretrieved = 0,
      dbr_assessed = as.numeric(dbr_assessed),
      dbr_excluded = dbr_excluded,
      other_assessed = 0,
      other_excluded = list(),
      new_studies = as.numeric(new_studies),
      new_reports = as.numeric(new_reports),
      previous_studies = as.numeric(previous_studies),
      previous_reports = as.numeric(previous_reports)
    )
    
    # Gera fluxograma
    plot <- PRISMA_flowdiagram(
      data,
      interactive = FALSE,
      previous = as.logical(show_previous),
      other = as.logical(show_other)
    )
    
    # Salva
    temp_file <- tempfile(fileext = paste0(".", format))
    PRISMA_save(plot, filename = temp_file, filetype = toupper(format))
    
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
      error = as.character(e$message)
    )
  })
}
