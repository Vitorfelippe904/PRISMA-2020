
library(plumber)
library(PRISMA2020)

#* @post /generate
function(req) {
  body <- jsonlite::fromJSON(req$postBody)

  png("prisma_output.png", width=1200, height=2000, res=150)
  prisma_flowdiagram(
    studies_identified = body$identification,
    studies_screened = body$screening,
    studies_included = body$included
  )
  dev.off()

  img <- base64enc::dataURI(file="prisma_output.png", mime="image/png")
  list(image_base64 = img)
}

pr <- plumb("api.R")
pr$run(host="0.0.0.0", port=8000)
