
'''
This test suite checks the existance of required variables
to run the prestage user enrollment script.

Python3.x is required to run this test suite. Change the variables
for the prestage user enrollment script and postinstall script below if
using this test suite outside of the context of the github repository.

to run the tests: 
open terminal, cd into this directory and run:
python3 test_runner.py

The test suite should verify that the required variables are set correctly.
Note. This test suite does not check the variables against your JumpCloud 
tenant for accuracy.
'''
import unittest

# import test modules
import pue_verify
import postinstall_verify

# set the files for testing
pue_verify.text_PUE.script = "../jumpcloud_bootstrap_template.sh"
postinstall_verify.text_POST.script = "../postinstall.sh"

# initialize test suite
loader = unittest.TestLoader()
suite = unittest.TestSuite()

# add tests to run
suite.addTests(loader.loadTestsFromModule(pue_verify))
suite.addTests(loader.loadTestsFromModule(postinstall_verify))

# initialize a runner, pass it your suite and run
runner = unittest.TextTestRunner(verbosity=2)
result = runner.run(suite)
