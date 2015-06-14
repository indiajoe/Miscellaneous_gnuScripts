#!/usr/bin/env bash
# This script is to manage the Symlinks listed in the input Symlink list file.
# The input symlink list file should have following four contents in each line

# PathtoSymboliclink PathToTargetDirInsidePartion UUIDofPartition NickNameOfPartion

SymlinkListFile="$1"

function check_status(){
    # Return 0 is the link is functional
    # 1 if the link is broken, and partion doesnot exist
    # 2 if the link is broken, and partion exists and can be corrected
    # 3 if the link is broken, and partion exists but path still not found and cannot be corrected

    read Link Path UUID DiskName <<< $1
    if [ ! -b /dev/disk/by-uuid/$UUID ] ; then # Partion is not available on system
	istatus=1
    elif readlink -e $Link && [ "$(readlink -f /dev/disk/by-uuid/$UUID)" = "$(df $Link |tail -1 |cut -d' ' -f1)" ] ; then  # SymLink is healthy
	istatus=0
    elif [ -e $(grep $(readlink -f /dev/disk/by-uuid/$UUID) /etc/mtab | cut -d' ' -f2)"/$Path" ] ; then # File exists, Repairable
	istatus=2
    else     # Not even file found, Path might have got changed, not repairable
	istatus=3
    fi
    return $istatus
}

function repair_link() {
    # Repairs broken symolick link by correcting to new location
    echo "Not implemented yet $1"
}
#while :
#do
    # Read contents of List file in array
    readarray -t ListEntryArray < "$SymlinkListFile"
    #First check the status of all the links
    Message="Status of Symbolic Links \n"
    MenuMsg=()  # Array to store fixable links
    FixableEntry=() # Array to store fixable link lines
    for entry in "${ListEntryArray[@]}" ; do
	if [ ! -z "$entry" ]; then # Not an empty line
	    check_status "$entry"
	    status=$?
	    NewMsg=""
	    read Link Path UUID DiskName <<< "$entry"
	    case $status in 
		0)
		    NewMsg="$Link ::\Zb\Z2 Healthy\Zn\n"
		    ;;
		1)
		    NewMsg="$Link ::\Zb\Z4 Connect Partition $DiskName\Zn\n"
		    ;;
		2)
		    MenuMsg+=("Auto Fix $Link")
		    FixableEntry+=("$entry")
		    ;;
		3)
		    NewMsg="$Link ::\Zb\Z3 Correct location in Partition $DiskName\Zn\n"
		    ;;
		    
	    esac
	else
	    NewMsg="\n"
	fi
	Message="$Message $NewMsg"
    done
    options=()
    for i in "${!MenuMsg[@]}"; do
	options+=($i  "${MenuMsg[$i]}" off)
    done
    if [[ ${#MenuMsg[@]} -gt 0 ]] ; then  # If there is any fixable links
	# Duplicate file descriptor 1 on descriptor 3
	exec 3>&1
	choices=$(dialog --colors --separate-output --backtitle "Symbolic Link Status" --title "Select to fix"  --checklist "$Message" 0 0 16 "${options[@]}" 2>&1 1>&3 ) 
	# Close file descriptor 3
	exec 3>&-

	for choice in $choices ; do
	    repair_link "${FixableEntry[$choice]}"
	done
    else  # No fixable links
	dialog --colors --backtitle "Symbolic Link Status" --title "Nothing to fix" --ok-label "Close" --msgbox "$Message" 0 0
    fi
#done
