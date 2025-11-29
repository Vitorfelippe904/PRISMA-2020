library(PRISMA2020)
library(jsonlite)

generate_prisma <- function(input_json, outfile = "prisma_output.png") {

  data <- fromJSON(input_json)

  png(outfile, width = 1200, height = 2000, res = 150)

  prisma_flowdiagram(
    studies_identified = data$identification,
    studies_screened   = data$screening,
    studies_included   = data$included
  )

  dev.off()

  return(outfile)
}
