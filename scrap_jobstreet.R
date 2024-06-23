# hapus environment
rm(list=ls())

library(dplyr)
library(rvest)
library(httr)
library(tidyverse)
library(stringr)

url_jobstreet <- "https://www.jobstreet.co.id/companies"
webpage_2 <- read_html(url_jobstreet)

# Ekstrak judul pekerjaan
companies <- webpage_2 %>%
  html_nodes("._1cyi0rr5") %>% # Ganti dengan selector CSS yang sesuai
  html_text()

# Membuat dataframe
scrap_jobstreet <- data.frame(
  Companies = companies,
  stringsAsFactors = FALSE
)

# Definisikan regex untuk mengekstrak informasi perusahaan
pattern <- "([A-Za-z &-]+\\d(?:\\.\\d)? \\· \\d+ Reviews\\d+ Jobs)"

# Ekstrak pola yang sesuai
extracted_info <- str_extract_all(scrap_jobstreet$Companies, pattern)

# Bentuk ulang menjadi data frame dengan satu kolom per baris
scrap_jobstreet <- data.frame(info = unlist(extracted_info))

# Pisahkan teks menjadi empat kolom
scrap_jobstreet <- scrap_jobstreet %>%
  mutate(
    Company = str_extract(info, "^[A-Za-z &-]+"), # Ekstrak nama perusahaan
    Rating = str_extract(info, "\\d+(\\.\\d)?"), # Ekstrak rating
    Reviews = str_extract(info, "\\d+ Reviews"), # Ekstrak ulasan
    Jobs = str_extract(info, "\\d+ Jobs") # Ekstrak jumlah pekerjaan
  )
scrap_jobstreet <- scrap_jobstreet %>% select(-info)

# Buat nama file
nama_file = Sys.time() %>% as.character()
nama_file = paste0(nama_file,".csv")

# Simpan data ke file CSV
write.csv(scrap_jobstreet, nama_file) 