CPANEL_SERVER=your_cpanel.com
CPANEL_USER=your_username
CPANEL_PASSWORD=your_password


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

filename=$(python -c "import urllib; print urllib.quote('''$filename''')")
filecontent=$(python -c "import urllib; print urllib.quote('''$filecontent''')")
filedir=$(python -c "import urllib; print urllib.quote('''$filedir''')")

function cpanel_result() { 
    python -c 'import json,sys;obj=json.load(sys.stdin);print obj["cpanelresult"]["event"]["result"];' 
}

case $action in
    "create")
	echo "Trying to upload challenge file" | STDERR
	url=https://$CPANEL_SERVER":2083/json-api/cpanel?cpanel_jsonapi_module=Fileman&cpanel_jsonapi_func=savefile&filename="$filename"&content="$filecontent
	r=`curl -s -u $CPANEL_USER":"$CPANEL_PASSWORD -X POST $url | cpanel_result`
	if [ $r -ne 1 ]; then
	    echo "Error uploading challenge file" | STDERR
	    exit 1
	fi
	
	url=https://$CPANEL_SERVER":2083/json-api/cpanel?cpanel_jsonapi_module=Fileman&cpanel_jsonapi_func=fileop&op=move&sourcefiles="$filename"&destfiles="$filedir
	r=`curl -s -u $CPANEL_USER":"$CPANEL_PASSWORD -X POST $url | cpanel_result`
	if [ $r -ne 1 ]; then
	    echo "Error uploading challenge file" | STDERR
	    exit 1
	fi
	
	;;
    "delete")
	echo "Trying to delete challenge file and cleanup" | STDERR
	url=https://$CPANEL_SERVER":2083/json-api/cpanel?cpanel_jsonapi_module=Fileman&cpanel_jsonapi_func=fileop&op=trash&sourcefiles="$filedir"/"$filename
	r=`curl -s -u $CPANEL_USER":"$CPANEL_PASSWORD -X POST $url | cpanel_result`
	if [ $r -ne 1 ]; then
	    echo "Error deleting file" | STDERR
	    exit 1
	fi
	;;
    *)
	echo "create or delete?" | STDERR
	exit 1
esac




