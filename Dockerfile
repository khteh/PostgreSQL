FROM pgvector/pgvector:pg18-trixie AS vector
FROM postgres:latest
#FROM postgis/postgis:latest This won't work as it will hit error: invalid command \restrict due to different versions of psql dump
LABEL org.opencontainers.image.authors="Kok How, Teh <funcoolgeeek@gmail.com>"
COPY --from=vector /usr/lib/postgresql/18/lib/vector.so /usr/lib/postgresql/18/lib/
COPY --from=vector /usr/share/postgresql/18/extension/vector* /usr/share/postgresql/18/extension/
# https://github.com/postgis/docker-postgis/blob/master/18-3.6/Dockerfile
ENV POSTGIS_MAJOR=3
ENV POSTGIS_VERSION=3.6.3+dfsg-1.pgdg13+1
RUN apt update -y\
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt install -y --no-install-recommends \
           # ca-certificates: for accessing remote raster files;
           #   fix: https://github.com/postgis/docker-postgis/issues/307
           ca-certificates \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
      && rm -rf /var/lib/apt/lists/*
#RUN mkdir -p /docker-entrypoint-initdb.d
ADD docker-entrypoint.sh /usr/local/bin/custom-docker-entrypoint.sh
#ADD initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh This will be overwritten by postgresql-initdb mounted volume, so we need to run it in entrypoint instead
ADD update-postgis.sh /usr/local/bin/update-postgis.sh
ENTRYPOINT ["custom-docker-entrypoint.sh"]
STOPSIGNAL SIGINT
EXPOSE 5432
CMD ["postgres"]
