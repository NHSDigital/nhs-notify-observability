#!/bin/bash
# ==============================================================================
# Script to assign Grafana group IDs for AWS Observability roles
#
# This script:
# - Determines the appropriate group names for admins, viewers, and editors.
# - Fetches the IdentityStore ID for AWS SSO using the AWS CLI.
# - Retrieves the Group IDs from AWS IdentityStore for the specified group names.
# - Exports the group IDs as Terraform variables for delegated Grafana roles.
#
# Prerequisites:
# - AWS CLI configured with appropriate IAM permissions to interact with AWS SSO and IdentityStore.
# - `jq` command-line tool for parsing JSON responses.
#
# Notes:
# run the script like DEBUG=1 pre.sh for additional information
# ==============================================================================

# Default group names
admin_group_name="AWS-NHSNotify-SharedInfra-GrafanaAdmin"
viewer_group_name="AWS-NHSNotify-SharedInfra-GrafanaViewer"
editor_group_name="AWS-NHSNotify-SharedInfra-GrafanaEditor"

# Debug print function
debug() {
  if [[ "${DEBUG}" == "1" ]]; then
    echo "[DEBUG] $1"
  fi
}

# Function to fetch group ID by group name
get_group_id() {
  local group_name="$1"
  debug "Fetching group ID for group: ${group_name}"
  aws identitystore get-group-id \
    --identity-store-id "${identity_store_id}" \
    --alternate-identifier "{\"UniqueAttribute\":{\"AttributePath\":\"displayName\",\"AttributeValue\":\"${group_name}\"}}" \
    | jq -r '.GroupId'
}

# Initialize the 'group' variable (if not set externally from tfvars)
group="${group:-}"
debug "Group variable is set to: ${group}"

# Adjust group names for prod if needed
if [[ -n "${group}" && "${group}" =~ "observability-prod" ]]; then
  admin_group_name="AWS-NHSNotify-SharedInfra-ProdGrafanaAdmin"
  debug "Admin group name: ${admin_group_name}"

  viewer_group_name="AWS-NHSNotify-SharedInfra-ProdGrafanaViewer"
  debug "Viewer group name: ${viewer_group_name}"

  editor_group_name="AWS-NHSNotify-SharedInfra-ProdGrafanaEditor"
  debug "Editor group name: ${editor_group_name}"
fi

# Fetch IdentityStoreID
identity_store_id=$(aws sso-admin list-instances | jq -r '.Instances[0].IdentityStoreId')
debug "Fetched IdentityStoreId: ${identity_store_id}"

# Ensure identity_store_id is set
if [[ -z "${identity_store_id}" ]]; then
  echo "Error: IdentityStoreId is empty or not found."
  exit 1
fi

admin_group_id=$(get_group_id "${admin_group_name}")
debug "Admin group ID: ${admin_group_id}"

viewer_group_id=$(get_group_id "${viewer_group_name}")
debug "Viewer group ID: ${viewer_group_id}"

editor_group_id=$(get_group_id "${editor_group_name}")
debug "Editor group ID: ${editor_group_id}"

# Ensure all group_ids are set
if [[ -z "${admin_group_id}" || -z "${viewer_group_id}" || -z "${editor_group_id}" ]]; then
  echo "Error: One or more group IDs are empty or not found."
  exit 1
fi

export TF_VAR_delegated_grafana_admin_group_ids="[\"${admin_group_id}\"]"
debug "Exported TF_VAR_delegated_grafana_admin_group_ids: [\"${admin_group_id}\"]"

export TF_VAR_delegated_grafana_viewer_group_ids="[\"${viewer_group_id}\"]"
debug "Exported TF_VAR_delegated_grafana_viewer_group_ids: [\"${viewer_group_id}\"]"

export TF_VAR_delegated_grafana_editor_group_ids="[\"${editor_group_id}\"]"
debug "Exported TF_VAR_delegated_grafana_editor_group_ids: [\"${editor_group_id}\"]"

# Package lambda dependencies
npm ci

npm run generate-dependencies --workspaces --if-present

npm run lambda-build --workspaces --if-present
