FROM postgres
COPY ./* /tmp/scripts/
# Run PSQL scripts
ENTRYPOINT /tmp/scripts/exec_psql.sh