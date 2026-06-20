#!/bin/bash
#docker build --no-cache --pull -t khteh/postgresql . --progress=plain 
docker build --pull -t khteh/postgresql .
docker push khteh/postgresql:latest
