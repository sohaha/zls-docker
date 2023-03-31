#!/bin/bash

# Service List: redis|mysql|mongodb|nginx|php|golang

# Default Startup Service
defaultContainer="nginx php mysql"
# Default Service
defaultBashContainer="php"

mydir=$0
_b=$(ls -ld $mydir | awk '{print $NF}')
_c=$(ls -ld $mydir | awk '{print $(NF-2)}')
[[ $_b =~ ^/ ]] && mydir=$_b || mydir=$(dirname $_c)/$_b

WORK_DIR=$(
  cd $(dirname $mydir)
  pwd
)
BIN_PATH="/usr/local/bin"
WORK_NAME=${WORK_DIR##*/}
SCRIPT_SOURCE_DIR=$(pwd)
WHOAMI=$(whoami)
TIME=$(date "+%Y-%m-%d %H:%M:%S")
DATE=$(date "+%Y-%m-%d")
cd $WORK_DIR

[[ ! $PATH =~ $BIN_PATH ]] && export PATH=$PATH:$BIN_PATH

function main() {
  if [[ ! -d $BIN_PATH ]]; then
    BIN_PATH="/usr/bin"
  fi
  local cmd
  config
  judge
  cmd=$1
  if [[ "" != $1 ]] && [[ "help" != $1 ]] && [[ "node" != $1 ]] && [[ "npm" != $1 ]] && [[ "sentry" != $1 ]] && [[ "go" != $1 ]] && [[ "composer" != $1 ]]; then
    shift
  fi
  case "$cmd" in
  status | s | ps)
    _status $@
    ;;
  stop)
    _stop $@
    ;;
  buildUp | buildup)
    _build $@
    _start $@
    ;;
  restart)
    _restart $@
    ;;
  start | up)
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
  bash2)
    _bash2 $@
    ;;
  cron)
    _cron $@
    ;;
  php | composer)
    _php $@
    ;;
  node | npm)
    _node $@
    ;;
  go)
    _go $@
    ;;
  sentry)
    _sentry $@
    ;;
  stats)
    docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
    ;;
  ssl)
    _certbot $@
    ;;
  ins)
    _inspect $@
    ;;
  stop_all | stopAll | stopall)
    docker ps -a -q
    ;;
  delete_all | deleteAll | deleteall)
    docker system prune -a
    ;;
  tools)
    _tools
    ;;
  mysql)
    _mysqlTools $@
    ;;
  mongodb)
    _mongodbTools $@
    ;;
  installDocker | installdocker)
    _installDocker
    ;;
  help)
    _help $@
    ;;
  logs)
    _logs $@
    ;;
  name)
    echo $WORK_NAME
    ;;
  *)
    _help $@
    ;;
  esac

}

function _help() {
  local cmd=${BASH_SOURCE[0]}
  cmd=$(echo $cmd | sed 's:\/usr\/bin\/::g')
  echo '        .__                        .___                __                   '
  echo '________|  |    ______           __| _/ ____    ____  |  | __  ____ _______ '
  echo '\___   /|  |   /  ___/  ______  / __ | /  _ \ _/ ___\ |  |/ /_/ __ \\_  __ \'
  echo ' /    / |  |__ \___ \  /_____/ / /_/ |(  <_> )\  \___ |    < \  ___/ |  | \/'
  echo '/_____ \|____//____  >         \____ | \____/  \___  >|__|_ \ \___  >|__|   '
  echo '      \/           \/               \/             \/      \/     \/        '
  echo ''
  tips " $cmd start        Start up service"
  tips " $cmd stop         Stop of Service"
  tips " $cmd reload       Reload Services"
  tips " $cmd restart      Restart Services"
  tips " $cmd status       View status"
  tips " $cmd stats        Display resources used"
  tips " $cmd bash         Exec Services"
  tips " $cmd cron         Exec Crontab"
  tips " $cmd build        Build services"
  tips " $cmd buildUp      Build and start services"
  tips " $cmd tools        Toolbox"
  tips " $cmd mysql        Mysql operating"
  tips " $cmd ssl          Renew the free certificates from Let's Encrypt."
  echo ''
  echo " Designated Language Directives(php, node, npm, golang, composer)"
  echo " $cmd php -v"
  echo " $cmd npm install xxx"
  echo ' ......'
}

