#!/bin/bash

################################################################################
# Laravel Deployment Script
#
# This Bash script is designed to automate the deployment process for a Laravel
# application. It performs tasks such as setting up environment variables,
# installing dependencies, generating keys, clearing caches, migrating the
# database, and restarting the Apache service.
#
# Usage:
#   1. Set the environment variables to match your Laravel app.
#   2. Execute the script in your server environment.
#
# Important:
#   - Review and customize the script according to your server setup.
#   - Execute with the necessary permissions, especially for 'sudo' commands.
#
# Author: Tecfinite
# Date: 15-09-2021
################################################################################

# Set the environment variables to fit your own Laravel app
export APP_ENV=production
export APP_NAME=YOUR_APP_NAME_HERE


# Database server credentials
export DB_HOST=DB_SERVER_URL_HERE
export DB_NAME=DB_NAME_HERE
export DB_USER=DB_USER_HERE
export DB_PASS=DB_PASS_HERE



# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ! DO NOT CHANGE THE NEXT LINES !
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


# Generating new ENV file
cp .env.example .env


# Initializing the ENV variables to the .env
sed -i "s/^APP_ENV=.*/APP_ENV=$APP_ENV/" .env
sed -i "s/^APP_NAME=.*/APP_NAME=$APP_NAME/" .env
sed -i "s/^DB_HOST=.*/DB_HOST=$APP_HOST/" .env
sed -i "s/^DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
sed -i "s/^DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env


# Install dependencies
composer install --optimize-autoloader --no-dev

# Generate a new application key
php artisan key:generate

# Clear the cache
sudo php artisan cache:clear

# Clear the route cache
php artisan route:cache

# Clear the view cache
php artisan view:clear

# Generate optimized autoload files
composer dump-autoload --optimize


# Migrate the database
php artisan migrate --force


#php artisan YOUR_LARAVEL_CUSTOM_COMMAND_HERE


# Restart the Apache service
sudo service apache2 restart
