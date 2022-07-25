import os
from os.path import dirname
import re
from urllib.parse import quote


# Base URL:
baseURL='https://github.com/TheJumpCloud/support/blob/master/'
GalleryURLpart='PowerShell/JumpCloud Commands Gallery/'
# Get location of the script
scriptPath = os.path.dirname(os.path.realpath(__file__))
# rootPath is root of the directory
rootPath = dirname(dirname(scriptPath))
# CommandPath contains linux, mac, windows commands
commandPath = os.path.join(rootPath, "PowerShell/JumpCloud Commands Gallery")
pathParts = ['Linux Commands','Mac Commands', 'Windows Commands']

cmds = []

for part in pathParts:
    path = os.path.join(commandPath, part)
    for file in os.listdir(path):
        if file.endswith(".md") == False: continue

        filePath = os.path.join(path, file)
        with open(filePath) as f:
            content = f.read();
            # print (baseURL + quote(GalleryURLpart) +  quote(part) + "/" +  quote(os.path.basename(filePath)))
            new_content = re.sub('(?:```\w+\n|```\n)Import-JCCommand -URL .*$\n```', '```\nImport-JCCommand -URL "' + baseURL + quote(GalleryURLpart) +  quote(part) + "/" +  quote(os.path.basename(filePath)) + '"' + '\n```', content, flags=re.MULTILINE)
        with open(filePath, 'w') as file:
            file.write(new_content)
