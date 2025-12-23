FROM pgvector/pgvector:0.8.1-pg18 AS vector
FROM postgres:latest
LABEL org.opencontainers.image.authors="Kok How, Teh <funcoolgeeek@gmail.com>"
COPY --from=vector /usr/lib/postgresql/18/lib/vector.so /usr/lib/postgresql/18/lib/
COPY --from=vector /usr/share/postgresql/18/extension/vector* /usr/share/postgresql/18/extension/
ADD docker-entrypoint.sh /usr/local/bin/custom-docker-entrypoint.sh
ENTRYPOINT ["custom-docker-entrypoint.sh"]
STOPSIGNAL SIGINT
EXPOSE 5432
CMD ["postgres"]
