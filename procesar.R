library(readxl)
library(readr)
library(janitor)
library(dplyr)

archivo <- dir("datos/datos_originales", full.names = T) |> str_subset("(?<!\\$)indicador.*xlsx")
# archivo <- "datos/datos_originales/SICVIR_SUBDERE_28Ene2025.xlsx"

# hoja_1 <- read_xlsx(archivo, sheet = 1)

# ubicacion_variables <- match("CAMPO", hoja_1[[1]])

# cargar etiquetas 
# (variables con su nombre de columna, año y descripción)
etiquetas <- read_xlsx(archivo, sheet = 1) |> 
  row_to_names(2) |> 
  clean_names() |> 
  rename(año = 2) |> 
  mutate(campo = make_clean_names(campo))

# cargar datos
datos <- read_xlsx(archivo, sheet = 2) |> 
  clean_names()


datos2 <- datos |> 
  # convertir columnas a numéricas
  mutate(across(matches("\\d+") & where(is.character), 
           ~parse_number(.x, locale = locale(decimal_mark = ".", grouping_mark = ""))
           ))


# guardar ----
write_csv2(datos2, "datos/sicvir_indicadores_rurales.csv")
writexl::write_xlsx(datos2, "datos/sicvir_indicadores_rurales.xlsx")

write_csv2(etiquetas, "datos/sicvir_etiquetas.csv")
writexl::write_xlsx(etiquetas, "datos/sicvir_etiquetas.xlsx")
