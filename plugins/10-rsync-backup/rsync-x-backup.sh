#!/bin/bash -e

# Incremental rsync backup

# usage: src=rsync-source-url tgtdir=local-dir rsync-x-backup.sh

# result:
# * rsync data from $src to $tgtdir/current-date-stamp-dir/
# * have $tgtdir/latest symlink to last successful backup dir above
# * use hard links for files that are not changed from previous sync.
# * use flock on $tgtdir/process/lockfile
# * save log to $tgtdir/rsync.log
# * save total size to $tgtdir/rsync.totalsize

# optional env params:
# * dryrun - do dry run
# * rsync_options - extra options for rsync command line

# 2020 (c) Pavel Vasev MIT license

test ! -z "$tgtdir"
test ! -z "$src"

processdir="$tgtdir/process"
latestdir="$tgtdir/latest"
datedir="$tgtdir/$(date +\%Y-\%m-\%d-\%H-\%M)"
logfile="$tgtdir/rsync.log"
sizefile="$tgtdir/rsync.size"

 # --copy-links is about symolic links in source bucket
 # --link-dest is about to where look for already downloaded data
 # --bwlimit 1000 useful option to limit download speed / disks io
 # -m skip empty dirs == --prune-empty-dirs

rsynccmd="rsync -rt --copy-links -v --delete --stats $src/ $processdir --link-dest=$latestdir $rsync_options"
# чето массив не сработал
#rsynccmd=(rsync -rt --copy-links -v --delete --stats $src/ $processdir --link-dest=$latestdir $rsync_options)
# https://unix.stackexchange.com/questions/444946/how-can-we-run-a-command-stored-in-a-variable


if test ! -z "$dryrun"; then
  echo "$rsynccmd"
  echo "#dryrun"
  exit 0
fi

if test -d "$datedir"; then
  echo "dir $datedir already exist! skipping backup."
  exit 0
fi

mkdir -p $tgtdir
(
flock --nonblock 9 || (echo lockfile is locked; skipping backup operation; exit 1)
# --verbose

mkdir -p $processdir # for some reason rsync fails if no dir exist

echo "running: $rsynccmd"
#"${rsynccmd[@]}" | tee "$logfile"
eval "$rsynccmd" | tee "$logfile"
echo "rsync complete"
sleep 3

# extract and save size
echo "$datedir" >>"$sizefile"
cat "$logfile" | grep -Po '(?<=total size is )[\d,]+' >>"$sizefile"

# move dirs
mv --no-target-directory "$processdir" "$datedir"
rm -f -d "$latestdir"
ln --relative -s "$datedir" "$latestdir"

echo "rsync-x-backup complete. logfile $logfile"

) 9>"$tgtdir/lockfile"
