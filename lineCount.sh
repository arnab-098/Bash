if [ $# -lt 2 ]; then
    echo "Please specify the directory and then file extensions!"
    echo "Syntax: $(basename "$0") <directory> <extension1> <extension2> <...>"
    exit
fi

directory="$1"
shift

if [ ! -d $directory ]; then
    if [ -d "./$directory" ]; then
        directory="./$directory"
    elif [[ -d "$HOME/$directory" ]]; then
        directory="$HOME/$directory"
    else
        echo "Directory $directory not found!"
        exit
    fi
fi

for fileType in "$@"; do
    count=$(find "$directory" -type f -name "*.$fileType" -print0 | xargs -0 cat 2>/dev/null | wc -l)
    echo "$fileType: $count"
done
