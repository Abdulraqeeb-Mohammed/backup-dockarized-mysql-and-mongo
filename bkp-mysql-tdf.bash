#!/bin/bash


#store current time
now="tdf-dump-$(date +'%Y%m%d-%H%M%S')"

#create root backup folder, and cd inside
mkdir $now
cd $now

#log the excution of this scipt to bkp.log  file
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>bkp.log 2>&1


#declare a folder for each database 
dbs=("db1" "db2" "db3" )
count=${dbs[@]}

# create folders, and run backup inside each one
for i in $count
do
  mkdir $i
  cd $i
  docker exec mysql /usr/bin/mysqldump -h <ipOrHost> -u  root --password=<Password> $i > "${i}_dump.sql"
  echo "finished $i"
  cd ..
done

#declare a folder for each database 
dbsmongo=("mongodb1" "mongodb2")
countmongo=${dbsmongo[@]}
var2="test"
# create folders, and run backup inside each one
for i in $countmongo
do
  mkdir $i
  cd $i 
  echo "start $i"
  cmd=" docker exec -i mongoorch sh -c 'mongodump --uri=\"mongodb://root:OoOoOo@ipOrHostname:7519/$i?authSource=admin\" -u root -p OoOoOo --archive' >  \"$i.dump\" "
  echo $cmd
  eval  $cmd;
  echo "finished $i"
  cd ..
done



# comprress root folder
cd ..
zip -r "${now}.zip" $now

swaks -s smtp.gmail.com:587 -tls -a LOGIN -f abdo.itis@gmail.com -t abdo.itis@gmail.com --auth-user abdo.itis@gmail.com --auth-password <appSpecificPassFromGamil>  --header "Subject: DB Backup ${now}" --body "DB Backup" --attach "${now}.zip"

# TODO 
#schedule this file to be excuted once every day using Crontab
