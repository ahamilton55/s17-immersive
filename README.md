# CSUN META+LAB Summer 2017 Immersive

This is a group of files created during the Summer 2017 Immersive for the CSUN META+LAB. This code will deploy a simple "Hello World" web page. It builds from a simple VM with Vagrant and configured with Ansible to building an AMI with Packer and Ansible and finally using Terraform to deploy a set of web servers running the created AMI behind and ELB.

## Vagrant
Vagrant allows us to easily create and destroy VMs. This is great when working with a configuration management system such as Ansible to make sure that building for a stock image is possible.

To use run the following:
```
$ cd vagrant
$ vagrant up
```

If you'd like to setup your SSH config file (`~/.ssh/config`) for easy access with vagrant run the following from the vagrant directory:
```
$ vagrant ssh-config >>~/.ssh/config
```
You can now run `ssh vagrant` to SSH into the VM.

## Ansible
Ansible is used for configuration management and deployment of our application.

1. Visit the Ansible website to learn how to install Ansible locally on your machine.

1. To run Ansible you will need to update the `hosts.ini` file with your favority text editor to work properly with your Vagrant VM. You might need to update the name in the `hosts.ini` file.

1. To run the playbook `web_server.yml` against the vagrant VM, after running the above step, execute the following:
    ```
    $ cd ansible
    $ ansible-playbook -i hosts.ini web_server.ini
    ```

## Packer
Packer is used to build a custom AMI using our Ansible playbook.

If you have not setup AWS credentials on your local host you will need to generate a set from AWS IAM and then use the `aws configure` command to setup the credentials on your local host.

If you have multiple AWS profiles setup on your computer, you should setup environment variables for the profile you want packer to use. You can find your credentials in `~/.aws/credentials` under the name of your profile. To setup environment variables do the following:
```
$ export AWS_ACCESS_KEY_ID=<access_key_id>
$ export AWS_SECRET_ACCESS_KEY=<secret_access_key>
```

To create your AMI run the following:
```
$ cd packer
$ packer build -var-file=web-server.json -var="build_date=$(date +%y%m%d%H%M)" packer.json
```

The AMI ID will be printed at the completion of the packer run and updated in the Terraform code.

To clean up your account you will need to manually delete the image from AWS.

## Terraform
Terraform is used to build out our AWS environment.

You will need to update the `web_server.tf` file with the correct VPC ID, VPC subnets, keypair name and AMI ID generated with Packer.

To build your environment run the following:
```
$ cd terraform
$ terraform plan
$ terraform apply
```

When you are done with your enviornment you should destroy it by running the following:
```
$ terraform destroy
```