POLICE_REQUESTS_PDF=input/Boston_Police_Department_Public_Records_Requests.pdf
POLICE_REQUESTS_CSV=output/boston_police_department_public_records_requests.csv

BOSTON_REQUESTS_PDF=input/City_of_Boston_Public_Records_Requests_Redacted.pdf
BOSTON_REQUESTS_CSV=output/city_of_boston_public_records_requests_redacted.csv

REQUESTS_2020_PDF=input/City_of_Boston_Public_Records_Requests_2020_Redacted.pdf
REQUESTS_2019_PDF=input/City_of_Boston_Public_Records_Requests_2019_Redacted.pdf
REQUESTS_2018_PDF=input/City_of_Boston_Public_Records_Requests_2018_Redacted.pdf
REQUESTS_2017_PDF=input/City_of_Boston_Public_Records_Requests_2017_Redacted.pdf
REQUESTS_PDFS=$(REQUESTS_2020_PDF) $(REQUESTS_2019_PDF) $(REQUESTS_2018_PDF) $(REQUESTS_2017_PDF)

REQUESTS_2020_CSV=output/City_of_Boston_Public_Records_Requests_2020_Redacted.csv
REQUESTS_2019_CSV=output/City_of_Boston_Public_Records_Requests_2019_Redacted.csv
REQUESTS_2018_CSV=output/City_of_Boston_Public_Records_Requests_2018_Redacted.csv
REQUESTS_2017_CSV=output/City_of_Boston_Public_Records_Requests_2017_Redacted.csv
REQUESTS_CSVS=$(REQUESTS_2020_CSV) $(REQUESTS_2019_CSV) $(REQUESTS_2018_CSV) $(REQUESTS_2017_CSV)

ALL_REQUESTS_CSV=output/boston_prr_2017_2020.csv
ALL_REQUESTS_XLSX=output/boston_prr_2017_2020.xlsx

.EXPORT_ALL_VARIABLES:

.PHONY: all
all: $(ALL_REQUESTS_XLSX)

.PHONY: clean-input
clean-input:
	rm -rf input && mkdir input && touch input/.keep

.PHONY: clean
clean:
	rm -rf output && mkdir output && touch output/.keep

.PHONY: deploy
deploy: $(ALL_REQUESTS_CSV) $(ALL_REQUESTS_XLSX)
	aws s3 cp $(ALL_REQUESTS_CSV) 's3://wokewindows-data' --acl public-read
	aws s3 cp $(ALL_REQUESTS_XLSX) 's3://wokewindows-data' --acl public-read

.PHONY: test
test:
	rspec

$(REQUESTS_PDFS):
	wget 'https://cdn.muckrock.com/foia_files/2021/04/12/$(subst input/,,$@)' -O $@

# manual offsets for fields on pages the script can't automatically figure out
$(REQUESTS_2020_CSV): export PAGE55=23,34,45,51,73,89
$(REQUESTS_2020_CSV): export PAGE220=23,34,45,67,88,118
$(REQUESTS_2020_CSV): export PAGE263=23,34,41,61,77,80
$(REQUESTS_2019_CSV): export PAGE75=23,34,45,66,84,85
$(REQUESTS_2019_CSV): export PAGE131=23,34,41,63,81,88

$(REQUESTS_CSVS): output/%.csv: input/%.pdf
	( echo "Reference No,Create Date,Close Date,Assigned Dept,Customer Full Name,Company Name,Public Record Desired"; ROW_REGEXP='^\s{0,15}[A-Z]\d\d+-\d+' FIELD_COUNT=7 ruby lib/tocsv.rb $< ) > $@

$(POLICE_REQUESTS_CSV): $(POLICE_REQUESTS_PDF) lib/tocsv.rb
	( echo "Reference No,Request Status,Create Date,Req. Compl. Date,Close Date,Assigned Dept,Customer Full Name,Company Name" ; ROW_REGEXP='^\s{0,15}[A-Z]\d\d+-\d+' FIELD_COUNT=8 ruby lib/tocsv.rb $(POLICE_REQUESTS_PDF) ) > $(POLICE_REQUESTS_CSV)

$(BOSTON_REQUESTS_CSV): $(BOSTON_REQUESTS_PDF) lib/tocsv.rb
	( echo "Reference No,Request Status,Create Date,Req. Compl. Date,Close Date,Assigned Dept,Customer Full Name,Company Name,Public Record Desired" ; ROW_REGEXP='^\w\d\d' FIELD_COUNT=9 ruby lib/tocsv.rb $(BOSTON_REQUESTS_PDF) ) > $(BOSTON_REQUESTS_CSV)

$(ALL_REQUESTS_CSV): $(BOSTON_REQUESTS_CSV) $(POLICE_REQUESTS_CSV) $(REQUESTS_CSVS)
	./lib/combine.sh > $@

# the 44,34,76 magic makes importing utf-8 csv work :shrugs:
%.xlsx : %.csv
	unoconv -i FilterOptions=44,34,76 -f xlsx -o $@ $<

input/%:
	wget -P input/ https://wokewindows-data.s3.amazonaws.com/$(@F)

.PHONY: docker-build
docker-build:
	docker build -t boston_public_records .

.PHONY: docker-run
docker-run:
	docker run --rm --env-file env.list -v `pwd`:/volume -ti boston_public_records sh
