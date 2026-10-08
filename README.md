# School Dropout Analysis with R and Power BI (Chile)

**Technical assessment for the Data Science Unit of the Chilean Ministry of Education (MINEDUC): quantifying school dropout in subsidised private schools and visualising it in an interactive dashboard.**

![](images/Logo_del_Ministerio_de_Educación_Chile1.jpg)

> **Language note:** the assessment brief, the descriptive-analysis document (PDFs) and the Power BI dashboard are in **Spanish** (the language of the assessment). The code, the analysis notebook and this README are in English.

## Context

Technical assessments are a common step when applying for analyst roles. This one tested **R programming**, **data handling** and **visualisation with Power BI**, applied to a real policy question: how many students leave subsidised private schools between 2023 and 2024, and where?

## What was done

- **Data processing in R** with official 2023 performance and 2024 enrolment files: a student is a *dropout* if they appear in the 2023 performance data but not in the 2024 enrolment (anti-join on student ID).
- **Data quality:** 14,885 duplicated student IDs found and removed, so the first count (348,749) became the real figure of **332,766 students**.
- **Metrics:** theoretical enrolment (current enrolment + dropouts) and dropout rate by **region** and by **school** (5,132 schools).
- **Dashboard in Power BI** with bars of dropouts by region, dropout % by region, slicers and KPI cards.
- **Descriptive analysis and policy proposals:** three prioritised measures to reduce dropout, based on the findings.

## Key results

- **332,766 students** left subsidised private schools in 2023-2024.
- Regional dropout rates range from **12.7% (Nuble) to 16.5% (Los Rios)**; the Metropolitan region concentrates the highest absolute number (134,997 students, 14.5%).
- Rates differ much more **between schools** than between regions, so school-level factors seem to matter more than geography.
- **Methodological caveats** (documented in the notebook): "dropout" here means leaving *this school type* (not necessarily the whole system), and students graduating in 2023 are probably counted as dropouts.

![](images/visualizador.png)
![](images/visualizador2.png)

## Where to look

| What | Where |
|---|---|
| Analysis notebook (code, outputs, caveats) | [`dropout_analysis.md`](dropout_analysis.md) |
| R script | [`script/dropout_analysis.R`](script/dropout_analysis.R) |
| Data (not included, instructions) | [`databases/README.md`](databases/README.md) |
| Original assessment brief (Spanish) | [`pdf/Evaluación_Técnica-Analista_UCD.pdf`](pdf/Evaluación_Técnica-Analista_UCD.pdf) |
| Descriptive analysis and proposals (Spanish) | [`pdf/Análisis_Descriptivo_Datos.pdf`](pdf/Análisis_Descriptivo_Datos.pdf) |
| Power BI file (.pbix) | [Google Drive](https://drive.google.com/file/d/1X59fU3MQ7g4r2e_skXa94bGQQTQVifbx/view?usp=drive_link) |

## Tech stack

R (tidyverse, writexl), Power BI.
