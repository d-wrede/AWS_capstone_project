#!/bin/bash

# Replace these variables with your actual values
rest_api_id=$(aws apigateway get-rest-apis --query 'items[0].id' --output text)
resource_id=$(aws apigateway get-resources --rest-api-id $rest_api_id --query 'items[?path==`/message`].id' --output text)
usage_plan_id=$(aws apigateway get-usage-plans --query 'items[0].id' --output text)
api_key=$(aws apigateway get-usage-plan-keys --usage-plan-id $usage_plan_id --query 'items[0].id' --output text)


# Run commands and save output to results.txt
{
  echo "GET REST APIs:"
  aws apigateway get-rest-apis

  echo -e "\nGET RESOURCES:"
  aws apigateway get-resources --rest-api-id $rest_api_id

  echo -e "\nGET POST METHOD:"
  aws apigateway get-method --rest-api-id $rest_api_id --resource-id $resource_id --http-method POST

  echo -e "\nGET OPTIONS METHOD:"
  aws apigateway get-method --rest-api-id $rest_api_id --resource-id $resource_id --http-method OPTIONS

  echo -e "\nGET USAGE PLANS:"
  aws apigateway get-usage-plans

  echo -e "\nGET USAGE PLAN KEYS:"
  aws apigateway get-usage-plan-keys --usage-plan-id $usage_plan_id

  echo -e "\nGET API KEY:"
  aws apigateway get-api-key --api-key $api_key --include-value

} > results.txt
