
echo "Altering server.conf so we can access solr from extenal IP"
sudo sed -i 's/address="127.0.0.1"/address="0.0.0.0"/g' /opt/solr-tomcat/tomcat/conf/server.xml

echo "Add startup of Apache Tomcat on reboot in crontab"
sudo crontab -l | { cat; echo "@reboot cd /opt/solr-tomcat/ && ./tomcat/bin/startup.sh"; } | sudo crontab -

exit 0