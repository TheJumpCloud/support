
import subprocess
import os
import git
from os.path import dirname
def test_script_functions():
    # get script path
    scriptPath = os.path.dirname(os.path.realpath(__file__))
    # get parent directory
    scriptRootPath = dirname(scriptPath)
    # get the 'build_commands_gallery' file
    build_file =os.path.join(scriptRootPath, "build_commands_gallery.py")
    try:
        result = subprocess.run(['python3', build_file], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        assert result.returncode == 0, f"Script exited with an error code: {result.returncode}"
    except FileNotFoundError:
        assert False, f"Script file '{build_file}' not found"
    assert not result.stderr, f"Build script produced an error:\n{result.stderr}"

def test_diff():
    # get script path
    scriptPath = os.path.dirname(os.path.realpath(__file__))
    # rootPath is root of the directory
    rootPath = dirname(dirname(dirname(scriptPath)))
    # get the commands.json file
    cmd_filepath = os.path.join(rootPath, "PowerShell/JumpCloud Commands Gallery/commands.json")
    # set repo path:
    repo = git.Repo(rootPath)
    # Get current origin branch
    # Do diff between remote and current branch
    diff = repo.git.diff(cmd_filepath)
    assert '' == diff, "Changes detected in commands gallery. Please run `python .github/scripts/build_commands_gallery.py` locally and commit the changes."