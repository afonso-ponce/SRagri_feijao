library(tibble)
library(sits)
library(sf)
library(dplyr)

amostras_sf <- st_read("SR_agricola/feijao/dados/pontos_feijao.gpkg") |>
  st_transform(crs = 4326) |>
  rename(label = Class_s) |>
  mutate(
    start_date = as.Date("2023-10-01"),  # ajuste ao início real da safra de feijão
    end_date   = as.Date("2024-03-31")   # ajuste ao fim real do ciclo
  ) |>
  select(label, start_date, end_date, geom)  # mantém só o essencial + geometria

amostras_feijao <- amostras_sf |> filter(label == "Feijao")

coords <- st_coordinates(amostras_feijao)

lon_max <- max(coords[, "X"])
lon_min <- min(coords[, "X"])
lat_max <- max(coords[, "Y"])
lat_min <- min(coords[, "Y"])

# Define o roi para os dados de feijão
roi_feijao <- c(
  "lat_max" = lat_max,
  "lat_min" = lat_min,
  "lon_max" = lon_max,
  "lon_min" = lon_min
)



bdc_cube <- sits_cube(
  source = "BDC",
  collection  = "SENTINEL-2-16D",
  bands = c("NDVI", "EVI"),
  roi = roi_feijao,
  start_date = "2019-09-30",
  end_date = "2020-09-29"
)


# Copy the region of interest to a local directory
lem_cube <- sits_cube_copy(
  cube = bdc_cube,
  roi = roi_feijao,
  output_dir = "/home/jovyan/SR_agricola/feijao/tempdir"
)

plot(lem_cube, palette = "RdYlGn")
