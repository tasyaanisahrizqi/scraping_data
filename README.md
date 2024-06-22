# PROSES SCRAPING

    library(rvest)

    ## Warning: package 'rvest' was built under R version 4.3.3

    library(httr)

    ## Warning: package 'httr' was built under R version 4.3.3

    library(tidyverse)

    ## Warning: package 'purrr' was built under R version 4.3.3

    ## ── Attaching core tidyverse packages ───────────────────────────────────────────────────── tidyverse 2.0.0 ──
    ## ✔ forcats 1.0.0     ✔ tibble  3.2.1
    ## ✔ purrr   1.0.2     ✔ tidyr   1.3.0
    ## ✔ readr   2.1.4     
    ## ── Conflicts ─────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter()         masks stats::filter()
    ## ✖ readr::guess_encoding() masks rvest::guess_encoding()
    ## ✖ dplyr::lag()            masks stats::lag()
    ## ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

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
    cuaca_22_06_24 <- df_prakiraan_1
    write.csv(cuaca_22_06_24, "cuaca_22_06_24.csv", row.names = FALSE)

## JOBSTREET

    url_jobstreet <- "https://www.jobstreet.co.id/companies"
    webpage_2 <- read_html(url_jobstreet)

    # Ekstrak judul pekerjaan
    companies <- webpage_2 %>%
      html_nodes("._1cyi0rr5") %>% # Ganti dengan selector CSS yang sesuai
      html_text()

    # Membuat dataframe
    df_jobstreet <- data.frame(
      Companies = companies,
      stringsAsFactors = FALSE
    )

    library(stringr)

    # Definisikan regex untuk mengekstrak informasi perusahaan
    pattern <- "([A-Za-z &-]+\\d(?:\\.\\d)? \\· \\d+ Reviews\\d+ Jobs)"

    # Ekstrak pola yang sesuai
    extracted_info <- str_extract_all(df_jobstreet$Companies, pattern)

    # Bentuk ulang menjadi data frame dengan satu kolom per baris
    df_jobstreet <- data.frame(info = unlist(extracted_info))

    # Pisahkan teks menjadi empat kolom
    df_jobstreet <- df_jobstreet %>%
      mutate(
        Company = str_extract(info, "^[A-Za-z &-]+"), # Ekstrak nama perusahaan
        Rating = str_extract(info, "\\d+(\\.\\d)?"), # Ekstrak rating
        Reviews = str_extract(info, "\\d+ Reviews"), # Ekstrak ulasan
        Jobs = str_extract(info, "\\d+ Jobs") # Ekstrak jumlah pekerjaan
      )

    df_jobstreet <- df_jobstreet %>% select(-info)

    df_jobstreet

    ##                  Company Rating      Reviews     Jobs
    ## 1               DBS Bank    4.4  159 Reviews  14 Jobs
    ## 2           Bank Danamon    4.2 1047 Reviews  13 Jobs
    ## 3               Manulife    4.2  149 Reviews  22 Jobs
    ## 4                     EY    4.2  130 Reviews  67 Jobs
    ## 5    Mitracomm Ekasarana    4.2  125 Reviews  32 Jobs
    ## 6     Schneider Electric    4.5  147 Reviews  14 Jobs
    ## 7              Traveloka    4.3   28 Reviews 105 Jobs
    ## 8                   ASRI    4.2   21 Reviews  77 Jobs
    ## 9  PT Freeport Indonesia    4.7  133 Reviews  10 Jobs
    ## 10              Deloitte    4.2   30 Reviews  29 Jobs
    ## 11     Indomobil Finance    3.9  133 Reviews  18 Jobs
    ## 12             Metrodata    3.9   12 Reviews  64 Jobs
    ## 13      Jiva Agriculture      4    3 Reviews  44 Jobs
    ## 14                Abbott    4.3   40 Reviews   4 Jobs
    ## 15                Nestle    4.5  125 Reviews   9 Jobs

    # Simpan data ke file CSV
    write.csv(df_jobstreet, "jobstreet_22_06_24.csv", row.names = FALSE)

# HASIL SCRAPING

## BMKG

    bmkg_15 <- read.csv("cuaca_15_06_24.csv")
    bmkg_16 <- read.csv("cuaca_16_06_24.csv")
    bmkg_17 <- read.csv("cuaca_17_06_24.csv")
    bmkg_18 <- read.csv("cuaca_18_06_24.csv")
    bmkg_19 <- read.csv("cuaca_19_06_24.csv")
    bmkg_20 <- read.csv("cuaca_20_06_24.csv")
    bmkg_21 <- read.csv("cuaca_21_06_24.csv")

    modify_dataframe <- function(df) {
      df <- df[c(3, 2, 1, 4:nrow(df)), ]
      df <- df[-c(1, 2), ]
      rownames(df) <- NULL
      colnames(df) <- c("Kota", "Pagi", "Siang", "Malam", "Dini_Hari", "Suhu", "Kelembapan")
      return(df)
    }
    bmkg <- list(bmkg_15, bmkg_16, bmkg_17, bmkg_18, bmkg_19, bmkg_20, bmkg_21)
    data_bmkg <- lapply(bmkg, modify_dataframe)
    bmkg_15 <- data_bmkg[[1]]
    bmkg_16 <- data_bmkg[[2]]
    bmkg_17 <- data_bmkg[[3]]
    bmkg_18 <- data_bmkg[[4]]
    bmkg_19 <- data_bmkg[[5]]
    bmkg_20 <- data_bmkg[[6]]
    bmkg_21 <- data_bmkg[[7]]

