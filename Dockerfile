FROM pgvector/pgvector:pg17 AS vector
FROM postgres:latest
COPY --from=vector /usr/lib/postgresql/17/lib/vector.so /usr/lib/postgresql/17/lib/
COPY --from=vector /usr/share/postgresql/17/extension/vector* /usr/share/postgresql/17/extension/
ADD docker-entrypoint.sh /usr/local/bin/custom-docker-entrypoint.sh
ENTRYPOINT ["custom-docker-entrypoint.sh"]
STOPSIGNAL SIGINT
EXPOSE 5432
CMD ["postgres"]
