# SCRAPING DATA BMKG DAN JOBSTREET

## Author
[Tasya Anisah Rizqi](https://github.com/tasyaanisahrizqi/) (G1501231046)

## Program R Data Scraping
[RPubs Data Scraping BMKG & Jobstreet](https://rpubs.com/tasyaanisahrizqi/scraping-data)

## Menu
+ [Data Scraping BMKG](#books-data-scraping-bmkg)
+ [Data Scraping Jobstreet](#books-data-scraping-jobstreet)
+ [Visualisasi Data Scraping BMKG](#books-visualisasi-data-scraping-bmkg)
+ [Visualisasi Data Scraping Jobstreet](#books-visualisasi-data-scraping-jobstreet)

## BMKG
Badan Meteorologi, Klimatologi, dan Geofisika (BMKG) adalah lembaga pemerintah Indonesia yang bertanggung jawab untuk menyediakan informasi cuaca, iklim, dan geofisika yang akurat dan terkini. Didirikan dengan tujuan utama untuk mengamati, mengumpulkan, menganalisis, dan menyebarluaskan data meteorologi, klimatologi, dan geofisika, BMKG memainkan peran vital dalam mendukung berbagai sektor, termasuk pertanian, perikanan, penerbangan, dan mitigasi bencana. Layanan yang disediakan oleh BMKG meliputi prakiraan cuaca harian, peringatan dini bencana alam seperti gempa bumi dan tsunami, serta analisis perubahan iklim yang dapat mempengaruhi kehidupan dan ekonomi masyarakat.
Cuaca adalah kondisi atmosfer yang terjadi di suatu tempat pada waktu tertentu, mencakup berbagai elemen seperti suhu, kelembapan, tekanan udara, angin, dan curah hujan. Cuaca memiliki pengaruh langsung terhadap kehidupan sehari-hari manusia dan ekosistem. Pemahaman tentang cuaca tidak hanya penting untuk aktivitas sehari-hari seperti berpakaian dan perencanaan perjalanan, tetapi juga krusial untuk sektor-sektor seperti pertanian, penerbangan, dan penanganan bencana alam. Sebagai contoh, petani mengandalkan prakiraan cuaca untuk menentukan waktu tanam dan panen, sementara maskapai penerbangan membutuhkan informasi cuaca untuk memastikan keselamatan penerbangan.

## Jobstreet
JobStreet adalah platform pencarian kerja terkemuka di Asia yang menghubungkan pencari kerja dengan berbagai peluang pekerjaan dari perusahaan-perusahaan di seluruh wilayah. Didirikan pada tahun 1997, JobStreet telah berkembang menjadi salah satu portal pekerjaan terbesar dan paling tepercaya, menyediakan akses ke ribuan lowongan pekerjaan di berbagai industri dan tingkatan karir.
JobStreet menawarkan berbagai fitur yang memudahkan pencari kerja dan pemberi kerja untuk menemukan kecocokan yang tepat. Fitur-fitur seperti pencarian pekerjaan yang disesuaikan, saran pekerjaan berdasarkan profil pengguna, dan layanan resume online membantu pencari kerja menemukan peluang yang relevan dengan cepat dan efisien. Di sisi lain, perusahaan dapat memanfaatkan berbagai alat dan layanan yang disediakan oleh JobStreet untuk menarik, menyaring, dan merekrut kandidat yang paling sesuai dengan kebutuhan mereka. Melalui inovasi teknologi dan komitmen untuk menyediakan layanan berkualitas tinggi, JobStreet terus memainkan peran penting dalam memajukan pasar tenaga kerja di Asia.

## :books: Data Scraping BMKG
Data diambil dari website [BMKG](https://www.bmkg.go.id/cuaca/prakiraan-cuaca-indonesia.bmkg) per 15-21 Juni 2024
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
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
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

### Data Rata-rata Pagi, Siang, Malam, dan Dini Hari serta Kategori Suhu dan Kelembapan
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
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
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

## :books: Data Scraping Jobstreet
Data diambil dari website [Jobstreet](https://www.jobstreet.co.id/companies) per 15-21 Juni 2024
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
<td style="text-align: left;">.../td>
<td style="text-align: left;">...</td>
<td style="text-align: right;">...</td>
<td style="text-align: right;">...</td>
<td style="text-align: right;">...</td>
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

### Data Kategori Rating
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
<tr class="odd">
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: left;">...</td>
<td style="text-align: right;">...</td>
<td style="text-align: right;">...</td>
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

## :books: Visualisasi Data Scraping BMKG
Grafik horizontal bar plot untuk variabel Pagi
+ ![](README_files/figure-markdown_strict/unnamed-chunk-48-1.png)

Grafik horizontal bar plot untuk variabel Siang
+ ![](README_files/figure-markdown_strict/unnamed-chunk-49-1.png)

Grafik horizontal bar plot untuk variabel Malam
+ ![](README_files/figure-markdown_strict/unnamed-chunk-50-1.png)

Grafik horizontal bar plot untuk variabel Dini Hari
+ ![](README_files/figure-markdown_strict/unnamed-chunk-51-1.png)

Grafik bar plot untuk Kota berdasarkan variabel Pagi
+ ![](README_files/figure-markdown_strict/unnamed-chunk-52-1.png)

Grafik bar plot untuk Kota berdasarkan variabel Siang
+ ![](README_files/figure-markdown_strict/unnamed-chunk-53-1.png)

Grafik bar plot untuk Kota berdasarkan variabel Malam
+ ![](README_files/figure-markdown_strict/unnamed-chunk-54-1.png)

Grafik bar plot untuk Kota berdasarkan variabel Dini Hari
+ ![](README_files/figure-markdown_strict/unnamed-chunk-55-1.png)

Grafik horizontal bar plot untuk variabel Suhu
+ ![](README_files/figure-markdown_strict/unnamed-chunk-56-1.png)

Grafik bar plot untuk Kota berdasarkan rata-rata suhu
+ ![](README_files/figure-markdown_strict/unnamed-chunk-57-1.png)

Grafik horizontal bar plot untuk variabel Kelembapan
+ ![](README_files/figure-markdown_strict/unnamed-chunk-58-1.png)

Grafik bar plot untuk Kota berdasarkan rata-rata kelembapan
+ ![](README_files/figure-markdown_strict/unnamed-chunk-59-1.png)

## :books: Visualisasi Data Scraping Jobstreet
Grafik horizontal bar plot untuk variabel Rating
+ ![](README_files/figure-markdown_strict/unnamed-chunk-60-1.png)

Grafik bar plot untuk Company berdasarkan Rating
+ ![](README_files/figure-markdown_strict/unnamed-chunk-61-1.png)

Grafik horizontal bar plot untuk variabel Reviews
+ ![](README_files/figure-markdown_strict/unnamed-chunk-62-1.png)

Grafik horizontal bar plot untuk variabel Jobs
+ ![](README_files/figure-markdown_strict/unnamed-chunk-63-1.png)
