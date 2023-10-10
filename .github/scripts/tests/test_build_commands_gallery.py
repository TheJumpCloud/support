import json
import os
# import git
import re
#from git
from tempfile import TemporaryDirectory
#Import the functions from the script
from ..build_commands_gallery import parse_commands_to_json, set_links, validate_commands_galleryMD
import subprocess
#import pytest



# Pull master then do pytest difference
def test_script_functions():
    # You can use temporary directories and files for testing if needed.
    # For simplicity, we'll just use the current directory for this example.

    # Capture the standard output to check for exceptions.
    try:
        parse_commands_to_json()
        set_links()
        validate_commands_galleryMD()
    except Exception as e:
        assert False, f"An exception occurred: {e}"

#subprocess.check_output(['git', 'diff', '--name-only', currentBranch + '..' + master])
def test_diff():

    # git_diff_output = subprocess.check_output(['git', 'diff', 'master'], universal_newlines=True)
    # grep_output = subprocess.check_output(['grep', 'b/PowerShell/JumpCloud Commands Gallery/commands.json'], input=git_diff_output, universal_newlines=True)
    # # Print the grep output
    # print(grep_output)
    # # Do assertions on the grep_output has to have b/PowerShell/JumpCloud Commands Gallery/commands.json
    # assert grep_output == 'b/PowerShell/JumpCloud Commands Gallery/commands.json\n'
    # Run the git diff command
    git_diff_output = subprocess.check_output(['git', 'diff', 'master'], universal_newlines=True)

    # Check if the expected lines are present in the output
    expected_lines = [
        "diff --git a/PowerShell/JumpCloud Commands Gallery/commands.json b/PowerShell/JumpCloud Commands Gallery/commands.json",
        "+++ b/PowerShell/JumpCloud Commands Gallery/commands.json"
    ]

    for line in expected_lines:
        assert line in git_diff_output