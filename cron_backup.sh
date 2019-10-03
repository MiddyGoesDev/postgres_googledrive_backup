#!/bin/bash

# THIS IS THE SCRIPT THAT IS RUN IN CRONTAB OF USER POSTGRES TO CREATE THE SQL DUMPS OF THE DATABASE TABLE VSDB, MAKE CHANGES WITH CARE!

# get current timestamp
timestamp=$(date +\%Y\%m\%d_\%H\%M)

# get ip address of machine, second command removes the dots from the ip addr
temp_ip4_addr=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
ip4_addr="${temp_ip4_addr//./}"

# this is for my email logs, so that subject is set properly
# echo "From: logmemiddy@gmail.com"
echo "Subject: Backup logs from $timestamp on $ip4_addr"

# send log entry to /var/log/messages
logger "Starting backup process of postgres table vsdb, timestamp for this backup is $timestamp"
echo "Starting backup process of postgres table vsdb, timestamp for this backup is $timestamp"

# the point where we save the backup files
save_dir="/tmp/vsdb_backups"
logger "Save direcory for backup sql file is $save_dir"
echo "Save direcory for backup sql file is $save_dir"

# if folder doesn't exist (due to reboot) make a new one, so that later save directory is valid
if [ ! -d $save_dir ]; then
  mkdir $save_dir
  logger "Direcory $save_dir does not exist, trying to create directory"
  echo "Direcory $save_dir does not exist, trying to create directory"

  if [ $? -eq 0 ]; then
    logger "Successfully created directory at $save_dir"
    echo "Successfully created directory at $save_dir"
  else
    logger "Failed to create new directory $save_dir, exiting backup process"
    echo "Failed to create new directory $save_dir, exiting backup process"
    exit
  fi
fi

# create the backup
pg_dump vsdb > $save_dir/$timestamp"_vsdb_dump_"$ip4_addr".sql"

# ouput depening on return code...:
if [ $? -eq 0 ]; then
  logger "Successfully create backup file of database table vdsb at $save_dir/${timestamp}_vsdb_dump_${ip4_addr}.sql"
  echo "Successfully create backup file of database table vdsb at $save_dir/${timestamp}_vsdb_dump_${ip4_addr}.sql"
  logger "Finished backup process"
  echo "Finished backup process"
else
  logger "Failed to create a backup file (Return code NE 0), check directory $save_dir, file ${timestamp}_vsdb_dump_${ip4_addr}.sql might be empty or non exisitant"
  echo "Failed to create a backup file (Return code NE 0), check directory $save_dir, file ${timestamp}_vsdb_dump_${ip4_addr}.sql might be empty or non exisitant"
  logger "Backup process terminated unsuccessfully"
  echo "Backup process terminated unsuccessfully"
  exit
fi
