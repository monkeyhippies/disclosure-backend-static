.PHONY: process

CD := $(shell pwd)

process: import

import: inputs/efile_COAK_2016_A-Contributions.csv inputs/oakland_candidates.csv inputs/oakland_committees.csv \
	inputs/oakland_referendums.csv create.sql
	dropdb disclosure-backend
	createdb disclosure-backend
	psql disclosure-backend < create.sql
	echo "COPY contributions FROM '${CD}/inputs/efile_COAK_2016_A-Contributions.csv' WITH CSV HEADER QUOTE '\"'" | \
		psql disclosure-backend
	csvsql --doublequote --db postgresql:///disclosure-backend --insert inputs/oakland_candidates.csv
	csvsql --doublequote --db postgresql:///disclosure-backend --insert inputs/oakland_referendums.csv
	csvsql --doublequote --db postgresql:///disclosure-backend --insert inputs/oakland_committees.csv

inputs/efile_COAK_%_A-Contributions.csv: downloads/efile_COAK_%.xlsx
	ssconvert -S $< inputs/$(subst .xlsx,_%s.csv,$(shell basename $<))

downloads/efile_COAK_%.xlsx: downloads/efile_COAK_%.zip
	 unzip -p $< > $@

downloads/efile_COAK_%.zip:
	wget -O $@ http://nf4.netfile.com/pub2/excel/COAKBrowsable/$(shell basename $@)

inputs/oakland_candidates.csv:
	wget -q -O- \
		'https://docs.google.com/spreadsheets/d/1272oaLyQhKwQa6RicA5tBso6wFruum-mgrNm3O3VogI/pub?gid=0&single=true&output=csv' | \
	sed -e '1s/ /_/g' | \
	sed -e '1s/[^a-zA-Z,_]//g' > $@

inputs/oakland_referendums.csv:
	wget -q -O- \
		'https://docs.google.com/spreadsheets/d/1272oaLyQhKwQa6RicA5tBso6wFruum-mgrNm3O3VogI/pub?gid=1693935349&single=true&output=csv' | \
	sed -e '1s/ /_/g' | \
	sed -e '1s/[^a-zA-Z,_]//g' > $@

inputs/oakland_committees.csv:
	wget -q -O- \
		'https://docs.google.com/spreadsheets/d/1272oaLyQhKwQa6RicA5tBso6wFruum-mgrNm3O3VogI/pub?gid=1995437960&single=true&output=csv' | \
	sed -e '1s/ /_/g' | \
	sed -e '1s/[^a-zA-Z,_]//g' > $@