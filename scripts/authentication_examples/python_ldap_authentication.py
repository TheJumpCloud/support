#!/usr/bin/env python

"""
Authenticate against JumpCloud LDAP

"""
import sys
import enum
import json
import pprint
import getpass
import argparse

from json import JSONDecodeError

import ldap


class LdapAuthenticationError(Exception):
    pass


class ConfigEnums(enum.Enum):
    LdapServer = "ldap_server"
    BindDn = "binddn"
    BaseDn = "basedn"
    SearchFilter = "search_filter"
    SearchAttribute = "search_attribute"


def parse_config():
    """ Parse the default JSON config file

    :param config_file: str Path to JSON config file.
    :returns: JSON
    """
    try:
        with open(CONFIG_FILE) as fp:
            return json.load(fp)

    except IOError as io_error:
        raise LdapAuthenticationError("CRITICAL: Problem with JSON config file {}:{}"
                                      .format(CONFIG_FILE, io_error))

    except JSONDecodeError as jd_error:
        raise LdapAuthenticationError("CRITICAL: Problem with json in {} : {}".format(CONFIG_FILE, jd_error))


def main():
    """ The main script function. """
    config_data = parse_config()

    ldap_server = config_data.get('ldap_server')
    print("LDAP Server: {}".format(ldap_server))

    binddn = config_data.get('binddn').format(bind_user, org_id)
    print("Bind DN: {}".format(binddn))

    ldap_server = "ldaps://" + config_data.get(ConfigEnums.LdapServer.value) + ":636"

    ldap_conn = ldap.initialize(ldap_server)

    # Bind to the LDAP Server with the Bind DN and Bind User password.
    try:
        ldap_conn.protocol_version = ldap.VERSION3
        ldap_conn.simple_bind_s(binddn, password_field)

    except ldap.INVALID_CREDENTIALS as invalid:
        raise LdapAuthenticationError("CRITICAL: Invalid username, password or Org Id.")

    except ldap.LDAPError as ldap_error:
        raise LdapAuthenticationError("CRITICAL: Problem with LDAP connection or Bind DN: {}".format(ldap_error))

    # -----
    # First example of sSearch for the supplied User in the supplied User Group.
    # -----
    search_scope = ldap.SCOPE_SUBTREE
    print("SearchScope: {}".format(search_scope))

    search_filter = config_data.get(ConfigEnums.SearchFilter.value).format(group, org_id, user_name)
    print("SearchFilter: {}".format(search_filter))

    search_attribute = config_data.get(ConfigEnums.SearchAttribute.value)
    print("SearchAttribute: {}".format(search_attribute))

    base_dn = config_data.get(ConfigEnums.BaseDn.value).format(org_id)
    print("BaseDn: {}".format(base_dn))

    try:
        ldap_result_id = ldap_conn.search(base_dn, search_scope, search_filter, search_attribute)
    except ldap.LDAPError as lde:
        raise LdapAuthenticationError("CRITICAL: Problem searching: {}".format(lde))

    else:
        result_set = []

        while True:
            result_type, result_data = ldap_conn.result(ldap_result_id, 0)
            if not result_data:
                break
            else:
                # if you are expecting multiple results you can append them
                # otherwise you can just wait for the initial result and then break out.
                if result_type == ldap.RES_SEARCH_ENTRY:
                    result_set.append(result_data)

        print("\nSearch example 1 result_set: ")
        pprint.pprint(result_set)

    finally:
        ldap_conn.unbind_s()

    # -----
    # Second example of search for the supplied User in the supplied User
    # Group.
    # 1. Not using ldaps
    # 2. Using the User DN format provided by the LDAP server.
    # -----
    if not result_set:
        raise LdapAuthenticationError("Search result set is empty, search user {} is not Authorized!"
                                      .format(bind_user))

    ldap_server = config_data.get(ConfigEnums.LdapServer.value)

    search_filter = "uid={}".format(user_name)
    user_dn = "uid={},ou=Users,o={},dc=jumpcloud,dc=com".format(user_name, org_id)

    # Adjust this base_dn to your Base DN for searching.
    base_dn = "ou=Users,o={},dc=jumpcloud,dc=com".format(org_id)

    try:
        ldap_conn = ldap.open(ldap_server)
        ldap_conn.bind_s(user_dn, password_field)
        result = ldap_conn.search_s(base_dn, search_scope, search_filter)

    except ldap.LDAPError as lde:
        raise LdapAuthenticationError("CRITICAL: Probably incorrect password - {}".format(lde))

    else:
        # Return all of the User data results.
        print("\nSearch example 2 results:")
        pprint.pprint(result)

    finally:
        ldap_conn.unbind_s()


if __name__ == "__main__":

    CONFIG_FILE = 'config.json'

    p = argparse.ArgumentParser(description=__doc__)
    _ = p.parse_args()

    # Get some information from the user.
    # org_id = '5952c31766d1b64b09de4d42'
    # bind_user = 'testldap'
    # password_field = 'solidfire'
    # group = 'betty'
    # user_name = 'testldap'

    print("\n")
    org_id = input("Please enter your Organization ID: ")
    bind_user = input("Please enter your search User: ")
    password_field = getpass.getpass('Search User Password:')
    group = input("Please enter your Group: ")
    user_name = input("Please enter your username: ")
    print("\n")

    if not password_field:
        print("Need a password!!")
        sys.exit(-1)

    try:
        main()

    except LdapAuthenticationError as lae:
        print("{}".format(lae))
        sys.exit(-1)

    print("Success!!")
