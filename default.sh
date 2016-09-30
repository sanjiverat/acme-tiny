function STDERR () {
    cat - 1>&2
}


filename=none
filecontent=''
filedir=none
action=none

while :; do
  case "$1" in
    "--help") 
	  echo "default.sh --create|--delete --filename <file name> --file-content <content> --file-dir <directory>" | STDERR
	  exit 1 
	  ;;
    "--create") 
	  action="create" 
	  ;;
    "--delete")  
	  action="delete" 
	  ;;
    "--file-name")
	  filename=$2
	  shift
	  ;;
      "--file-content")
	  filecontent=$2
	  shift
	  ;;
      "--file-dir")
	  filedir=$2
	  shift
	  ;;
      *)  
	  break
  esac
  shift
done

if [ $filename = "none" -o $filedir = "none" ]; then
    echo "file name and directory and needed" | STDERR
    exit 1
fi

filedir=${filedir%/}


case $action in
    "create")
	echo $filecontent > "$filedir"/"$filename"
	;;
    "delete")
	filedir=${filedir%/}/
	rm -rf "$filedir"/"$filename"
	;;
    *)
	echo "create or delete?" | STDERR
	exit 1
esac




