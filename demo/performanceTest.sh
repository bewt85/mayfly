#!/bin/bash

echo 'We can also show that there is zero downtime (only milli blips)'
echo "Open this in another tab, change it but don't save"
echo 'sudo docker run -i -t --rm --volumes-from frontend_registrar ubuntu vi /etc/mayfly/environments/prod.yaml'
echo
echo "When you're ready, <Press Enter> to start the siege.  You have 30 seconds to save the updated prod config"
read -s
echo
siege www.example.com
echo
echo "Note the change in file size shows when the change occured"
