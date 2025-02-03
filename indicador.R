library(readr)

# cargar datos
sicvir <- read_csv2("datos/sicvir_indicadores_rurales_2025.csv")
etiquetas <- read_csv2("datos/sicvir_etiquetas_2025.csv")




# guardar datos
write_csv2(sicvir, "/Users/baolea/R/subdere/indice_brechas/sicvir_indicadores_rurales.csv")
write_csv2(etiquetas, "/Users/baolea/R/subdere/indice_brechas/sicvir_etiquetas.csv")
