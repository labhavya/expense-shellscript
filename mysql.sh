#!/bin/bash
#!/bin/bash
USER=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
LOG_FILE=$(echo $0 |cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"
echo "script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME
CHECK_ROOT(){
            if [ $USER -ne 0 ]
            then 
                echo "ERROR:: user doens't have permission to install"
                exit 1
            fi 
}
VALIDATE() 
{
    if [ $1 -eq 0 ]
    then 
        echo -e "$2....$G success $N"
        
    else 
        echo -e "$2....$R failed $N"
        exit 1
    fi
}
CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "mysql install is"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "service enable is"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "service start is"

mysql -h mysql.devdom.fun -u root -pExpenseApp@1 -e "show databases";
if [ $? -ne 0 ]
then 
    echo "mysql root password not set" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting root password"
else
    ehco "password is already set...........$Y SKIPPING"