### Menampilkan Data Scraping

    library(dplyr)
    library(lubridate)
    library(knitr)

    # Menyimpan dataset dalam list
    bmkg <- list(bmkg_15, bmkg_16, bmkg_17, bmkg_18, bmkg_19, bmkg_20, bmkg_21)

    # Membuat urutan tanggal dari 15 Juni 2024 hingga 21 Juni 2024
    dates <- seq(ymd("2024-06-15"), by = "days", length.out = length(bmkg))

    # Menggabungkan semua dataset dalam list menjadi satu dataset besar dan menambahkan kolom tanggal
    data_bmkg <- bind_rows(bmkg, .id = "Tanggal") %>%
      mutate(Tanggal = dates[as.numeric(Tanggal)])

    kable(data_bmkg, format = "markdown")

<table>
<colgroup>
<col style="width: 10%" />
<col style="width: 14%" />
<col style="width: 13%" />
<col style="width: 13%" />
<col style="width: 13%" />
<col style="width: 13%" />
<col style="width: 7%" />
<col style="width: 10%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Tanggal</th>
<th style="text-align: left;">Kota</th>
<th style="text-align: left;">Pagi</th>
<th style="text-align: left;">Siang</th>
<th style="text-align: left;">Malam</th>
<th style="text-align: left;">Dini_Hari</th>
<th style="text-align: left;">Suhu</th>
<th style="text-align: left;">Kelembapan</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Banda Aceh</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">24 - 34</td>
<td style="text-align: left;">60 - 85</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Denpasar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">70 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Serang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 34</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Bengkulu</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">22 - 32</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Yogyakarta</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 32</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Jakarta Pusat</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">24 - 30</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Gorontalo</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Jambi</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Bandung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">20 - 27</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Semarang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Surabaya</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">26 - 33</td>
<td style="text-align: left;">55 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Pontianak</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 34</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Banjarmasin</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Palangkaraya</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Samarinda</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">24 - 28</td>
<td style="text-align: left;">85 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Tarakan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Pangkal Pinang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Tanjung Pinang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 31</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Bandar Lampung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">55 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Ambon</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 30</td>
<td style="text-align: left;">80 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Ternate</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Mataram</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">22 - 31</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Kupang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">50 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Kota Jayapura</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Manokwari</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Pekanbaru</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 30</td>
<td style="text-align: left;">80 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Mamuju</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">25 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Makassar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">75 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Kendari</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Manado</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Padang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">23 - 30</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Palembang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Medan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Banda Aceh</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 35</td>
<td style="text-align: left;">50 - 85</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Denpasar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Serang</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">22 - 32</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Bengkulu</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Yogyakarta</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Jakarta Pusat</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 29</td>
<td style="text-align: left;">80 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Gorontalo</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Jambi</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Bandung</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">19 - 26</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Semarang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Surabaya</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">25 - 33</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Pontianak</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">23 - 34</td>
<td style="text-align: left;">55 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Banjarmasin</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Palangkaraya</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 34</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Samarinda</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Tarakan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Pangkal Pinang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Tanjung Pinang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Bandar Lampung</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 28</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Ambon</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 30</td>
<td style="text-align: left;">80 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Ternate</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 31</td>
<td style="text-align: left;">70 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Mataram</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">22 - 32</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Kupang</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">50 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Kota Jayapura</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Manokwari</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Pekanbaru</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">24 - 29</td>
<td style="text-align: left;">80 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Mamuju</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">26 - 30</td>
<td style="text-align: left;">70 - 85</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Makassar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Kendari</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Manado</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Padang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 26</td>
<td style="text-align: left;">90 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Palembang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Medan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 29</td>
<td style="text-align: left;">80 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Banda Aceh</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">55 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Denpasar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Serang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Bengkulu</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Yogyakarta</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Jakarta Pusat</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 32</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Gorontalo</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Jambi</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Bandung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">17 - 32</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Semarang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">26 - 33</td>
<td style="text-align: left;">60 - 85</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Surabaya</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">25 - 33</td>
<td style="text-align: left;">60 - 85</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Pontianak</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Banjarmasin</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Palangkaraya</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Samarinda</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Tarakan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 31</td>
<td style="text-align: left;">75 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Pangkal Pinang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Tanjung Pinang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Bandar Lampung</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 29</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Ambon</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 30</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Ternate</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Mataram</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">22 - 31</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Kupang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">50 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Kota Jayapura</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Manokwari</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Pekanbaru</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">24 - 30</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Mamuju</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">25 - 28</td>
<td style="text-align: left;">80 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Makassar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 33</td>
<td style="text-align: left;">65 - 85</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Kendari</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Manado</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">22 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Padang</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">75 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Palembang</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">23 - 29</td>
<td style="text-align: left;">80 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Medan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Banda Aceh</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 33</td>
<td style="text-align: left;">55 - 80</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Denpasar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">22 - 32</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Serang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 34</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Bengkulu</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Yogyakarta</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Jakarta Pusat</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 28</td>
<td style="text-align: left;">80 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Gorontalo</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Jambi</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Bandung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">20 - 32</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Semarang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 33</td>
<td style="text-align: left;">60 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Surabaya</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">26 - 32</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Pontianak</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Banjarmasin</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Palangkaraya</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Samarinda</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">24 - 29</td>
<td style="text-align: left;">80 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Tarakan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Pangkal Pinang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Tanjung Pinang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 32</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Bandar Lampung</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 28</td>
<td style="text-align: left;">80 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Ambon</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 30</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Ternate</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Mataram</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">22 - 32</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Kupang</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">22 - 33</td>
<td style="text-align: left;">55 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Kota Jayapura</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Manokwari</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Pekanbaru</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Mamuju</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Makassar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">26 - 33</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Kendari</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Manado</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Padang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">75 - 85</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Palembang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Medan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Banda Aceh</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 34</td>
<td style="text-align: left;">55 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Denpasar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">60 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Serang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 34</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Bengkulu</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Yogyakarta</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Jakarta Pusat</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 32</td>
<td style="text-align: left;">60 - 85</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Gorontalo</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Jambi</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Bandung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">20 - 31</td>
<td style="text-align: left;">50 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Semarang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 35</td>
<td style="text-align: left;">55 - 85</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Surabaya</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 34</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Pontianak</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Banjarmasin</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Palangkaraya</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Samarinda</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">23 - 30</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Tarakan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">75 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Pangkal Pinang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Tanjung Pinang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Bandar Lampung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 29</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Ambon</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 29</td>
<td style="text-align: left;">80 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Ternate</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Mataram</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">21 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Kupang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">50 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Kota Jayapura</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Manokwari</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Pekanbaru</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Mamuju</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Makassar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">26 - 33</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Kendari</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Manado</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 30</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Padang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">80 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Palembang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 34</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Medan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Banda Aceh</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">25 - 34</td>
<td style="text-align: left;">55 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Denpasar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 31</td>
<td style="text-align: left;">55 - 85</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Serang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 34</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Bengkulu</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">80 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Yogyakarta</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">22 - 34</td>
<td style="text-align: left;">55 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Jakarta Pusat</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 31</td>
<td style="text-align: left;">60 - 85</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Gorontalo</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Jambi</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Bandung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">20 - 30</td>
<td style="text-align: left;">60 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Semarang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 34</td>
<td style="text-align: left;">50 - 85</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Surabaya</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">50 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Pontianak</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 34</td>
<td style="text-align: left;">60 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Banjarmasin</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Palangkaraya</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Samarinda</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Tarakan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">25 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Pangkal Pinang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Tanjung Pinang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 31</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Bandar Lampung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 29</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Ambon</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 30</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Ternate</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Mataram</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">21 - 32</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Kupang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">50 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Kota Jayapura</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Manokwari</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Pekanbaru</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 30</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Mamuju</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Makassar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 34</td>
<td style="text-align: left;">65 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Kendari</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Manado</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Padang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 27</td>
<td style="text-align: left;">85 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Palembang</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 30</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Medan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Banda Aceh</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 34</td>
<td style="text-align: left;">50 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Denpasar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">60 - 85</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Serang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 34</td>
<td style="text-align: left;">60 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Bengkulu</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">25 - 33</td>
<td style="text-align: left;">70 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Yogyakarta</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">50 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Jakarta Pusat</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">25 - 31</td>
<td style="text-align: left;">60 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Gorontalo</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Jambi</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 32</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Bandung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">20 - 32</td>
<td style="text-align: left;">55 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Semarang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 34</td>
<td style="text-align: left;">50 - 85</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Surabaya</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">25 - 35</td>
<td style="text-align: left;">40 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Pontianak</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Banjarmasin</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">60 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Palangkaraya</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 34</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Samarinda</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">24 - 29</td>
<td style="text-align: left;">80 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Tarakan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">25 - 31</td>
<td style="text-align: left;">70 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Pangkal Pinang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Tanjung Pinang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">25 - 31</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Bandar Lampung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">21 - 30</td>
<td style="text-align: left;">65 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Ambon</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">24 - 29</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Ternate</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">70 - 100</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Mataram</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">20 - 32</td>
<td style="text-align: left;">55 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Kupang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">21 - 32</td>
<td style="text-align: left;">50 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Kota Jayapura</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Manokwari</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan Tebal</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Pekanbaru</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 33</td>
<td style="text-align: left;">75 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Mamuju</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">25 - 30</td>
<td style="text-align: left;">70 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Makassar</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">70 - 90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Kendari</td>
<td style="text-align: left;">Hujan Sedang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">24 - 30</td>
<td style="text-align: left;">75 - 95</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Manado</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">23 - 31</td>
<td style="text-align: left;">65 - 95</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Padang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">24 - 31</td>
<td style="text-align: left;">75 - 90</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Palembang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 33</td>
<td style="text-align: left;">60 - 100</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Medan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">23 - 32</td>
<td style="text-align: left;">70 - 95</td>
</tr>
</tbody>
</table>

