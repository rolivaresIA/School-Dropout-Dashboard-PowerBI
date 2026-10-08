# School Dropout Analysis (Chile): R part of the technical assessment

This notebook documents the R processing behind the Power BI dashboard. It answers the questions of the technical assessment for the position **Professional Analyst in the Data Science Unit of the Study Center of the Chilean Ministry of Education**, which tests data handling, domain knowledge in education and analytical ability. The assessment had to be solved with **R and Power BI**.

> The assessment brief and the dashboard are in Spanish; the code below is the same logic as in `script/dropout_analysis.R`. The raw data is **not** stored in this repository (see [`databases/README.md`](databases/README.md)), so the printed outputs below are the ones obtained when the analysis was run on the official 2023-2024 files.

## 1. Data loading and exploration

Two official files are used:

* **Academic performance 2023** (`rendimiento_2023.csv`): one row per student, with the school type and region.
* **Enrolment 2024** (`Matricula_unica_2024...CSV`): one row per enrolled student.

```r
performance <- read_csv("databases/rendimiento_2023.csv")
enrolment   <- read_csv2("databases/20240913_Matrícula_unica_2024_20240430_WEB.CSV")
```

## 2. Processing and main calculations

### a) Number of students who left the system, 2023-2024

The analysis is restricted to **subsidised private schools** (`COD_DEPE == 3`) for the corresponding year:

```r
performance_filtered <- filter(performance, COD_DEPE == 3 & AGNO == 2023)
enrolment_filtered   <- filter(enrolment,   COD_DEPE == 3 & AGNO == 2024)
```

A student who **dropped out** (*desvinculado*) is one who appears in the 2023 performance file but **not** in the 2024 enrolment. That is an **anti-join** on the student ID (`MRUN`):

```r
dropouts <- anti_join(performance_filtered, enrolment_filtered, by = "MRUN")
n_dropouts <- nrow(dropouts)
```

```text
## [1] 348749
```

On closer inspection there are **duplicated `MRUN`s**, so some students are counted more than once (probably because they changed course or timetable within the same school):

```r
duplicated_ids <- dropouts %>% group_by(MRUN) %>% filter(n() > 1) %>% count()
```

```text
## # A tibble: 14,885 x 2
```

After keeping one row per student:

```r
dropouts <- dropouts %>% distinct(MRUN, .keep_all = TRUE)
n_dropouts_unique <- nrow(dropouts)
```

```text
## [1] 332766
```

So the real number of students who left subsidised private schools in the period is **332,766** (14,885 IDs were duplicated in the first count).

### b) and c) Theoretical enrolment and dropout rate by region

* **Theoretical enrolment of year *t*** = enrolment of year *t* + students who dropped out.
* **Dropout rate** = dropouts / theoretical enrolment x 100.

```r
enrolment_by_region <- enrolment_filtered %>%
  group_by(NOM_REG_RBD_A) %>%
  summarise(current_enrolment = n())

dropouts_by_region <- dropouts %>%
  group_by(NOM_REG_RBD_A) %>%
  summarise(dropouts = n())

results_by_region <- enrolment_by_region %>%
  left_join(dropouts_by_region, by = "NOM_REG_RBD_A") %>%
  mutate(theoretical_enrolment = current_enrolment + dropouts,
         dropout_rate = (dropouts / theoretical_enrolment) * 100)
```

| Region code | Current enrolment | Dropouts | Theoretical enrolment | Dropout rate (%) |
|---|---:|---:|---:|---:|
| ANTOF | 48,357 | 7,389 | 55,746 | 13.3 |
| ARAUC | 119,729 | 20,552 | 140,281 | 14.7 |
| ATCMA | 21,193 | 3,679 | 24,872 | 14.8 |
| AYP | 32,412 | 5,827 | 38,239 | 15.2 |
| AYSEN | 12,936 | 2,326 | 15,262 | 15.2 |
| BBIO | 166,104 | 25,230 | 191,334 | 13.2 |
| COQ | 98,284 | 17,309 | 115,593 | 15.0 |
| LAGOS | 90,339 | 17,006 | 107,345 | 15.8 |
| LGBO | 87,196 | 14,593 | 101,789 | 14.3 |
| MAG | 11,831 | 2,221 | 14,052 | 15.8 |
| MAULE | 104,851 | 17,921 | 122,772 | 14.6 |
| NUBLE | 51,859 | 7,552 | 59,411 | 12.7 |
| RIOS | 39,991 | 7,898 | 47,889 | 16.5 |
| RM | 794,054 | 134,997 | 929,051 | 14.5 |
| TPCA | 55,661 | 9,604 | 65,265 | 14.7 |
| VALPO | 204,644 | 38,662 | 243,306 | 15.9 |

Dropout rates are fairly homogeneous across regions (12.7% to 16.5%); **Los Rios (16.5%), Valparaiso (15.9%) and Los Lagos / Magallanes (15.8%)** are the highest, and **Nuble (12.7%)** the lowest.

### d) A different breakdown: by school

The same logic, now grouped by school name (`NOM_RBD`):

```r
enrolment_by_school <- enrolment_filtered %>%
  group_by(NOM_RBD) %>%
  summarise(enrolled_students = n())

dropouts_by_school <- dropouts %>%
  group_by(NOM_RBD) %>%
  summarise(dropout_students = n())

results_by_school <- enrolment_by_school %>%
  left_join(dropouts_by_school, by = "NOM_RBD") %>%
  mutate(theoretical_enrolment = enrolled_students + dropout_students,
         dropout_rate = (dropout_students / theoretical_enrolment) * 100)
```

There are **5,132 schools** in the enrolment file and 4,843 with at least one dropout. Rates vary much more between schools than between regions (for example 7.4% to 30.8% among the first ten rows), which suggests that **school-level factors matter more than region**.

## 3. Methodological notes and what I would refine

These points were not part of the assessment's scope, but they matter when interpreting the numbers:

1. **"Dropout" here means "left subsidised private schools", not "left the education system".** A student who moved to a public school, or to a school of another type, appears as a dropout of this sector. To measure true system exit, the 2024 enrolment of **all** school types (not only `COD_DEPE == 3`) should be used in the anti-join.
2. **Graduating students are likely counted as dropouts.** Students in the final grade of secondary school (4th year) in 2023 finish school and will not appear in the 2024 enrolment. They should be identified and excluded from the 2023 base, otherwise the rate is probably inflated.
3. **Small schools** produce unstable rates (a few students move the percentage a lot); a minimum-size filter or confidence intervals would help for the school-level ranking.
4. **Descriptive, not causal.** The analysis shows where dropout is higher, not why. Variables such as grade, gender, age, prior-year attendance and performance would be needed for a predictive risk model (the assessment's descriptive analysis document discusses the available variables and their limits).
