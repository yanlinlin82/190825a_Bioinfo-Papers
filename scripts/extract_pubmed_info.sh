#!/bin/bash

mkdir -pv data/01_extract/

if [ ! -e "data/01_extract/pubmed_journal.txt.gz" ]; then
	echo 1>&2 "Generate 'data/01_extract/pubmed_journal.txt.gz'"
	zcat data/00_raw/pubmed_result.txt.gz \
		| awk '{
				if ($1 == "PMID-") {
					pmid = $2
				} else if ($1 == "JT") {
					s[pmid] = substr($0, 6)
				}
			} END {
				OFS = "\t"
				print "pmid", "journal"
				for (i in s) {
					print i, s[i]
				}
			}' \
		| gzip -9 \
		> data/01_extract/pubmed_journal.txt.gz
fi

if [ ! -e "data/01_extract/pubmed_date.txt.gz" ]; then
	echo 1>&2 "Generate 'data/01_extract/pubmed_date.txt.gz'"
	zcat data/00_raw/pubmed_result.txt.gz \
		| awk '{
				if ($1=="PMID-") {
					pmid=$2; a[pmid]=1
				} else if ($1=="PHST-") {
					b[$4]=1; c[pmid":"$4]=$2
				}
			} END {
				OFS="\t"
				print "pmid","type","date"
				for(i in a){
					for(j in b){
						if(c[i":"j]!=""){
							print i,j,c[i":"j]
						}
					}
				}
			}' \
		| gzip -9 \
		> data/01_extract/pubmed_date.txt.gz
fi

if [ ! -e "data/01_extract/pubmed_author.txt.gz" ]; then
	echo 1>&2 "Generate 'data/01_extract/pubmed_author.txt.gz'"
	zcat data/00_raw/pubmed_result.txt.gz \
		| awk '{
				if ($1=="PMID-") {
					pmid=$2; a[pmid]=1
				} else if ($1=="FAU") {
					b[pmid] = (b[pmid]==""?"":(b[pmid]";"))substr($0,6)
				}
			} END {
				OFS="\t"
				print "pmid","author"
				for(i in a){
					print i,b[i]
				}
			}' \
		| gzip -9 \
		> data/01_extract/pubmed_author.txt.gz
fi
