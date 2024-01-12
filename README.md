**HowTo**

_AWS_

1. Create S3 bucket and folder in it. Replace <VARIABLE_S>

2. Install master/coordinator

```
wget https://raw.githubusercontent.com/viktordremio/config/master/installation-universal.sh
chmod +x installation-universal.sh
sudo ./installation-universal.sh master <NAME_OF_CLUSTER> <link-to-rmp> <ACCESS_KEY> <SECRET_KEY> "dremioS3:///BUCKET-NAME/FOLDER" aws


```

1.  Install executor

```
wget https://raw.githubusercontent.com/viktordremio/config/master/installation-universal.sh
chmod +x installation-universal.sh
sudo ./installation-universal.sh executor <NAME_OF_CLUSTER> <link-to-rmp> <ACCESS_KEY> <SECRET_KEY> "dremioS3:///BUCKET-NAME/FOLDER" aws <COORDINATOR_IP>:2181


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

_S3_onPrem_

1. Create S3 bucket and folder in it. Replace <VARIABLE_S>

2. Install master/coordinator

```
wget https://raw.githubusercontent.com/viktordremio/config/master/installation-universal.sh
chmod +x installation-universal.sh
sudo ./installation-universal.sh master <NAME_OF_CLUSTER> <link-to-rmp> <ACCESS_KEY> <SECRET_KEY> "dremioS3:///BUCKET-NAME/FOLDER" s3 <DREMIO_S3_PREM_ENDPOINT>


```

1.  Install executor

```
wget https://raw.githubusercontent.com/viktordremio/config/master/installation-universal.sh
chmod +x installation-universal.sh
sudo ./installation-universal.sh executor <NAME_OF_CLUSTER> <link-to-rmp> <ACCESS_KEY> <SECRET_KEY> "dremioS3:///BUCKET-NAME/FOLDER" s3 <DREMIO_S3_PREM_ENDPOINT> <COORDINATOR_IP>:2181


```
