# DigitalOcean Terraform and Ansible For A ReacJS // Django project

This repository contains [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/) configurations to launch and set up some basic infrastructure on DigitalOcean. As server deployments and development teams continue to get larger and more complex, the practice of defining infrastructure as version-controlled code has taken off. Tools such as Ansible and Terraform allow you to clearly define the servers you need (and firewalls, load balancers, etc.) and the configuration of the operating system and software on those servers.

This demo will create the following infrastructure using Terraform:

- Two 1 GB Droplets in the NYC3 datacenter running Ubuntu 20.04
- One DigitalOcean Load Balancer to route HTTP traffic to the Droplets
- One DigitalOcean Cloud Firewall to lock down communication between the Droplets and the outside world

## Prerequisites

You will need the following software installed:

- **Git:**
- **Terraform:** Terraform will control your server and load balancer infrastructure. To install it locally, read the _Install Terraform_ section of [How To Use Terraform with DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean#install-terraform)
- **Ansible:**

**You will also need an SSH key set up on your local computer**, with the public key uploaded to the DigitalOcean Control Panel. You can find out how to do that using our tutorial [How To Use SSH Keys with DigitalOcean Droplets](https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets).

**You will need a personal access token for the DigitalOcean API**. You can find out more about the API and how to generate a token by reading [How To Use the DigitalOcean API v2](https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2)

Finally, **you will need a personal access token, account id and a domain for the DNSimple API**. You can find out more about the API and how to generate a token by reading [How To Use the DNSimple API v2](https://developer.dnsimple.com/v2/)

When you have the software, an SSH key, and the APIs tokens, proceed to the first step.


## Step 1 — Clone the Repository and Configure

First, download the repository to your local computer using `git clone`. Make sure you're in the directory you'd like to download to, then enter the following command:

```
$ git clone https://github.com/exposeee/infra.git
```

Navigate to the resulting directory:

```
$ cd infra
```

We need to update a few variables to let Terraform know about our keys and tokens. Terraform will look for variables in any `.tfvars` file. An example file is included in the repo. Copy the example file to to a new file, removing the `.example` extension:

```
$ cp terraform.tfvars.example terraform.tfvars
```

Open the new file in your favorite text editor. You'll see the following:

```
do_token = ""
ssh_fingerprint = ""

dnsimple_token = ""
dnsimple_account = ""
dnsimple_domain = ""
```

Fill in each variable:

- **do_token:** is your personal access token for the DigitalOcean API
- **ssh_fingerprint:** the DigitalOcean API refers to SSH keys using their _fingerprint_, which is a shorthand identifier based on the key itself.

  To get the fingerprint for your key, run the following command, being sure to update the path (currently `~/.ssh/id_rsa.pub`) to the key you're using with DigitalOcean, if necessary:

  ```
  $ ssh-keygen -E md5 -lf ~/.ssh/id_rsa.pub | awk '{print $2}'
  ```

  The output will be similar to this:

  ```
  MD5:ac:eb:de:c1:95:18:6f:d5:58:55:05:9c:51:d0:e8:e3
  ```

  **Copy everything _except_ the initial `MD5:`** and paste it into the variable.

- **dnsimple_token:** is your personal access token for the DNSimple API.
- **dnsimple_account:** is your personal account id for the DNSimple API.
- **dnsimple_domain:** is a domain register in your DNSimple account.

Now we can initialize Terraform. This will download some information for the DigitalOcean Terraform _provider_, and check our configuration for errors.

```
$ terraform init
```

You should get some output about initializing plugins. Now we're ready to provision the infrastructure and configure it.


## Step 2 — Run Terraform and Ansible

We can provision the infrastructure with the following command:

```
$ terraform apply
```

Terraform will figure out the current state of your infrastructure, and what changes it needs to make to satisfy the configuration in `terraform.tf`. In this case, it should show that it's creating two Droplets, a load balancer, a firewall, and a _null_resource_ (this is used to create the `inventory` file for Ansible).

If all looks well, type `yes` to proceed.

Terraform will give frequent status updates as it launches infrastructure. Eventually, it will complete and you'll be returned to your command line prompt. Take note of the IP that Terraform outputs at the end:

```
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

api-ip = 203.0.113.11

app-ip = 203.0.113.12
```

This is the IP of your a ReactJS application and the Django rest API. If you navigate to it in your browser, you'll get an error: the Droplets aren't serving anything yet!


Let first copy the django project env example file and remove the `.example` extension:

```
$ cp api-ansible-role/templates/env.j2.example api-ansible-role/templates/env.j2
```

Don't forget to edit the new file adding the correct variable values.
Now let's run Ansible to finish setting up the servers:

```
$ ansible-playbook -i inventory api-inventory.yml
$ ansible-playbook -i inventory app-inventory.yml
```

Ansible will output some status information as it works through the tasks we've defined in `*-inventory.yml`. When it's done, the two Droplets will be serving a two different web page.

When you're done exploring, you can destroy all of the demo infrastructure using Terraform:

```
$ terraform destroy
```

This will delete everything we set up.

## Local test

The local test requires the use of `vagrant` virtual machine:

- First copy the three local inventory files.

```
$ cp db-inventory-local.example db-inventory-local
$ cp api-inventory-local.example api-inventory-local
$ cp app-inventory-local.example app-inventory-local
```

- Change the values in the local inventory files, for example:

```
  db-vbox-ip = '123.4.5.6'
  api-vbox-ip = '123.4.5.7'
  app-vbox-ip = '123.4.5.8'
  database_password = 'abcdefg'
```

- And than you can provision each vbox in the following way:

```
$ vagrant up exposeee-db
$ vagrant provision  exposeee-db
```

```
$ vagrant up exposeee-api
$ vagrant provision  exposeee-api
```

```
$ vagrant up exposeee-app
$ vagrant provision  exposeee-app
```