### Menampilkan Rata-rata Pagi, Siang, Malam, dan Dini Hari serta Kategori Suhu dan Kelembapan

    # Fungsi untuk mengubah nilai rentang menjadi nilai tengah
    convert_range <- function(x) {
      # Split rentang menjadi nilai terendah dan tertinggi
      range_values <- strsplit(x, " - ")
      min_value <- as.numeric(sapply(range_values, `[`, 1))
      max_value <- as.numeric(sapply(range_values, `[`, 2))
      # Kembalikan nilai tengah
      return((min_value + max_value) / 2)
    }

    # Mengonversi variabel suhu dan kelembapan menjadi nilai numerik tengah
    data_bmkg <- data_bmkg %>%
      mutate(across(c(Suhu, Kelembapan), convert_range))

    stat_mode <- function(x) {
      uniq_x <- unique(x)
      uniq_x[which.max(tabulate(match(x, uniq_x)))]
    }

    # Buat ringkasan berdasarkan kota
    bmkg_by_city <- data_bmkg %>%
      group_by(Kota) %>%
      summarize(mean_pagi = stat_mode(Pagi),
                mean_siang = stat_mode(Siang),
                mean_malam = stat_mode(Malam),
                mean_dini_hari = stat_mode(Dini_Hari),
                mean_suhu = mean(Suhu),
                mean_kelembapan = mean(Kelembapan))

    # Menambahkan kolom kategori suhu
    bmkg_by_city <- bmkg_by_city %>%
      mutate(mean_suhu = case_when(
        as.numeric(mean_suhu) < 10 ~ "Sangat Dingin",
        as.numeric(mean_suhu) >= 10 & as.numeric(mean_suhu) < 15 ~ "Dingin",
        as.numeric(mean_suhu) >= 15 & as.numeric(mean_suhu) < 20 ~ "Sejuk",
        as.numeric(mean_suhu) >= 20 & as.numeric(mean_suhu) < 25 ~ "Sedang",
        as.numeric(mean_suhu) >= 25 & as.numeric(mean_suhu) < 30 ~ "Hangat",
        as.numeric(mean_suhu) >= 30 & as.numeric(mean_suhu) < 35 ~ "Panas",
        as.numeric(mean_suhu) >= 35 ~ "Sangat Panas",
        TRUE ~ "Tidak Diketahui"  # Untuk menangani nilai yang tidak sesuai kategori di atas
      )) %>%
      mutate(mean_kelembapan = case_when(
        as.numeric(mean_kelembapan) < 30 ~ "Sangat Kering",
        as.numeric(mean_kelembapan) >= 30 & as.numeric(mean_kelembapan) < 40 ~ "Kering",
        as.numeric(mean_kelembapan) >= 40 & as.numeric(mean_kelembapan) < 60 ~ "Sedang",
        as.numeric(mean_kelembapan) >= 60 & as.numeric(mean_kelembapan) < 80 ~ "Lembap",
        as.numeric(mean_kelembapan) >= 80 ~ "Sangat Lembap",
        TRUE ~ "Tidak Diketahui"  # Untuk menangani nilai yang tidak sesuai kategori di atas
      ))
    kable(bmkg_by_city, format = "markdown")

