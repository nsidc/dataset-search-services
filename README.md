# NSIDC Open Search

NSIDC OpenSearch web service (yet another OpenSearch)

The service currently exposes four endpoints:

* `/OpenSearchDescription` - OpenSearch Description Document (accessing this
  endpoint provides descriptions for each other endpoint)
* `/OpenSearch` - dataset search, used by NSIDC Search and the ADE
* `/Facets` - facets to go with the dataset search
* `/suggest` - retrieve suggested phrase completions for auto-suggest/auto-complete

For the most part, these endpoints support queries following the OpenSearch and
relevant OpenSearch Extension specifications. However, they each take an
additional optional URL parameter that is not in the standard,
`source`. [NSIDC Search](https://nsidc.org/data/search/) and
[the Arctic Data Explorer](https://nsidc.org/acadis/search/) (ADE) each use the
same instance of this service, and the same Solr store to retrieve metadata;
however, the ADE contains metadata for datasets from variety of sources as well
as from NSIDC, and a simple way to distinguish between the two applications was
needed. The `source` parameter in queries made by NSIDC Search is set to
`NSIDC`, and for queries from the ADE is set to `ADE` - this corresponds to the
"source" value in the solr datastore.

## Installation & Usage

##### Requirements

  * Ruby (see `.ruby-version` for the required version)
  * [Bundler](http://bundler.io/)
  * Ubuntu 14.04 (only required if setting up the Upstart service)

##### Configuration

`config/app_config.yaml` contains settings for different environments to run the
service in. Each environment other than `development` merges in the `common`
settings. You may need to modify some settings in the appropriate section this
file:

* `relative_url_root` determines the path to access the service, e.g., with a
  value of `/api/dataset/2`, you can access the running service at
  [http://localhost:3000/api/dataset/2](http://localhost:3000/api/dataset/2)
* `solr_url` is the URL of the Solr core containing your data
* `solr_auto_suggest` is the URL of the Solr core containing autocomplete data

### Simple Setup

1. Clone the source code - `git clone git@github.com:nsidc/dataset-search-services.git`
1. `cd dataset-search-services`
1. Install the dependencies - `bundle install`
1. Modify the `development` section in `config/app_config.yaml` so that it has
   the values you need (if `RACK_ENV` is set to something other than
   `development`, the section matching its value will be used)
1. `bundle exec rake run` starts the service on port `3000`
1. The service can be queried via `curl` or in the browser with an OpenSearch
   request, e.g.,
   [http://localhost:3000/OpenSearchDescription](http://localhost:3000/OpenSearchDescription),
   which will provide a list of endpoints provided by the service and their
   required parameters

### As a Systemd service (requires Ubuntu 16.04 or higher)

`tasks/deploy.rake` contains `rake` tasks to set up and start the service on a
Vagrant VM hosted on NSIDC's internal network. To set up the service outside of
this network, follow these steps:

1. Clone the source code - `git clone git@github.com:nsidc/dataset-search-services.git`
1. `cd dataset-search-services`
1. Set `APP_PATH` in `config/app_config.rb` to where you want the code to be run
   * the following steps assume the environment variable `APP_PATH` is set to the
     same value used in `config/app_config.rb`
1. `mkdir -p $APP_PATH`
1. `cp -R . $APP_PATH`
1. `cd $APP_PATH; bundle install`
1. `mkdir -p $APP_PATH/run/log`
1. Set `ENV` to your desired environment (`development`, `integration`, `qa`,
   etc.)
1. Configure the appropriate section in `$APP_PATH/config/app_config.yaml`
1. `echo $ENV > $APP_PATH/config/environment`
1. Create a search_services.service file in /etc/systemd/system.  See the example file below, which
   assumes the $APP_PATH is /opt/search_services
   * The User and Group should be changed to whatever user/group will own the service
1. Create a puma run file:
   * `sudo mkdir /etc/search_services`
   * Create a file `/etc/search_services/puma.rb` file; see below for an example.  As above,
     this example assumes the $APP_PATH is /opt/search_services 
1. `sudo systemctl start search_services.service`
   * the service must be able to write to `/var/log` and `/var/run/puma` (the
     full paths of the relevant files can be seen in `config/app_config.yaml`)
1. The service can be queried at using the `port` and `relative_url_root` set in
  `$APP_PATH/config/app_config.yaml`
   * For example, if `port` is `10680` and `relative_url_root` is
    `/api/dataset/2`, you can access the OpenSearch Description Document provided
    by the service at
    [http://localhost:10680/api/dataset/2/OpenSearchDescription](http://localhost:10680/api/dataset/2/OpenSearchDescription).
    
#### Example search_services.service file
```
[Unit]
Description=search_services - puma application
   
[Service]
Type=forking
WorkingDirectory=/opt/search_services
RuntimeDirectory=search_services
PIDFile=/var/run/search_services/puma.pid
User=www
Group=www
   
# The command to start puma
ExecStart=/usr/local/bin/bundle exec puma -C /etc/search_services/puma.rb
Restart=on-failure
   
[Install]
WantedBy=multi-user.target
```

#### Example /etc/search_services/puma.rb file
Configure environment, port, etc, according to your needs.

```
directory '/opt/search_services
environment 'development'
daemonize
pidfile "/var/run/search_services/puma.pid"
stdout_redirect "/var/log/search_services.puma.stderr.log", "/var/log/search_services.puma.stdout.log"
threads 1, 1
bind 'tcp://0.0.0.0:10680'
plugin 'tmp_restart'
restart_command "bundle exec puma"
workers 2
preload_app!
```

## Changes

Notes on changes can be found in
[`CHANGELOG.md`](https://github.com/nsidc/dataset-search-services/blob/master/CHANGELOG.md).

## Developer Info

Instructions and notes for developing this project are in
[`DEVELOPMENT.md`](https://github.com/nsidc/dataset-search-services/blob/master/DEVELOPMENT.md).

## How to contact NSIDC

User Services and general information:  
Support: [http://support.nsidc.org](http://support.nsidc.org)  
Email: nsidc@nsidc.org  

Phone: +1 303.492.6199  
Fax: +1 303.492.2468  

Mailing address:  
National Snow and Ice Data Center  
CIRES, 449 UCB  
University of Colorado  
Boulder, CO 80309-0449 USA

## License

Every file in this repository is covered by the GNU GPL Version 3; a copy of the
license is included in the file COPYING.
