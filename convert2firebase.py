#!/usr/bin/python

import requests
import io, json
import lxml.html

# xargs -n 1 curl -O < urls.txt

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

        print "http://orthodoxbookshop.asia/media/" + images[book["pk"]]

        output["index"][book["pk"]] = { "title_en"         : book["fields"]["title_en"],
                                        "title_ru"         : book["fields"]["title_ru"],
                                        "title_zh_cn"      : book["fields"]["title_zh_cn"],
                                        "title_zh_hk"      : book["fields"]["title_zh_hk"],
                                        "download_url"     : book["fields"]["download_url"],
                                        "epub_url"         : book["fields"]["epub_url"],
                                        "date_created"  : book["fields"]["pub_date"],
                                        "image"         : "http://orthodoxbookshop.asia/media/" + images[book["pk"]]
        }


for book in  r.json():
    download_url = book["fields"]["download_url"]
    if download_url and "paidbooks" not in download_url:

        description_en = book["fields"]["description_en"].replace('\r\n', '')
        description_ru = book["fields"]["description_ru"].replace('\r\n', '')
        #if "description_ru" in book["fields"] else ""
        description_zh_cn = book["fields"]["description_zh_cn"].replace('\r\n', '')
        description_zh_hk = book["fields"]["description_zh_hk"].replace('\r\n', '')

        output["details"][book["pk"]] = {
                                        "title_en"          : book["fields"]["title_en"],
                                        "title_ru"          : book["fields"]["title_ru"],
                                        "title_zh_cn"       : book["fields"]["title_zh_cn"],
                                        "title_zh_hk"       : book["fields"]["title_zh_hk"],
                                "description_en"    : lxml.html.fromstring(description_en).text_content(),
                                "description_ru"    : lxml.html.fromstring(description_ru).text_content() if len(description_ru) > 0 else "",
                                "description_zh_cn" : lxml.html.fromstring(description_zh_cn).text_content() if len(description_zh_cn) > 0 else "",
                                "description_zh_hk" : lxml.html.fromstring(description_zh_hk).text_content() if len(description_zh_hk) > 0 else "",
                                        "date_created"      : book["fields"]["pub_date"],
                                        "image"             : "http://orthodoxbookshop.asia/media/" + images[book["pk"]],
                                        "author_en"         : book["fields"]["author_en"],
                                        "author_ru"         : book["fields"]["author_ru"],
                                        "author_zh_cn"      : book["fields"]["author_zh_cn"],
                                        "author_zh_hk"      : book["fields"]["author_zh_hk"],
                                        "translator"       : book["fields"]["translator"],
                                        "language"         : book["fields"]["text_script"],
                                        "pages"            : str(book["fields"]["num_pages"]),
                                        "publisher"        : book["fields"]["publisher"],
        }

with io.open('books.json', 'w', encoding='utf-8') as f:
  f.write(unicode(json.dumps(output, sort_keys=True, indent=4, separators=(',', ': '), ensure_ascii=False)))
