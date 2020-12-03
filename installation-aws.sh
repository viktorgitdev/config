export DREMIO_TYPE=$1
export DREMIO_CLUSTER_NAME=$2
export DREMIO_LINK=$3 
export DREMIO_BUCKET_KEY=$4 
export DREMIO_SECRET=$5
export DDREMIO_BUCKET_PATH=$6
if [ $DREMIO_TYPE == "executor" ]; then 
    export DREMIO_IPZK=$7 
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
sudo sed -i "/local:/a \ \ dist: \"$DDREMIO_BUCKET_PATH\"" /opt/dremio/conf/dremio.conf
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
sudo touch /opt/dremio/conf/core-site.xml
sudo chmod 777 /opt/dremio/conf/core-site.xml
echo '<?xml version="1.0"?>'>>/opt/dremio/conf/core-site.xml
echo '<configuration>'>>/opt/dremio/conf/core-site.xml
echo '    <property>'>>/opt/dremio/conf/core-site.xml
echo '        <name>fs.dremioS3.impl</name>'>>/opt/dremio/conf/core-site.xml
echo '        <description>The FileSystem implementation. Must be set to com.dremio.plugins.s3.store.S3FileSystem</description>'>>/opt/dremio/conf/core-site.xml
echo '        <value>com.dremio.plugins.s3.store.S3FileSystem</value>'>>/opt/dremio/conf/core-site.xml
echo '    </property>'>>/opt/dremio/conf/core-site.xml
echo '    <property>'>>/opt/dremio/conf/core-site.xml
echo '        <name>fs.s3a.access.key</name>'>>/opt/dremio/conf/core-site.xml
echo '        <description>AWS access key ID.</description>'>>/opt/dremio/conf/core-site.xml
echo '        <value>ACCESSKEY</value>'>>/opt/dremio/conf/core-site.xml
echo '    </property>'>>/opt/dremio/conf/core-site.xml
echo '    <property>'>>/opt/dremio/conf/core-site.xml
echo '        <name>fs.s3a.secret.key</name>'>>/opt/dremio/conf/core-site.xml
echo '        <description>AWS secret key.</description>'>>/opt/dremio/conf/core-site.xml
echo '        <value>SECRETKEY</value>'>>/opt/dremio/conf/core-site.xml
echo '    </property>'>>/opt/dremio/conf/core-site.xml
echo '    <property>'>>/opt/dremio/conf/core-site.xml
echo '        <name>fs.s3a.aws.credentials.provider</name>'>>/opt/dremio/conf/core-site.xml
echo '        <description>The credential provider type.</description>'>>/opt/dremio/conf/core-site.xml
echo '        <value>org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider</value>'>>/opt/dremio/conf/core-site.xml
echo '    </property>'>>/opt/dremio/conf/core-site.xml
echo '</configuration>'>>/opt/dremio/conf/core-site.xml
sudo sed -i "s/ACCESSKEY/$DREMIO_BUCKET_KEY/g" /opt/dremio/conf/core-site.xml
sudo sed -i "s#SECRETKEY#$DREMIO_SECRET#g" /opt/dremio/conf/core-site.xml
sudo chmod 644 /opt/dremio/conf/core-site.xml
#service
sudo cp /opt/dremio/share/dremio/dremio.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start dremio
sudo systemctl enable dremio
sudo chown -R dremio:dremio /var/log/dremio
sudo chown -R dremio:dremio /var/lib/dremio
sudo chown -R dremio:dremio /var/run/dremio
sudo chown -R dremio:dremio /data
