WITH diag AS
(
    SELECT 
        hadm_id
        , CASE WHEN icd_version = 9 THEN icd_code ELSE NULL END AS icd9_code
        , CASE WHEN icd_version = 10 THEN icd_code ELSE NULL END AS icd10_code
    FROM mimic_hosp.diagnoses_icd diag
)
, com AS
(
    SELECT
        ad.hadm_id
        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) IN ('410','412')
            OR
            SUBSTRING(icd10_code FROM 1 for 3) IN ('I21','I22')
            OR
            SUBSTRING(icd10_code FROM 1 for 4) = 'I252'
            THEN 1 
            ELSE 0 END) AS mi1 --Myocardial infarction

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) = '428'
            OR
            icd9_code IN ('39891','40201','40211','40291','40401','40403',
                          '40411','40413','40491','40493')
            OR 
            SUBSTRING(icd9_code FROM 1 for 4) BETWEEN '4254' AND '4259'
            OR
            SUBSTRING(icd10_code FROM 1 for 3) IN ('I43','I50')
            OR
            SUBSTRING(icd10_code FROM 1 for 4) IN ('I099','I110','I130','I132','I255','I420',
                                                   'I425','I426','I427','I428','I429','P290')
            THEN 1 
            ELSE 0 END) AS chf1 --Congestive heart failure

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) IN ('440','441')
            OR
            SUBSTRING(icd9_code FROM 1 for 4) IN ('0930','4373','4471','5571','5579','V434')
            OR
            SUBSTRING(icd9_code FROM 1 for 4) BETWEEN '4431' AND '4439'
            OR
            SUBSTRING(icd10_code FROM 1 for 3) IN ('I70','I71')
            OR
            SUBSTRING(icd10_code FROM 1 for 4) IN ('I731','I738','I739','I771','I790',
                                                   'I792','K551','K558','K559','Z958','Z959')
            THEN 1 
            ELSE 0 END) AS pvd1 --Peripheral vascular disease

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) BETWEEN '430' AND '438'
            OR
            icd9_code = '36234'
            OR
            SUBSTRING(icd10_code FROM 1 for 3) IN ('G45','G46')
            OR 
            SUBSTRING(icd10_code FROM 1 for 3) BETWEEN 'I60' AND 'I69'
            OR
            SUBSTRING(icd10_code FROM 1 for 4) = 'H340'
            THEN 1 
            ELSE 0 END) AS cd1 --Cerebrovascular disease

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) = '290'
            OR
            SUBSTRING(icd9_code FROM 1 for 4) IN ('2941','3312')
            OR
            SUBSTRING(icd10_code FROM 1 for 3) IN ('F00','F01','F02','F03','G30')
            OR
            SUBSTRING(icd10_code FROM 1 for 4) IN ('F051','G311')
            THEN 1 
            ELSE 0 END) AS de1 --Dementia

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) BETWEEN '490' AND '505'
            OR
            SUBSTRING(icd9_code FROM 1 for 4) IN ('4168','4169','5064','5081','5088')
            OR 
            SUBSTRING(icd10_code FROM 1 for 3) BETWEEN 'J40' AND 'J47'
            OR 
            SUBSTRING(icd10_code FROM 1 for 3) BETWEEN 'J60' AND 'J67'
            OR
            SUBSTRING(icd10_code FROM 1 for 4) IN ('I278','I279','J684','J701','J703')
            THEN 1 
            ELSE 0 END) AS cpd1 --Chronic pulmonary disease

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) = '725'
            OR
            SUBSTRING(icd9_code FROM 1 for 4) IN ('4465','7100','7101','7102','7103',
                                                  '7104','7140','7141','7142','7148')
            OR
            SUBSTRING(icd10_code FROM 1 for 3) IN ('M05','M06','M32','M33','M34')
            OR
            SUBSTRING(icd10_code FROM 1 for 4) IN ('M315','M351','M353','M360')
            THEN 1 
            ELSE 0 END) AS rd1 --Rheumatic disease

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) IN ('531','532','533','534')
            OR
            SUBSTRING(icd10_code FROM 1 for 3) IN ('K25','K26','K27','K28')
            THEN 1 
            ELSE 0 END) AS pud1 --Peptic ulcer disease

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) IN ('570','571')
            OR
            SUBSTRING(icd9_code FROM 1 for 4) IN ('0706','0709','5733','5734','5738','5739','V427')
            OR
            icd9_code IN ('07022','07023','07032','07033','07044','07054')
            OR
            SUBSTRING(icd10_code FROM 1 for 3) IN ('B18','K73','K74')
            OR
            SUBSTRING(icd10_code FROM 1 for 4) IN ('K700','K701','K702','K703','K709','K713',
                                                   'K714','K715','K717','K760','K762',
                                                   'K763','K764','K768','K769','Z944')
            THEN 1 
            ELSE 0 END) AS mld1 --Mild liver disease

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 4) IN ('2500','2501','2502','2503','2508','2509') 
            OR
            SUBSTRING(icd10_code FROM 1 for 4) IN ('E100','E10l','E106','E108','E109','E110','E111',
                                                   'E116','E118','E119','E120','E121','E126','E128',
                                                   'E129','E130','E131','E136','E138','E139','E140',
                                                   'E141','E146','E148','E149')
            THEN 1 
            ELSE 0 END) AS dm1 --Diabetes without chronic complication

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 4) IN ('2504','2505','2506','2507')
            OR
            SUBSTRING(icd10_code FROM 1 for 4) IN ('E102','E103','E104','E105','E107','E112','E113',
                                                   'E114','E115','E117','E122','E123','E124','E125',
                                                   'E127','E132','E133','E134','E135','E137','E142',
                                                   'E143','E144','E145','E147')
            THEN 1 
            ELSE 0 END) AS dm2 --Diabetes with chronic complication

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) IN ('342','343')
            OR
            SUBSTRING(icd9_code FROM 1 for 4) IN ('3341','3440','3441','3442',
                                                  '3443','3444','3445','3446','3449')
            OR 
            SUBSTRING(icd10_code FROM 1 for 3) IN ('G81','G82')
            OR 
            SUBSTRING(icd10_code FROM 1 for 4) IN ('G041','G114','G801','G802','G830',
                                                   'G831','G832','G833','G834','G839')
            THEN 1 
            ELSE 0 END) AS he2 --Hemiplegia or paraplegia

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) IN ('582','585','586','V56')
            OR
            SUBSTRING(icd9_code FROM 1 for 4) IN ('5880','V420','V451')
            OR
            SUBSTRING(icd9_code FROM 1 for 4) BETWEEN '5830' AND '5837'
            OR
            icd9_code IN ('40301','40311','40391','40402','40403','40412','40413','40492','40493')          
            OR
            SUBSTRING(icd10_code FROM 1 for 3) IN ('N18','N19')
            OR
            SUBSTRING(icd10_code FROM 1 for 4) IN ('I120','I131','N032','N033','N034',
                                                   'N035','N036','N037','N052','N053',
                                                   'N054','N055','N056','N057','N250',
                                                   'Z490','Z491','Z492','Z940','Z992')
            THEN 1 
            ELSE 0 END) AS rd2 --Renal disease

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) BETWEEN '140' AND '172'
            OR
            SUBSTRING(icd9_code FROM 1 for 4) BETWEEN '1740' AND '1958'
            OR
            SUBSTRING(icd9_code FROM 1 for 3) BETWEEN '200' AND '208'
            OR
            SUBSTRING(icd9_code FROM 1 for 4) = '2386'
            OR
            SUBSTRING(icd10_code FROM 1 for 3) IN ('C43','C88')
            OR
            SUBSTRING(icd10_code FROM 1 for 3) BETWEEN 'C00' AND 'C26'
            OR
            SUBSTRING(icd10_code FROM 1 for 3) BETWEEN 'C30' AND 'C34'
            OR
            SUBSTRING(icd10_code FROM 1 for 3) BETWEEN 'C37' AND 'C41'
            OR
            SUBSTRING(icd10_code FROM 1 for 3) BETWEEN 'C45' AND 'C58'
            OR
            SUBSTRING(icd10_code FROM 1 for 3) BETWEEN 'C60' AND 'C76'
            OR
            SUBSTRING(icd10_code FROM 1 for 3) BETWEEN 'C81' AND 'C85'
            OR
            SUBSTRING(icd10_code FROM 1 for 3) BETWEEN 'C90' AND 'C97'
            THEN 1 
            ELSE 0 END) AS mal2 --Any malignancy, including lymphoma and leukemia, except malignant neoplasm of skin

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 4) IN ('4560','4561','4562')
            OR
            SUBSTRING(icd9_code FROM 1 for 4) BETWEEN '5722' AND '5728'
            OR
            SUBSTRING(icd10_code FROM 1 for 4) IN ('I850','I859','I864','I982','K704','K711',
                                                   'K721','K729','K765','K766','K767')
            THEN 1 
            ELSE 0 END) AS ld3 --Moderate or severe liver disease


        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) IN ('196','197','198','199')
            OR 
            SUBSTRING(icd10_code FROM 1 for 3) IN ('C77','C78','C79','C80')
            THEN 1 
            ELSE 0 END) AS mst6 --Metastatic solid tumor

        , MAX(CASE WHEN 
            SUBSTRING(icd9_code FROM 1 for 3) IN ('042','043','044')
            OR 
            SUBSTRING(icd10_code FROM 1 for 3) IN ('B20','B21','B22','B24')
            THEN 1 
            ELSE 0 END) AS aids6 --AIDS/HIV
    FROM mimic_core.admissions ad
    LEFT JOIN diag
    ON ad.hadm_id = diag.hadm_id
    GROUP BY ad.hadm_id
)
, ag AS
(
    SELECT 
        hadm_id
        , age
        , CASE WHEN age <= 40 THEN 0
    WHEN age <= 50 THEN 1
    WHEN age <= 60 THEN 2
    WHEN age <= 70 THEN 3
    ELSE 4 END AS age_score
    FROM mimic_derived.age_info
)
SELECT 
    ad.subject_id
    , ad.hadm_id
    , ag.age
    , ag.age_score
    , mi1
    , chf1
    , pvd1
    , cd1
    , de1
    , cpd1
    , rd1
    , pud1
    , mld1
    , dm1
    , dm2
    , he2
    , rd2
    , mal2
    , ld3 
    , mst6 
    , aids6
    , mi1 + chf1 + pvd1 + cd1 + de1 + cpd1 + 
    rd1 + pud1 + mld1 + GREATEST(2*dm2, dm1) + 2*he2 + 
    2*rd2 + 2*mal2 + 3*ld3 + 6*mst6 + 6*aids6 +
    age_score
    AS charlson
FROM mimic_core.admissions ad
LEFT JOIN com
ON ad.hadm_id = com.hadm_id
LEFT JOIN ag
ON com.hadm_id = ag.hadm_id
;
