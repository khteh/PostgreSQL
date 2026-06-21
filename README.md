# postgresql

- Overwrite docker-entrypoint.sh in https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh to enable multiple databases

## Extensions:

- `pgvector`:
  ```
  postgres=# \c Langchain
  You are now connected to database "Langchain" as user "postgres".
  Langchain=# \dx
                                        List of installed extensions
    Name   | Version | Default version |   Schema   |                     Description
  ---------+---------+-----------------+------------+------------------------------------------------------
  plpgsql | 1.0     | 1.0             | pg_catalog | PL/pgSQL procedural language
  vector  | 0.8.3   | 0.8.3           | public     | vector data type and ivfflat and hnsw access methods
  (2 rows)
  ```
- `postgis`:
  ```
  postgres=# \c postgres
  postgres=# \dx
                                                  List of installed extensions
            Name          | Version | Default version |   Schema   |                        Description
  ------------------------+---------+-----------------+------------+------------------------------------------------------------
  fuzzystrmatch          | 1.2     | 1.2             | public     | determine similarities and distance between strings
  plpgsql                | 1.0     | 1.0             | pg_catalog | PL/pgSQL procedural language
  postgis                | 3.6.4   | 3.6.4           | public     | PostGIS geometry and geography spatial types and functions
  postgis_tiger_geocoder | 3.6.4   | 3.6.4           | tiger      | PostGIS tiger geocoder and reverse geocoder
  postgis_topology       | 3.6.4   | 3.6.4           | topology   | PostGIS topology spatial types and functions
  (5 rows)
  ```

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

- `docker_process_postgis`:
  - Add PostGIS initialization script which would otherwise be overwritten by postgresql-initdb mounted volume.

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

```
postgres=# SELECT * FROM pg_available_extensions WHERE name = 'postgis';
  name   | default_version | installed_version |                          comment
---------+-----------------+-------------------+------------------------------------------------------------
 postgis | 3.6.4           |                   | PostGIS geometry and geography spatial types and functions
```

## PostgreSQL HA cluster

- https://github.com/bitnami/charts/tree/main/bitnami/postgresql-ha

### Readings

- https://www.cncf.io/blog/2023/09/29/recommended-architectures-for-postgresql-in-kubernetes/
