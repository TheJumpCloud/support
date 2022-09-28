from logging import exception
import os
from os.path import dirname
from string import printable

# Get location of the script
scriptPath = os.path.dirname(os.path.realpath(__file__))
# rootPath is root of the directory
rootPath = dirname(dirname(scriptPath))
# CommandPath contains linux, mac, windows commands
commandPath = os.path.join(rootPath, "PowerShell/JumpCloud Commands Gallery")
pathParts = ['Linux Commands','Mac Commands', 'Windows Commands']

for part in pathParts:
    path = os.path.join(commandPath, part)
    for file in os.listdir(path):
        if file.endswith(".md") == False: continue

        filePath = os.path.join(path, file)

        lstOfItems = ["#### Name","#### commandType","#### Command","#### Description","#### *Import This Command*"]

        with open(filePath) as f:
            content = f.read();
            
            # Iterate through the list of headers then find it in the contents of the .md file
            for i in lstOfItems:
                if("{}".format(i) in content ):
                    print("Validated: "+ i +" in " + file)
                elif("#### _Import This Command_" in content):
                    print("Validated: "+ file)
                else:
                    raise Exception("Header {} was not in the content".format(i) + file)
                    
               