#!/bin/bash

# Replace these variables with your actual values
rest_api_id=$(aws apigateway get-rest-apis --query 'items[0].id' --output text)
# resource_id1=$(aws apigateway get-resources --rest-api-id $rest_api_id --query 'items[?path==`/contact`].id' --output text)
# resource_id2=$(aws apigateway get-resources --rest-api-id $rest_api_id --query 'items[?path==`/chat`].id' --output text)
resource_id1=$(aws apigateway get-resources --rest-api-id $rest_api_id --query 'items[0].id' --output text)
echo ${resource_id1}
resource_id2=$(aws apigateway get-resources --rest-api-id $rest_api_id --query 'items[2].id' --output text)
echo ${resource_id2}
usage_plan_id=$(aws apigateway get-usage-plans --query 'items[0].id' --output text)
api_key=$(aws apigateway get-usage-plan-keys --usage-plan-id $usage_plan_id --query 'items[0].id' --output text)

# remove old results.txt file
rm results.txt
echo "old results file removed"

# Run commands and save output to results.txt
{
  echo "GET REST APIs:"
  aws apigateway get-rest-apis

  echo -e "\nGET CORS:"
  aws apigateway get-cors --rest-api-id $rest_api_id

  echo -e "\nGET RESOURCES:"
  aws apigateway get-resources --rest-api-id $rest_api_id

  echo -e "\nGET METHODS FOR RESOURCE 1:"
  # echo -e "\nGET METHOD:"
  # aws apigateway get-method --rest-api-id $rest_api_id --resource-id $resource_id1 --http-method GET
  echo -e "\nPOST METHOD:"
  aws apigateway get-method --rest-api-id $rest_api_id --resource-id $resource_id1 --http-method POST

  echo -e "\nPOST CORS:"
  aws apigateway get-method-response --rest-api-id $rest_api_id --resource-id $resource_id1 --http-method POST --status-code 200


  echo -e "\nGET METHODS FOR RESOURCE 2:"
  # echo -e "\nGET METHOD:"
  # aws apigateway get-method --rest-api-id $rest_api_id --resource-id $resource_id2 --http-method GET
  echo -e "\nPOST METHOD:"
  aws apigateway get-method --rest-api-id $rest_api_id --resource-id $resource_id2 --http-method POST

  echo -e "\nPOST CORS:"
  aws apigateway get-method-response --rest-api-id $rest_api_id --resource-id $resource_id2 --http-method POST --status-code 200

} > results.txt

  # echo -e "\nGET OPTIONS METHOD:"
  # aws apigateway get-method --rest-api-id $rest_api_id --resource-id $resource_id --http-method OPTIONS

  # echo -e "\nGET USAGE PLANS:"
  # aws apigateway get-usage-plans

  # echo -e "\nGET USAGE PLAN KEYS:"
  # aws apigateway get-usage-plan-keys --usage-plan-id $usage_plan_id

  #echo -e "\nGET API KEY:"
  #aws apigateway get-api-key --api-key $api_key --include-value