function judge() {
  type docker >/dev/null 2>&1 || {
    _installDocker
    error "Please install Docker!"
  }

  type docker-compose >/dev/null 2>&1 || {
    tips 'command:'
    tips '         sudo curl -L https://get.daocloud.io/docker/compose/releases/download/v2.16.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose'
    tips '         sudo chmod +x /usr/local/bin/docker-compose'
    error "Please install docker-compose!"
  }
}

function askRoot() {
  if [ $(id -u) != 0 ]; then
    error "You must be root to run this script, please use root run"
  fi
}

function config() {
  local dockerComposePath="$WORK_DIR/docker-compose.yml"
  local configPath="$WORK_DIR/.env"

  if [[ ! -f $configPath ]]; then
    cp $configPath".example" $configPath
    if [ $? -ne 0 ]; then
      error ".env does not exist, initialize Error."
    else
      tips ".env does not exist, initialize."
    fi
  fi

  if [[ ! -f $dockerComposePath ]]; then
    cp $dockerComposePath".example" $dockerComposePath
    if [ $? -ne 0 ]; then
      error "docker-compose.yml does not exist, initialize Error."
    else
      tips "docker-compose.yml does not exist, initialize."
    fi
  fi
  source $configPath
}

function _installDocker() {
  #askRoot

  local info=$(cat /etc/os-release)
  if [[ "" != $(echo $info | grep CentOS) ]]; then
    tips 'OS is CentOS'
    tips 'command:'
    tips "        sudo curl -sSL https://get.docker.com | sh"
    tips "        sudo usermod -aG docker $USER"
    tips "        newgrp docker"
    tips "        sudo curl -L https://get.daocloud.io/docker/compose/releases/download/v2.16.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose"
    tips "        sudo chmod +x /usr/local/bin/docker-compose"
    tips "        docker-compose --version"
    tips "start:  "
    tips "        sudo systemctl start docker"
    tips "        sudo systemctl enable docker"
  elif [[ "" != $(echo $info | grep Ubuntu) ]]; then
    tips 'OS is Ubuntu'
    tips 'command:'
    tips "        sudo curl -sSL https://get.docker.com | sh"
    tips "        sudo usermod -aG docker $USER"
    tips "        newgrp docker"
    tips "        sudo curl -L https://get.daocloud.io/docker/compose/releases/download/v2.16.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose"
    tips "        sudo chmod +x /usr/local/bin/docker-compose"
    tips "        docker-compose --version"
    tips "start:  "
    tips "        sudo service start docker"
  else
    tips "See: https://docs.docker.com/install/"
  fi
}

function _install() {
  local zdc="$BIN_PATH/zdc"
  local zdocker="$BIN_PATH/zdocker"
  if [ -f "$zdocker" ]; then
    sudo mv -f $zdocker $zdocker"-old"
  fi

  if [ -f "$zdc" ]; then
    tips "old zdc mv zdc-old"
    sudo mv -f $zdc $zdc"-old"
  fi

  sudo ln -s $WORK_DIR/run.sh $zdocker
  sudo ln -s $WORK_DIR/run.sh $zdc
  tips "You can now use zdc instead of ./run.sh: "
  tips "  zdc up"
  tips "  zdc help"
}

function _tools() {
  tips "********please enter your choise:(1-7)****"
  cat <<EOF
  (1) Install script into system bin
  (2) Auto optimize php-fpm conf
  (3) Custom composer repositories
  (4) Clean up all stopped containers
  (5) Start Sentry - Error Tracking Software
  (6) Start Yapi - api management platform
  (0) Exit
EOF
  read -p "Now select the top option to: " input
  case $input in
  1)
    _install
    ;;
  2)
    optimizePHPFpm
    ;;
  3)
    _php composer config -g repo.packagist composer $COMPOSER_PACKAGIST
    _php composer global require hirak/prestissimo
    ;;
  4)
    docker container prune
    ;;
  5)
    __sentry
    ;;
  6)
    __yapi
    ;;
  0)
    exit 1
    ;;
  *)
    echo "Please enter the correct option"
    ;;
  esac
}

