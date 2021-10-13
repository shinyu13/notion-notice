#/bin/sh

NOTION_API_TOKEN='secret_Ay9RENPjSQvzYgk2PBEWnhCOP0kubmxe7JkkKXWB3gi'


#######################################################
## ワークスペース直下のページ(最上位階層ページ).
#######################################################
curl  -X POST 'https://api.notion.com/v1/search' \
  -H "Notion-Version: 2021-05-13" \
  -H 'Authorization: Bearer '$NOTION_API_TOKEN'' \
  -H 'Content-Type: application/json' \
  --data '{
    "sort":{
      "direction":"descending",
      "timestamp":"last_edited_time"
    }
  }' | \
jq -c '.results[] | select (.parent.type == "workspace")' | \
jq -c '{ object: .object, last_edited_time: .last_edited_time, id: .id, page_title: .properties.title.title[0].plain_text  } ' > update-histories-notion.json


#######################################################
## ワークスペース直下のページ(最上位階層以外のページ).
#######################################################
curl  -X POST 'https://api.notion.com/v1/search' \
  -H "Notion-Version: 2021-05-13" \
  -H 'Authorization: Bearer '$NOTION_API_TOKEN'' \
  -H 'Content-Type: application/json' \
  --data '{
    "sort":{
      "direction":"descending",
      "timestamp":"last_edited_time"
    }
  }' |\
jq -c '.results[] | select (.object == "page" and .parent.type == "page_id")' | \
jq -c '{ object: .object, last_edited_time: .last_edited_time, id: .id, page_title: .properties.title.title[0].plain_text } ' >> update-histories-notion.json


#######################################################
## ワークスペース直下のページ(テーブルページ).
#######################################################
curl  -X POST 'https://api.notion.com/v1/search' \
  -H "Notion-Version: 2021-05-13" \
  -H 'Authorization: Bearer '$NOTION_API_TOKEN'' \
  -H 'Content-Type: application/json' \
  --data '{
    "sort":{
      "direction":"descending",
      "timestamp":"last_edited_time"
    }
  }' | \
jq -c '.results[] | select (.object == "database")' | \
jq -c '{ object: .object, last_edited_time: .last_edited_time, id: .id, page_title: .title[0].plain_text } ' >> update-histories-notion.json


#######################################################
## ワークスペース配下にあるテーブル関連ページ(議事録).
#######################################################
curl  -X POST 'https://api.notion.com/v1/search' \
  -H "Notion-Version: 2021-05-13" \
  -H 'Authorization: Bearer '$NOTION_API_TOKEN'' \
  -H 'Content-Type: application/json' \
  --data '{
    "sort":{
      "direction":"descending",
      "timestamp":"last_edited_time"
    }
  }' |\
jq -c '. | select (.object == "list")' | \
jq '.results[] | select (.object == "page" and .properties["ステータス"] !=null)' | \
jq -c '{ object: .object, last_edited_time: .last_edited_time, id: .id, page_title: .properties["ステータス"].title[].plain_text } ' >> update-histories-notion.json


#######################################################
## ワークスペース配下にあるテーブル関連ページ(タイトル).
#######################################################
curl  -X POST 'https://api.notion.com/v1/search' \
  -H "Notion-Version: 2021-05-13" \
  -H 'Authorization: Bearer '$NOTION_API_TOKEN'' \
  -H 'Content-Type: application/json' \
  --data '{
    "sort":{
      "direction":"descending",
      "timestamp":"last_edited_time"
    }
  }' |\
jq -c '. | select (.object == "list")' | \
jq '.results[] | select (.object == "page" and .properties["タイトル"] !=null)' | \
jq -c '{ object: .object, last_edited_time: .last_edited_time, id: .id, page_title: .properties["タイトル"].title[].plain_text } ' >> update-histories-notion.json


#######################################################
## マージした履歴情報を更新日時で降順ソート.
#######################################################
jq -c '. | sort_by(.last_edited_time) | reverse | .[]' --slurp update-histories-notion.json > update-histories-notion-sorted.json


#######################################################
## ソート済みjsonファイルを使ってPythonでHTMLを整形.
#######################################################
python read-notion-json.py
