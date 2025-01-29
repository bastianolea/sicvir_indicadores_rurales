library(readxl)
library(readr)
library(janitor)
library(dplyr)

# datos enviados por Matías Poch el 19/01/2025
archivo <- "datos/datos_originales/SICVIR_SUBDERE_28Ene2025.xlsx"

# cargar etiquetas 
# (variables con su nombre de columna, año y descripción)
etiquetas <- read_xlsx(archivo, sheet = 1) |> 
  row_to_names(6) |> 
  clean_names() |> 
  mutate(campo = make_clean_names(campo))

# cargar datos
datos <- read_xlsx(archivo, sheet = 2) |> 
  clean_names()

library(tidyr)
library(stringr)

# tienen una variable en el nombre de columna
datos2 <- datos |> 
  pivot_longer(cols = 6:last_col(), 
               values_transform = as.character,
               names_to = "variable",
               values_to = "valor") |> 
  mutate(valor = parse_number(valor, locale = locale(decimal_mark = ".", grouping_mark = ""))) |> 
  separate(variable, into = c("variable", "año"), sep = "_") |> 
  mutate(año = factor(año, c("lb", "2m", "3m", "4m")))

# dejar solo la medición más reciente
datos3 <- datos2 |> 
  group_by(codigo_region, codigo_comuna, variable) |> 
  slice_max(año) |> 
  ungroup()

# volver a wide
datos4 <- datos3 |> 
  select(-año) |>
  pivot_wider(values_from = valor, names_from = variable)

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
