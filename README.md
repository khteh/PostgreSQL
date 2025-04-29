# postgresql

- Overwrite docker-entrypoint.sh in https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh to enable multiple databases
- Add `pgvector` extension

## Customization Details:

- https://hub.docker.com/_/postgres "How to extend this image"

- `docker_process_init_files`:
  - Add the following 3 lines to each of file extensions found in `/docker-entrypoint-initdb.d`:
  ```
  file=${f##*/}
  database=${file%.*}
  export DBNAME=$database
  ```
- `docker_process_sql`:
  - Process the database files defined by `docker_process_init_files` with `DB_NAME` variable:
  ```
  if [ -n "$DBNAME" ]; then
  	query_runner+=( --dbname "$DBNAME" )
  ```
- `docker_setup_db`:
  - Check and setup all the `POSTGRES_DB_<foo>`
  - Set the stage in first `POSTGRES_DB_1` for the custom user required by all the subsequent DBs:
  ```
  CREATE USER :"user" WITH PASSWORD :'password' ;
  ```
  - In case a privilege escalation is needed,`CREATE EXTENSION <foo>`, for instance,
  ```
  ALTER USER :"user" WITH SUPERUSER ;
  ```

## Check Existing Databases

```
$ psql -U guest -h <svc-postgresql-nodeport> -l
Password for user guest:
                                                        List of databases
       Name       |  Owner   | Encoding | Locale Provider |  Collate   |   Ctype    | Locale | ICU Rules |   Access privileges
------------------+----------+----------+-----------------+------------+------------+--------+-----------+-----------------------
 AspNetCoreWebApi | guest    | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           |
 Langchain        | guest    | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           |
 library          | guest    | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           |
 postgres         | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           |
 school           | guest    | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           |
 template0        | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | =c/postgres          +
                  |          |          |                 |            |            |        |           | postgres=CTc/postgres
 template1        | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | =c/postgres          +
                  |          |          |                 |            |            |        |           | postgres=CTc/postgres
(7 rows)
```

## Dump the selected database

```
$ pg_dump -U guest -h <svc-postgresql-nodeport> -d <database> -f <database>.sql
```

## Map the databases in postgresql.yml

```
            - name: POSTGRES_DB_1
              value: AspNetCoreWebApi
            - name: POSTGRES_DB_2
              value: library
            - name: POSTGRES_DB_3
              value: school
            - name: POSTGRES_DB_4
              value: LangchainCheckpoint
```

## PostGIS

- Use https://hub.docker.com/r/postgis/postgis as base image

## PostgreSQL HA cluster

- https://github.com/bitnami/charts/tree/main/bitnami/postgresql-ha

### Readings

- https://www.cncf.io/blog/2023/09/29/recommended-architectures-for-postgresql-in-kubernetes/
