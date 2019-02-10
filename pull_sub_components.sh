#!/bin/bash

mkdir -p ./boms/.bom
cd ./boms/.bom

mkdir ./.bom/echo
cd ./.bom/echo
wget https://raw.githubusercontent.com/spinnaker/echo/master/halconfig/echo-scheduler.yml
wget https://raw.githubusercontent.com/spinnaker/echo/master/halconfig/echo.yml
wget https://raw.githubusercontent.com/spinnaker/echo/master/halconfig/echo-worker.yml
 
cd ../
mkdir clouddriver
cd clouddriver/
wget https://raw.githubusercontent.com/spinnaker/clouddriver/master/halconfig/clouddriver-bootstrap.yml
wget https://raw.githubusercontent.com/spinnaker/clouddriver/master/halconfig/clouddriver-caching.yml
wget https://raw.githubusercontent.com/spinnaker/clouddriver/master/halconfig/clouddriver-ro-deck.yml
wget https://raw.githubusercontent.com/spinnaker/clouddriver/master/halconfig/clouddriver-ro.yml
wget https://raw.githubusercontent.com/spinnaker/clouddriver/master/halconfig/clouddriver-rw.yml
wget https://raw.githubusercontent.com/spinnaker/clouddriver/master/halconfig/clouddriver.yml

cd ../
mkdir deck
cd deck/
wget https://raw.githubusercontent.com/spinnaker/deck/master/halconfig/settings.js

cd ../
mkdir fiat
cd fiat/
wget https://raw.githubusercontent.com/spinnaker/fiat/master/halconfig/fiat.yml

cd ../
mkdir front50
cd front50/
wget https://raw.githubusercontent.com/spinnaker/front50/master/halconfig/front50.yml

cd ../
mkdir gate
cd gate/
wget https://raw.githubusercontent.com/spinnaker/gate/master/halconfig/gate.yml

cd ../
mkdir igor
cd igor/
wget https://raw.githubusercontent.com/spinnaker/igor/master/halconfig/igor.yml


cd ../
mkdir kayenta
cd kayenta/
wget https://raw.githubusercontent.com/spinnaker/kayenta/master/halconfig/kayenta.yml

cd ../
mkdir orca
cd orca/
wget https://raw.githubusercontent.com/spinnaker/orca/master/halconfig/orca-bootstrap.yml
wget https://raw.githubusercontent.com/spinnaker/orca/master/halconfig/orca.yml

cd ../
mkdir rosco
cd rosco/
wget https://raw.githubusercontent.com/spinnaker/rosco/master/halconfig/images.yml
wget https://raw.githubusercontent.com/spinnaker/rosco/master/halconfig/rosco.yml




