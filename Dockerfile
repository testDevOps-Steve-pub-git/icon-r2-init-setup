FROM postgres
RUN apt-get update && apt-get install -y zip
ADD ./* /tmp/scripts/
WORKDIR /tmp/scripts
# Run PSQL scripts
ENTRYPOINT ./exec_psql.sh
