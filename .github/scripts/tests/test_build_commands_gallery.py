from ..build_commands_gallery import parse_commands_to_json, set_links, validate_commands_galleryMD
import subprocess
import os
import git
from os.path import dirname
def test_script_functions():
    try:
        parse_commands_to_json()
        set_links()
        validate_commands_galleryMD()
    except Exception as e:
        assert False, f"An exception occurred: {e}"

#subprocess.check_output(['git', 'diff', '--name-only', currentBranch + '..' + master])
def test_diff():
    # try:
    #     base_ref = os.environ.get('github.base.ref')
    #     head_ref = os.environ.get('github.head_ref')

    #     print(base_ref)
    #     print(head_ref)
    #     diff = subprocess.check_output(['git', 'diff', 'origin/master', 'sa-3606-Update-CommandsJSON-CI'], universal_newlines=True, stderr=subprocess.STDOUT)

    # except subprocess.CalledProcessError as e:
    #     print("Exception on process, rc=", e.returncode, "output=", e.output)
    scriptPath = os.path.dirname(os.path.realpath(__file__))
    # rootPath is root of the directory
    rootPath = dirname(dirname(dirname(scriptPath)))
    print(rootPath)
    repo = git.Repo(rootPath)
    diff = repo.git.diff()
    #Check if the expected lines are present in the output
    expected_lines = [
        "diff --git a/PowerShell/JumpCloud Commands Gallery/commands.json b/PowerShell/JumpCloud Commands Gallery/commands.json",
        "+++ b/PowerShell/JumpCloud Commands Gallery/commands.json"
    ]

    for line in expected_lines:
        assert line in diff