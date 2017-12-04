## The Ruby version of LDAP Authentication examples.

require 'json'
require 'getoptlong'
require 'net/ldap'
require 'highline'

CONFIG_FILE = 'ruby-config.json'.freeze

# "Constants" for the JSON configuration keys - see the ruby JSON configuration
# file.
module Configs
  LdapServer = 'ldap_server'.freeze
  BindDn = 'binddn'.freeze
  BaseDn = 'basedn'.freeze
  SearchFilter = 'search_filter'.freeze
  SearchAttribute = 'search_attribute'.freeze
end

# Parse the JSON configuration file.
def parse_json
  jfile = open(CONFIG_FILE)
  json = jfile.read
  JSON.parse(json)
end

# Command line help.
opts = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT]
)
opts.each do |opt, arg|
	case opt
	when '--help'
		puts <<-EOF

		EOF
	end
end

# Get values from script operator.
# Organization ID: The ID of the Organization containing our Bind User.
# Bind User: User name of the User bound to the LDAP Server.
# Bind User Password: Self explanatory.
# Group: The User Group Name containing the User we are searching for.
# Username: Name of the User to search for.
# Userpassword: Password of the above User.
cli = HighLine.new
org_id = cli.ask 'Please enter your Organization ID: '
bind_user = cli.ask 'Please enter your search User: '
password_field = cli.ask('Search User Password: ') { |q| q.echo = false }
group = cli.ask 'Please enter your Group: '
user_name = cli.ask 'Please enter User: '
user_password = cli.ask('Please enter User Password: ') { |q| q.echo = false }

# org_id = '5952c31766d1b64b09de4d42'
# bind_user = 'testldap'
# password_field = 'solidfire'
# group = 'bobby'
# user_name = 'testldap'
# user_password = 'solidfire'

puts "Your Org ID: #{org_id}"
puts "Bind User: #{bind_user}"
puts "User Group: #{group}"
puts "User Name to search for: #{user_name}"


parsed = parse_json
ldap_server = parsed[Configs::LdapServer]
puts "LDAP Server: #{ldap_server}"

#---- LDAP connection using ldaps ----#
binddn = "uid=#{bind_user},ou=Users,o=#{org_id},dc=jumpcloud,dc=com"
puts "Bind DN: #{binddn}"

ldap = Net::LDAP.new :host => ldap_server,
                     :port => 636,
										 :encryption => :simple_tls,
										 :base => 'dc=jumpcloud,dc=com',
										 :auth => {
												:method => :simple,
												:username => binddn,
												:password => password_field
										 }
if ldap.bind
  puts 'Bind Authentication successful!'
else
	# get_operation_result.result_code & result_message come from constants in the
	# Net::LDAP code. Not every error returned from the LDAP server has a
	# corresponding code+message constant.
	rcode = ldap2.get_operation_result.result_code
	rmsg = ldap2.get_operation_result.result_message
	if rcode
		puts "Bind Authentication failed! Code: #{rcode} - #{rmsg}"
	else
		puts "Bind Authentication failed! Probably invalid credentials."
	end
end

#---- First search example. ----#
puts 'Searching ...'
search_attributes = ["mail", "uid"]
treebase = "ou=Users,o=#{org_id},dc=jumpcloud,dc=com"
search_filter = Net::LDAP::Filter.eq('mail', "#{user_name}*.com")

# We are setting :return_result to false because we aren't using the results
# outside of the block.  This also avoids a memory leak (unclear if leak is fixed) ->
#   https://stackoverflow.com/questions/3320054/memory-leak-in-ruby-net-ldap-module?rq=1
ldap.search(:filter => search_filter,
						:attributes => search_attributes,
						:return_result => false, :base => treebase) { |item|
							item.each do |attr, values|
								values.each do |value|
									puts "\t#{attr} - #{value}"
								end
							end
}

#---- Simple LDAP connection. ----#
ldap2 = Net::LDAP.new :host => ldap_server,
										 :port => 389,
										 :auth => {
												:method => :simple,
												:username => "uid=#{user_name},ou=Users,o=#{org_id},dc=jumpcloud,dc=com",
												:password => user_password
										 }
if ldap2.bind
  puts '2nd Bind Authentication succeeded'
else
	# See the previous authentication example for an explanation of result_code
	# and result_message
  rcode = ldap2.get_operation_result.result_code
  rmsg = ldap2.get_operation_result.result_message
	if rcode
   puts "2nd Bind Authentication failed! Code: #{rcode} - #{rmsg}"
	else
   puts '2nd Bind Authentication failed!  Probably invalid credentials.'
	end
end

#---- Second search example. Search by uid ----#
puts '2nd Search example'
treebase = "ou=Users,o=#{org_id},dc=jumpcloud,dc=com"

# A simple search filter.
# search_filter2 = Net::LDAP::Filter.eq('uid', "#{user_name}*")

# A constructed search filter using LDAP search query syntax.
search_filter2 = Net::LDAP::Filter.construct("(&(objectClass=inetOrgPerson)(memberOf=cn=#{group},ou=Users,o=#{org_id},dc=jumpcloud,dc=com)(uid=#{user_name}))")
puts "constructed search query: #{search_filter2}"

i = 0
ldap2.search(:base => treebase, :filter => search_filter2, :return_result => false) do |entry|
	entry.each do |attr, values|
		i += 1
		values.each do |value|
			puts "\t#{attr} - #{value}"
		end
	end
end

if i.zero?
  puts "Search result set is empty, search user #{user_name} is not Authorized!"
end

# We change :return_result to true here in order to test the result_set - this is not great for large
# data sets.
# result_set = ldap2.search(:base => treebase, :filter => search_filter2, :return_result => true);

# if result_set.empty?
#   puts "Search result set is empty, search user #{user_name} is not Authorized!"
# end

# result_set.each do |entry|
# 	entry.each do |attr, values|
# 		values.each do |value|
# 			puts "\t#{attr} - #{value}"
# 		end
# 	end
# end
