# MIMIC-IV Concepts

## Generating the concepts in PostgreSQL (*nix/Mac OS X)

Analogously to [MIMIC-III Concepts](https://github.com/MIT-LCP/mimic-code/tree/master/concepts), the SQL scripts here are written in BigQuery's Standard SQL syntax, so that the following changes are necessary to make them compaible with PostgreSQL:

* create postgres functions which emulate BigQuery functions (identical to MIMIC-III)
* modify SQL scripts for incompatible syntax
* run the modified SQL scripts and direct the output into tables in the PostgreSQL database

This can be done as follows (again, analogously to [MIMIC-III](https://github.com/MIT-LCP/mimic-code/tree/master/concepts):

1. Open a terminal in the `concepts` folder.
2. Run [postgres-functions.sql](postgres-functions.sql).
    * e.g. `psql -f postgres-functions.sql`
    * This script creates functions which emulate BigQuery syntax.
3. Run [postgres_make_concepts.sh](postgres_make_concepts.sh).
    * e.g. `bash postgres_make_concepts.sh`
    * This file runs the scripts after applying a few regular expressions which convert table references and date calculations appropriately.
    * This file generates all concepts on the `public` schema.

The main difference to MIMIC-III are different slightly different regular expressions and a loop similar to [make_concepts.sh](make_concepts.sh). Also, one of them uses `perl` now, which might be necessary to install.

### Known Problems

* [postgres_make_concepts.sh](postgres_make_concepts.sh) fails for [icustays_hourly.sh](demographics/icustays_hourly.sh) due to `INTERVAL CAST(hr AS INT64) HOUR)', which cannot easily be changed into a PostrgeSQL compatible expression.
