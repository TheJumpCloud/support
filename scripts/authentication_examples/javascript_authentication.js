/*
 * Dependencies:
 * 1. Install nodejs and then update npm
 *    http://blog.npmjs.org/post/85484771375/how-to-install-npm
 * 2. Install assert - 'npm install assert'
 * 3. Install ldapjs - 'npm install ldapjs'
 */

var assert = require('assert');
var ldap = require('ldapjs');
var console = require('console');

/*
Change the following variables as to fit your environment:

ldap_server - LDAP Server - IP address or hostname of the LDAP Server.
org_id - Organization ID - The ID of the Organization containing our Bind User.
bind_user - Bind User - User name of the User bound to the LDAP Server.
password_field - Bind User Password - Self explanatory.
group - Group - The User Group Name containing the User we are searching for.
user_name - Username - Name of the User to search for.
user_password - Userpassword - Password of the above User.
*/
var ldap_server = 'ldap.jumpcloud.com';
var org_id = '5952c31766d1b64b09de4d42';
var bind_user = 'testldap';
var password_field = 'solidfire';
var group = 'betty';
var user_name = 'testldap';
var user_password = 'solidfire';

console.log('ldap_server: ' + ldap_server);
console.log('org_id: ' + org_id);
console.log('bind_user: ' + bind_user);
console.log('group: ' + group);
console.log('user_name: ' + user_name);

var bind_dn = 'uid=' + bind_user + ',ou=Users,o=' + org_id +',dc=jumpcloud,dc=com';
console.log('bind_dn: ' + bind_dn);

// Create the client and bind to LDAP
var client = ldap.createClient({url: 'ldaps://' + ldap_server + ':636'});
client.bind(bind_dn, password_field, function(err) {
	assert.ifError(err);
});

// Search for the User.
var search_filter = '(&(objectClass=inetOrgPerson)(memberOf=cn=' + group + ',ou=Users,o=' + org_id + ',dc=jumpcloud,dc=com)(uid=' + user_name + '))';
console.log('search_filter: ' + search_filter);

var opts = {
  // filter: '(&(l=Seattle)(email=*@foo.com))',
  // filter: search_filter,
  filter: '(mail=' + user_name + '*.com)',
  scope: 'base',
  attributes: ['mail', 'uid']
};

var basedn = 'ou=Users,o=' + org_id + ',dc=jumpcloud,dc=com';
console.log('Search basedn: ' + basedn);

client.search(basedn, opts, function(err, res) {
  assert.ifError(err);

  res.on('searchEntry', function(entry) {
    console.log('entry: ' + JSON.stringify(entry.object));
  });
  res.on('searchReference', function(referral) {
    console.log('referral: ' + referral.uris.join());
  });
  res.on('error', function(err) {
    console.error('error: ' + err.message);
  });
  res.on('end', function(result) {
    console.log('status: ' + result.status);
  });
});
