#!/bin/bash

# Fetch workspace ID from SSM Parameter Store
workspace_id=$(aws ssm get-parameter --with-decryption --name nhs-notify-${2}-acct-grafana-workspace-id | jq -r '.Parameter.Value')

if [[ -z "$workspace_id" ]]; then
  echo "Error: workspace_id is empty or null"
  exit 1
fi

# Define service account name
svc_account_name="terraformdeploy"

# Fetch existing service account name
existing_svc_name=$(aws grafana list-workspace-service-accounts --workspace-id "${workspace_id}" | jq -r '.serviceAccounts[0].name')

# Check if service account exists, if not create it
if [[ "${existing_svc_name}" != "${svc_account_name}" ]]; then
  echo "Creating service account ${svc_account_name}..."
  aws grafana create-workspace-service-account --grafana-role ADMIN --name "${svc_account_name}" --workspace-id "${workspace_id}"
else
  echo "Service account ${svc_account_name} already exists."
fi

# Fetch service account ID
svc_account_id=$(aws grafana list-workspace-service-accounts --workspace-id "${workspace_id}" | jq -r '.serviceAccounts[0].id')

if [[ -z "$svc_account_id" ]]; then
  echo "Error: svc_account_id is empty or null"
  exit 1
fi

#Check if token exists first and if it does, delete it as we can't retrieve the key by any other describe/get call
existing_token_id=$(aws grafana list-workspace-service-account-tokens --service-account-id "${svc_account_id}" --workspace-id "${workspace_id}" | jq -r '.serviceAccountTokens[0].id')

if [[ -n "$existing_token_id" ]]; then
  aws grafana delete-workspace-service-account-token --service-account-id "${svc_account_id}" --workspace-id "${workspace_id}" --token-id "$existing_token_id"
  echo "Deleted existing token with ID: $existing_token_id"
else
  echo "No existing token found to delete."
fi

# Now, create a new token
echo "Creating new token for service account ${svc_account_name}..."
token=$(aws grafana create-workspace-service-account-token --name terraformdeploytoken --seconds-to-live 3600 --service-account-id "${svc_account_id}" --workspace-id "${workspace_id}" | jq '.serviceAccountToken.key' | sed 's/^"\(.*\)"$/\1/')

# Export the new token as an environment variable
export TF_VAR_service_account_token="${token}"
