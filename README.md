## Set up a virtual machine with terraform and ansible on digital ocean
The project sets up a virtual machine with terraform and ansible on digital ocean. Terraform is used to create the droplet (virtual machine) and ansible for configuring the droplet. Docker, docker-compose, Miniconda (miniature installation of anaconda) and gcloud cli are installed onto the droplet. Follow the instructions below when setting it up.

### Prerequisites

- Digital ocean account, [sign up for a new account](https://cloud.digitalocean.com/registrations/new)
- Digital ocean personal access token, [how to create a personal access token](https://docs.digitalocean.com/reference/api/create-personal-access-token/)
- Create an SSH key [how to create an ssh key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) (`NOTE`: Ensure to add the SSH private key to the ssh agent using `ssh-add --apple-use-keychain ~/.ssh/id_ed25519` where id_ed25519 is the key name)
- SSH key added to your digital ocean account [how to manage ssh public keys](https://docs.digitalocean.com/platform/teams/upload-ssh-keys/) (NOTE: The name of the key is used when referencing the digitalocean_ssh_key)
- Installation of terraform, [install terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- `Optional`: Installation of the [digital ocean CLI (doctl)](https://docs.digitalocean.com/reference/doctl/how-to/install/)

### Set default configurations
- Generate a config file from sample config
```sh
cp sample_config.sh.txt config.sh && chmod +x $_ && chmod +x unset_config.sh
```

- The config.sh file includes variables prefixed with TF_VAR_. Terraform can automatically recognize and import these environment variables as Terraform variables. Any environment variable starting with TF_VAR_ is mapped directly to a corresponding Terraform variable with the same name e.g `TF_VAR_pvt_key` will map to `pvt_key` in the `main.tf` file

- The config.sh file also creates txt files containing the allowed provision arguments for a digital ocean droplet. It require `doctl` to run generate these files. If `doctl` does not exist, terraform will use the existing `txt` files uploaded in the `assets` folder

- The script `run_terraform.sh` can be used to create the droplet using `terraform apply` and then destroy the resource using `terraform destroy` after 1 hour

- `unset_config` is used to unset the configurations after running terraform destroy
- Install ansible roles
```sh
ansible-galaxy install -r requirements.yml
```

#### Update the following in config.sh
- Set `{pvt_key_name}` to the name of the SSH private key
- Set `{pub_key_name}` to the name of the SSH public key
- Set `{name_of_ssh_key_used_in_digital_ocean}` to the name of the ssh key used in digital ocean
- Set `{your_personal_access_token}` to the value of the digital ocean personal access token
- Set `TF_LOG` environment to any one of the valid levels [TRACE DEBUG INFO WARN ERROR OFF](https://stackoverflow.com/questions/2031163/when-to-use-the-different-log-levels). It's currently set to TRACE to enable detailed logging of everything terraform is trying to do.

#### Run the config script
Before setting the configurations, run the command below to unset any conflicting configurations
```sh
source unset_config.sh
```
Set the configurations
```sh
source config.sh
```

### Configuration of terraform for digital ocean
- Run ``terraform get` to download and update modules mentioned in root module.
```sh
terraform get --update=true
```
- Initialise terraform
```sh
terraform init
```
- OPTIONAL: Run `terraform providers` to show information about the providers requirements of the configuration in the current working directory
```sh
terraform providers
```

- Update the size of droplet in the file `vm-my-rides.tf` based on the [digital ocean size slug chart](https://slugs.do-api.dev/). Currently set to the lowest size but for data engineering tasks I recommend `s-4vcpu-8gb` which is the Basic Regular (Disk type: SSD, 8GB memory, 4 CPUs, 160GB SSD Disk, 5TB transfer at $0.071/hour or $48/ month at the time of creating this project)

NOTE: To know which argurments are required or optional for a Droplet resource, refer to the official Terraform documentation: [Digital Ocean Droplet Specification](http://www.terraform.io/docs/providers/do/r/droplet)

#### Create the droplet
- See the execution plan (what terraform will attempt to build) by runing `terraform plan`. Have to specify the values for Digital Ocean Access Token (`TF_VAR_do_token`) and the path to your private key (`TF_VAR_pvt_key`) in `config.sh`. The private key is used for accessing the droplet to install other dependencies e.g docker using ansible
```sh
terraform plan
```

- Run `terraform apply` to execute the current plan
```sh
terraform apply
```

- To view current state of the environment. `ipv4_address` will show the public IP address of the Droplet
```sh
terraform show terraform.tfstate
```

- To view outputs
```sh
terraform output
```

Note: If you modify your infrastructure outside of Terraform, your state file will be out of date. If your resources are modified outside of Terraform, you’ll need to refresh the state file to bring it up to date. This command will pull the updated resource information from your provider(s):
```sh
terraform refresh
```

Run `terraform destroy` to destroy the created resources
```sh
terraform destroy
```

Unset configurations
```sh
source unset_config.sh
```

#### Running ansible
The ansible playbook is run by terraform in the `vm-my-rides.tf` file, under `provisioner "local-exec"`.
To run ansible separate from terraform, you will have to run
```sh
ansible-playbook -u root -i "{ipv4_address}," --private-key ${PVT_KEY} -e "pub_key=${PUB_KEY}" configure_droplet.yml
```
`{ipv4_address}` should be replaced by the IPv4 address of the running droplet. Take note that the comma after the IP address has to remain present The other option is to add the IPv4 address to the inventory file and run
```sh
ansible-playbook -u root -i inventory --private-key ${PVT_KEY} -e "pub_key=${PUB_KEY}" configure_droplet.yml
```
Check what kind of information is available for the droplet setup with terraform
```sh
ansible all -u root -i inventory -m setup
```
To obtain a subset of the data, we use `filter` parameter and provide a pattern
```sh
ansible all -u root -i inventory -m setup -a "filter=*ipv4*"
```



### SOURCES:
[How to use terraform with digital ocean](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean)

[How to create reusable infrastructure with terraform modules and templates](https://www.digitalocean.com/community/tutorials/how-to-create-reusable-infrastructure-with-terraform-modules-and-templates)

[How to use ansible with terraform for configuration management](https://www.digitalocean.com/community/tutorials/how-to-use-ansible-with-terraform-for-configuration-management)

[How to use ansible to install and set up docker](https://www.digitalocean.com/community/tutorials/how-to-use-ansible-to-install-and-set-up-docker-on-ubuntu-20-04)

[How to access system information facts in ansible playbooks](https://www.digitalocean.com/community/tutorials/how-to-access-system-information-facts-in-ansible-playbooks)

