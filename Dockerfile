FROM postgres
COPY ./* /tmp/scripts/
COPY scripts/* /tmp/scripts/

# Run PSQL scripts
ENTRYPOINT /tmp/scripts/exec_psql.sh