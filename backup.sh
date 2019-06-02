# programmer : Morteza Ghasemi

# colors
RED='\033[1;31m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
GRAY='\033[1;37m'
NC='\033[0m' # No Color

# Show Info Program
echo -e "${GRAY} __  __ __  __ ____  _____
|  \/  |  \/  | __ )|  ___|
| |\/| | |\/| |  _ \| |_
| |  | | |  | | |_) |  _|
|_|  |_|_|  |_|____/|_|
                           ";
echo -e "Welcome to ${PURPLE}MMBF${GRAY}[${PURPLE}M${GRAY}orteza ${PURPLE}M${GRAY}ysql ${PURPLE}B${GRAY}ackup and ${PURPLE}F${GRAY}TP]\n"

# configs
BackupFolder='backupfol'
LogFolder='logfol'



PhpMyadminUser='root'
PhpMyadminPass=''
DatabaseName='wp'
Now_date=$(date +%F)
Now_time_stamp=$(date +%s);
Now_date_time_log=$(date +%F---%T)



FtpServer='ftp.example.com'
FtpPath='/backups/'
FtpUser='username'
FtpPass='password'
ServerBackupFolder='backups/'

echo $1;

# get variable length
BackupFolderSTRLENGTH=$(echo -n $BackupFolder | wc -m)
PhpMyadminUserSTRLENGTH=$(echo -n $PhpMyadminUser | wc -m)
PhpMyadminPassSTRLENGTH=$(echo -n $PhpMyadminPass | wc -m)
DatabaseNameSTRLENGTH=$(echo -n $DatabaseName | wc -m)

# check variable length
if [ $BackupFolderSTRLENGTH = 0 ]
then
    BackupFolder=''
else
    if [ ! -d $BackupFolder ]
    then
        mkdir $(echo $BackupFolder)
        BackupFolder="${BackupFolder}/"
    else
        BackupFolder="${BackupFolder}/"
    fi

    echo -e "${BLUE}SET BACKUP DIRECTORY ON SYSTEM TO${PURPLE} ${BackupFolder}"
fi
if [ ! -d $LogFolder ]; then mkdir $(echo $LogFolder); else echo -e "${BLUE}SET LOG DIRECTORY TO${PURPLE}" ${LogFolder}; fi
if [ $PhpMyadminUserSTRLENGTH = 0 ]; then PhpMyadminUser='root'; else echo -e "${BLUE}SET MYSQL USERNAME TO${PURPLE}" ${PhpMyadminUser}; fi
if [ $PhpMyadminPassSTRLENGTH = 0 ]; then PhpMyadminPass=''; else echo -e "${BLUE}SET MYSQL PASSWORD TO${PURPLE}" ${PhpMyadminPass}; fi
if [ $DatabaseNameSTRLENGTH = 0 ]; then DatabaseName='test'; else echo -e "${BLUE}SET DATABASE NAME TO${PURPLE}" ${DatabaseName}; fi

# execute backup
BackupName=${DatabaseName}-${Now_date}-${Now_time_stamp}.sql

if [[ $PhpMyadminPassSTRLENGTH = 0 ]]
then
    echo -e "${BLUE}SET NO PASSWORD FOR CONNECTING TO DB${PURPLE} ${DatabaseName}"
    echo -e "${GRAY}-------------"${NC}
    GetData=$(mysqldump -u $(echo $PhpMyadminUser) $(echo $DatabaseName))

    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}Successful. creating file ..."
        mysqldump -u $(echo $PhpMyadminUser) $(echo $DatabaseName) > $(echo $BackupFolder)$(echo $BackupName)
        echo -e "${GREEN}Successful. file created in${PURPLE}" $(pwd)"/"${BackupFolder}${BackupName}${NC}
        curl -T $(echo $BackupFolder)$(echo $BackupName) ftp://$(echo $FtpServer)/$(echo $ServerBackupFolder)$(echo $BackupName) --user $(echo $FtpUser):$(echo $FtpPass)
        if [ $? -eq 0 ]
        then
            echo -e "${GREEN}Successful. file uploaded in${PURPLE}" "ftp://"${FtpServer}"/"${ServerBackupFolder}${BackupName}
        else
            echo -e "${RED}Error in FTP"
        fi
    else
        echo -e "${RED}Error in mysqldump"
    fi

else
    echo -e "${BLUE}SET" $($PhpMyadminPass) "FOR CONNECTING TO DB" ${DatabaseName}
    GetData=$(mysqldump -u $(echo $PhpMyadminUser) -p[$(echo $PhpMyadminPass)] $(echo $DatabaseName))

    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}Successful. creating file ..."
        mysqldump -u $(echo $PhpMyadminUser) -p[$(echo $PhpMyadminPass)] $(echo $DatabaseName) > $(echo $BackupFolder)$(echo $BackupName)
        echo -e "${GREEN}Successful. file created in${PURPLE}" $(pwd)"/"${BackupFolder}${BackupName}
        curl -T $(echo $BackupFolder)$(echo $BackupName) ftp://$(echo $FtpServer)/$(echo $ServerBackupFolder)$(echo $BackupName) --user $(echo $FtpUser):$(echo $FtpPass)
        if [ $? -eq 0 ]
        then
            echo -e "${GREEN}Successful. file uploaded in${PURPLE}" "ftp://"${FtpServer}"/"${ServerBackupFolder}${BackupName}
        else
            echo -e "${RED}Error in FTP"
        fi
    else
        echo -e "${RED}Error in mysqldump"
    fi
fi
PWD=$(pwd)
LogData="<<< ${Now_date_time_log} \n\t Backup Folder: ${PWD}/${BackupFolder} \n\t Server Backup Folder: ${PWD}/${ServerBackupFolder} \n\t FTP Server: ${FtpServer} \n\t FTP Path: ${Path} \n\t PHPMyadmin User: ${PhpMyadminUser} \n>>>"
echo -e "$LogData" >> $(echo $LogFolder)/log.txt
