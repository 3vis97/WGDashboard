#!/bin/bash

app_name="dashboard.py"
dashes='------------------------------------------------------------'
help () {
  printf "<Wireguard Dashboard> by Donald Zou - https://github.com/donaldzou \n"
  printf "Usage: ./wgd.sh <option>"
  printf "\n \n"
  printf "Available options: \n"
  printf "    start: To start Wireguard Dashboard.\n"
  printf "    stop: To stop Wireguard Dashboard.\n"
  printf "    debug: To start Wireguard Dashboard in debug mode (i.e run in foreground).\n"
  printf "    update: To update Wireguard Dashboard to the newest version from GitHub.\n"
  printf "    install: To install Wireguard Dasboard.\n"
  printf "Thank you for using this dashboard! Your support is my motivation ;) \n"
  printf "\n"
}

install_wgd(){
    rm db/hi.txt >  /dev/null 2>&1
    printf "| Installing latest Python dependencies                    |\n"
    python3 -m pip install -r requirements.txt >  /dev/null 2>&1
    printf "| Wireguard Dashboard installed successfully!              |\n"
    printf "| Starting Dashboard                                       |\n"
    start_wgd
}


check_wgd_status(){
  if ps aux | grep '[p]ython3 '$app_name > /dev/null;
    then
      return 0
      else
        return 1
  fi
}

start_wgd () {
    printf "| Starting Wireguard Dashboard in the background.          |\n"
    if [ ! -d "log" ]
      then mkdir "log"
    fi
    d=$(date '+%Y%m%d%H%M%S')
    python3 "$app_name" > log/"$d".txt 2>&1 &
    printf "| Log files is under log/                                  |\n"
}

stop_wgd() {
  kill "$(ps aux | grep "[p]ython3 $app_name" | awk '{print $2}')"
}

start_wgd_debug() {
  printf "| Starting Wireguard Dashboard in the foreground.          |\n"
  python3 "$app_name"
}

update_wgd() {
  new_ver=$(python3 -c "import json; import urllib.request; data = urllib.request.urlopen('https://api.github.com/repos/donaldzou/wireguard-dashboard/releases/latest').read(); output = json.loads(data);print(output[0]['tag_name'])")
  printf "%s\n" "$dashes"
  printf "Are you sure you want to update to the %s? (Y/N): " "$new_ver"
  read up
  if [ "$up" = "Y" ]; then
    printf "| Shutting down Wireguard Dashboard...                     |\n"
    kill "$(ps aux | grep "[p]ython3 $app_name" | awk '{print $2}')"
    printf "| Downloading %s from GitHub...                            |\n" "$new_ver"
    git stash > /dev/null 2>&1
    git pull https://github.com/donaldzou/wireguard-dashboard.git $new_ver --force >  /dev/null 2>&1
    printf "| Installing latest Python dependencies                    |\n"
    python3 -m pip install -r requirements.txt >  /dev/null 2>&1
    printf "| Update Successfully!                                     |\n"
    start_wgd
  else
    printf "%s\n" "$dashes"
    printf "CANCEL update. \n"
    printf "%s\n" "$dashes"
  fi
}


if [ "$#" != 1 ];
  then
    help
  else
    if [ "$1" = "start" ]; then
        if check_wgd_status; then
          printf "| Wireguard Dashboard is already running.                  |\n"
          else
            start_wgd
        fi
      elif [ "$1" = "stop" ]; then
        if check_wgd_status; then
            stop_wgd
            printf "| Wireguard Dashboard is stopped.                          |\n"
            else
              printf "| Wireguard Dashboard is not running.                      |\n"
        fi
      elif [ "$1" = "update" ]; then
        update_wgd
      elif [ "$1" = "install" ]; then
        install_wgd
      elif [ "$1" = "restart" ]; then
         if check_wgd_status; then
           stop_wgd
           sleep 2
           printf "| Wireguard Dashboard is stopped.                          |\n"
           start_wgd
        else
          start_wgd
        fi
      elif [ "$1" = "debug" ]; then
        if check_wgd_status; then
          printf "| Wireguard Dashboard is already running.                  |\n"
          else
            start_wgd_debug
        fi
      else
        help
    fi
fi

