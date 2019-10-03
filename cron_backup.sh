#!/bin/bash

# use like: ./cron_backup.sh "path/to/config.yaml"

# yaml parser function
# https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# read first and only command line argument, which must be the full, absolute path to the config.yaml file
config_path=$1

echo "config_path: $config_path"

# parse the yaml configuration file
eval $(parse_yaml $config_path)


# get current timestamp
timestamp=$(date +\%Y\%m\%d_\%H\%M)

# get ip address of machine, second command removes the dots from the ip addr
temp_ip4_addr=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
ip4_addr="${temp_ip4_addr//./}"

# this is for my email logs, so that subject is set properly
# echo "From: logmemiddy@gmail.com"
echo "Subject: Backup logs from $timestamp on $ip4_addr"

# send log entry to /var/log/messages
echo "Starting backup process of postgres table vsdb, timestamp for this backup is $timestamp"

# the point where we save the backup files, parsed from yaml config file
save_dir=$local_backup_folder
echo "Save direcory for backup sql file is $save_dir"

# if folder doesn't exist (due to reboot) make a new one, so that later save directory is valid
if [ ! -d $save_dir ]; then
  mkdir $save_dir
  echo "Direcory $save_dir does not exist, trying to create directory"

  if [ $? -eq 0 ]; then
    echo "Successfully created directory at $save_dir"
  else
    echo "Failed to create new directory $save_dir, exiting backup process"
    exit
  fi
fi

# create the backup
# pg_dump vsdb > $save_dir/$timestamp"_vsdb_dump_"$ip4_addr".sql"
pg_dump $target_db > $save_dir/$timestamp"_vsdb_dump_"$ip4_addr".sql"

# ouput depening on return code...:
if [ $? -eq 0 ]; then
  echo "Successfully create backup file of database table vdsb at $save_dir/${timestamp}_vsdb_dump_${ip4_addr}.sql"
  echo "Finished backup process"
else
  echo "Failed to create a backup file (Return code NE 0), check directory $save_dir, file ${timestamp}_vsdb_dump_${ip4_addr}.sql might be empty or non exisitant"
  echo "Backup process terminated unsuccessfully"
  exit
fi
