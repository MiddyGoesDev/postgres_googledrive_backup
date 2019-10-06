# At 23:50 we create the sql backup dump and at 23:55 we upload it into the cloud.
# At 23:59 we send an email of the logfile.
# At sunday 00:00 on every sunday we empty the backup folder
50 23 * * * /home/pcadmin/cron_backup.sh > /tmp/backup.log
55 23 * * * /usr/bin/python3 /home/pcadmin/upload_script/drive_upload.py >> /tmp/backup.log
59 23 * * * /usr/sbin/sendmail -F "192.168.1.2" finnrietz@googlemail.com < /tmp/backup.log
0 0 * * 0 rm -r /tmp/vsdb_backups/*