function optimizePHPFpm() {
  echo "optimize:"
  local mem=$(free -m | awk '/Mem:/{print $2}')
  local conf="$WORK_DIR/config/php/php-fpm.conf"
  local max_children="pm.max_children = $(($mem / 2 / 20))"
  local start_servers="pm.start_servers = $(($mem / 2 / 30))"
  local min_spare_servers="pm.min_spare_servers = $(($mem / 2 / 40))"
  local max_spare_servers="pm.max_spare_servers = $(($mem / 2 / 20))"
  tips "    $max_children"
  tips "    $start_servers"
  tips "    $min_spare_servers"
  tips "    $max_spare_servers"
  sed -i "s@^pm.max_children.*@$max_children@" $conf
  sed -i "s@^pm.start_servers.*@$start_servers@" $conf
  sed -i "s@^pm.min_spare_servers.*@$min_spare_servers@" $conf
  sed -i "s@^pm.max_spare_servers.*@$max_spare_servers@" $conf
  echo "restart:"
  _reload php
}

function _bash() {
  local container
  local cmd
  container=$1
  shift
  cmd=$@
  if [[ "" == $container ]]; then
    tips "No service is specified (default service): $defaultBashContainer"
    container=$defaultBashContainer
  fi
  if [[ "" == $cmd ]]; then
    if [[ "go" == $container || "mysql" == $container || "ubuntu" == $container ]]; then
      cmd="bash"
    else
      cmd="sh"
    fi
  fi
  docker-compose exec $container $cmd
}

function _bash2() {
  local container
  local cmd
  container=$1
  shift
  cmd=$@
  if [[ "" == $container ]]; then
    tips "No service is specified (default service): $defaultBashContainer"
    container=$defaultBashContainer
  fi
  if [[ "" == $cmd ]]; then
    if [[ "go" == $container || "mysql" == $container ]]; then
      cmd="bash"
    else
      cmd="sh"
    fi
  fi
  docker-compose exec -T $container $cmd
}

function _cron() {
  local container
  local cmd
  container=$1
  shift
  cmd=$@
  if [[ "" == $container ]]; then
    tips "No service is specified (default service): $defaultBashContainer"
    container=$defaultBashContainer
  fi
  if [[ "" == $cmd ]]; then
    if [[ "go" == $container ]]; then
      container="go"
      cmd="bash"
    else
      cmd="sh"
    fi
  fi
   docker-compose exec -T $container $cmd
}

function _stop() {
  docker-compose stop $@
}

function _status() {
  docker-compose ps
}

function _start() {
  local container
  container=$@
  if [[ "" == $container ]]; then
    echo "No service is specified (default service): $defaultContainer"
    container=$defaultContainer
  fi
  docker-compose up -d $container
}

function _restart() {
  local container
  container=$@
  if [[ "" == $container ]]; then
    echo "No service is specified (default service): $defaultContainer"
    container=$defaultContainer
  fi
  docker-compose restart $container
}

function _reload() {
  local container=$@
  if [[ "" == $container ]]; then
    local caddy=$(docker ps | grep "$WORK_NAME"-caddy | awk '{print $1;}')
    if [[ "" == $caddy ]]; then
      container="nginx"
    else
      container="caddy"
    fi
  fi

  case $container in
  php)
    _bash php kill -USR2 1
    ;;
  nginx)
    _bash nginx nginx -s reload
    ;;
  caddy)
    local caddy=$(docker ps | grep "$WORK_NAME"-caddy | awk '{print $1;}')
    docker exec -w /etc/caddy $caddy caddy reload
    ;;
  *)
    _restart $@
    ;;
  esac
}

