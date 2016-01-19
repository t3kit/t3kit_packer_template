
echo "Altering server.conf so we can access solr from extenal IP"
sudo sed -i 's/address="127.0.0.1"/address="0.0.0.0"/g' /opt/solr-tomcat/tomcat/conf/server.xml

echo "Add startup of Apache Tomcat on reboot in crontab"
sudo crontab -l | { cat; echo "@reboot cd /opt/solr-tomcat/ && ./tomcat/bin/startup.sh"; } | sudo crontab -

echo "Create some cores"
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_sv_SE\" instanceDir=\"typo3cores\" schema=\"swedish/schema.xml\" dataDir=\"data/t3kit_sv_SE\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_uk_UA\" instanceDir=\"typo3cores\" schema=\"ukrainian/schema.xml\" dataDir=\"data/t3kit_uk_UA\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_fr_FR\" instanceDir=\"typo3cores\" schema=\"french/schema.xml\" dataDir=\"data/t3kit_fr_FR\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_da_DK\" instanceDir=\"typo3cores\" schema=\"danish/schema.xml\" dataDir=\"data/t3kit_da_DK\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_nb_NO\" instanceDir=\"typo3cores\" schema=\"norwegian/schema.xml\" dataDir=\"data/t3kit_nb_NO\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_fi_FI\" instanceDir=\"typo3cores\" schema=\"finnish/schema.xml\" dataDir=\"data/t3kit_fi_FI\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_it_IT\" instanceDir=\"typo3cores\" schema=\"italian/schema.xml\" dataDir=\"data/t3kit_it_IT\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_es_ES\" instanceDir=\"typo3cores\" schema=\"spanish/schema.xml\" dataDir=\"data/t3kit_es_ES\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_ro_RO\" instanceDir=\"typo3cores\" schema=\"romanian/schema.xml\" dataDir=\"data/t3kit_ro_RO\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_de_DE\" instanceDir=\"typo3cores\" schema=\"german/schema.xml\" dataDir=\"data/t3kit_de_DE\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_en_US\" instanceDir=\"typo3cores\" schema=\"english/schema.xml\" dataDir=\"data/t3kit_en_US\" />\"" /opt/solr-tomcat/solr/solr.xml
sudo sed -i "/core name=\"core_en\" instanceDir=\"typo3cores\"/a\\<core name=\"t3kit_en_GB\" instanceDir=\"typo3cores\" schema=\"english/schema.xml\" dataDir=\"data/t3kit_en_GB\" />\"" /opt/solr-tomcat/solr/solr.xml

exit 0