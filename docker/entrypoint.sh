#!/bin/sh
exec /opt/${APP_NAME}/bin/${APP_NAME} start >> /var/log/${APP_NAME}.log 2>&1