function STDERR () {
    cat - 1>&2
}


keyfile=none
certfile=none

while :; do
  case "$1" in
    "--help") 
	  echo "save-cert.sh --key-file <domain.private.key> --cert-file <certificate.pem>" | STDERR
	  exit 1 
	  ;;
    "--key-file")
	  keyfile=$2
	  shift
	  ;;
      "--cert-file")
	  certfile=$2
	  shift
	  ;;
      *)
	  break
  esac
  shift
done

if [ $keyfile = "none" -o $certfile = "none" ]; then
    echo "private key and certificate files are needed" | STDERR
    echo "save-cert.sh --key-file <domain.private.key> --cert-file <certificate.pem>" | STDERR
    exit 1
fi


URL="https://"$CPANEL_SERVER":2083/json-api/cpanel?cpanel_jsonapi_module=SSL&cpanel_jsonapi_func=installssl"

CERT=`cat $certfile`
CERT=$(python -c "import urllib; print urllib.quote('''$CERT''')")

KEY=`cat $keyfile`
KEY=$(python -c "import urllib; print urllib.quote('''$KEY''')")

curl -u $CPANEL_USER":"$CPANEL_PASSWORD -d 'crt='$CERT'&key='$KEY -X POST $URL