## 1.1

#### RELEASE DATE

September 19, 2019

#### RELEASE NOTES

The jumpcloud_bootstrap_template.sh has been updated with logic to delete the `DECRYPT_USER` and the `ENROLLMENT_USER` accounts from the macOS system. This logic has been added to the end of the jumpcloud_bootstrap_template.sh.Removing the `ENROLLMENT_USER` is an important step as this user has a valid Secure Token and while they are disabled via the JumpCloud agent (In Version 1.0) their account will be present at the macOS FileVault decryption screen. By removing this account from the system the Secure Token is invalided and the account does not display at the FileVault decrypt screen.
