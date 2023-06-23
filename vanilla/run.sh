#!/bin/bash

## 若环境变量中没有设置对应参数，则使用默认值
dft_realmdDBStr="host.docker.internal;3306;root;root;realmd"
dft_mangosDBStr="host.docker.internal;3306;root;root;mangos"
dft_characterDBStr="host.docker.internal;3306;root;root;characters"
dft_logsDBStr="host.docker.internal;3306;root;root;logs"

## 世界服务器端口默认值
dft_mangosServerPort=8085
## 登录服务器端口默认值
dft_realmServerPort=3724
## 本次启动的默认资料片版本
dft_wowPatch=10
## 默认服务器类型
## 0 = NORMAL; 1 = PVP; 4 = NORMAL; 6 = RP; 8 = RPPVP
## 16 FFA_PVP (除休息区域外全域默认开启pvp)
dft_gameType=1
## 时区
dft_timeZoneOffset=8
## 登录界面消息
dft_motd="Welcome to World of Warcraft!"
## 启动何种类型的server, realmd/mangosd/all, 默认两个都启动
dft_serverType="all"

if [ -z "$realmdDBStr" ]; then
  realmdDBStr=$dft_realmdDBStr
fi

if [ -z "$mangosDBStr" ]; then
  mangosDBStr=$dft_mangosDBStr
fi

if [ -z "$characterDBStr" ]; then
  characterDBStr=$dft_characterDBStr
fi

if [ -z "$logsDBStr" ]; then
  logsDBStr=$dft_logsDBStr
fi

if [ -z "$mangosServerPort" ]; then
  mangosServerPort=$dft_mangosServerPort
fi

if [ -z "$realmServerPort" ]; then
  realmServerPort=$dft_realmServerPort
fi

if [ -z "$wowPatch" ]; then
  wowPatch=$dft_wowPatch
fi

if [ -z "$gameType" ]; then
  gameType=$dft_gameType
fi

if [ -z "$timeZoneOffset" ]; then
  timeZoneOffset=$dft_timeZoneOffset
fi

if [ -z "$motd" ]; then
  motd=$dft_motd
fi

if [ -z "$serverType" ]; then
  serverType=$dft_serverType
fi

## 启动服务器
start_server() {
  if [ -n "$1" ]; then
    echo "Starting the $1 server..."
    gosu admin nohup gosu admin /home/admin/vmangos/bin/${1} >/home/admin/vmangos/logs/${1}/nohup.out 2>&1 &
  else
    report_err_exit "Server not specified."
  fi
}

## 报错并退出
report_err_exit() {
  if [ -n "$1" ]; then
    echo ${1} 1>&2
  fi
  exit 1
}

## 将配置项应用到对应配置文件
sed -i "s/^LoginDatabase\.Info.*$/LoginDatabase.Info              = \"${realmdDBStr}\"/g" /home/admin/vmangos/etc/mangosd.conf
sed -i "s/^LoginDatabaseInfo.*$/LoginDatabaseInfo = \"${realmdDBStr}\"/g" /home/admin/vmangos/etc/realmd.conf
sed -i "s/^WorldDatabase\.Info.*$/WorldDatabase.Info              = \"${mangosDBStr}\"/g" /home/admin/vmangos/etc/mangosd.conf
sed -i "s/^CharacterDatabase\.Info.*$/CharacterDatabase.Info              = \"${characterDBStr}\"/g" /home/admin/vmangos/etc/mangosd.conf
sed -i "s/^LogsDatabase\.Info.*$/LogsDatabase.Info              = \"${logsDBStr}\"/g" /home/admin/vmangos/etc/mangosd.conf
sed -i "s/^WorldServerPort.*$/WorldServerPort = ${mangosServerPort}/g" /home/admin/vmangos/etc/mangosd.conf
sed -i "s/^RealmServerPort.*$/RealmServerPort = ${realmServerPort}/g" /home/admin/vmangos/etc/realmd.conf
sed -i "s/^WowPatch.*$/WowPatch = ${wowPatch}/g" /home/admin/vmangos/etc/mangosd.conf
sed -i "s/^GameType.*$/GameType = ${gameType}/g" /home/admin/vmangos/etc/mangosd.conf
sed -i "s/^TimeZoneOffset.*$/TimeZoneOffset = ${timeZoneOffset}/g" /home/admin/vmangos/etc/mangosd.conf
sed -i "s/^Motd.*$/Motd = ${motd}/g" /home/admin/vmangos/etc/mangosd.conf

## 根据本实例server类型启动server
cd /home/admin/vmangos || exit
if [ "realmd" = "$serverType" ]; then
  start_server "realmd"
elif [ "mangosd" = "$serverType" ]; then
  start_server "mangosd"
elif [ "all" = "$serverType" ]; then
  start_server "realmd"
  start_server "mangosd"
else
  report_err_exit "Unrecognized server type: $serverType" 1>&2
fi

gosu admin bash
