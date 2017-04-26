FROM postgres
RUN apt-get update && apt-get install -y zip gawk
ADD ./* /tmp/psql/
WORKDIR /tmp/psql
RUN chmod +x ./exec_psql.sh
# Run PSQL scripts
ENTRYPOINT ./exec_psql.sh
