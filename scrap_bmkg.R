library(rvest)
library(httr)
library(tidyverse)


## BMKG
url_cuaca <- "https://www.bmkg.go.id/cuaca/prakiraan-cuaca-indonesia.bmkg"
webpage_1 <- read_html(url_cuaca)

# Misalkan kita ingin mengekstrak tabel prakiraan cuaca
tabel_prakiraan <- webpage_1 %>%
  html_nodes("table") %>%
  html_table(fill = TRUE)

# Convert list ke dataframe
df_prakiraan_1 <- tabel_prakiraan[[1]]

# Simpan data ke file CSV
scrap_bmkg <- df_prakiraan_1
write.csv(scrap_bmkg, "scrap_bmkg.csv", row.names = FALSE)