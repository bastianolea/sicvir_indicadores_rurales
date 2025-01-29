# Sistema de Indicadores de Calidad de Vida Rural
# https://www.ine.gob.cl/herramientas/portal-de-mapas/sicvir

url <- "https://www.ine.gob.cl/docs/default-source/sistema-de-indicadores-de-calidad-de-vida-rural/indicadores/3ra-medición/indicadores-sicvir-3ra-medicion-resultados.xlsx"

# library(rvest)
# sitio <- session("https://www.ine.gob.cl/herramientas/portal-de-mapas/sicvir") |> 
#   read_html()
# 
# sitio |> 
#   html_elements(".tituloDescargaArchivos")

dir.create("datos")
dir.create("datos/datos_originales")

library(stringr)

archivo <- url |> str_extract("indicadores-sicvir.*xlsx")
ruta <- paste("datos/datos_originales/", archivo, sep = "")

# descargar
download.file(url, ruta)


