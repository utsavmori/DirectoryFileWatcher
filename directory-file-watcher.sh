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
for file in $1/*; do
    x=$(md5sum $file)
    separateOutchksum $x[@]

    arr+=("$retval $file ")

done
# to print initial list
# echo "${arr[@]}"

#checking files checksum
while 1; do
    for f in $1/*; do
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
                    echo "Identical $fname"
                else
                    echo "Different $fname"
                fi
                break
            fi
        done
        if [ $found = false ]; then
            echo "new file added $f"
        fi
    done
    sleep 60
done