function _build() {
  local container
  container=$@
  # --force-recreate
  if [[ "" == $container ]]; then
    error "Please enter the compiled service"
  else
    docker-compose build $container
  fi
}

function tips() {
  echo -e "\033[32m$@\033[0m"
}

function error() {
  echo -e "\033[1;31m$@\033[0m" 1>&2
  exit 1
}

function _php() {
  local phpv="php"
  local cmd
  cmd=$1
  images $phpv
  local composerPath=$(
    cd ${COMPOSER_DATA_DIR/.\/$SCRIPT_SOURCE_DIR/}
    pwd
  )
  if [[ "composer" == $cmd ]]; then
    docker run --tty --interactive --rm --cap-add SYS_PTRACE --volume $composerPath:/composer:rw --volume $SCRIPT_SOURCE_DIR:/var/www/html --workdir /var/www/html $WORK_NAME"_php" $@

    #docker run --tty --interactive --rm --user $(id -u):$(id -g) --cap-add SYS_PTRACE --volume /etc/passwd:/etc/passwd:ro --volume /etc/group:/etc/group:ro --volume $composerPath:/composer:rw --volume $SCRIPT_SOURCE_DIR:/var/www/html --workdir /var/www/html $WORK_NAME"_php" $@
  else
    # _bash $phpv php $@
    docker run --tty --interactive --rm --cap-add SYS_PTRACE --volume $composerPath:/composer:rw --volume $SCRIPT_SOURCE_DIR:/var/www/html --workdir /var/www/html $WORK_NAME"_php" php $@
  fi
}

function _sentry() {
  images sentry
  _bash sentry "$@"
}

function _node() {
  images node
  docker run --tty --interactive --rm --volume $SCRIPT_SOURCE_DIR:/var/www/html:rw --workdir /var/www/html $WORK_NAME"_node" "$@"
}

function _go() {
  images go
  local goproxy=https://goproxy.cn,direct
  if [[ -n "${GOPROXY}" ]]; then
    goproxy=$GOPROXY
  fi
  local cmd=$@
  if [[ "bash" == $2 ]];then
      docker run -it -e GOPROXY="$goproxy" --volume $SCRIPT_SOURCE_DIR:/var/www/html:rw --workdir /var/www/html $WORK_NAME"_go" bash
    return
  fi
  if [[ -n "${GOPROXY}" ]]; then
    docker run --tty --interactive -e GOPROXY="$goproxy" --volume $SCRIPT_SOURCE_DIR:/var/www/html:rw --workdir /var/www/html $WORK_NAME"_go" "$cmd"
  fi
}

function images() {
  local container=$1
  if [[ "" == $(echo $(docker images) | grep $WORK_NAME"_"$container) ]]; then
    tips "The $container service is for the first time, please wait ..."
    _start --build $container
  elif [[ "" == $(echo $(docker-compose images) | grep $WORK_NAME"_"$container) ]]; then
    _start $container
  fi
}

function __path() {
  echo $1
}

function _logs() {
  local container=$1
  docker-compose logs $container
}

