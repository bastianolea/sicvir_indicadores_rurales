library(readxl)
library(readr)
library(janitor)
library(dplyr)
library(tidyr)
library(stringr)

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



# tienen una variable en el nombre de columna
datos2 <- datos |> 
  pivot_longer(cols = 6:last_col(), 
               values_transform = as.character,
               names_to = "variable",
               values_to = "valor") |> 
  # convertir columnas a numéricas
  mutate(valor = parse_number(valor, locale = locale(decimal_mark = ".", grouping_mark = ""))) |> 
  # separar variable compuesta
  separate(variable, into = c("variable", "año"), sep = "_") |> 
  # ordenar años
  mutate(año = factor(año, c("lb", "2m", "3m", "4m")))

# dejar solo la medición más reciente
datos3 <- datos2 |> 
  group_by(codigo_region, codigo_comuna, variable) |> 
  slice_max(año) |> 
  ungroup()

# volver a wide
datos4 <- datos3 |> 
  select(-año) |>
  pivot_wider(values_from = valor, names_from = variable) |> 
  rename(region = nombre_region)

# limpiar
datos5 <- datos4 |> 
  rename(clasificacion = clasificacion_pndr) |> 
  mutate(clasificacion = str_to_title(clasificacion))

# cargar nombres de comunas
cut_comunas <- read_csv2("datos/datos_externos/cut_comuna.csv") |> 
  select(codigo_region, nombre_region, codigo_comuna, nombre_comuna) |> 
  mutate(codigo_comuna = as.numeric(codigo_comuna))

# estandarizar nombres de comunas
datos6 <- datos5 |> 
  select(-codigo_region, -region, -comuna) |>
  left_join(cut_comunas,
            by = "codigo_comuna") |> 
  relocate(codigo_region, nombre_region, codigo_comuna, nombre_comuna,
           everything())

# solo dejar etiquetas presentes en los datos
etiquetas2 <- etiquetas |> 
  filter(campo %in% names(datos6),
         !str_detect(campo, "codigo_"),
         !str_detect(campo, "nombre_")) |> 
  arrange(campo)

# agregar columna de ultima medición
etiquetas3 <- etiquetas2 |> 
  mutate(across(starts_with("ano"),
                ~na_if(.x, "-"))) |>
  pivot_longer(starts_with("ano"),
               values_to = "ultima_medicion", names_to = "medicion",
               values_transform = as.numeric) |> 
  # select(-medicion) |> 
  mutate(medicion = ifelse(is.na(ultima_medicion), NA, medicion)) |> 
  distinct() |> 
  group_by(campo) |> 
  slice_max(ultima_medicion) |> 
  ungroup()


# guardar ----
write_csv2(datos6, "datos/sicvir_indicadores_rurales_2025.csv")
writexl::write_xlsx(datos6, "datos/sicvir_indicadores_rurales_2025.xlsx")

write_csv2(etiquetas3, "datos/sicvir_etiquetas_2025.csv")
writexl::write_xlsx(etiquetas3, "datos/sicvir_etiquetas_2025.xlsx")
