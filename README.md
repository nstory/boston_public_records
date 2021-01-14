# Boston Public Records
This is quickie script that converts a table of public records requests to the City of Boston (provided to me as two PDF files) into CSV and XLSX files.

This project is probably over-engineered for what it accomplishes; I wanted to riff on some of the practices expoused in [Patrick Ball: Principled Data Processing](https://www.youtube.com/watch?v=ZSunU9GQdcI).

## RUNNING
The only requirement for running this project is a working install of [Docker](https://www.docker.com/). All other dependencies are installed as specified in the [Dockerfile](Dockerfile).

```
$ docker build -t boston_public_records .
...
$ docker run --rm --env-file env.list -v `pwd`:/volume -ti boston_public_records sh
/volume # make clean && make all # generated files are stored in target/
/volume # make deploy # upload files to S3
```

## FILE LAYOUT
* input files are stored in `input/`
* output files are stored in `target/`
* source code is stored in `src/`
* Makefile is used to execute everything

## LICENSE
This project is released under the MIT License.
