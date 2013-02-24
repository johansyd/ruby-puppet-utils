#!/usr/bin/ruby
# A simple script which fetches external nodes from Foreman
# you can basically use anything that knows how to get http data, e.g. wget/curl
# etc.
# author: Johan Sydseter, <johan.sydseter@startsiden.no>

# Foreman destination
# Define FOREMAN_HOST, FOREMAN_PORT and FOREMAN_METHOD in the system 
# environment to use foreman. Falls back to the node definitions in 
# ../manifests/yaml

foreman_host = ENV['FOREMAN_HOST']     || 'foreman.startsiden.no'
foreman_port = ENV['FOREMAN_PORT']     || '80'
foreman_method = ENV['FOREMAN_METHOD'] || 'http'
yaml_node_dir = ENV['YAML_NODE_DIR'] || '/var/local/puppet/yaml/facts'
foreman_url = foreman_method + '://' + foreman_host + ':' + foreman_port

node = ARGV[0]
foreman_url += "/node/#{node}?format=yml" 

date = `date +"%b %d %T" | tr -d "\n"`
script = $0


require 'net/http'
require 'net/https' if foreman_url =~ /^https/

url = URI.parse(foreman_url)
con = Net::HTTP.new(url.host, url.port)

# decide whether to use ssl
if foreman_url =~ /^https/
    con.use_ssl = (url.scheme == 'https')
end

# start the call to forman
begin

    req = Net::HTTP::Get.new(foreman_url)
    res = con.start { |http| http.request(req) }

rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, SocketError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
    $stderr.puts date + ' ' + script + ": ERROR reaching forman: " + e.to_s
end

case res

# Return the result if the forman call was successfull
when Net::HTTPOK
    puts res.body
else
    # Return the yaml content of the file in yaml/$node_name
    # cat_result = `cat yaml/#{ARGV[0]}`
    if Dir[yaml_node_dir].nil?
        $stderr.puts date + ' ' + script + "Could not find #{yaml_node_dir}";
        $stderr.puts date + ' ' + script + 
            "When no forman server is present, the default is to search for \
            a yaml file with the same name as the puppet agent host for \
            instantiation of puppet modules. When there are no directory where \
            these yaml files exist. node.rb fails."
        puts "\n---\nclasses:"
    end
    $stderr.puts date + ' ' + script + ": ERROR retrieving node %s from Forman." % [node]
    $stderr.puts date + ' ' + script + 
        ": TRACE retrieving node %s from #{yaml_node_dir}/%s.yml" % [node, node]
    cat_result = `cat #{yaml_node_dir}/#{ARGV[0]}.yml 2> /dev/null || echo 0 | tr -d "\n"`

    if cat_result != '0'
        puts cat_result
    else
        # There where no such file return a empty yaml definition
        $stderr.puts date + ' ' + script + 
            ": ERROR retrieving node %s from #{yaml_node_dir}/%s.yml" % [node, node]
        $stderr.puts date + ' ' + script +
            ": TRACE fall back to empty node definition."
        puts "\n---\nclasses:"
    end
end
