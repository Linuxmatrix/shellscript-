rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

echo '[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md' > /etc/yum.repos.d/elastic.repo
Stat $? "Setup Yum Repo"

yum install --enablerepo=elasticsearch elasticsearch -y &>>/tmp/elastic.log
Stat $? "Install Elasticsearch"

IPADDR=$(hostname -i | awk '{print $NF}')
sed -i -e "/network.host/ c network.host: 0.0.0.0" -e "/http.port/ c http.port: 9200" -e "/cluster.initial_master_nodes/ c cluster.initial_master_nodes: \[\"${IPADDR}\"\]" /etc/elasticsearch/elasticsearch.yml

systemctl enable elasticsearch &>>/tmp/elastic.log
systemctl start elasticsearch &>>/tmp/elastic.log
Stat $? "Start Elasticsearch"

yum install kibana  --enablerepo=elasticsearch -y &>>/tmp/elastic.log
Stat $? "Install Kibana"

systemctl enable kibana &>>/tmp/elastic.log
systemctl start kibana &>>/tmp/elastic.log
Stat $? "Start Kibana"


yum install logstash --enablerepo=elasticsearch -y &>>/tmp/elastic.log
Stat $? "Install LogStash"

echo 'input {
  beats {
    port => 5044
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "%{[@metadata][beat]}-%{[@metadata][version]}"
  }
}' >/etc/logstash/conf.d/logstash.conf

systemctl enable logstash &>>/tmp/elastic.log
systemctl start logstash &>>/tmp/elastic.log
Stat $? "Start Logstash"

yum install nginx -y &>/dev/null
Stat $? "Install Nginx"








----
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;
  ## Kibana Config
  upstream kibana {
    server 127.0.0.1:5601;
    keepalive 15;
  }

  server {
    listen 80;

    location / {
      proxy_pass http://kibana;
      proxy_redirect off;
      proxy_buffering off;

      proxy_http_version 1.1;
      proxy_set_header Connection "Keep-Alive";
      proxy_set_header Proxy-Connection "Keep-Alive";
    }

  }
}
