#!/usr/bin/env bash
# This script is to backup a set of directories to an external hardisk

declare -a DirectoriesToBackup=("/home/joe/Research" 
"/home/joe/zotero"
"/home/joe/Github"
"/home/joe/ImportantFiles"
"/home/joe/ConfSchoolWorkshops"
"/home/joe/PD_applications"
"/home/joe/Projects"
"/home/joe/Webpages")

# To obtain the mounted directory of Hdisk using its UUID use findmnt command
# Eg:
# findmnt -n -o TARGET /dev/disk/by-uuid/b4f4662d-eca1-4698-8d1b-802226f6939b
# Else provide the directory path to destination below

DestinationHdisk=$(findmnt -n -o TARGET /dev/disk/by-uuid/b4f4662d-eca1-4698-8d1b-802226f6939b)
if [[ -z "$DestinationHdisk" ]]; then
    echo "Destination Hardisk not mounted.."
    echo "Please mount the destination to backup."
    echo "Exiting without Backup.."
    exit 1
fi

BackupDestination="$DestinationHdisk"/Backup/


for dir in "${DirectoriesToBackup[@]}"; do
    echo "|> Backing up $dir to $BackupDestination"
    rsync -av "$dir" "$BackupDestination"
done

    
