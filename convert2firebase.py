#!/usr/bin/python

import requests
import io, json

r = requests.get('http://www.orthodoxbookshop.asia/static/product.json')
output = {"books": {}}

for book in  r.json():
    download_url = book["fields"]["download_url"]
    if download_url and "paidbooks" not in download_url:
#        print book["pk"]
#        print book["fields"]["title_en"]

        output["books"][book["pk"]] = { "title"         : book["fields"]["title_en"],
                                        "date_created"  : book["fields"]["date_created"]
        }

with io.open('books.json', 'w', encoding='utf-8') as f:
  f.write(unicode(json.dumps(output, sort_keys=True, indent=4, separators=(',', ': '), ensure_ascii=False)))

#        print book["fields"]["date_created"]
