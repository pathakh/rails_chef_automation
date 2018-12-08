# README

- This repo is helpful for provisioning a single rails ubuntu server using knife solo
- The cookbook op installs deploy user with sudo access, rvm, ruby, nginx, postgres, your ssh keys etc...
- First install chefdk and knife-solo

# Then You can use the following to bootstrap:

- Run: ````bundle install && berks install && berks vendor````

    ````knife solo bootstrap ubuntu@$host -i <ssh_key> -r "role[<insert role name here from roles directory>]"````

or you can use the following script:

    ./deploy.sh <host address> <rolename from roles directory> <ssh key name in .ssh directory>

# Additonal

- You can paste your ssh keys in cookbooks/op/files/authorized_keys
    - Make sure to keep these changes local only.  DO NOT PUSH YOUR KEYS
- You can paste your github repo access keys in id_rsa_private, and id_rsa_public
    - Add your id_rsa_public key to github access keys
    - Make sure to keep these changes local only.  DO NOT PUSH YOUR KEYS


