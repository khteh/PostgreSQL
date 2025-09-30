#!/bin/bash
docker build -t khteh/postgresql . --no-cache
docker push khteh/postgresql:latest
