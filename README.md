**HowTo** 

_AWS_

1. Create S3 bucket and folder in it. Replace <VARIABLE_S>

2. Install master/coordinator
```
wget https://raw.githubusercontent.com/viktordremio/config/master/installation-universal.sh
chmod +x installation-universal.sh
sudo ./installation-universal.sh master <NAME_OF_CLUSTER> <link-to-rmp> <ACCESS_KEY> <SECRET_KEY> "dremioS3:///BUCKET-NAME/FOLDER" aws


#alternative azure
sudo ./installation-universal.sh master <NAME_OF_CLUSTER> <link-to-rmp> <ACCOUNTNAME> <SECRET_KEY> "dremioAzureStorage://:///<FILE_SYSTEM_NAME>/<ALTERNATIVE_STORAGE_ROOT_DIRECTORY>" azure
```


1.  Install executor
```
wget https://raw.githubusercontent.com/viktordremio/config/master/installation-universal.sh
chmod +x installation-universal.sh
sudo ./installation-universal.sh executor <NAME_OF_CLUSTER> <link-to-rmp> <ACCESS_KEY> <SECRET_KEY> "dremioS3:///BUCKET-NAME/FOLDER" aws <COORDINATOR_IP>:2181


#alternativ 
sudo ./installation-universal.sh executor <NAME_OF_CLUSTER> <link-to-rmp> <ACCOUNTNAME> <SECRET_KEY> "dremioAzureStorage://:///<FILE_SYSTEM_NAME>/<ALTERNATIVE_STORAGE_ROOT_DIRECTORY>" azure <COORDINATOR_IP>:2181
```





_AZURE_

1. Create ADLSG2 starage, conatiner and folder. Replace <VARIABLE_S>

2. Install master/coordinator 



```
wget https://raw.githubusercontent.com/viktordremio/config/master/installation-universal.sh
chmod +x installation-universal.sh
sudo ./installation-universal.sh master <NAME_OF_CLUSTER> <link-to-rmp> <CONTAINER_NAME> <SECRET_KEY> "dremioAzureStorage://:///<CONTAINER>/<FOLDER>" azure
```

3.  Install executor


```
wget https://raw.githubusercontent.com/viktordremio/config/master/installation-universal.sh
chmod +x installation-universal.sh
sudo ./installation-universal.sh executor <NAME_OF_CLUSTER> <link-to-rmp> <CONTAINER_NAME> <SECRET_KEY> "dremioAzureStorage://:///<CONTAINER>/<FOLDER>" azure <COORDINATOR_IP>:2181
```

