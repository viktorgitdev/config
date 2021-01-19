export DREMIO_TYPE=$1
export DREMIO_BUCKET_KEY=$2 
export DREMIO_SECRET=$3 
export DREMIO_IPZK=$4
export DREMIO_VERSION=$5 
export DREMIO_BUCKET=$6
export DREMIO_CLUSTER=$7 
export DREMIO_MEMORY_DIRECT=`free -m | awk '/Mem:/ {print $2}'  | awk '{ if ($1>=32000) print $1-8129-2048; else if ( $1>=16000 ) print $1-2048-4096; else if ( $1>=4096 ) print 1024; else print int($1/4)}'`
export DREMIO_MEMORY_HEAP=`free -m | awk '/Mem:/ {print $2}'  | awk '{ if ($1>=32000) print 8129; else if ( $1>=16000 ) print 4096; else if ( $1>=4096 ) print 2048; else print int($1/4) }'`
sudo mkdir -p /data/$DREMIO_CLUSTER && chmod -R 777 /data
sudo yum update -y && sudo yum install -y java-1.8.0-openjdk
sudo sed -i "s#.*local:.*#local: \"/data/$DREMIO_CLUSTER\"#g" /opt/dremio/conf/dremio.conf
sudo sed -i "s/.*DREMIO_MAX_DIRECT_MEMORY_SIZE_MB.*/DREMIO_MAX_DIRECT_MEMORY_SIZE_MB=$DREMIO_MEMORY_DIRECT/g" /opt/dremio/conf/dremio-env
sudo sed -i "s/.*DREMIO_MAX_HEAP_MEMORY_SIZE_MB.*/DREMIO_MAX_HEAP_MEMORY_SIZE_MB=$DREMIO_MEMORY_HEAP/g" /opt/dremio/conf/dremio-env
sudo sed -i "s/.*coordinator.enabled.*/coordinator.enabled: false,/g" /opt/dremio/conf/dremio.conf
sudo sed -i "s/.*coordinator.master.enabled.*/coordinator.master.enabled: false,/g" /opt/dremio/conf/dremio.conf
sudo sed -i "/local:/a \ \ dist: \"$DREMIO_BUCKET\"" /opt/dremio/conf/dremio.conf
sudo sed -i -e '$azookeeper: "IPZK"' /opt/dremio/conf/dremio.conf
sudo sed -i "s#IPZK#$DREMIO_IPZK#g" /opt/dremio/conf/dremio.conf
sudo touch /opt/dremio/conf/core-site.xml
sudo chmod 777 /opt/dremio/conf/core-site.xml
echo '<?xml version="1.0"?>'>>/opt/dremio/conf/core-site.xml
echo '<configuration>'>>/opt/dremio/conf/core-site.xml
echo '    <property>'>>/opt/dremio/conf/core-site.xml
echo '        <name>fs.dremioAzureStorage.impl</name>'>>/opt/dremio/conf/core-site.xml
echo '        <description>The FileSystem implementation. Must always be com.dremio.plugins.azure.AzureStorageFileSystem</description>'>>/opt/dremio/conf/core-site.xml
echo '        <value>com.dremio.plugins.azure.AzureStorageFileSystem</value>'>>/opt/dremio/conf/core-site.xml
echo '    </property>'>>/opt/dremio/conf/core-site.xml
echo '    <property>'>>/opt/dremio/conf/core-site.xml
echo '        <name>dremio.azure.account</name>'>>/opt/dremio/conf/core-site.xml
echo '        <description>The shared access key for the storage account.</description>'>>/opt/dremio/conf/core-site.xml
echo '        <value>ACCESSKEY</value>'>>/opt/dremio/conf/core-site.xml
echo '    </property>'>>/opt/dremio/conf/core-site.xml
echo '    <property>'>>/opt/dremio/conf/core-site.xml
echo '        <name>dremio.azure.key</name>'>>/opt/dremio/conf/core-site.xml
echo '        <description>The shared access key for the storage account.</description>'>>/opt/dremio/conf/core-site.xml
echo '        <value>SECRETKEY</value>'>>/opt/dremio/conf/core-site.xml
echo '    </property>'>>/opt/dremio/conf/core-site.xml
echo '    <property>'>>/opt/dremio/conf/core-site.xml
echo '        <name>dremio.azure.mode</name>'>>/opt/dremio/conf/core-site.xml
echo '        <description>The storage account type. Value: STORAGE_V2</description>'>>/opt/dremio/conf/core-site.xml
echo '        <value>STORAGE_V2</value>'>>/opt/dremio/conf/core-site.xml
echo '    </property>'>>/opt/dremio/conf/core-site.xml
echo '    <property>'>>/opt/dremio/conf/core-site.xml
echo '        <name>dremio.azure.secure</name>'>>/opt/dremio/conf/core-site.xml
echo '        <description>Boolean option to enable SSL connections. Default: True Value: True/False</description>'>>/opt/dremio/conf/core-site.xml
echo '        <value>True</value>'>>/opt/dremio/conf/core-site.xml
echo '    </property>'>>/opt/dremio/conf/core-site.xml
echo '</configuration>'>>/opt/dremio/conf/core-site.xml
sudo sed -i "s/ACCESSKEY/$DREMIO_BUCKET_KEY/g" /opt/dremio/conf/core-site.xml
sudo sed -i "s#SECRETKEY#$DREMIO_SECRET#g" /opt/dremio/conf/core-site.xml
sudo chmod 644 /opt/dremio/conf/core-site.xml
sudo cp /opt/dremio/share/dremio/dremio.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start dremio
sudo systemctl enable dremio
sudo chown -R dremio:dremio /var/log/dremio
sudo chown -R dremio:dremio /var/lib/dremio
sudo chown -R dremio:dremio /var/run/dremio
sudo chown -R dremio:dremio /data
