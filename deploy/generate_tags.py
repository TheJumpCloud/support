#!/usr/bin/env python

'''
tag_generator.py
Adapted by Long Qians script: https://longqian.me/2017/02/09/github-jekyll-tag/
This script creates tags for your Jekyll blog hosted by Github page.
No plugins required.
'''

import glob
import os

post_dir = '_posts/'
draft_dir = '_drafts/'
tag_dir = 'tag/'

filenames = glob.glob(post_dir + '*md')
#print(filenames)
filenames = filenames + glob.glob(draft_dir + '*md')
#print(filenames)

total_tags = []
for filename in filenames:
    f = open(filename, 'r', encoding='utf8')
    crawl = False
    tag_lines_coming = False
    for line in f:
        current_line = line.strip()
        if crawl:
            if current_line == 'tags:':
                tag_lines_coming = True
                continue
            
        # If --- delimiter is found, start crawling.
        if current_line == '---':
            if not crawl:
                crawl = True
            else:
                crawl = False
                break
            
        # If we are in the actual tag lines (that is, tag_lines_coming is
        # True and we aren't in the tags: line), extract them.
        if tag_lines_coming and (current_line != 'tags:'):
            total_tags.append(current_line.strip('- '))
    f.close()
    
    # Make tags unique in a set.
    # total_tags = set(total_tags)
total_tags = set(total_tags)

old_tags = glob.glob(tag_dir + '*.md')
for tag in old_tags:
    os.remove(tag)
if not os.path.exists(tag_dir):
    os.makedirs(tag_dir)

for tag in total_tags:
    tag_filename = tag_dir + tag.replace(' ', '_') + '.md'
    f = open(tag_filename, 'a')
    write_str = '---\nlayout: tagpage\ntitle: \"Tag: ' + tag + '\"\ntag: ' + tag + '\ndescription: \"Script examples related to: ' + tag + '\"\nrobots: noindex\n---\n'
    f.write(write_str)
    f.close()
print("Tags generated, count", total_tags.__len__())