function _certbot() {
  local certsPath="$WORK_DIR"
  local ACME=~/.acme.sh/acme.sh
  local binCmd=$certsPath/run.sh
  local zdc="$BIN_PATH/zdc"
  if [ -f "$zdc" ]; then
    binCmd=zdc
  fi
  local help="Usage: $binCmd ssl -d mydomain.com -w $certsPath/www/mydomain.com/public"
  local email
  local debug
  local force
  local reloadcmd
  if [ ! -f "$ACME" ]; then
    tips "$ACME does not exist, installing..."
    curl https://get.acme.sh | sh
    # 自动更新
    $ACME --upgrade  --auto-upgrade
    #tips "Please set a scheduled task:"
    #echo -e "    55 5 * * * $cmd reload"
  fi

  if [[ "$1" == "" ]]; then
    error $help
  fi

  args=()

  while [ "$1" != "" ]; do
      case "$1" in
          --email )                       email="$2";                     shift;;
          --dns )                         dns="$2";                       shift;;
          -d | --domain )                 domain="$2";                    shift;;
          -B | --broad )                  broad="general analysis";       shift;;
          -B | --broad )                  broad="general analysis";       shift;;
          -a | --alias )                  alias="$2";                     shift;;
          -w | --webroot )                webroot="--webroot $2";         shift;;
          -h | --help )                   tips $help;                     exit;;
          * )                             args+=("$1")
      esac
      shift
  done
  if [[ -z "${domain}" ]]; then
      error "Please enter the domain name"
  fi


  if [[ -z ${webroot} && -n "${dns}" ]]; then
      # dns_cf
      dns="--dns ${dns}";
  fi

  if [[ -n "${broad}" ]]; then
      broad="-d  *.${domain}";
  fi

  if [[ -n "${alias}" ]]; then
      alias_str="--challenge-alias ${alias}";
  fi

  ## --force --debug --reloadcmd "zdc reload"

  $ACME --issue $dns $alias_str -d $domain $broad $webroot $args

  if [ $? -ne 0 ]; then
    exit
  fi

  echo "create certs dir: $certsPath/config/nginx/conf.d/certs/$domain"
  mkdir -p $certsPath/config/nginx/conf.d/certs/$domain

  $ACME --install-cert -d $domain $broad --reloadcmd "${binCmd} reload" --key-file $certsPath/config/nginx/conf.d/certs/$domain/server.key --fullchain-file $certsPath/config/nginx/conf.d/certs/$domain/server.crt

  tips "reference:"
  echo "  cp $certsPath/config/nginx/conf.d/localhost_https.conf $certsPath/config/nginx/conf.d/[DOMAIN]_https.conf"
}

function _mysqlTools() {
  local yes=0
  local BAK_DIR="$MYSQL_CONF_DIR/backup"
  local BAK_FILE="$BAK_DIR/$TIME.sql"
  local DAYS=15
  mkdir -p $BAK_DIR
  if [[ "backup" == $1 ]]; then
    cat >$BAK_DIR/.bak_mysql.sh<<EOF
#!/usr/bin/env bash

mysql -e "show databases;" -uroot -p${MYSQL_ROOT_PASSWORD} | grep -Ev "Database|information_schema|mysql|test|performance_schema|information_schema" | xargs mysqldump -uroot -p${MYSQL_ROOT_PASSWORD} --databases > "/mysql/backup/${TIME}.sql"

find /mysql/backup/ -mtime +$DAYS -delete
EOF
    _bash mysql chmod 777 /mysql/backup/.bak_mysql.sh
    _bash mysql /mysql/backup/.bak_mysql.sh
    if [ $? -eq 0 ];then
      echo "bak database Sucessfully."
      echo "export -> $BAK_FILE"
    else
      echo "bak database failed!"
      echo $(pwd)
      echo $BAK_DIR
      cat $BAK_DIR/.bak_mysql.sh
    fi
    rm -f $BAK_DIR/.bak_mysql.sh
    exit
  fi
  tips "********Mysql Tools****"
  cat <<EOF
  (1) Export Data
  (2) Import Data
  (3) Create Databases
  (0) Exit
EOF
  read -p "Now select the top option to: " input
  case $input in
  1)
    __determine "Mysql Export"
    yes=$?
    if [[ $yes == 1 ]]; then
      _bash mysql mysqldump --all-databases -uroot -p$MYSQL_ROOT_PASSWORD > "$BAK_FILE"
      echo "export -> $BAK_FILE"
    else
      echo "Give up Export mysql"
    fi
    ;;
  2)
    tips 'command:'
    echo "        ${BASH_SOURCE[0]} bash mysql"
    echo "        mysql -uroot -p$MYSQL_ROOT_PASSWORD"
    echo "        source /mysql/backup/xxx.sql"
    ;;
  3)
    __Enter_Database_Name
    tips "Please enter password for mysql user ${database_name}: "
    read mysql_password
    echo "Your password: ${mysql_password} "
    cat >$BAK_DIR/.add_mysql.sql<<EOF