<table style="width:100%;">
<colgroup>
<col style="width: 15%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 15%" />
<col style="width: 10%" />
<col style="width: 16%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Kota</th>
<th style="text-align: left;">mean_pagi</th>
<th style="text-align: left;">mean_siang</th>
<th style="text-align: left;">mean_malam</th>
<th style="text-align: left;">mean_dini_hari</th>
<th style="text-align: left;">mean_suhu</th>
<th style="text-align: left;">mean_kelembapan</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Ambon</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Banda Aceh</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Bandar Lampung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Bandung</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Sedang</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Banjarmasin</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Bengkulu</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Denpasar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Gorontalo</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Jakarta Pusat</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Jambi</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Kendari</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Kota Jayapura</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Kupang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Makassar</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Mamuju</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Manado</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Manokwari</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Mataram</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Medan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Lebat</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Padang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Palangkaraya</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Palembang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Pangkal Pinang</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Petir</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Pekanbaru</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Pontianak</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Samarinda</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Kabut</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Semarang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Serang</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Surabaya</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Tanjung Pinang</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Tarakan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="even">
<td style="text-align: left;">Ternate</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Hujan Ringan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Sangat Lembap</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Yogyakarta</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Cerah Berawan</td>
<td style="text-align: left;">Berawan</td>
<td style="text-align: left;">Hangat</td>
<td style="text-align: left;">Lembap</td>
</tr>
</tbody>
</table>

## JOBSTREET

    jobstreet_15 <- read.csv("jobstreet_15_06_24.csv")
    jobstreet_16 <- read.csv("jobstreet_16_06_24.csv")
    jobstreet_17 <- read.csv("jobstreet_17_06_24.csv")
    jobstreet_18 <- read.csv("jobstreet_18_06_24.csv")
    jobstreet_19 <- read.csv("jobstreet_19_06_24.csv")
    jobstreet_20 <- read.csv("jobstreet_20_06_24.csv")
    jobstreet_21 <- read.csv("jobstreet_21_06_24.csv")

    library(dplyr)
    library(stringr)

    remove_df <- function(df)
    {
      df %>%
        mutate(Reviews = str_replace(Reviews, " Reviews", "")) %>%
        mutate(Reviews = as.numeric(Reviews)) %>%
        mutate(Jobs = str_replace(Jobs, " Jobs", "")) %>%
        mutate(Jobs = as.numeric(Jobs))
    }

    # Terapkan fungsi remove_reviews ke masing-masing dataset
    jobstreet_15 <- remove_df(jobstreet_15)
    jobstreet_16 <- remove_df(jobstreet_16)
    jobstreet_17 <- remove_df(jobstreet_17)
    jobstreet_18 <- remove_df(jobstreet_18)
    jobstreet_19 <- remove_df(jobstreet_19)
    jobstreet_20 <- remove_df(jobstreet_20)
    jobstreet_21 <- remove_df(jobstreet_21)

