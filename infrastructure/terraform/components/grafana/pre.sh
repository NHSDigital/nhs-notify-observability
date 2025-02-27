#!/bin/bash
# ==============================================================================
# Script to assign Grafana admin group ID for the AWS Observability admins
#
# This script:
# - Determines the appropriate group name based on the `group` variable.
# - Fetches the IdentityStore ID for AWS SSO using the AWS CLI.
# - Retrieves the Group ID from AWS IdentityStore for the specified group name.
# - Exports the group ID as a Terraform variable for delegated Grafana admins.
#
# Prerequisites:
# - AWS CLI configured with appropriate IAM permissions to interact with AWS SSO and IdentityStore.
# - `jq` command-line tool for parsing JSON responses.
# ==============================================================================

# Default group name
group_name="AWS-NHSNotify-Observability-Admins"

# Initialize the 'group' variable (if not set externally)
group="${group:-}"

# Check if the group variable is set and contains "prod" (case-insensitive)
if [[ -n "${group}" && "${group}" =~ "prod" ]]; then
  group_name="AWS-NHSNotify-Observability-ProdAdmins"
fi

# Fetch IdentityStoreID
identity_store_id=$(aws sso-admin list-instances | jq -r '.Instances[0].IdentityStoreId')

# Ensure identity_store_id is set
if [[ -z "${identity_store_id}" ]]; then
  echo "Error: IdentityStoreId is empty or not found."
  exit 1
fi

# Fetch Group ID from IdentityStore
group_id=$(aws identitystore get-group-id \
  --identity-store-id "${identity_store_id}" \
  --alternate-identifier "{\"UniqueAttribute\":{\"AttributePath\":\"displayName\",\"AttributeValue\":\"${group_name}\"}}" \
  | jq -r '.GroupId')

# Ensure group_id is set
if [[ -z "${group_id}" ]]; then
  echo "Error: group_id is empty or not found."
  exit 1
else
  export TF_VAR_delegated_grafana_admin_group_ids="[\"${group_id}\"]"
fi
