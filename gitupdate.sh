#!/bin/sh
cmt="AUTO UPDATE $(date '+%Y/%m/%d %H:%M:%S')"
echo "${cmt}"
git add .
git commit -m "${cmt}" 
git push
echo Press Enter...
read