#!/bin/bash

retval=''
separateOutchksum() {
    retval=''
    x=''
    for i in $1; do
        x=$i
        break
    done
    retval=$x
}

# creating list of  files initially
arr=()
for file in $(find "$1"); do
    # check is file
    if [ -f $file ]; then
    x=$(md5sum $file)
    separateOutchksum $x[@]
    arr+=("$retval $file")
    fi
done
echo "finished initial indexing"
# to print initial list
# echo "${arr[@]}"

# checking files checksum
while [ 1 ]; do
    echo "checking for updates"
    addUpdate=()
    deleteUpdate=()
    # check for new file and updated files
    for f in $(find "$1"); do
        if [ -f $f ]; then
        found=false
        for file in "${arr[@]}"; do
            fname=''
            for i in $file; do
                fname=$i
            done

            if [ "$fname" = "$f" ]; then
                found=true
                separateOutchksum $file[@]
                oldchksum=$retval
                newchksum="$(md5sum "$fname")"
                separateOutchksum $newchksum[@]

                if [ "$retval" = "$oldchksum" ]; then
                    # echo "Identical $fname"
                    :
                else
                    addUpdate+=("$retval $fname")
                    deleteUpdate+=("$oldchksum $fname")
                    echo "Different $fname"
                fi
                break
            fi
        done
        if [ $found = false ]; then
            newchksum="$(md5sum "$f")"
            separateOutchksum $newchksum[@]
            addUpdate+=("$retval $f")
            echo "new file added $f"
        fi
        
        fi
    done
    # check for deleted file
    
    for file in "${arr[@]}"; do
        flag=false
        fname=''
        for i in $file; do
            fname=$i
        done
        for f in $(find "$1"); do
            if [ -f $f ]; then
                if [ "$f" = "$fname" ]; then 
                    flag=true
                    break
                fi
            fi
        done
        if [ $flag = false ]; then 
            deleteUpdate+=("$file")
            echo "file deleted $fname"
        fi
    done
    # updating tracking array
    for del in "${deleteUpdate[@]}"
    do
        arr=("${arr[@]/$del}") 
    done
    # try to re allocate spaces that are deleted if no spaces found than do new allocation
    for ad in "${addUpdate[@]}"
    do
        flg=false
        ind=0
        for q in "${arr[@]}"; do
            if [ "$q" = "" ]; then
                arr[ind]=$ad
                flg=true
                break
            fi
            ind+=1
        done
        if [ $flg = false ]; then
            arr+=("$ad") 
        fi
    done
    sleep 60
    echo "completed next watch will be after 60 seconds"
done
