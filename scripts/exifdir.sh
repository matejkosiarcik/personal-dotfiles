#!/bin/sh
set -euf

usage() {
    printf 'Usage: exifdir [-h] [-n] [-i] [-f] <dir>\n'
    printf ' dir    directory to analyze\n'
    printf ' -h     show help message\n'
    printf ' -n     dry run\n'
    printf ' -f     force\n'
}

if [ "$#" -lt 2 ]; then
    printf 'Not enough arguments\n\n' >&2
    usage >&2
    exit 1
fi

mode=''
if [ "$1" = '-n' ]; then
    mode='n'
elif [ "$1" = '-f' ]; then
    mode='f'
fi
if [ "$mode" = '' ]; then
    printf 'No mode specified (specify either -n|-i|-f)\n\n' >&2
    usage >&2
    exit 1
fi

dir="$2"
cd "$dir"

find . \( -iname '*.jpg' -or -iname '*.jpeg' \) -maxdepth 1 -type f | sort --version-sort | while read -r file; do
    filedir="$dir/$(dirname "$file")"
    filename="$(basename "$file")"

    date="$(exiftool -short -short -short -CreateDate "$file" 2>/dev/null | sed 's~:~-~g;s~\.~-~g;s~ ~_~g')"
    if [ "$date" = '' ]; then
        date="$(exiftool -short -short -short -DateTimeOriginal "$file" 2>/dev/null | sed 's~:~-~g;s~\.~-~g;s~ ~_~g')"
    fi
    if [ "$date" = '' ]; then
        date="$(exiftool -short -short -short -FileModifyDate "$file" 2>/dev/null | sed 's~:~-~g;s~\.~-~g;s~ ~_~g' | sed -E 's~\+.+$~~')"
    fi

    if [ "$date" != '' ]; then
        newfilename="$date.jpg"
        i=0
        while [ -e "$filedir/$newfilename" ]; do
            i="$((i + 1))"
            newfilename="$date $i.jpg"
        done
        if [ ! -e "$filedir/$newfilename" ]; then
            printf '%s <- %s\n' "$newfilename" "$filename"
            if [ "$mode" = 'f' ]; then
                mv "$filedir/$filename" "$filedir/$newfilename"
            fi
        else
            printf 'ERROR: Can not move %s to %s (file already exists)\n' "$filename" "$newfilename"
        fi
    else
        printf 'ERROR: No date for %s\n' "$filename" >&2
    fi
done