CREATE USER '${database_name}'@'localhost' IDENTIFIED BY '${mysql_password}';
CREATE USER '${database_name}'@'127.0.0.1' IDENTIFIED BY '${mysql_password}';
CREATE USER '${database_name}'@'%' IDENTIFIED BY '${mysql_password}';
GRANT USAGE ON *.* TO '${database_name}'@'localhost' with grant option;
GRANT USAGE ON *.* TO '${database_name}'@'127.0.0.1' with grant option;
CREATE DATABASE IF NOT EXISTS \`${database_name}\`;
GRANT ALL PRIVILEGES ON \`${database_name}\`.* TO '${database_name}'@'localhost';
GRANT ALL PRIVILEGES ON \`${database_name}\`.* TO '${database_name}'@'127.0.0.1';
GRANT ALL PRIVILEGES ON \`${database_name}\`.* TO '${database_name}'@'%';
FLUSH PRIVILEGES;
EOF
    cat >$BAK_DIR/.add_mysql.sh<<EOF
#!/usr/bin/env bash

mysql -uroot -p${MYSQL_ROOT_PASSWORD} < /mysql/backup/.add_mysql.sql
EOF
    _bash mysql chmod 777 /mysql/backup/.add_mysql.sh
    _bash mysql /mysql/backup/.add_mysql.sh
    [ $? -eq 0 ] && echo "Add database Sucessfully." || echo "Add database failed!"
    rm -f $BAK_DIR/.add_mysql.sql
    rm -f $BAK_DIR/.add_mysql.sh
    ;;
  0)
    exit 1
    ;;
  *)
    echo "Please enter the correct option"
    ;;
  esac
}

function _mongodbTools() {
  local yes=0
  local BAK_DIR="${MONGODB_CONF_DIR:-./config/mongodb}/backup"
  local BAK_FILE="$BAK_DIR/$DATE"
  local DAYS=15
  mkdir -p $BAK_FILE
  if [[ "backup" == $1 ]]; then
    cat >$BAK_DIR/.bak.sh<<EOF
#!/usr/bin/env bash

mongodump  -u ${MONGODB_INITDB_ROOT_USERNAME} -p ${MONGODB_INITDB_ROOT_PASSWORD}  --authenticationDatabase admin  -o /backup/${DATE}
tar -zcvf /backup/${DATE}.tar.gz /backup/${DATE}
rm -rf /backup/${DATE}
find /backup/ -mtime +$DAYS -delete
EOF
    _bash mongodb chmod 777 /backup/.bak.sh
    _bash mongodb /backup/.bak.sh
    if [ $? -eq 0 ];then
      echo "bak database Sucessfully."
      echo "export -> $BAK_FILE"
    else
      echo "bak database failed!"
      echo $(pwd)
      echo $BAK_DIR
      cat $BAK_DIR/.bak.sh
    fi
    rm -f $BAK_DIR/.bak.sh
    exit
  fi
}

function __Enter_Database_Name()
{
    while :;do
        tips "Enter database name: "
        read database_name
        if [ "${database_name}" == "" ]; then
            error "Database Name can't be empty!"
        else
            break
        fi
    done
}

function __determine() {
  echo -e "Please determine if you want to perform \033[32m$1\033[0m operation (yes|NO)"
  read -p "Now select the top option to: " input
  case $input in
  "y" | "Y" | "yes" | "YES")
    return 1
    ;;
  *)
    return 0
    ;;
  esac
}

function _inspect() {
  docker inspect $WORK_NAME"_$@"
}

function __yapi() {
  docker-compose up -d yapi
  tips "yapi: http://127.0.0.1:$YAPI_HOST_PORT"
}

function __sentry() {
  local cmd=${BASH_SOURCE[0]}
  # shellcheck disable=SC2001
  cmd=$(echo $cmd | sed 's:\/usr\/bin\/::g')
  docker-compose up -d sentry sentry_celery_beat sentry_celery_worker
  tips "For the first time, please execute the following command to initialize sentry:\n"
  tips "  $cmd sentry upgrade"
  tips ""
}

main "$@"
