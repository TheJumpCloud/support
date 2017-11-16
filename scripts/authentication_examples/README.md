# Authentication Examples

## LDAP

### Python

### Ruby

It assumed that you have installed a recent version of Ruby for your
Operating System.

We use the default Ruby package manager
 [gem](https://en.wikipedia.org/wiki/RubyGems),
 in conjunction with [bundler](http://bundler.io/) to manage Ruby dependency
installation.

#### Installation of Dependencies

1. install bundler
   `gem install bundler`

2. Install the ruby_ldap_authentication.rb dependencies.
   `bundle install`

#### Example Script Execution


#### List of Ruby Dependencies

* LDAP Server interation - [net-ldap](https://github.com/ruby-ldap/ruby-net-ldap/)


## Troubleshooting

#### Error installing bundler

If you see something like the following, try installing `bundler` using `sudo`

```
$ /usr/bin/gem install bundler
Fetching: bundler-1.16.0.gem (100%)
Successfully installed bundler-1.16.0
ERROR:  While executing gem ... (NoMethodError)
    undefined method `source_paths' for
    #<Gem::Specification:0x3fc40f829aac bundler-1.16.0>
```
