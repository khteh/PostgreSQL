#!/bin/bash
docker build -t khteh/postgresql .
docker push khteh/postgresql:latest