### Menampilkan Data Scraping

    library(dplyr)

    # Menyimpan dataset dalam list
    jobstreet <- list(jobstreet_15, jobstreet_16, jobstreet_17, jobstreet_18, jobstreet_19, jobstreet_20, 
                 jobstreet_21)

    # Membuat urutan tanggal dari 15 Juni 2024 hingga 21 Juni 2024
    dates <- seq(ymd("2024-06-15"), by = "days", length.out = length(jobstreet))

    # Menggabungkan semua dataset dalam list menjadi satu dataset besar dan menambahkan kolom tanggal
    data_jobstreet <- bind_rows(jobstreet, .id = "Tanggal") %>%
      mutate(Tanggal = dates[as.numeric(Tanggal)])

    kable(data_jobstreet, format = "markdown")

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Tanggal</th>
<th style="text-align: left;">Company</th>
<th style="text-align: right;">Rating</th>
<th style="text-align: right;">Reviews</th>
<th style="text-align: right;">Jobs</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Aeon Credit Service</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">44</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Gojek</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">213</td>
<td style="text-align: right;">62</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">United Tractors</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">129</td>
<td style="text-align: right;">12</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Deloitte</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">30</td>
<td style="text-align: right;">25</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Nusantara Sakti Group</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">429</td>
<td style="text-align: right;">14</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">EY</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">130</td>
<td style="text-align: right;">66</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">PT Freeport Indonesia</td>
<td style="text-align: right;">4.7</td>
<td style="text-align: right;">133</td>
<td style="text-align: right;">4</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Manulife</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">149</td>
<td style="text-align: right;">23</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">XL Axiata</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">264</td>
<td style="text-align: right;">23</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Panin Dai-Ichi Life</td>
<td style="text-align: right;">4.1</td>
<td style="text-align: right;">58</td>
<td style="text-align: right;">8</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">RGE Indonesia</td>
<td style="text-align: right;">3.8</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">4</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Kanmo Group</td>
<td style="text-align: right;">3.5</td>
<td style="text-align: right;">29</td>
<td style="text-align: right;">20</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">BFI Finance Indonesia</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">355</td>
<td style="text-align: right;">122</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Schneider Electric</td>
<td style="text-align: right;">4.5</td>
<td style="text-align: right;">147</td>
<td style="text-align: right;">11</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">Finfleet</td>
<td style="text-align: right;">3.4</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Aeon Credit Service</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">44</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Metrodata</td>
<td style="text-align: right;">3.9</td>
<td style="text-align: right;">12</td>
<td style="text-align: right;">61</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Indomobil Finance</td>
<td style="text-align: right;">3.9</td>
<td style="text-align: right;">133</td>
<td style="text-align: right;">15</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Gojek</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">213</td>
<td style="text-align: right;">62</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">JT International</td>
<td style="text-align: right;">4.6</td>
<td style="text-align: right;">45</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Nusantara Sakti Group</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">429</td>
<td style="text-align: right;">11</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">PwC</td>
<td style="text-align: right;">4.5</td>
<td style="text-align: right;">71</td>
<td style="text-align: right;">59</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">DBS Bank</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">159</td>
<td style="text-align: right;">14</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Nestle</td>
<td style="text-align: right;">4.5</td>
<td style="text-align: right;">125</td>
<td style="text-align: right;">6</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">PT Freeport Indonesia</td>
<td style="text-align: right;">4.7</td>
<td style="text-align: right;">133</td>
<td style="text-align: right;">4</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">EY</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">130</td>
<td style="text-align: right;">66</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">IBM</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">76</td>
<td style="text-align: right;">39</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Bank Danamon</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">1047</td>
<td style="text-align: right;">16</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">Finfleet</td>
<td style="text-align: right;">3.4</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">AXA</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">138</td>
<td style="text-align: right;">59</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Sinar Mas Land</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">78</td>
<td style="text-align: right;">7</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Finfleet</td>
<td style="text-align: right;">3.4</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">23</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Aeon Credit Service</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">44</td>
<td style="text-align: right;">14</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">BFI Finance Indonesia</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">355</td>
<td style="text-align: right;">142</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Lazada</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">100</td>
<td style="text-align: right;">38</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">DBS Bank</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">159</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Bayan Resources</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">18</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Manulife</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">149</td>
<td style="text-align: right;">23</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">AXA</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">138</td>
<td style="text-align: right;">59</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Kanmo Group</td>
<td style="text-align: right;">3.5</td>
<td style="text-align: right;">29</td>
<td style="text-align: right;">17</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Coway</td>
<td style="text-align: right;">3.9</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">6</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Panin Dai-Ichi Life</td>
<td style="text-align: right;">4.1</td>
<td style="text-align: right;">58</td>
<td style="text-align: right;">11</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">ASRI</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">21</td>
<td style="text-align: right;">81</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">United Tractors</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">129</td>
<td style="text-align: right;">12</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">PwC</td>
<td style="text-align: right;">4.5</td>
<td style="text-align: right;">71</td>
<td style="text-align: right;">61</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Bank Danamon</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">1047</td>
<td style="text-align: right;">12</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Schneider Electric</td>
<td style="text-align: right;">4.5</td>
<td style="text-align: right;">147</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Aeon Credit Service</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">44</td>
<td style="text-align: right;">14</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Finfleet</td>
<td style="text-align: right;">3.4</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">19</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Panin Dai-Ichi Life</td>
<td style="text-align: right;">4.1</td>
<td style="text-align: right;">58</td>
<td style="text-align: right;">8</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Sheraton</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">53</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">IBM</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">76</td>
<td style="text-align: right;">27</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">XL Axiata</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">264</td>
<td style="text-align: right;">22</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">ASRI</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">21</td>
<td style="text-align: right;">81</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">PwC</td>
<td style="text-align: right;">4.5</td>
<td style="text-align: right;">71</td>
<td style="text-align: right;">61</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Lazada</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">100</td>
<td style="text-align: right;">6</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Indomobil Finance</td>
<td style="text-align: right;">3.9</td>
<td style="text-align: right;">133</td>
<td style="text-align: right;">16</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Kawan Lama</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">180</td>
<td style="text-align: right;">52</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">BFI Finance Indonesia</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">355</td>
<td style="text-align: right;">131</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Yakult</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">223</td>
<td style="text-align: right;">68</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Sheraton</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">47</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">United Tractors</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">129</td>
<td style="text-align: right;">12</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Deloitte</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">30</td>
<td style="text-align: right;">26</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Nestle</td>
<td style="text-align: right;">4.5</td>
<td style="text-align: right;">125</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Panin Dai-Ichi Life</td>
<td style="text-align: right;">4.1</td>
<td style="text-align: right;">58</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Accenture</td>
<td style="text-align: right;">4.1</td>
<td style="text-align: right;">42</td>
<td style="text-align: right;">15</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">JT International</td>
<td style="text-align: right;">4.6</td>
<td style="text-align: right;">45</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Coda Payments</td>
<td style="text-align: right;">5.0</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">18</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">DBS Bank</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">159</td>
<td style="text-align: right;">16</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Indomobil Finance</td>
<td style="text-align: right;">3.9</td>
<td style="text-align: right;">133</td>
<td style="text-align: right;">19</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Manulife</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">149</td>
<td style="text-align: right;">20</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Danone</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">68</td>
<td style="text-align: right;">12</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Finfleet</td>
<td style="text-align: right;">3.4</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">25</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Metrodata</td>
<td style="text-align: right;">3.9</td>
<td style="text-align: right;">12</td>
<td style="text-align: right;">59</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Bayan Resources</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">18</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Coda Payments</td>
<td style="text-align: right;">5.0</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">18</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">JobsEY</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">130</td>
<td style="text-align: right;">67</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Indomobil Finance</td>
<td style="text-align: right;">3.9</td>
<td style="text-align: right;">133</td>
<td style="text-align: right;">19</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Finfleet</td>
<td style="text-align: right;">3.4</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">30</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">DBS Bank</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">159</td>
<td style="text-align: right;">15</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">PwC</td>
<td style="text-align: right;">4.5</td>
<td style="text-align: right;">71</td>
<td style="text-align: right;">61</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">PT Freeport Indonesia</td>
<td style="text-align: right;">4.7</td>
<td style="text-align: right;">133</td>
<td style="text-align: right;">10</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">XL Axiata</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">264</td>
<td style="text-align: right;">23</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">United Tractors</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">129</td>
<td style="text-align: right;">12</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Aeon Credit Service</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">44</td>
<td style="text-align: right;">15</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Kanmo Group</td>
<td style="text-align: right;">3.5</td>
<td style="text-align: right;">29</td>
<td style="text-align: right;">16</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Sheraton</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">49</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">co</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">2</td>
<td style="text-align: right;">19</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Gojek</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">213</td>
<td style="text-align: right;">89</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Sinar Mas Agribusiness and Food</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">431</td>
<td style="text-align: right;">72</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Bayan Resources</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">18</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Accenture</td>
<td style="text-align: right;">4.1</td>
<td style="text-align: right;">42</td>
<td style="text-align: right;">17</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Kanmo Group</td>
<td style="text-align: right;">3.5</td>
<td style="text-align: right;">29</td>
<td style="text-align: right;">19</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">KB Finansia Multi Finance</td>
<td style="text-align: right;">4.1</td>
<td style="text-align: right;">229</td>
<td style="text-align: right;">45</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Finfleet</td>
<td style="text-align: right;">3.4</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">24</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Traveloka</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">28</td>
<td style="text-align: right;">105</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Panin Dai-Ichi Life</td>
<td style="text-align: right;">4.1</td>
<td style="text-align: right;">58</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Yakult</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">223</td>
<td style="text-align: right;">72</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">JT International</td>
<td style="text-align: right;">4.6</td>
<td style="text-align: right;">45</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Nusantara Sakti Group</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">429</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">DBS Bank</td>
<td style="text-align: right;">4.4</td>
<td style="text-align: right;">159</td>
<td style="text-align: right;">14</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">ASRI</td>
<td style="text-align: right;">4.2</td>
<td style="text-align: right;">21</td>
<td style="text-align: right;">77</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Danone</td>
<td style="text-align: right;">4.3</td>
<td style="text-align: right;">68</td>
<td style="text-align: right;">12</td>
</tr>
</tbody>
</table>

