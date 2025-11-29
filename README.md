# PRISMA API Service

Microserviço em R que gera fluxogramas PRISMA 2020 usando o pacote oficial **PRISMA2020**.

## Endpoint principal

`POST /generate`

### Corpo (JSON)

```json
{
  "format": "png",
  "interactive": false,
  "previous": false,
  "other": true,
  "fontsize": 10,
  "overrides": {
    "database_results": 1760,
    "duplicates": 209,
    "records_screened": 1551,
    "records_excluded": 1518,
    "db_r_sought_reports": 33,
    "db_r_notretrieved_reports": 0,
    "db_r_assessed": 33,
    "db_r_excluded": 30,
    "new_studies": 3
  }
}
