from logging import exception
import os
from os.path import dirname
import re
import json
from urllib.parse import quote
from string import printable

def parse_commands_to_json ():
    # Get location of the script
    scriptPath = os.path.dirname(os.path.realpath(__file__))
    # rootPath is root of the directory
    rootPath = dirname(dirname(scriptPath))
    # CommandPath contains linux, mac, windows commands
    commandPath = os.path.join(rootPath, "PowerShell/JumpCloud Commands Gallery")
    pathParts = ['Linux Commands','Mac Commands', 'Windows Commands']

    def get_sections(s):
        for sec in s.split('\n#### '):
            yield sec if sec.startswith('#### ') else '#### '+sec

    cmds = []

    for part in pathParts:
        path = os.path.join(commandPath, part)
        for file in os.listdir(path):
            if file.endswith(".md") == False: continue

            filePath = os.path.join(path, file)

            cmd = {
                'name': '',
                'type': '',
                'command': '',
                'link': '',
                'description': ''
            }

            with open(filePath) as f:
                content = f.read();
                for i,sec in enumerate(get_sections(content)):
                    secTitleMatch = re.match(r"#### ([\_ \w]+|[\* \w]+)[\r\n]", sec)
                    if (secTitleMatch == None):
                        continue

                    secTitle = secTitleMatch.group(1).replace('*','').replace('_','')
                    secContent = sec.replace(f"#### {secTitle}", "").strip()
                    # if one of the content types are empty throw an error:
                    if (secContent == ''):
                        raise exception(secTitle + " in file: " + os.path.basename(filePath) + " was null or misformatted")
                    # compile each object
                    if (secTitle == 'Name'):
                        cmd['name'] = secContent
                    elif(secTitle == 'commandType'):
                        cmd['type'] = secContent.lower()
                    elif(secTitle == 'Command'):
                        scriptLang = re.search(r"```(\w+)", secContent)
                        # if script language is specified, strip from contents, else just strip the backticks
                        if (scriptLang):
                            cmd['command'] = secContent.replace('```' + (scriptLang.group(1)), '').strip()
                            cmd['command'] = cmd['command'].replace('```', '').strip()
                        else:
                            cmd['command'] = secContent.replace('```', '').strip()
                    elif(secTitle == 'Description'):
                        cmd['description'] = secContent
                    elif((secTitle == 'Import This Command')):
                        linkMatch = re.search(r"Import-JCCommand.+(https:.+)(\'|\")", secContent)
                        if (linkMatch != None):
                            cmd['link'] = linkMatch.group(1).strip()
                cmds.append(cmd)
    # validate that no null objects are left in json
    for item in cmds:
        for i in item.keys():
            if (item[i] == ''):
                raise exception("Missing value for " + i + " found in " + item['name'])

    # default sort by type then name for each object
    cmds.sort(key=lambda x: (x["type"], x["name"]))
    # write out the json object
    final = json.dumps(cmds, indent=2)

    f = open(os.path.join(commandPath,"commands.json"), 'w+')
    f.write(final)
    f.close()

def set_links():
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

def validate_commands_galleryMD ():
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


if __name__ == "__main__":
    parse_commands_to_json()
    set_links()
    validate_commands_galleryMD()