### Menampilkan Kategori Rating

    data_jobstreet <- data_jobstreet %>%
      arrange(Company, desc(Tanggal)) %>%
      distinct(Company, .keep_all = TRUE) %>%
      distinct(Rating, Reviews, Jobs, .keep_all = TRUE) %>%
      mutate(Rating = case_when(
        as.numeric(Rating) <= 1 ~ "Sangat Buruk",
        as.numeric(Rating) > 1 & as.numeric(Rating) <= 2 ~ "Buruk",
        as.numeric(Rating) > 2 & as.numeric(Rating) <= 3 ~ "Cukup",
        as.numeric(Rating) > 3 & as.numeric(Rating) <= 4 ~ "Baik",
        as.numeric(Rating) > 4 & as.numeric(Rating) <= 5 ~ "Sangat Baik",
        TRUE ~ "Tidak Diketahui"  # Untuk menangani nilai yang tidak sesuai kategori di atas
      ))

    kable(data_jobstreet, format = "markdown")

<table>
<colgroup>
<col style="width: 16%" />
<col style="width: 47%" />
<col style="width: 17%" />
<col style="width: 11%" />
<col style="width: 7%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">Tanggal</th>
<th style="text-align: left;">Company</th>
<th style="text-align: left;">Rating</th>
<th style="text-align: right;">Reviews</th>
<th style="text-align: right;">Jobs</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">JobsEY</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">130</td>
<td style="text-align: right;">67</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">ASRI</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">21</td>
<td style="text-align: right;">77</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">AXA</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">138</td>
<td style="text-align: right;">59</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Accenture</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">42</td>
<td style="text-align: right;">17</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Aeon Credit Service</td>
<td style="text-align: left;">Baik</td>
<td style="text-align: right;">44</td>
<td style="text-align: right;">15</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">BFI Finance Indonesia</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">355</td>
<td style="text-align: right;">131</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Bank Danamon</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">1047</td>
<td style="text-align: right;">12</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Bayan Resources</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">18</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Coda Payments</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">18</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Coway</td>
<td style="text-align: left;">Baik</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">6</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">DBS Bank</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">159</td>
<td style="text-align: right;">14</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Danone</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">68</td>
<td style="text-align: right;">12</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Deloitte</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">30</td>
<td style="text-align: right;">26</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-16</td>
<td style="text-align: left;">EY</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">130</td>
<td style="text-align: right;">66</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Finfleet</td>
<td style="text-align: left;">Baik</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">24</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Gojek</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">213</td>
<td style="text-align: right;">89</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">IBM</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">76</td>
<td style="text-align: right;">27</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Indomobil Finance</td>
<td style="text-align: left;">Baik</td>
<td style="text-align: right;">133</td>
<td style="text-align: right;">19</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">JT International</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">45</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">KB Finansia Multi Finance</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">229</td>
<td style="text-align: right;">45</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Kanmo Group</td>
<td style="text-align: left;">Baik</td>
<td style="text-align: right;">29</td>
<td style="text-align: right;">19</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Kawan Lama</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">180</td>
<td style="text-align: right;">52</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Lazada</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">100</td>
<td style="text-align: right;">6</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Manulife</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">149</td>
<td style="text-align: right;">20</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Metrodata</td>
<td style="text-align: left;">Baik</td>
<td style="text-align: right;">12</td>
<td style="text-align: right;">59</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-19</td>
<td style="text-align: left;">Nestle</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">125</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Nusantara Sakti Group</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">429</td>
<td style="text-align: right;">13</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">PT Freeport Indonesia</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">133</td>
<td style="text-align: right;">10</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Panin Dai-Ichi Life</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">58</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">PwC</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">71</td>
<td style="text-align: right;">61</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-15</td>
<td style="text-align: left;">RGE Indonesia</td>
<td style="text-align: left;">Baik</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">4</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-18</td>
<td style="text-align: left;">Schneider Electric</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">147</td>
<td style="text-align: right;">9</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">Sheraton</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">49</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Sinar Mas Agribusiness and Food</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">431</td>
<td style="text-align: right;">72</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-17</td>
<td style="text-align: left;">Sinar Mas Land</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">78</td>
<td style="text-align: right;">7</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Traveloka</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">28</td>
<td style="text-align: right;">105</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">United Tractors</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">129</td>
<td style="text-align: right;">12</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">XL Axiata</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">264</td>
<td style="text-align: right;">23</td>
</tr>
<tr class="odd">
<td style="text-align: left;">2024-06-21</td>
<td style="text-align: left;">Yakult</td>
<td style="text-align: left;">Sangat Baik</td>
<td style="text-align: right;">223</td>
<td style="text-align: right;">72</td>
</tr>
<tr class="even">
<td style="text-align: left;">2024-06-20</td>
<td style="text-align: left;">co</td>
<td style="text-align: left;">Baik</td>
<td style="text-align: right;">2</td>
<td style="text-align: right;">19</td>
</tr>
</tbody>
</table>

