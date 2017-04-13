FROM postgres

COPY ./* /tmp/scripts/
WORKDIR /tmp/scripts
# Run PSQL scripts
ENTRYPOINT ./exec_psql.sh