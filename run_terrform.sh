#! /bin/bash

# source ./config.sh

# Check to see that environment variables are set
if command -v terraform &> /dev/null &&
   [[ -n "$TF_VAR_droplet_size" ]] &&
   [[ -n "$TF_VAR_pvt_key" ]] &&
   [[ -n "$TF_VAR_pub_key" ]] &&
   [[ -n "$TF_VAR_do_ssh_key_name" ]] &&
   [[ -n "$TF_VAR_do_token" ]]; then
  terraform apply
  total_duration_in_seconds=3600
  sleep_duration=60
  if [[ $(($sleep_duration <= $total_duration_in_seconds)) -eq 1 ]]; then
    for ((i=total_duration_in_seconds/sleep_duration; i>=0; i--)); do
      echo "Terraform resource will be destroyed in $((i*$sleep_duration))"
      sleep "$sleep_duration"
    done
  fi
  terraform destroy --auto-approve
fi


