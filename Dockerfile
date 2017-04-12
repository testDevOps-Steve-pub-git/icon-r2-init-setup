FROM postgres
COPY ./* /tmp/scripts/

# Run PSQL scripts
RUN /tmp/scripts/scripts/exec_psql.sh