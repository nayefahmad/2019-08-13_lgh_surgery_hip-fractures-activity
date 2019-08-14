
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
library(DT)
library(denodoExtractor)

# help(package = "denodoExtractor")

setup_denodo()

#+ analysis
# denodo/sql connections: --------
vw_surgery_completed_cases <- dplyr::tbl(cnx, 
                                         dbplyr::in_schema("publish", 
                                                           "surgery_case_completed"))

# Sqlserv cnx: 
cnx2 <- dbConnect(odbc::odbc(),
                  dsn = "cnx_SPDBSCSTA001")
vw_adr_mart <- dplyr::tbl(cnx2, 
                         dbplyr::in_schema("ADRMart.dbo", 
                                           "vwAbstractFact"))


#' ## Matching given dx desc with data in ADRMart

#' In the excel file, we have some dx descriptions. These are not `surg_dx_desc`
#' or `surg_px1_desc`. What are they? 
#' 

#' **Answer**: they're Dx1Codes from ADRMart. 
#' 
#' Note that latest available data for LGH in ADRMart is `r vw_adr_mart %>% filter(FacilityShortName == 'LGH') %>% select(AdmitDate) %>% arrange(desc(AdmitDate)) %>% collect %>% slice(1) %>% pull(AdmitDate)`. 



#****************************************************************
# dx codes for hip fractures: ------------

df1.hip_fracture_dx <- 
  data.frame(Dx1Desc = 
                c("Other fracture of femoral neck, closed",
                  "Intertrochanteric fracture, closed",
                  "Unspecified fracture of neck of femur, closed",
                  "Subtrochanteric fracture, closed",
                  "Unspecified trochanteric fracture, closed",
                  "Fracture of base of femoral neck (cervicotrochanteric) closed",
                  "Mechanical complication of hip prosthesis, breakage and dissociation",
                  "Fracture of acetabulum, closed",
                  "Fracture of femur, part unspecified, closed",
                  "Intertrochanteric fracture, open")) 

# join on ADRMart: 
df2.dx_desc_and_code <- 
  df1.hip_fracture_dx %>% 
  
  left_join(vw_adr_mart %>% 
              filter(FacilityShortName == "LGH", 
                     AdmitDate >= "20180401",
                     !is.na(Px1Code)) %>% 
              select(Dx1Desc, 
                     Dx1Code, 
                     FacilityShortName, 
                     PAtientID, 
                     PHN, 
                     RegisterNumber, 
                     AdmitDate, 
                     Px1Code, 
                     Px1Desc) %>%
              collect) %>% 
  mutate(admit_date = lubridate::ymd(AdmitDate)) %>% 
  arrange(admit_date)


# str(df2.dx_desc_and_code)


df2.dx_desc_and_code %>% 
  datatable()


df2.dx_desc_and_code %>% 
  count(admit_date, 
        sort = TRUE) %>% 
  arrange(admit_date)







