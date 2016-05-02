#!/usr/bin/env bash
# This script is to backup a set of directories to an external hardisk

declare -a DirectoriesToBackup=("/home/joe/Research" 
"/home/joe/zotero"
"/home/joe/GitHub"
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

FailedDirs=""

#Do copying one directory at a time
for dir in "${DirectoriesToBackup[@]}"; do
    echo
    echo "|> Backing up $dir to $BackupDestination"
    rsync -av "$dir" "$BackupDestination"
    if [ $? -ne 0 ]; then
	echo -e "\e[1;31m ERROR >>> Backup of $dir Failed ************ \e[0m"
	FailedDirs="$FailedDirs"" | $dir |"
    fi
done


# Report summary of success
if [[ -z "$FailedDirs" ]]; then
    echo "All Directories Backedup successfully."
    exit 0
else
    echo " ************************************"
    echo -e "\e[1;31m WARNING >>> Failed to Backup following directories \e[0m"
    echo -e "\e[1;31m $FailedDirs \e[0m"
    echo " ************************************"
    exit 1
fi
    
