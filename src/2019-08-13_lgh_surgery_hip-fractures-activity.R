
#'--- 
#' title: "LGH - Hip fractures with surgical interventions "
#' author: "Nayef Ahmad"
#' date: "2019-08-13"
#' output: 
#'   html_document: 
#'     keep_md: yes
#'     code_folding: show
#'     toc: true
#'     toc_float: true
#' ---

#' jira ds-3203
#' 
#' goal: to update the LGH Hip Fracture tables (see attached) to FY 2019/20 YTD

#+ lib, include = FALSE
library(tidyverse)
library(here)
library(odbc)
library(stringr)
library(denodoExtractor)

setup_denodo()

#+ analysis
#' ## Matching given dx desc with data in ORMart/denodo
 
#' In the excel file, we have some dx descriptions. These are not `surg_dx_desc`
#' or `surg_px1_desc`. What are they? 
#' 
#' Probably just admission_discharge `admit_dx_icd_1_desc`


# denodo surgery view: --------
vw_surgery_completed_cases <- dplyr::tbl(cnx, 
                                         dbplyr::in_schema("publish", 
                                                           "surgery_case_completed"))



# dx codes for hip fractures: 
df1.hip_fracture_dx <- 
  data.frame(surg_dx_desc = 
                c("Other fracture of femoral neck, closed",
                  "Intertrochanteric fracture, closed",
                  "Unspecified fracture of neck of femur, closed",
                  "Subtrochanteric fracture, closed",
                  "Unspecified trochanteric fracture, closed",
                  "Fracture of base of femoral neck (cervicotrochanteric) closed",
                  "Mechanical complication of hip prosthesis, breakage and dissociation",
                  "Fracture of acetabulum, closed",
                  "Fracture of femur, part unspecified, closed",
                  "Intertrochanteric fracture, open", 
                  "Screening Colonoscopy; Not BCCA pers/sig. family history")) # last one is just to test the join
  
df2.dx_desc_and_code <- 
  df1.hip_fracture_dx %>% 
    left_join(vw_surgery_completed_cases %>% 
              select(surg_dx_desc, 
                     surg_dx_cd) %>% 
              distinct() %>% 
              collect())


# try keywords: 
df3.denodo_femoral_dx_desc <- 
  vw_surgery_completed_cases %>% 
  filter(surg_dx_desc %like% "%femoral%") %>% 
  select(surg_dx_desc) %>%  # show_query()
  collect() %>% 
  distinct()


# are these actually procedure codes? NO. 
vw_surgery_completed_cases %>% 
  filter(surg_px_1_desc %like% "%femoral neck%") %>% 
  select(surg_px_1_desc) %>%  # show_query()
  collect() %>% 
  distinct() %>% View("px femoral")


# or maybe they're `admit_dx_icd_1_desc`? 
vw_adtc %>% 
  filter(admit_dx_icd_1_desc %like% "%femoral%neck%") %>% 
  select(admit_dx_icd_1_desc) %>% 
  collect() %>% 
  distinct() %>% View("adtc_dx")


#***********************************************
# SQL Serv surgery view: --------
cnx2 <- dbConnect(odbc::odbc(),
                  dsn = "cnx_SPDBSCSTA001")
vw_or_mart <- dplyr::tbl(cnx2, 
                         dbplyr::in_schema("ORMart.dbo", 
                                           "vwRegionalORCompletedCase"))


df1.hip_fracture_dx %>% 
  left_join(vw_or_mart %>% 
              select(DiagnosisDescription, 
                     DxTargetInWeeks) %>% 
              collect, 
            by = c("surg_dx_desc" = "DiagnosisDescription"))


# try keywords: 
df4.sqlserv_femoral_dx_desc <- 
  vw_or_mart %>% 
  filter(DiagnosisDescription %like% "%femoral%") %>% 
  select(DiagnosisDescription) %>%  # show_query()
  collect() %>% 
  distinct()





