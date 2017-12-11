# LDAP Authentication Examples

## Python

The Python script "should" be able to run with python 2.7+ but has been tested primarily with
python 3.6+

[Pip](https://pypi.python.org/pypi/pip/) is used to install the python script dependencies.  The dependencies
are listed in the requirements.txt file.

### Installation of Python Dependencies

1. Install [pip](https://pypi.python.org/pypi/pip/) for your Operating System.
2. Install the python script dependencies:

`pip install -r requirements.txt`

### Example Script Execution.

`python python_ldap_authentication.py`

### Dependency reference.

* [pyldap](https://github.com/pyldap/pyldap/) - an object-oriented API to access LDAP directory servers
from Python.  Supports both python 2.7+ and python 3.x - it wraps the OpenLDAP client

## Ruby

It assumed that you have installed a recent version of Ruby for your
Operating System.

We use the default Ruby package manager
 [gem](https://en.wikipedia.org/wiki/RubyGems),
 in conjunction with [bundler](http://bundler.io/) to manage Ruby dependency
installation.

### Installation of Ruby Dependencies

1. install bundler
   `gem install bundler`

2. Install the ruby_ldap_authentication.rb dependencies.
   `bundle install`

### Example Script Execution

`ruby ruby_ldap_authentication.rb`

### Dependency reference.

* [net-ldap](https://github.com/ruby-ldap/ruby-net-ldap/) - A pure Ruby implementation of LDAP for client
access to LDAP directory servers.

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
