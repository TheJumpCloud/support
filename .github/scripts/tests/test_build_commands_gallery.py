from ..build_commands_gallery import parse_commands_to_json, set_links, validate_commands_galleryMD
import subprocess



def test_script_functions():
    try:
        parse_commands_to_json()
        set_links()
        validate_commands_galleryMD()
    except Exception as e:
        assert False, f"An exception occurred: {e}"

#subprocess.check_output(['git', 'diff', '--name-only', currentBranch + '..' + master])
def test_diff():

    github_base_ref = os.environ.get("GITHUB_BASE_REF")
    git_diff_output = subprocess.check_output(['git', 'diff', github_base_ref], universal_newlines=True)

    # Check if the expected lines are present in the output
    expected_lines = [
        "diff --git a/PowerShell/JumpCloud Commands Gallery/commands.json b/PowerShell/JumpCloud Commands Gallery/commands.json",
        "+++ b/PowerShell/JumpCloud Commands Gallery/commands.json"
    ]

    for line in expected_lines:
        assert line in git_diff_output