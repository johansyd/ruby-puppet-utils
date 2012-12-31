##Ruby puppet utils
###Author
[Johan Sydseter](http://www.sydseter.com)
###Description

This repository contains utilities for developing and working with puppet.

###Tools

The following tools can be found.

####node.rb - An external node script

The node.rb is the external node script that returns the node definition 
for the different nodes as defined either by forman or by the yaml files 
in the manifests/yaml folder. An empty node definition will be returned 
if the node requested is not available.

The node rb requiers node manifests and yaml configuration files to work.
The following guidelines should be followed as an recipe.

#####The node manifests

The node manifests directory should be found in the same directory as the 
external node script. f.ex: /etc/puppet/manifests/nodes and are used to 
secure the sequence of the stagging of the different modules. There should be 
one node manifest for each node. A node manifest is defined in the following 
way:

    # /etc/puppet/manifests/nodes/name.of.node.pp
    # see: http://projects.puppetlabs.com/projects/1/wiki/Advanced_Puppet_Pattern
    node 'name.of.node' {

        ##
        # Stagging
        ##

        #modules
        Class['run_first'] ->
        Class['run_second'] ->
        Class['run_third']

    }

    # [end]

#####The Yaml configuration files

The script first tries to make contact with forman before reading the yaml 
files. The yaml directory should be copied or available as a sybolic link from
the same catalog as the node.rb f.ex: /etc/puppet/manifests/yaml if the script
is available at /etc/puppet/manifests/ruby.rb

The yaml directory contains all the parameters that will be used by the puppet modules.

    # /etc/puppet/manifests/yaml/name.of.node.yml
    # see: http://docs.puppetlabs.com/guides/external_nodes.html
    # This is the minimum of what have to be written
    ---
    classes:
    # The instantiation of the classes.
    # Does not need to be in a certain order.
        run_second:
    # Named parameters for the run_second class
            param1: true
            param2: another value
        run_third:
        run_first:
        parameter:
          global_var: used by all classes
    # The type of environment.
    # Can be used in site.pp or any other node manifest
    # see: http://docs.puppetlabs.com/guides/environment.html
      environment: example
