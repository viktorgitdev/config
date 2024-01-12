export DREMIO_TYPE=$1
export DREMIO_CLUSTER_NAME=$2
export DREMIO_LINK=$3 
export DREMIO_BUCKET_KEY=$4 
export DREMIO_SECRET=$5
export DREMIO_BUCKET_PATH=$6
export DREMIO_DIST_TYPE=$7
export DREMIO_S3_PREM_ENDPOINT=$8
if [ $DREMIO_TYPE == "executor" ]; then 
    export DREMIO_IPZK=$9 
fi

export DREMIO_MEMORY_DIRECT=`free -m | awk '/Mem:/ {print $2}'  | awk '{ if ($1>=32000) print $1-8129-2048; else if ( $1>=16000 ) print $1-2048-4096; else if ( $1>=4096 ) print 1024; else print int($1/4)}'`
export DREMIO_MEMORY_HEAP=`free -m | awk '/Mem:/ {print $2}'  | awk '{ if ($1>=32000) print 8129; else if ( $1>=16000 ) print 4096; else if ( $1>=4096 ) print 2048; else print int($1/4) }'`
sudo mkdir -p /data/$DREMIO_CLUSTER_NAME && chmod -R 777 /data
sudo yum update -y && sudo yum install -y java-1.8.0-openjdk $DREMIO_LINK
#dremio-env
sudo sed -i "s/.*DREMIO_MAX_DIRECT_MEMORY_SIZE_MB.*/DREMIO_MAX_DIRECT_MEMORY_SIZE_MB=$DREMIO_MEMORY_DIRECT/g" /opt/dremio/conf/dremio-env
sudo sed -i "s/.*DREMIO_MAX_HEAP_MEMORY_SIZE_MB.*/DREMIO_MAX_HEAP_MEMORY_SIZE_MB=$DREMIO_MEMORY_HEAP/g" /opt/dremio/conf/dremio-env
#dremio.conf
sudo sed -i "s#.*local:.*#local: \"/data/$DREMIO_CLUSTER_NAME\"#g" /opt/dremio/conf/dremio.conf
sudo sed -i "/local:/a \ \ dist: \"$DREMIO_BUCKET_PATH\"" /opt/dremio/conf/dremio.conf
if [ $DREMIO_TYPE == "executor" ]; then 
    sudo sed -i "s/.*coordinator.enabled.*/coordinator.enabled: false,/g" /opt/dremio/conf/dremio.conf
    sudo sed -i "s/.*coordinator.master.enabled.*/coordinator.master.enabled: false,/g" /opt/dremio/conf/dremio.conf
    sudo sed -i -e '$azookeeper: "IPZK"' /opt/dremio/conf/dremio.conf   
    sudo sed -i "s#IPZK#$DREMIO_IPZK#g" /opt/dremio/conf/dremio.conf
else
    sudo sed -i "s/.*coordinator.enabled.*/coordinator.enabled: true,/g" /opt/dremio/conf/dremio.conf
    sudo sed -i "s/.*coordinator.master.enabled.*/coordinator.master.enabled: true,/g" /opt/dremio/conf/dremio.conf
    sudo sed -i "s/.*executor.enabled.*/executor.enabled: false,/g" /opt/dremio/conf/dremio.conf
fi
#core-site.xml

function write_coresite_xml_azure {
cat > /opt/dremio/conf/core-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
<property>
 <name>fs.dremioAzureStorage.impl</name>
 <description>FileSystem implementation. Must always be com.dremio.plugins.azure.AzureStorageFileSystem</description>
 <value>com.dremio.plugins.azure.AzureStorageFileSystem</value>
</property>
<property>
  <name>dremio.azure.account</name>
  <description>The name of the storage account.</description>
  <value>DREMIO_BUCKET_KEY</value>
</property>
<property>
  <name>dremio.azure.key</name>
  <description>The shared access key for the storage account.</description>
  <value>DREMIO_SECRET</value>
</property>
<property>
  <name>dremio.azure.mode</name>
  <description>The storage account type. Value: STORAGE_V2</description>
  <value>STORAGE_V2</value>
</property>
<property>
  <name>dremio.azure.secure</name>
  <description>Boolean option to enable SSL connections. Value: True/False</description>
  <value>True</value>
</property>
</configuration>
EOF
}

