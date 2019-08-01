#!/bin/bash

# Service List：redis|mysql|mongodb|nginx|php|golang

# Default Startup Service
defaultContainer="nginx php72 mysql"
# Default Service
defaultBashContainer="php72"

WORK_DIR=$(cd `dirname $0`; pwd)
WORK_NAME=${WORK_DIR##*/}

function main()
{
    local cmd
    cmd=$1
    if [[ "" != $1 ]] && [[ "help" != $1 ]] && [[ "node" != $1 ]] && [[ "npm" != $1 ]] && [[ "go" != $1 ]] && [[ "composer" != $1 ]];then
        shift
    fi
    case "$cmd" in
        status)
            _status $@
        ;;
        stop)
            _stop $@
        ;;
        start|up)
            _start $@
        ;;
        reload)
            _reload $@
        ;;
        build)
            _build $@
        ;;
        bash)
            _bash $@
        ;;
        php|composer)
            _php $@
        ;;
        node|npm)
            _node $@
        ;;
        go)
            _go $@
        ;;
        stats)
            docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
        ;;
        certbot)
            _certbot $@
        ;;
        stop_all)
            docker ps -a -q
        ;;
        clear_all)
            docker container prune
        ;;
        delete_all)
            docker system prune -a
        ;;
        *)
            _help $@
        ;;
    esac

}

function _help(){
    echo '        .__                        .___                __                   '
    echo '________|  |    ______           __| _/ ____    ____  |  | __  ____ _______ '
    echo '\___   /|  |   /  ___/  ______  / __ | /  _ \ _/ ___\ |  |/ /_/ __ \\_  __ \'
    echo ' /    / |  |__ \___ \  /_____/ / /_/ |(  <_> )\  \___ |    < \  ___/ |  | \/'
    echo '/_____ \|____//____  >         \____ | \____/  \___  >|__|_ \ \___  >|__|   '
    echo '      \/           \/               \/             \/      \/     \/        '
    echo ''
    tips " start        Start up service"
    tips " stop         Stop of Service"
    tips " reload       Reload Services"
    tips " status       View status"
    tips " bash         Exec Services"
    tips " build        Build services"
    echo ''
    tips " Designated Language Directives(php, node, npm, golang, composer)"
    tips " ${BASH_SOURCE[0]} php -v"
    tips " ${BASH_SOURCE[0]} npm install xxx"
}

function _bash(){
    local container
    local cmd
    container=$1
    shift
    cmd=$@
    if [[ "" = $container ]];then
        tips "No service is specified (default service): $defaultBashContainer"
        container=$defaultBashContainer
    fi
    if [[ "" = $cmd ]];then
        if [[ "go" = $container ]];then
            container="go"
            cmd="bash"
        else
            cmd="sh"
        fi
    fi
    docker-compose exec $container $cmd
}

function _stop(){
    docker-compose stop $@
}

function _status(){
    docker-compose ps
}

function _start(){
    local container
    container=$@
    if [[ "" = $container ]];then
        echo "No service is specified (default service): $defaultContainer"
        container=$defaultContainer
    fi
    docker-compose up -d $container
}

function _reload(){
    local container
    container=$@
    if [[ "" = $container ]];then
        container="nginx"
    fi
    if [[ "nginx" = $container ]];then
        _bash nginx nginx -s reload
    else
        docker-compose restart $container
    fi
}

function _build(){
    local container
    container=$@
    if [[ "" = $container ]];then
        error "Please enter the compiled service"
    else
        docker-compose build $container
    fi
}

function tips(){
    echo -e "  \033[32m$@\033[0m"
}

function error(){
    echo -e "  \033[1;31m$@\033[0m" 1>&2
    exit 1
}

function _php(){
    local phpv="php72"
    local cmd
    cmd=$1
    if [[ "composer" = $cmd ]];then
        docker run --tty --interactive --rm --user $(id -u):$(id -g) --volume $WORK_DIR/data/composer:/tmp --volume /etc/passwd:/etc/passwd:ro --volume /etc/group:/etc/group:ro --volume $(pwd):/app composer
    else
        images $phpv
        _bash $phpv php $@
    fi
}

function _node(){
    images node
    docker run --tty --interactive --rm --volume $WORK_DIR:/var/www/html:rw --workdir /var/www/html $WORK_NAME"_node" "$@"
}

function _go(){
    images go
    docker run --tty --interactive --rm --volume $WORK_DIR:/var/www/html:rw --workdir /var/www/html $WORK_NAME"_go" "$@"
}

function images(){
    local container
    container=$1
    if [[ "" == $(echo $(docker images)|grep $WORK_NAME"_"$container) ]];then
        tips "The $container service is for the first time, please wait ..."
        _start --build $container
    elif [[ "" == $(echo $(docker-compose images)|grep $WORK_NAME"_"$container) ]];then
        _start $container
    fi
}

function _certbot(){
    local domain
    local vhostDir
    local certsPath="$WORK_DIR/data/letsencrypt"
    domain=$1
    if [[ "" == $domain ]];then
        error "Please enter the domain name"
    fi
    vhostDir="$WORK_DIR/www/$domain"
    docker run -it --rm --name certbot \
        --volume "$certsPath:/etc/letsencrypt/live/archive" \
        --volume "$vhostDir:/var/www/html" \
        --volume "$WORK_DIR/log:/var/log" \
        certbot/certbot certonly -n --no-eff-email --email admin@73zls.com --agree-tos --webroot -w /var/www/html -d $domain
}

main "$@"
