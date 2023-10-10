from ..build_commands_gallery import parse_commands_to_json, set_links, validate_commands_galleryMD
import subprocess
import os
import git

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
    #     base_ref = os.environ.get('GITHUB_BASE_REF')

    #     print(base_ref)
    #     diff_output = subprocess.check_output(['git', 'diff', base_ref], universal_newlines=True, stderr=subprocess.STDOUT)

    # except subprocess.CalledProcessError as e:
    #     print("Exception on process, rc=", e.returncode, "output=", e.output)
    repo = git.Repo('.')
    diff = repo.git.diff('refs/heads/main')
    # Check if the expected lines are present in the output
    expected_lines = [
        "diff --git a/PowerShell/JumpCloud Commands Gallery/commands.json b/PowerShell/JumpCloud Commands Gallery/commands.json",
        "+++ b/PowerShell/JumpCloud Commands Gallery/commands.json"
    ]

    for line in expected_lines:
        assert line in diff