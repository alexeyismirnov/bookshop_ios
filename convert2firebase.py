#!/usr/bin/python

import requests
import io, json
import lxml.html

images = {}
r = requests.get('http://www.orthodoxbookshop.asia/static/productimage.json')

for image in r.json():
    product = image["fields"]["product"]
    if not product in images:
        images[product] = image["fields"]["original"]

r = requests.get('http://www.orthodoxbookshop.asia/static/product.json')
output = {"index": {},
          "details": {}}

for book in  r.json():
    download_url = book["fields"]["download_url"]
    if download_url and "paidbooks" not in download_url:

        output["index"][book["pk"]] = { "title"         : book["fields"]["title_en"],
                                        "date_created"  : book["fields"]["date_created"],
                                        "image"         : "http://orthodoxbookshop.asia/media/" + images[book["pk"]]
        }

for book in  r.json():
    download_url = book["fields"]["download_url"]
    if download_url and "paidbooks" not in download_url:

        description = book["fields"]["description_en"].replace('\r\n', '')
        t = lxml.html.fromstring(description)

        output["details"][book["pk"]] = { "title"       : book["fields"]["title_en"],
                                        "description"   : t.text_content(),
                                        "date_created"  : book["fields"]["date_created"],
                                        "image"         : "http://orthodoxbookshop.asia/media/" + images[book["pk"]],
                                        "author"        : book["fields"]["author_en"],
                                        "translator"    : book["fields"]["translator"],
                                        "language"      : book["fields"]["text_script"],
                                        "pages"         : str(book["fields"]["num_pages"]),
                                        "publisher"     : book["fields"]["publisher"],
        }

with io.open('books.json', 'w', encoding='utf-8') as f:
  f.write(unicode(json.dumps(output, sort_keys=True, indent=4, separators=(',', ': '), ensure_ascii=False)))
