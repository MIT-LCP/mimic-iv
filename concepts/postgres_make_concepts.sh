#!/bin/bash
# This file makes tables for the concepts in this subfolder.
# Be sure to run postgres-functions.sql first, as the concepts rely on those function definitions.
# Note that this may take a large amount of time and hard drive space.

# string replacements are necessary for some queries
export REGEX_DATETIME_DIFF="s/DATETIME_DIFF\((.+?),\s?(.+?),\s?(DAY|MINUTE|SECOND|HOUR|YEAR)\)/DATETIME_DIFF(\1, \2, '\3')/g"
export REGEX_SCHEMA='s/`physionet-data.(mimic_core|mimic_icu|mimic_derived|mimic_hosp).(.+?)`/\1.\2/g'
# Add necessary quotes to INTERVAL, e.g. "INTERVAL 5 hour" to "INTERVAL '5' hour"
export REGEX_INTERVAL="s/interval\s([[:digit:]])\s(hour|day|month|year)/INTERVAL '\1' \2/gI"
# Add numeric cast to ROUND(), e.g. "ROUND(1.234, 2)" to "ROUND( CAST(1.234 as numeric), 2)" over 0 or 3 lines
export PERL_REGEX_ROUND='s/round\((.*|.*[\n]?.*[\n]?.*[\n]?.*)(\, \d\))/ROUND\( CAST\($1 as numeric\)$2/gi'
export CONNSTR='-d mimic'

# this is set as the search_path variable for psql
# a search path of "public,mimic_icu" will search both public and mimic_icu
# schemas for data, but will create tables on the public schema
export PSQL_PREAMBLE='SET search_path TO public,mimic_icu'
export TARGET_DATASET='mimic_derived'

echo ''
echo '==='
echo 'Beginning to create tables for MIMIC database.'
echo 'Any notices of the form "NOTICE: TABLE "XXXXXX" does not exist" can be ignored.'
echo 'The scripts drop views before creating them, and these notices indicate nothing existed prior to creating the view.'
echo '==='
echo ''

# generate tables in subfolders
# for d in demographics measurement medication treatment firstday score;
for d in firstday;
do
    for fn in `ls $d`;
    do
        echo "${d}"
        # only run SQL queries
        if [[ "${fn: -4}" == ".sql" ]]; then
            # table name is file name minus extension
            tbl="${fn::-4}"

            # skip first_day_sofa as it depends on other firstday queries
            if [[ "${tbl}" == "first_day_sofa" ]]; then
                continue
            fi
            echo "Generating ${TARGET_DATASET}.${tbl}"
            { echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ${TARGET_DATASET}.${tbl}; CREATE TABLE ${TARGET_DATASET}.${tbl} AS "; cat "${d}/${fn}";} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | perl -0777 -pe "${PERL_REGEX_ROUND}" |  psql ${CONNSTR}
        fi
    done
done


# generate first_day_sofa table last
echo "Generating ${TARGET_DATASET}.first_day_sofa"
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ${TARGET_DATASET}.first_day_sofa; CREATE TABLE ${TARGET_DATASET}.first_day_sofa AS "; cat firstday/first_day_sofa.sql;} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | perl -0777 -pe "${PERL_REGEX_ROUND}" |  psql ${CONNSTR}
