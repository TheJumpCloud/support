import os
import re
import json

rootPath = "./"
# rootPath = "./PowerShell/JumpCloud Commands Gallery"
pathParts = ['Linux Commands','Mac Commands', 'Windows Commands']

def get_sections(s):
    for sec in s.split('\n#### '):
        yield sec if sec.startswith('#### ') else '#### '+sec

cmds = []

for part in pathParts:
    path = os.path.join(rootPath, part)
    for file in os.listdir(path):
        if file.endswith(".md") == False: continue

        filePath = os.path.join(path, file)

        cmd = {
            'name': '',
            'type': '',
            'script': '',
            'link': '',
            'description': ''
        }

        with open(filePath) as f:
            content = f.read();
            for i,sec in enumerate(get_sections(content)):
                secTitleMatch = re.match(r"#### ([\* \w]+)[\r\n]", sec)
                if (secTitleMatch == None): continue;

                secTitle = secTitleMatch.group(1).replace('*','')
                secContent = sec.replace(f"#### {secTitle}", "").strip()

                if (secTitle == 'Name'):
                    cmd['name'] = secContent
                elif(secTitle == 'commandType'):
                    cmd['type'] = secContent
                elif(secTitle == 'Command'):
                    cmd['script'] = secContent
                elif(secTitle == 'Description'):
                    cmd['description'] = secContent
                elif(secTitle == 'Import This Command'):
                    linkMatch = re.search(r"Import-JCCommand.+(https:.+)\'", secContent)
                    if (linkMatch != None):
                        cmd['link'] = linkMatch.group(1).strip()

            cmds.append(cmd)

final = json.dumps(cmds, indent=2)

f = open('./commands.json', 'w+')
f.write(final)
f.close()