# VISUALISASI DATA SCRAPING

## BMKG

    library(ggplot2)

    # Buat grafik horizontal bar plot untuk variabel Pagi
    ggplot(data_bmkg, aes(x = Kota, fill = Pagi)) +
      geom_bar(position = "dodge") +
      coord_flip() +
      labs(title = "Distribusi Cuaca Pagi Berdasarkan Kota per 15-21 Juni 2024",
           x = "Kota",
           y = "Frekuensi",
           fill = "Cuaca Pagi") +
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))

![](README_files/figure-markdown_strict/unnamed-chunk-48-1.png)

    # Buat grafik horizontal bar plot untuk variabel Siang
    ggplot(data_bmkg, aes(x = Kota, fill = Siang)) +
      geom_bar(position = "dodge") +
      coord_flip() +
      labs(title = "Distribusi Cuaca Siang Berdasarkan Kota per 15-21 Juni 2024",
           x = "Kota",
           y = "Frekuensi",
           fill = "Cuaca Siang") +
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))

![](README_files/figure-markdown_strict/unnamed-chunk-49-1.png)

    # Buat grafik horizontal bar plot untuk variabel Malam
    ggplot(data_bmkg, aes(x = Kota, fill = Malam)) +
      geom_bar(position = "dodge") +
      coord_flip() +
      labs(title = "Distribusi Cuaca Malam Berdasarkan Kota per 15-21 Juni 2024",
           x = "Kota",
           y = "Frekuensi",
           fill = "Cuaca Malam") +
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))

![](README_files/figure-markdown_strict/unnamed-chunk-50-1.png)

    # Buat grafik horizontal bar plot untuk variabel Dini Hari
    ggplot(data_bmkg, aes(x = Kota, fill = Dini_Hari)) +
      geom_bar(position = "dodge") +
      coord_flip() +
      labs(title = "Distribusi Cuaca Dini Hari Berdasarkan Kota per 15-21 Juni 2024",
           x = "Kota",
           y = "Frekuensi",
           fill = "Cuaca Dini Hari") +
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))

![](README_files/figure-markdown_strict/unnamed-chunk-51-1.png)

    # Buat grafik bar plot untuk Kota berdasarkan variabel Pagi
    ggplot(data_bmkg, aes(x = Pagi, fill = Kota)) +
      geom_bar(position = "dodge") +
      labs(title = "Distribusi Kota Berdasarkan Cuaca Pagi\nper 15-21 Juni 2024",
           x = "Cuaca Pagi",
           y = "Jumlah Kota",
           fill = "Kota") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"),
            axis.text.x = element_text(angle = 45, hjust = 1))

