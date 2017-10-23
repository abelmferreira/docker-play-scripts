#!/bin/bash

# Simple Docker Run Script for fast mysql database up
# Runs with --rm for destroy conteiner after use
#
# Choose your start mode
#   -it = para console interativo
#   -d  = para rodar como daemon
#
# Add this line if you have have a sql init script
#   -v $(pwd)/db_init:/docker-entrypoint-initdb.d \

docker run -it --rm --name db \
	-e MYSQL_DATABASE=mydb \
	-e MYSQL_USER=mydbuser \
	-e MYSQL_PASSWORD=mydbuserpass \
	-e MYSQL_ROOT_PASSWORD=mydbrootpass \
	-v $(pwd)/db_data:/var/lib/mysql \
	-p 3306:3306 \
	mysql/mysql-server:latest --character-set-server=utf8 --collation-server=utf8_general_ci


