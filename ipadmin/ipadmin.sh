#/bin/sh

F_TO_GREP_FOR_IPS='/var/log/auth.log'
STR_TO_GREP='Accepted password for'

F_DIR='./tmp'
F_IPS="${F_DIR}/fips"
F_GEO_JSON="${F_DIR}/fgeojson.json"
F_OPENLAYER="./fopenlayer.txt"

SEP='\t'
OPENLAYER_HEAD="lat${SEP}lon${SEP}title${SEP}description${SEP}icon${SEP}${SEP}iconSize${SEP}${SEP}iconOffset"

grepforips() {
  grep "$1" "$2" \
    | awk '{print $11}' \
    | sort -u
}

getgeoip() {
  curl -sS http://freegeoip.net/json/$1
}

# https://gist.github.com/cjus/1047794
jsonval() {
  temp=$(echo $1 \
    | sed 's/\\\\\//\//g' \
    | sed 's/[{\"}]//g' \
    | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' \
    | sed 's/\"\:\"/\|/g' \
    | sed 's/[\,]/ /g' \
    | sed 's/\"//g' \
    | grep -w $2 \
    | awk -F ':' '{print $2}')

  echo ${temp##*|}
}

##
if [ ! -r ${F_TO_GREP_FOR_IPS} ]
then
  echo "No read permission on ${F_TO_GREP_FOR_IPS}."
  echo 'Aborting'
  exit 1
fi

if [ ! -d ${F_DIR} ]; then mkdir ${F_DIR}; fi

echo "Looking for IPs in ${F_TO_GREP_FOR_IPS}"
test -e ${F_IPS} && mv -f ${F_IPS} ${F_IPS}.old
touch ${F_IPS}

echo $(grepforips "${STR_TO_GREP}" "${F_TO_GREP_FOR_IPS}") > ${F_IPS}
echo "Found $(wc -w ${F_IPS} | awk '{print $1}') different IPs"

echo "Getting geo info about found IPs"
test -e ${F_GEO_JSON} && mv -f ${F_GEO_JSON} ${F_GEO_JSON}.old
touch ${F_GEO_JSON}

for ip in $(cat ${F_IPS}); do
  getgeoip ${ip} >> ${F_GEO_JSON}
  echo >> ${F_GEO_JSON}
done
echo 'Done'

echo 'Generating OpenLayer file'
test -e ${F_OPENLAYER} && mv -f ${F_OPENLAYER} ${F_OPENLAYER}.old
echo ${OPENLAYER_HEAD} > ${F_OPENLAYER}

ICON='./img/Ol_icon_blue_example.png'
I_SIZE='16,16'
I_OFFSET='-8,-8'

cat ${F_GEO_JSON} | while read json; do
  lat=$(jsonval "${json}" latitude)
  long=$(jsonval "${json}" longitude)
  ip=$(jsonval "${json}" ip)
  city=$(jsonval "${json}" city)
  region_name=$(jsonval "${json}" region_name)
  desc="${city}, ${region_name}"

  echo "${lat}${SEP}${long}${SEP}${ip}${SEP}${desc}${SEP}${ICON}${SEP}${I_SIZE}${SEP}${I_OFFSET}" \
    >> ${F_OPENLAYER}
done

echo "" >> ${F_OPENLAYER}
echo 'Done'
