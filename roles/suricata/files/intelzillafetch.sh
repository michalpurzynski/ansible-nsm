#!/bin/bash

date >> /var/log/intelzillafetch.log
cd ~/intelzilla && git pull 2>&1 >> /var/log/intelzillafetch.log

