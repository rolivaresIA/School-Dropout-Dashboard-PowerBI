# School dropout analysis (Chile) - technical assessment, R part
# Input files (not stored in this repository, see databases/README.md):
#   databases/rendimiento_2023.csv
#   databases/20240913_Matricula_unica_2024_20240430_WEB.CSV
# Run from the repository root.

library(tidyverse)   # dplyr, readr, ggplot2, ...
library(writexl)

performance <- read_csv("databases/rendimiento_2023.csv")
enrolment   <- read_csv2("databases/20240913_Matrícula_unica_2024_20240430_WEB.CSV")

# a) Number of students who left, period 2023-2024 ---------------------------------
# Keep subsidised private schools (COD_DEPE == 3) and the corresponding year.
performance_filtered <- filter(performance, COD_DEPE == 3 & AGNO == 2023)
enrolment_filtered   <- filter(enrolment,   COD_DEPE == 3 & AGNO == 2024)

# A "dropout" is a student present in the 2023 performance file (year t-1) who does
# not appear in the 2024 enrolment (year t).
dropouts <- anti_join(performance_filtered, enrolment_filtered, by = "MRUN")
n_dropouts <- nrow(dropouts)
print(n_dropouts)            # 348,749 (includes duplicated student IDs)

# Some MRUN are duplicated (probably students who changed course or timetable within
# the same school), so they would be counted more than once. Keep one row per student.
duplicated_ids <- dropouts %>% group_by(MRUN) %>% filter(n() > 1) %>% count()

dropouts <- dropouts %>% distinct(MRUN, .keep_all = TRUE)
n_dropouts_unique <- nrow(dropouts)
print(n_dropouts_unique)     # 332,766 (the real number)

# b) and c) Theoretical enrolment and dropout rate by region ------------------------
# Theoretical enrolment of year t = enrolment of year t + dropouts of year t.
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

results_by_region

# d) A different breakdown: by school (NOM_RBD) -------------------------------------
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

# Export the tables (used as inputs for the Power BI dashboard) ----------------------
dir.create("output", showWarnings = FALSE)
write_xlsx(results_by_region, "output/dropout_by_region.xlsx")
write_xlsx(results_by_school, "output/dropout_by_school.xlsx")