![](README_files/figure-markdown_strict/unnamed-chunk-52-1.png)

    # Buat grafik bar plot untuk Kota berdasarkan variabel Siang
    ggplot(data_bmkg, aes(x = Siang, fill = Kota)) +
      geom_bar(position = "dodge") +
      labs(title = "Distribusi Kota Berdasarkan Cuaca Siang\nper 15-21 Juni 2024",
           x = "Cuaca Siang",
           y = "Jumlah Kota",
           fill = "Kota") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"),
            axis.text.x = element_text(angle = 45, hjust = 1))

![](README_files/figure-markdown_strict/unnamed-chunk-53-1.png)

    # Buat grafik bar plot untuk Kota berdasarkan variabel Malam
    ggplot(data_bmkg, aes(x = Malam, fill = Kota)) +
      geom_bar(position = "dodge") +
      labs(title = "Distribusi Kota Berdasarkan Cuaca Malam\nper 15-21 Juni 2024",
           x = "Cuaca Malam",
           y = "Jumlah Kota",
           fill = "Kota") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"),
            axis.text.x = element_text(angle = 45, hjust = 1))

![](README_files/figure-markdown_strict/unnamed-chunk-54-1.png)

    # Buat grafik bar plot untuk Kota berdasarkan variabel Dini Hari
    ggplot(data_bmkg, aes(x = Dini_Hari, fill = Kota)) +
      geom_bar(position = "dodge") +
      labs(title = "Distribusi Kota Berdasarkan Cuaca Dini Hari\nper 15-21 Juni 2024",
           x = "Cuaca Dini Hari",
           y = "Jumlah Kota",
           fill = "Kota") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"),
            axis.text.x = element_text(angle = 45, hjust = 1))

![](README_files/figure-markdown_strict/unnamed-chunk-55-1.png)

    # Buat grafik horizontal bar plot untuk variabel Suhu
    ggplot(bmkg_by_city, aes(x = Kota, fill = mean_suhu)) +
      geom_bar(position = "dodge") +
      coord_flip() +
      labs(title = "Distribusi Suhu Berdasarkan Kota per 15-21 Juni 2024",
           x = "Kota",
           y = "Frekuensi",
           fill = "Suhu") +
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))

![](README_files/figure-markdown_strict/unnamed-chunk-56-1.png)

    # Buat grafik bar plot untuk Kota berdasarkan rata-rata suhu
    ggplot(bmkg_by_city, aes(x = mean_suhu, fill = Kota)) +
      geom_bar(position = "dodge") +
      labs(title = "Distribusi Kota Berdasarkan Suhu\nper 15-21 Juni 2024",
           x = "Suhu",
           y = "Jumlah Kota",
           fill = "Kota") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"),
            axis.text.x = element_text(angle = 45, hjust = 1))

![](README_files/figure-markdown_strict/unnamed-chunk-57-1.png)

    # Buat grafik horizontal bar plot untuk variabel Kelembapan
    ggplot(bmkg_by_city, aes(x = Kota, fill = mean_kelembapan)) +
      geom_bar(position = "dodge") +
      coord_flip() +
      labs(title = "Distribusi Kelembapan Berdasarkan Kota per 15-21 Juni 2024",
           x = "Kota",
           y = "Frekuensi",
           fill = "Kelembapan") +
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))

![](README_files/figure-markdown_strict/unnamed-chunk-58-1.png)

    # Buat grafik bar plot untuk Kota berdasarkan rata-rata kelembapan
    ggplot(bmkg_by_city, aes(x = mean_kelembapan, fill = Kota)) +
      geom_bar(position = "dodge") +
      labs(title = "Distribusi Kota Berdasarkan Kelembapan\nper 15-21 Juni 2024",
           x = "Kelembapan",
           y = "Jumlah Kota",
           fill = "Kota") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"),
            axis.text.x = element_text(angle = 45, hjust = 1))

![](README_files/figure-markdown_strict/unnamed-chunk-59-1.png)

## JOBSTREET

    library(ggplot2)

    # Buat grafik horizontal bar plot untuk variabel Rating
    ggplot(data_jobstreet, aes(x = Company, fill = Rating)) +
      geom_bar(position = "dodge") +
      coord_flip() +
      labs(title = "Distribusi Rating Berdasarkan Company per 15-21 Juni 2024",
           x = "Company",
           y = "Frekuensi",
           fill = "Rating") +
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))

![](README_files/figure-markdown_strict/unnamed-chunk-60-1.png)

    # Buat grafik bar plot untuk Company berdasarkan Rating
    ggplot(data_jobstreet, aes(x = Rating, fill = Company)) +
      geom_bar(position = "dodge") +
      labs(title = "Distribusi Company Berdasarkan Rating\nper 15-21 Juni 2024",
           x = "Rating",
           y = "Jumlah Company",
           fill = "Company") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"),
            axis.text.x = element_text(angle = 45, hjust = 1))

![](README_files/figure-markdown_strict/unnamed-chunk-61-1.png)

    library(ggplot2)

    # Buat grafik horizontal bar plot untuk variabel Reviews
    ggplot(data_jobstreet, aes(x = Company, y = Reviews)) +
      geom_bar(stat = "identity", fill = "pink")+
      coord_flip() +
      labs(title = "Distribusi Reviews Berdasarkan Company per 15-21 Juni 2024",
           x = "Company",
           y = "Reviews") +
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))

![](README_files/figure-markdown_strict/unnamed-chunk-62-1.png)

    library(ggplot2)

    # Buat grafik horizontal bar plot untuk variabel Jobs
    ggplot(data_jobstreet, aes(x = Company, y = Jobs)) +
      geom_bar(stat = "identity", fill = "skyblue")+
      coord_flip() +
      labs(title = "Distribusi Jobs Berdasarkan Company per 15-21 Juni 2024",
           x = "Company",
           y = "Jobs") +
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))

![](README_files/figure-markdown_strict/unnamed-chunk-63-1.png)
