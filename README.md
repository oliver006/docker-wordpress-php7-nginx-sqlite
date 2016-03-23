# docker-wordpress-php7-nginx-sqlite

A minimal Dockerfile that installs the latest wordpress, php7.0, nginx, php-fpm and sqlite. <br>
It does not install and run mysql or require a running mysql container.

## Cool, how do I run this?

The easiest way is to pull this docker image is straight from the docker registry:

```bash
$ docker pull 21zoo/docker-wordpress-php7-nginx-sqlite
```

And then start a new instance:

```bash
$ docker run -p 20080:80 --name wp-php7 -d 21zoo/docker-wordpress-php7-nginx-sqlite
```

Now you can navigate to 

```
http://<<DOCKER IP>>:20080
```



Inspired by: https://github.com/eugeneware/docker-wordpress-nginx 