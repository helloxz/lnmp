#!/bin/bash
#####	CentOS 7一键安装LNMP	#####
#####	Author:xiaoz			#####
#####	Update:2017.11.19		#####

#安装Nginx
function install_nginx() {
	#创建用户和用户组
	groupadd www
	useradd -g www www
	#下载到指定目录
	wget https://soft.hixz.org/nginx/nginx-binary-1.12.2.tar.gz -P /usr/local

	#解压
	cd /usr/local && tar -zxvf nginx*.tar.gz
	rm -rf nginx*.tar.gz
	#环境变量
	echo "export PATH=$PATH:/usr/local/nginx/sbin" >> /etc/profile
	export PATH=$PATH:'/usr/local/nginx/sbin'

	#启动
	/usr/local/nginx/sbin/nginx
	#开机自启
	echo "/usr/local/nginx/sbin/nginx" >> /etc/rc.d/rc.local
	chmod +x /etc/rc.d/rc.local
}

#安装MariaDB
function install_db() {
	read -p "设置数据库密码：" mdpass
	#创建数据库存放目录
	mkdir -p /data/mariadb
	#创建用户和组
	groupadd mysql && useradd -g mysql mysql
	
	#下载安装包
	wget -c https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-10.2.10/bintar-linux-glibc_214-x86_64/mariadb-10.2.10-linux-glibc_214-x86_64.tar.gz
	#解压
	tar -xvzf mariadb*.tar.gz
	#删除
	rm -rf mariadb*.tar.gz
	#移动
	mv mariadb* /usr/local/mariadb/
	#进入目录
	cd /usr/local/mariadb
	#备份配置文件
	mv /etc/my.cnf /etc/my.cnf.bak
	#复制配置文件
	cp support-files/my-small.cnf /etc/my.cnf
	#修改配置文件
	sed -i "/^\[mysqld\]/a\basedir = /usr/local/mariadb\ndatadir = /data/mariadb\npid-file = /data/mariadb/mysql.pid" /etc/my.cnf
	#重置权限
	cp -a data/* /data/mariadb/
	chown -R mysql:mysql ./*
	chown -R mysql:mysql /data/mariadb
	#执行安装
	/usr/local/mariadb/scripts/mysql_install_db --user=mysql
	#启动脚本
	#bin/mysqld_safe --user=mysql &
	#添加服务
	cp support-files/mysql.server /etc/init.d/mysql
	#启动脚本
	service mysql start
	#开机启动
	chkconfig mysql on
	#设置环境变量
	echo "export PATH=$PATH:/usr/local/mariadb/bin" >> /etc/profile
	export PATH=$PATH:'/usr/local/mariadb/bin'
	#设置root密码
	bin/mysqladmin -u root password ${mdpass}
}

#安装PHP
function install_php() {
	#安装依赖
	yum -y install epel-release
	yum -y install libxml2 libxml2-devel openssl openssl-devel curl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel mhash gd gd-devel libaio*
	#下载
	wget http://soft.hixz.org/php/php7.tar.gz
	#解压
	tar -zxvf php7.tar.gz
	rm -rf php7.tar.gz
	mv php/php-fpm /etc/init.d/
	mv php /usr/local

	service php-fpm start
	#环境变量
	echo "export PATH=$PATH:/usr/local/php/bin" >> /etc/profile
	export PATH=$PATH:'/usr/local/php/bin'
}

#安装选项
#declare -i options
echo "##########	欢迎使用一键安装LNMP脚本^_^	##########"
echo "请选择:"
echo "1) 安装Nginx"
echo "2) 安装MariaDB"
echo "3) 安装Nginx + MariaDB + PHP"
echo "q) 退出"
read -p ":" options

if [ "$options" == 1 ]
then
	#执行安装
	install_nginx
	. /etc/profile
	#获取IP
	osip=$(curl http://https.tn/ip/myip.php?type=onlyip)
	echo "##########	安装完成	##########"
	echo "请访问：http://${osip}"
elif [ "$options" == 2 ]
	then
		#安装MariaDB
		install_db
		. /etc/profile
		echo "##########	安装完成	##########"
		echo "数据库密码为:"${mdpass}
elif [ "$options" == 3 ]
	then
		#安装全部
		install_nginx
		install_php
		install_db
		. /etc/profile
		#获取IP
		osip=$(curl http://https.tn/ip/myip.php?type=onlyip)
		echo "##########	安装完成	##########"
		echo "请访问：http://${osip}"
		echo "数据库密码为:"${mdpass}
elif [ "$options" == 'q' ]
	then
		exit
else
	echo "参数错误！"
	exit
fi
