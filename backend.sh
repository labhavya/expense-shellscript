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

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "disabling node js"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "enabling node js"

dnf install nodejs -y >>$LOG_FILE_NAME 
VALIDATE $? "installing  node js" 

useradd expense
VALIDATE $? "adding expense user" 

mkdir /app
VALIDATE $? "creating app directory" 

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "downlaoding backend" 

cd /app

unzip /tmp/backend.zip
VALIDATE $? "unzip backend"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "installing dependencies"

cp /home/ec2-user/expense-shellscript/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "installing mysql client"

mysql -h mysql.devdom.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "setting up trasnaciton schema and tables"

systemctl daemon-reload
VALIDATE $? "daemon load"

systemctl start backend
VALIDATE $? "starting backend service."

systemctl enable backend
VALIDATE $? "enabling backend serivce"
