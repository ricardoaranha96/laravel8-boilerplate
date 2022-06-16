#!/bin/sh

cd /var/www

composer update

# php artisan migrate:fresh --seed
#php artisan cache:clear
#php artisan route:cache

php artisan storage:link
php artisan migrate
php artisan db:seed

chmod 777 /var/www/storage/logs/laravel.log

/usr/bin/supervisord -c /etc/supervisord.conf