#!/bin/bash

# make for the EzShare SD card wifi / microSD white
# Not suee if compatible with all versions
# The webinterface could differt and then have to modify the getLine function
# about the mode for example HardMode=15s NormalMode= SoftMode=3min15s

########## Edit this to change your local destination ########### ########### ########### ########### ########### 

# Local directory for the data
mainDir="/config/SDCARD/"

# Ez Share top Url, top directory, first folder and subfolders
mainUrl="http://192.168.4.1"

remoteDir=("dir=A:")

# auto check if all utilities are present
check="true"

# 3 Modes of download: 
# normal
# soft
# hard
# soft download mode is slower, dl 1 by 1 but safer (useless but was my first method so if problem use it)
# hardmode is fast but less safe (if card crash disable it)
mode="normal"

# parallels download aviable only for normal mode (decrease if computer isssue or play with it to try to download faster)
pDl=16 #default: 8

# Use this program as a ignoreList or a fileList, as you prefer
fileList=".log|.crc|.tgt|.dat|.edf|.json|DATALOG|SETTINGS"
#ignoreList=".Spotlight-V100|.Trashes|._.DS_Store|.DS_Store|.fseventsd|Volume|SYSTEM~1|EZSHARE.CFG|Id.txt"                                         
                                                                                                      
########### Don't touch the rest ########### ########### ########### ########### ########### ########### ###########

# Removing STR.edf file, sometimes the extension is ALL CAPS and won't import into OSCAR
rm ${mainDir}STR.edf 2>/dev/null

########### some variables ###########
SECONDS=0

currentDir=0
nbdAll=0

nbfAll=0
nbfNew=0
nbfUpd=0

nbfDl=0
dlList=()


########### check installed utilities ###########
for ex in \
echo echo date grep sed xargs wget
  do
    loc=$(which "${ex}")
    if [ "${loc}" = "" ] ; then
      echo "${ex} is missing"
      check="false"
    fi
done
if [ "${check}" = "false" ] ; then
    echo "Some utilities are missing"
    exit 1
fi
ECHO=$(which echo)


#################### download files ####################
# from absolute link could be faster with the download links
# from the webbrowser but I started like that
dlList()
{
  [ -d "${mainDir}$/{relPath[$currentDir]}" ] || mkdir -p "${mainDir}/${relPath[$currentDir]}"
  if [ "${mode}" == "normal" ]; then
    dlList["$nbfDl"]="${localFile} ${mainUrl}/${relFile}"
    let nbfDl=nbfDl+1
  else
    echo "${localFile} ${mainUrl}/${relFile}" |  xargs -n 2 -P "${pDl}" wget --no-use-server-timestamps -q -O 
  fi
}


#################### show files to downlad ####################
dlShow()
{
  for value in "${dlList[@]}"
  do
    echo "${value}"
  done
}


#################### dowlnoad files ####################
dlProcess()
{
   echo "${dlList[*]}" | xargs -n 2 -P "${pDl}" wget --no-use-server-timestamps -q -O 
}


########## cleanning lines ##########
getLine()
{
  wget -q -O- "${mainUrl}/dir?${remoteDir[$currentDir]}" |
  sed -n '/a>$/p' | sed -e '/\.<\/a>$/d' |  sed -e 's/<\/a>//g' | sed -e 's/<a href="//g' | sed -e 's/">//g' |
  sed -e's/- /-0/g' | sed -e 's/: /:0/g' | sed -e 's/&lt;DIR&gt;/DIR/g' |
  if [ ! -z "$ignoreList" ] ; then grep -vwE -i "${ignoreList}" ; elif [ ! -z "$fileList" ] ; then grep -E -i "${fileList}" ; fi
}


#################### get info from the webbrowser ####################
getDataInfo()
{ 
  while read line ; do
    if [ ! -z "$line" ]; then
      arr=(${line})
      for i in "${arr[@]}" ; do
        echo $i
      done
    fi
  done <<< $(getLine)
}


