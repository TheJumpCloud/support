#!/usr/bin/env python

'''
tag_generator.py
Adapted by Long Qians script: https://longqian.me/2017/02/09/github-jekyll-tag/
This script creates tags for your Jekyll blog hosted by Github page.
No plugins required.
'''

import glob
import os

post_dir = '../_posts/'
draft_dir = '../_drafts/'
tag_dir = '../tag/'

filenames = glob.glob(post_dir + '*md')
filenames = filenames + glob.glob(draft_dir + '*md')

total_tags = []
for filename in filenames:
    f = open(filename, 'r', encoding='utf8')
    crawl = False
    for line in f:
        if crawl:
            current_tags = line.strip().split(':') 
            if current_tags[0] == 'tags':
                if (current_tags[1].strip().startswith('[')):
                    clean_tag = ''.join(c for c in current_tags[1] if c not in '[]')
                    list_tags = map(str.strip, clean_tag.split(','))
                    total_tags.extend(list_tags)
                else: 
                    list_tags = map(str.strip, current_tags[1].strip().split())
                    total_tags.extend(list_tags)
                crawl = False
                break
        if line.strip() == '---':
            if not crawl:
                crawl = True
            else:
                crawl = False
                break
    f.close()
total_tags = set(total_tags)

old_tags = glob.glob(tag_dir + '*.md')
for tag in old_tags:
    os.remove(tag)
if not os.path.exists(tag_dir):
    os.makedirs(tag_dir)

for tag in total_tags:
    tag_filename = tag_dir + tag.replace(' ', '_') + '.md'
    f = open(tag_filename, 'a')
    write_str = '---\nlayout: tagpage\ntitle: \"Tag: ' + tag + '\"\ntag: ' + tag + '\nrobots: noindex\n---\n'
    f.write(write_str)
    f.close()
print("Tags generated, count", total_tags.__len__())