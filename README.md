**HowTo run installation on EC2** 
1. Create S3 bucket and folder

2. Install master/coordinator
wget https://raw.githubusercontent.com/viktordremio/config/master/installation-aws.sh
chmod +x installation-aws.sh
sudo ./installation-aws.sh master <NAME_OF_CLUSTER> <link to rmp> ACCESS_KEY SECRET_KEY "dremioS3:///<BUCKET-NAME>/<FODLER>" 

3.  Install executor
wget https://raw.githubusercontent.com/viktordremio/config/master/installation-aws.sh
chmod +x installation-aws.sh
sudo ./installation-aws.sh executor <NAME_OF_CLUSTER> <link to rmp> ACCESS_KEY SECRET_KEY  "dremioS3:///<BUCKET-NAME>/<FODLER>"  COORDINATOR_IP