
ProduceJSON <-
  function(row = 6,
           start_col = 3,
           end_col = 1000,
           sheet_name,
           sheet_path) {
    foo <-
      list(
        sheet = sheet_name,
        row = row,
        start_col = start_col,
        end_col = end_col,
        fields = as.list(names(as.list(
          read_excel(
            path = sheet_path,
            sheet = sheet_name,
            range = cell_limits(c(row, start_col),
                                c(row, end_col))
          )
        )))
      )
    
    foo$fields <- foo$fields[!grepl("X_", foo$fields)]
    foo$end_col = start_col + length(foo$fields)-1
    
    return(foo)
    
  }

produceSchema <- function(sheet_path,mode) {
  
  sheets <- excel_sheets(sheet_path)
  sheets <- sheets[grepl("Targets", sheets)]
  
  foo <- list()
  for (i in 1:length(sheets)) {
    bar <- ProduceJSON(sheet_path = sheet_path, sheet_name = sheets[i])
    foo <- list.append(foo, bar)
  }
  return(list(mode=mode,schema=foo))
}

sheet_path = "/home/jason/development/data-pack-importer/data-raw/COP18DisaggToolTemplate_HTS v2018.01.02.xlsx"
mode="HTS"
hts_schema<-produceSchema(sheet_path,mode)

sheet_path = "/home/jason/development/data-pack-importer/data-raw/KenyaCOP18DisaggToolv2018.01.19.xlsx"
mode="NORMAL"
main_schema<-produceSchema(sheet_path,mode)

schemas<-list(hts=hts_schema,normal=main_schema)
names(schemas)<-c("hts","normal")

cat(toJSON(schemas,auto_unbox = TRUE),file="schemas.json")
devtools::use_data(hts_schema,main_schema,internal = TRUE,overwrite = TRUE)