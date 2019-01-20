TABLE_NAME="notifications"
KEY="id"
aws dynamodb scan --table-name $TABLE_NAME --attributes-to-get "$KEY" \
  --query "Items[].$KEY.S" --output text | \
  tr "\t" "\n" | \
  xargs -t -I keyvalue aws dynamodb delete-item --table-name $TABLE_NAME \
  --key "{\"$KEY\": {\"S\": \"keyvalue\"}}"