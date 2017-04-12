FROM postgres
COPY ./* /tmp/scripts/

# Run PSQL scripts
ENTRYPOINT ["/tmp/scripts/scripts/exec_psql.sh"]