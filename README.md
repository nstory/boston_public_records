# Boston Public Records
This project produces a spreadsheet containing public records requests (PRRs) made to the City of Boston from 2017 to 2020. It parses and combines multiple PDF files provided by the city.

These records were exported from the [Boston GovQA Public Records Center](https://bostonma.govqa.us/WEBAPP/_rs/(S(drgaqavruzr2edqgq0jblw5g))/login.aspx) and include requests to the Boston Police Department from 2017 - 2020. Other city departments began using the GovQA system in early 2020.

See also [the blog post](https://blog.wokewindows.org/2021/01/14/boston-public-records-log.html).

## DOWNLOADS
You probably just want to download the final spreadsheets:
* [boston_prr_2017_2020.csv](https://wokewindows-data.s3.amazonaws.com/boston_prr_2017_2020.csv)
* [boston_prr_2017_2020.xlsx](https://wokewindows-data.s3.amazonaws.com/boston_prr_2017_2020.xlsx)

## RUNNING
The only requirement for running this project is a working install of [Docker](https://www.docker.com/). All other dependencies are managed in the [Dockerfile](Dockerfile).

```
$ make docker-build
...
$ make docker-run # if this fails, touch env.list
/volume # make clean all # generated files are stored in output/
/volume # make deploy # upload files to S3
```

## FILE LAYOUT
This project's structure is modeled on the practices espoused in [Patrick Ball: Principled Data Processing](https://www.youtube.com/watch?v=ZSunU9GQdcI).

* Makefile is used to execute everything
* input files are stored in `input/` &mdash; there are Make targets to download these
* output files are stored in `output/`
* source code is stored in `lib/`

## LICENSE
This project is released under the MIT License.
