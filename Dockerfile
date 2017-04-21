FROM postgres
RUN apt-get update && apt-get install -y zip gawk
ADD ./* /tmp/psql/
WORKDIR /tmp/psql
# Run PSQL scripts
ENTRYPOINT ./exec_psql.sh
