
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
#' goal: to update the LGH Hip Fracture tables (see attached) to FY 2019/20 YTD

library(tidyverse)
library(denodoExtractor)

setup_denodo()


# set up denodo surgery view: 
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
                  "Screening Colonoscopy; Not BCCA pers/sig. family history")) %>%  # last one is just to test the join
  
  left_join(vw_surgery_completed_cases %>% 
              select(surg_dx_desc, 
                     surg_dx_cd) %>% 
              distinct() %>% 
              collect())








