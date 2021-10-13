from pytz import timezone
from dateutil import parser
import datetime
import json

# HTMLファイルの作成.
f = open('notion_update_histories.html', 'w', encoding='UTF-8')
f.write('<html><title>Notion Update Histories.</title><body>\n')
f.write('<h2>Notion Update Histories.</h2>\n')
f.write('<p>Last Updated: ' + str(datetime.datetime.now()) + '</p>')
f.write('<ul>\n')

# ファイル読み込み＆データ整形.
with open('./update-histories-notion-sorted.json', 'r') as json_file:
    json_list = list(json_file)

for json_str in json_list:
    result = json.loads(json_str)
    #print("result: {}".format(result))
    #print("----")
    #print(result["object"])
    #print(result["last_edited_time"])
    #print(result["id"])
    #print(result["page_title"])

    utc_string = str(result["last_edited_time"])
    jst_time = parser.parse(utc_string).astimezone(timezone('Asia/Tokyo'))
    #print(jst_time) 

    notion_url = "https://www.notion.so/" + result["id"].replace('-','')
    #print(notion_url)

    f.write('<li>' + str(jst_time) + ' - <a target="_blank" href="' + notion_url + '">' + str(result["page_title"]) + '</a>' + '</li>')


f.write('</ul>\n')
f.write('</body></html>')
f.close()
