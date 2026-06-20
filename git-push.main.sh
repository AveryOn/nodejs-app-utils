#!/bin/sh

DATE=$(date +"%Y-%m-%d-%s")
TEXT="$1"

git add .
git commit -m "[$DATE] $TEXT"
git push origin main
