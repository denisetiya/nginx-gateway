#!/bin/bash

# Script to enable/disable maintenance mode
# Usage: ./maintenance-mode.sh [on|off]

if [ $# -ne 1 ]; then
    echo "Usage: $0 [on|off]"
    exit 1
fi

MODE=$1

if [ "$MODE" = "on" ]; then
    echo "Enabling maintenance mode..."
    docker-compose exec nginx touch /etc/nginx/maintenance.on
    docker-compose exec nginx nginx -s reload
    echo "Maintenance mode enabled"
elif [ "$MODE" = "off" ]; then
    echo "Disabling maintenance mode..."
    docker-compose exec nginx rm -f /etc/nginx/maintenance.on
    docker-compose exec nginx nginx -s reload
    echo "Maintenance mode disabled"
else
    echo "Invalid option. Use 'on' or 'off'"
    exit 1
fi