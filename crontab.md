# At 23:50 we create the sql backup dump and 
# At 23:55 we upload it into the cloud.
# At sunday 00:00 on every sunday we empty the backup folder
50 23 * * * /home/pcadmin/automatic_backup/cron_backup.sh /path/to/config.yaml > /tmp/backup.log
55 23 * * * /usr/bin/python3 /home/pcadmin/automatic_backup/drive_upload.py -cf /path/to/config.yaml >> /tmp/backup.log
0 0 * * 0 rm -r /tmp/vsdb_backups/*