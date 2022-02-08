# xbackup-tool

# Usage

1. Create a CSV file with configuration for the tool.

example.csv:
```
bucket, host, tgtdir, dayofweek, clean, rsync_options

### example-db-main - this is comment
root@host.com:/mnt/lact_logs/backup/, host15, /data/xbackup-all/example-db-main, 1-7, 60:7 180:32 1000:-1
root@host.com:/mnt/lact_logs/backup/, data3, /data/xbackup-all/example-db-main, 1-7, 60:7 180:32 1000:-1

### example-db-sites - this is comment
root@host.com:/data-db/korzinki/db1, host15, /data/xbackup-all/example-db-sites, 1-7, 60:7 180:32 1000:-1,--bwlimit=1000
root@host.com:/data-db/korzinki/db1, data3, /data/xbackup-all/example-db-sites, 1,    60:7 180:32 1000:-1,--bwlimit=1000
```

* each line denotes a task.
* `bucket` column is a rsync-format url to get files from
* `tgtdir` column is a dir on local machine to backup files to

* `host` column is a filter. Only if local machine name equals to host value, the task is performed.
* `dayofweek` column is filter. Only if current day matches dayofweek value, the task is performed.

* `clean` column denotes how old copies should be cleaned up.
* `rcync_options` column is extra options for rsync.

See full specification for details.

2. Run backup-tool:
```
xbackup-tool example.csv
```

This loads example.csv and performs tasks specified in it, one by one.
Many files may be specified, for example: `xbackup-tool my-backups*.csv`

# Specification
[spec](spec.md)


# Copyright
2022 (c) Pavel Vasev