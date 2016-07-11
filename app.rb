require 'bundler'
require 'sinatra/base'
require 'yaml'

Bundler.require :default, ENV['RACK_ENV'].to_sym

class App < Sinatra::Base
  register Sinatra::RespondWith

  set :root, File.dirname(__FILE__)

  set :env, ENV['RACK_ENV'] || 'development'

  set :base_path, '/raw/ceph/'

  configure :development, :test do
    set :etcd_config, Proc.new { YAML.load_file('config/etcd.yml')[settings.env.to_sym] }
  end

  configure :production do
    set :etcd_config, Proc.new { YAML.load(ERB.new(File.read('config/etcd_prod.yml')).result)[settings.env.to_sym] }
  end

  set :etcd, Proc.new {
    Etcd.client(
      host: etcd_config[:host],
      port: etcd_config[:port],
      user_name: etcd_config[:user_name],
      password: etcd_config[:password]
    )
  }

  get "/ping" do
    'pong'
  end

  get '/clusters' do
    clusters = etcd.get('/raw/ceph').children.map{|c|
      id = c.key.split(settings.base_path)[1]
      name = etcd.get("#{c.key}/maps/config/cluster_name").value
      { 
        id: id,
        name: name,
        type: 'ceph'
      } 
    }
    respond_to do |f|
      f.json { clusters.to_json }
    end
  end

  get '/clusters/:cluster_id' do
    cluster = etcd.get("/raw/ceph/#{params[:cluster_id]}")
    name = etcd.get("#{cluster.key}/maps/config/cluster_name").value
    config = JSON.parse etcd.get("#{cluster.key}/maps/config/data").value.gsub(/'/, "\"")
    health = JSON.parse etcd.get("#{cluster.key}/maps/health/data").value.gsub(/'/, "\"")
    cluster_hash = {
      id: params[:cluster_id],
      name: name,
      config: config,
      health: health
    }

    respond_to do |f|
      f.json { cluster_hash.to_json }
    end
  end

  # get '/clusters/:cluster_id/:object_type'
  get '/clusters/:cluster_id/osd' do
    cluster = etcd.get("/raw/ceph/#{params[:cluster_id]}")
    osds = JSON.parse(etcd.get("#{cluster.key}/maps/osd_map/data").value.gsub(/'/, "\""))['osds']

    respond_to do |f|
      f.json { osds.to_json }
    end
  end

  # get '/clusters/:cluster_id/:object_type/:object_id'
  get '/clusters/:cluster_id/osd/:osd_id' do
    cluster = etcd.get("/raw/ceph/#{params[:cluster_id]}")
    osds_data = JSON.parse(etcd.get("#{cluster.key}/maps/osd_map/data").value.gsub(/'/, "\""))
    osd = osds_data['osds'].find{|e| e['uuid'] == params[:osd_id] }
    osd_metadata = osds_data['osd_metadata'].find{|e| e['osd'] == osd['osd'] }

    respond_to do |f|
      f.json { osd.merge(osd_metadata).to_json }
    end
  end

  private

  def etcd
    settings.etcd
  end

end