function write_coresite_xml_aws {
cat > /opt/dremio/conf/core-site.xml <<EOF
<?xml version="1.0"?>
 <configuration>
    <property>
        <name>fs.dremioS3.impl</name>
        <description>The FileSystem implementation. Must be set to com.dremio.plugins.s3.store.S3FileSystem</description>
        <value>com.dremio.plugins.s3.store.S3FileSystem</value>
    </property>
    <property>
        <name>fs.s3a.access.key</name>
        <description>AWS access key ID.</description>
        <value>DREMIO_BUCKET_KEY</value>
    </property>
    <property>
        <name>fs.s3a.secret.key</name>
        <description>AWS secret key.</description>
        <value>DREMIO_SECRET</value>
    </property>
    <property>
        <name>fs.s3a.aws.credentials.provider</name>
        <description>The credential provider type.</description>
        <value>org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider</value>
    </property>
 </configuration>
EOF
}

function write_coresite_xml_s3 {
cat > /opt/dremio/conf/core-site.xml <<EOF
<?xml version="1.0"?>
 <configuration>
    <property>
        <name>fs.dremioS3.impl</name>
        <description>The FileSystem implementation. Must be set to com.dremio.plugins.s3.store.S3FileSystem</description>
        <value>com.dremio.plugins.s3.store.S3FileSystem</value>
    </property>
    <property>
        <name>fs.s3a.access.key</name>
        <description>AWS access key ID.</description>
        <value>DREMIO_BUCKET_KEY</value>
    </property>
    <property>
        <name>fs.s3a.secret.key</name>
        <description>AWS secret key.</description>
        <value>DREMIO_SECRET</value>
    </property>
    <property>
        <name>fs.s3a.aws.credentials.provider</name>
        <description>The credential provider type.</description>
        <value>org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider</value>
    </property>
    <property>
        <name>fs.s3a.endpoint</name>
        <description>Endpoint can either be an IP or a hostname, where Minio server is running . However the endpoint value cannot contain the http(s) prefix. E.g. 175.1.2.3:9000 is a valid endpoint. </description>
        <value>DREMIO_S3_PREM_ENDPOINT</value>
    </property>
    <property>
        <name>fs.s3a.path.style.access</name>
        <description>Value has to be set to true.</description>
        <value>true</value>
    </property>
    <property>
        <name>dremio.s3.compat</name>
        <description>Value has to be set to true.</description>
        <value>true</value>
    </property>
    <property>
        <name>fs.s3a.connection.ssl.enabled</name>
        <description>Value can either be true or false, set to true to use SSL with a secure Minio server.</description>
        <value>SSL_ENABLED</value>
    </property>
 </configuration>
EOF
}

if [ $DREMIO_DIST_TYPE == "aws" ]; then 
     write_coresite_xml_aws
elif [ $DREMIO_DIST_TYPE == "s3" ]; then 
     write_coresite_xml_s3
else 
     write_coresite_xml_azure     
fi

sudo touch /opt/dremio/conf/core-site.xml
sudo chmod 777 /opt/dremio/conf/core-site.xml
sudo sed -i "s/DREMIO_BUCKET_KEY/$DREMIO_BUCKET_KEY/g" /opt/dremio/conf/core-site.xml
sudo sed -i "s#DREMIO_SECRET#$DREMIO_SECRET#g" /opt/dremio/conf/core-site.xml

#service
sudo cp /opt/dremio/share/dremio/dremio.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start dremio
sudo systemctl enable dremio
sudo chown -R dremio:dremio /var/log/dremio
sudo chown -R dremio:dremio /var/lib/dremio
sudo chown -R dremio:dremio /var/run/dremio
sudo chown -R dremio:dremio /data