#################### scan server ####################
fileORdir()
{
echo "Scan of ${remoteDir[0]}${relPath[$currentDir]}"
while read fileDate ; do
  if [ ! -z "$fileDate" ]; then
  read fileTime
  read fileSize
  read link
  read fileName
  remoteTime="$(date -d "${fileDate} ${fileTime}" +%s)"
  ########## DIR ##########
  if [ "$fileSize" = "DIR" ] ; then
    let nbdAll=nbdAll+1
    let currentDir=currentDir+1
    #chemin relatif du dossier (local&web) + #chemin relatif du champ de dossier web
    if [ "$currentDir" -eq "1" ] ; then
      relPath[$currentDir]="${fileName}"
      remoteDir[$currentDir]="${remoteDir[0]}${fileName}"
    else
      relPath[$currentDir]="${relPath[$currentDir-1]}/${fileName}"
      remoteDir[$currentDir]="${remoteDir[$currentDir-1]}%5C${fileName}"
    fi
    fileORdir
    let currentDir=currentDir-1
########## To check >>>> (maybe can't work if server return the bad informations could be usefull to skip folders have to add it)
: <<'END'
    local_DIR="${mainDir}/${relPath[$currentDir]}"

    if ! [ -d "${local_DIR}" ]; then
      let nbdNEW=nbdNEW+1
      fileORdir
      echo "New directory find: ${local_DIR}"
    elif [ "$(date -r "${local_DIR}" +%s)" -lt "$(date -d "${fileDate}" +%s)" ] ; then
      let nbdUPD=nbdUPD+1
      fileORdir
      echo "Updated directory find: /${local_DIR}"
    fi
END
########## <<<<< To check 
  ########## FILE ##########
  else
    let nbfAll=nbfAll+1

    if [ "$currentDir" -eq "0" ] ; then
      relFile="${fileName}"
    else
      relFile="${relPath[$currentDir]}/${fileName}"
    fi

    localFile="${mainDir}/${relFile}"
    if ! [ -f "${localFile}" ]; then
      let nbfNew=nbfNew+1
      if [ "${mode}" == "soft" ] ; then
        dlList
        echo "New file downloaded: ${relFile}"
      elif  [ "${mode}" == "normal" ] ; then
        dlList
        echo "Updated file added to downloads: ${relFile}"  
      else
        dlList &
        echo "New file added to downloads: ${relFile}"
      fi
    elif [ "$(date -r "${localFile}" +%s)" -lt "${remoteTime}" ] ; then
      let nbfUpd=nbfUpd+1
      if [ "${mode}" == "soft" ] ; then
        dlList
        echo "File updated: ${relFile}"
      elif  [ "${mode}" == "normal" ] ; then
        dlList
        echo "Updated file added to downloads: ${relFile}"        
      else
        dlList &
        echo "Updated file added to downloads: ${relFile}"

      fi
    fi
  fi
fi

done <<< $(getDataInfo)
}

########## main body ##########
#2021-3-24 13:45:10

fileORdir

echo "${nbfAll} File(s) scanned in ${nbdAll} Folder(s)"

if [ "${mode}" == "normal" ] && [ "${nbfDl}" -ne "0" ] ; then
  echo "Downloading of ${nbfDl} Files in progress, Please Wait..."
  dlProcess 
fi 

if [ "${nbfNew}" != "0" ] ; then echo "${nbfNew} New(s) file(s) downloaded" ; fi

if [ "${nbfUpd}" != "0" ] ; then echo "${nbfUpd} File(s) Updated" ; fi


if (( $SECONDS > 3600 )) ; then
    let "hours=SECONDS/3600"
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $hours hour(s), $minutes minute(s) and $seconds second(s)" 
elif (( $SECONDS > 60 )) ; then
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $minutes minute(s) and $seconds second(s)"
else
    echo "Completed in $SECONDS seconds"
fi

# Sometimes the extension is ALL CAPS for this file and Oscar does not like that
mv ${mainDir}STR.EDF ${mainDir}STR.edf 2>/dev/null

echo "Processing Completed"
