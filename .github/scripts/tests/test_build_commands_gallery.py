import subprocess
import os

def test_generate_json_and_git_diff():
    # Step 2: Run the Python script to generate the .json file
    subprocess.run(["python", "your_script.py"])

    # Step 3: Add and commit changes
    subprocess.run(["git", "add", "."])
    subprocess.run(["git", "commit", "-m", "Generated .json file"])

    # Step 4: Switch to the master branch
    subprocess.run(["git", "checkout", "master"])

    # Step 5: Pull the latest changes from the master branch
    subprocess.run(["git", "pull", "origin", "master"])

    # Step 6: Run git diff to compare
    diff_output = subprocess.check_output(["git", "diff", "master"])
    assert diff_output == b'', "There are differences between branches"

if __name__ == "__main__":
    test_generate_json_and_git_diff()