#!/bin/bash

USERID= $(id -u)
#set colours
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#setup log folder:
mkdir -p /var/log/shellscript-logs
LOGS_FOLDER="/var/log/shellscript-logs"
LOG_FILE=$(echo $0 |cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

CHECK_ROOT(){
   if [ $USERID -ne 0 ]
    then
        echo "user doesn't have root access"
        exit 1
    fi
}

VALIDATE(){
if [ $1 -eq 0 ]
   then
   echo -e "$2......$G success $N"
else
   echo -e "$2.......$R failed $N"
   exit 1
fi
}

CHECK_ROOT

#install nginx
dnf install nginx -y  &>>$LOG_FILE_NAME
VALIDATE $? "installing nginx"

#enable nginx
systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "enabling nginx"

#start nginx
systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "starting nginx"

#remove default content
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "removing default content"

#download frontend content 
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "downlaoding content"

cd /usr/share/nginx/html

#unzip content
unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzipping content"

cp /home/ec2-user/expense-shellscript/expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "starting nginx"