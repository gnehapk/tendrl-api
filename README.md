# Tendrl API
### Installation
```shell
$ rbenv install 2.3.1 # Install ruby 2.3.1
$ gem install bundler
$ bundle install
$ cp config/etcd.sample.tml to config/etcd.yml
```
### Start Server
```shell
  $ rackup config.ru
```
### API Endpoints
```
GET /clusters
GET /clusters/cluster_id
GET /clusters/:cluster_id/osds
GET /clusters/:cluster_id/osds/:osd_id
GET /clusters/:cluster_id/pools
GET /clusters/:cluster_id/pools/:pool_id
```
