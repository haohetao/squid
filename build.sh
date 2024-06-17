#!/bin/sh

docker build . -t haohetao/squid --build-arg http_proxy=http://192.168.33.6:3128 --build-arg https_proxy=http://192.168.33.6:3128
