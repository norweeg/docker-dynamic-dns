#!/bin/bash

while true; do

  if [ -z "$USER" ]; then
    echo "No user was set. Use -u=username"
    exit 10
  fi
  if [ -z "$PASSWORD" ]; then
    echo "No password was set. Use -p=password"
    exit 20
  fi
  if [ -z "$HOSTNAME" ]; then
    echo "No host name. Use -h=host.example.com"
    exit 30
  fi
  if [ -n "$DETECTIP" ]; then
    IP=$(wget -qO- "https://api.ipify.org")

    if [ -n "$UPDATEIPV6" ]; then
      IPV6=$(wget -qO- "https://api64.ipify.org")
    fi
  fi
  if [ -n "$DETECTIP" ] && [ -z $IP ]; then
    RESULT="Could not detect external IP."
  fi
  if [[ $INTERVAL != [0-9]* ]]; then
    echo "Interval is not an integer."
    exit 35
  fi


  SERVICEURL="dynupdate.no-ip.com/nic/update"
  case "$SERVICE" in
    noip)
      SERVICEURL="dynupdate.no-ip.com/nic/update"
      ;;
    dyndns)
      SERVICEURL="members.dyndns.org/v3/update"
      ;;
    duckdns)
      SERVICEURL="www.duckdns.org/v3/update"
      ;;
    google)
      SERVICEURL="domains.google.com/nic/update"
      ;;
    freedns)
      SERVICEURL="freedns.afraid.org/nic/update"
      ;;
    *)
      SERVICEURL="dynupdate.no-ip.com/nic/update"
  esac
  

  USERAGENT="User-Agent: no-ip shell script/1.0 mail@mail.com"
  AUTHHEADER="Authorization: Basic $(echo -n "$USER:$PASSWORD" | base64)"
  
  NOIPURL="https://$USER:$PASSWORD@$SERVICEURL"
  NOIPURL="https://$SERVICEURL"
  if [ -n "$IP" ] || [ -n "$HOSTNAME" ]; then
    NOIPURL="$NOIPURL?"
  fi
  if [ -n "$HOSTNAME" ]; then
    NOIPURL="${NOIPURL}hostname=${HOSTNAME}"
  fi
  if [ -n "$IP" ]; then
    if [ -n "$HOSTNAME" ]; then
      NOIPURL="$NOIPURL&"
    fi
    NOIPURL="${NOIPURL}myip=$IP"
    if [ -n "$UPDATEIPV6" ]; then
      NOIPURL="${NOIPURL},$IPV6&myipv6=$IPV6"
    fi
  fi


  echo "[$(date +'%Y-%m-%d %H:%M:%S')] curl -H \"$USERAGENT\" -H \"$AUTHHEADER\" $NOIPURL"
  RESULT=$(curl -sS -H "$USERAGENT" -H "$AUTHHEADER" $NOIPURL)
  echo $RESULT
  if [ $INTERVAL -eq 0 ]; then
    break
  else
    sleep "${INTERVAL}m"
  fi
done

exit 0
