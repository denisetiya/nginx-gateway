#!/bin/bash

# Script to add a new service to the Nginx gateway
# Usage: ./add-service.sh SERVICE_NAME SERVICE_PORT SERVICE_PREFIX DOMAIN

if [ $# -ne 4 ]; then
    echo "Usage: $0 SERVICE_NAME SERVICE_PORT SERVICE_PREFIX DOMAIN"
    echo "Example: $0 user-service 3000 /api/users example.com"
    exit 1
fi

SERVICE_NAME=$1
SERVICE_PORT=$2
SERVICE_PREFIX=$3
DOMAIN=$4

# Create service configuration from template
cp conf.d/service-template.conf conf.d/$SERVICE_NAME.conf

# Replace placeholders with actual values
sed -i "s/SERVICE_NAME/$SERVICE_NAME/g" conf.d/$SERVICE_NAME.conf
sed -i "s/SERVICE_PORT/$SERVICE_PORT/g" conf.d/$SERVICE_NAME.conf
sed -i "s/SERVICE_PREFIX/$SERVICE_PREFIX/g" conf.d/$SERVICE_NAME.conf
sed -i "s/YOUR_DOMAIN/$DOMAIN/g" conf.d/$SERVICE_NAME.conf

echo "Service $SERVICE_NAME added with prefix $SERVICE_PREFIX on port $SERVICE_PORT"
echo "Configuration file created at conf.d/$SERVICE_NAME.conf"
echo "Restart Nginx to apply changes: docker-compose restart nginx"