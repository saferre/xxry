#!/bin/bash

#Xray版本
mkdir /xraybin
cd /xraybin
wget --no-check-certificate "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip"
unzip Xray-linux-64.zip
rm -f Xray-linux-64.zip
chmod +x ./xray
ls -al

cd /wwwroot
tar xvf wwwroot.tar.gz
rm -rf wwwroot.tar.gz


sed -e "/^#/d"\
    -e "s/\${UUID}/${UUID}/g"\
    -e "s|\/${UUID}-vless|/${UUID}-vless|g"\
    -e "s|\/${UUID}-vmess|/${UUID}-vmess|g"\
    /conf/Xray.template.json >  /xraybin/config.json
echo /xraybin/config.json
cat /xraybin/config.json

if [[ -z "${ProxySite}" ]]; then
  s="s/proxy_pass/#proxy_pass/g"
  echo "site:use local wwwroot html"
else
  s="s|\${ProxySite}|${ProxySite}|g"
  echo "site: ${ProxySite}"
fi

sed -e "/^#/d"\
    -e "s/\${PORT}/${PORT}/g"\
    -e "s|\/${UUID}-vless|/${UUID}-vless|g"\
    -e "s|\/${UUID}-vmess|/${UUID}-vmess|g"\
    -e "$s"\
    /conf/nginx.template.conf > /etc/nginx/conf.d/ray.conf
echo /etc/nginx/conf.d/ray.conf
cat /etc/nginx/conf.d/ray.conf


cd /xraybin
./xray run -c ./config.json &
rm -rf /etc/nginx/sites-enabled/default
nginx -g 'daemon off;'
