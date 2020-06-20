# XBackup specification

xbackup program performs multiple rsync incremental backup operations according to configuration.

The program reads a set of csv-formatted files,
Each csv file contains a set of specific columns which parametrizes backup process.
Each data line specify one backup operation.

Consider following example `file.csv`:
```
bucket, host, tgtdir, dayofweek, clean
repo@server.com:/var/datadir/, machine1, /data/xbackup/data1, 1-7, 30:7 365:-1
repo@server.com:/var/datadir/, machine2, /data/xbackup/data1, 1-7, 30:7 365:-1
repo@server2.com:/other/dir/, machine1, /data/xbackup/other-dir, 3, 30:7 365:-1
```
Running `xbackup file.csv` will result in:
1. Only operations that match `host` column to the current computer's hostname will be performed.
2. Only operations that match `dayofweek` column to current day of week will be performed.

That is, if xbackup is started on computer with hostname "machine1" on wendesday,
the first and last operations will be peformed.
If xbackup is started say on sunday, only first operation will be performed.

3. After successful data copy from `bucket` to directory `dir` on `host`, 
a directory `dir` will be cleaned up from unnecessary data according to `clean` configuration.

Processing steps
================

Each line of incoming csv data is processed by following steps in order as they specified in this document.

Host filter
-----------

Day of week filter
------------------

Copy
----
If bucket and dir columns exist: 
 * rsync data from `bucket` to `tgtdir`/`current-date-stamp-dir`/
 * use hard links for files that are not changed from previous sync.
 * have `tgtdir`/latest symlink to last successful backup dir above
 
As a result, a following directory structure appears:
```
/tgtdir
/tgtdir/latest
/tgtdir/date1
/tgtdir/date2
...
```
where each date folder contains full data backup. 

Additionally:
 * use file lock on `dir`/lockfile. if file is already locked - discard operation.
 * save `tgtdir`/rsync.log file
 * save `tgtdir`/rsync.size file with total size of data reported by rsync

Clean
-----
Cleans extra copies of data in `tgtdir` according to specified configuration.

Let tgtdir contains items (files or dirs) which names looks like date -- whis is so after `copy` operation mentioned above.
Let there is a configuration for cleaning in a form:
* ago1:window1 ago2:window2 ... agoN:windowN

Clean step deletes those items who match:
*   itemdate < ago_i days
*   &&
*   there already found other item in window_i days.

`window` valid values: -1..32, where
* -1=delete
* 0=keep all copies
* 1=keep one item during day,
* 7=keep one item during week
* 32=keep one item in a month

Example clean configuration: 
> 0:1 30:7 180:30 365:-1
which means after 0 days, keep 1 item for each day; after 30 days, keep 1 copy of 7 days, after 180 days, keep 1 copy of 30 days, after 365, delete all"

Postcmd
-------

Plugin system
=============
Copy, filters, clean aspects mentioned above are plugins. Other plugins might exist.
A common algorythm of processing is a following.

- Let `columns` is a list of columns of current csv file.
- Let `d` is a list of values of fields of current line.
- Let `h` is a hash for of `d` where keys are column names.

## Step 1.
Call `is_allowed? : h -> true|false` method. If operation is allowed, it should return true.

Each plugin of xbackup might prepend it's own code to `is_allowed?` algorythm and thus influence `is_allowed?` behaviour.
For example, `host` plugin will check presence of `host` column and if present, check current computer hostname for matching 
to `d.host` value.

## Step 2.
If step 1 returns true, call `perform : h -> true|false` method, which do the job. 

All plugins might prepend their alrorithms to `perform`
and thus do various useful things. For example, `clean` alroryhtm will do the clean job after data copy.
The order of algorythm prepends is importand, and is specified by xbackup.

Actually, the step performs ECS-style processing of operation.
Operations are entities, columns are components, methods are systems.
