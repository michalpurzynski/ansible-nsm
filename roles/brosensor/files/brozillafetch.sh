#!/bin/bash

date >> /var/log/brozillafetch.log
cd ~/brozilla && git pull 2>&1 >> /var/log/brozillafetch.log

