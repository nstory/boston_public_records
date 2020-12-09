POLICE_REQUESTS_PDF=input/Boston_Police_Department_Public_Records_Requests.pdf
POLICE_REQUESTS_CSV=target/boston_police_department_public_records_requests.csv
POLICE_REQUESTS_XLSX=target/boston_police_department_public_records_requests.xlsx
BOSTON_REQUESTS_PDF=input/City_of_Boston_Public_Records_Requests_Redacted.pdf
BOSTON_REQUESTS_CSV=target/city_of_boston_public_records_requests_redacted.csv
BOSTON_REQUESTS_XLSX=target/city_of_boston_public_records_requests_redacted.xlsx

.PHONY: clean all

all: $(POLICE_REQUESTS_CSV) $(BOSTON_REQUESTS_CSV) $(POLICE_REQUESTS_XLSX) $(BOSTON_REQUESTS_XLSX)

clean:
	rm -rf target && mkdir target && touch target/.keep

$(POLICE_REQUESTS_CSV): $(POLICE_REQUESTS_PDF) tocsv.rb
	( echo "Reference No,Request Status,Create Date,Req. Compl. Date,Close Date,Assigned Dept,Customer Full Name,Company Name" ; ROW_REGEXP='^\w\d\d' FIELD_COUNT=8 ruby tocsv.rb $(POLICE_REQUESTS_PDF) ) > $(POLICE_REQUESTS_CSV)

$(BOSTON_REQUESTS_CSV): $(BOSTON_REQUESTS_PDF) tocsv.rb
	( echo "Reference No,Request Status,Create Date,Req. Compl. Date,Close Date,Assigned Dept,Customer Full Name,Company Name,Public Record Desired" ; ROW_REGEXP='^\w\d\d' FIELD_COUNT=9 ruby tocsv.rb $(BOSTON_REQUESTS_PDF) ) > $(BOSTON_REQUESTS_CSV)

# the 44,34,76 magic makes importing utf-8 csv work :shrugs:
%.xlsx : %.csv
	unoconv -i FilterOptions=44,34,76 -f xlsx -o $@ $<
