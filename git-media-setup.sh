git config filter.media.clean "git-media filter-clean %s"
git config filter.media.smudge "git-media filter-smudge %s"


git config git-media.sha-file-prefix "{prefix could be blank or 'sha1_' or similar}"
git config git-media.sha-file-suffix "{suffix could be blank or '.blob' or similar}"

#==================
#=== Transports
#==================

git config git-media.transport "{local|s3|scp}"

#For 'local'
git config git-media.localpath "{localpath}"

#For 'scp'
git config git-media.scpuser "{scpuser}"
git config git-media.scphost "{scphost}"
git config git-media.scppath "{scppath}"

#For 's3'
git config git-media.s3bucket "{s3bucket}"
git config git-media.s3key "{s3key}"
git config git-media.s3secret "{s3secret}"



