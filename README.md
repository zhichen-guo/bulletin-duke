# Bulletin

## Getting VM for deployment  
* Make sure you are connected to the Duke VPN  
* Go to [Duke VCM](https://vcm.duke.edu/) and click "Reserve a VM"  
* Under **Plain VM: No Apps** select **Ubuntu Server 20.04**  
* Choose **Less Secure Option** on the popup  
    * You most likely already have keys on your computer, so we will use these instead of creating new ones  
* Once your VM has been assigned, you can **Create an Alias** for your server  
    * Aliases are personalized names that you can use to access your website, instead of the VM's assigned hostname, and always end in .colab.duke.edu  
    * They will appear at the bottom of the VM page  
    * For example: "thegulletin.colab.duke.edu" as an alias for the VM "vcm-12345.vm.duke.edu"  
    * To do this, press the **Create an Alias** button under the On/Off buttons  
* Go into the **.ssh** folder  
    * This is where you will find the keys you need to connect to the VM  
`cd ~/.ssh`  
* [Copy your SSH key from this directory into the VM](https://www.ssh.com/ssh/copy-id#copy-the-key-to-a-server)  
`ssh-copy-id -i ./id_ed25519.pub <netID>@<hostname-or-alias>`  
    * Make sure you are using the **public key** which name ends in .pub  
    * When promped, use your Duke netID password  
* Log into your VM!  
`ssh <netID>@<hostname-or-alias>`  
    * Use your SSH key password to log in, if it has a password  

## Deployment Instructions (work in progress)  
* [Generate ssh keys](https://gitlab.oit.duke.edu/help/ssh/README#generating-a-new-ssh-key-pair) for VM  
    * This is so you can pull The Bulletin from GitLab  
    * We recommend replacing `<comment>` with your hostname or the alias of your VM  
`ssh-keygen -t ed25519 -C "<comment>"`  
    * When prompted for the **file in which to save the key** press **ENTER**. This is so your key will be saved in the default folder (.ssh)  
    * When prompted for passphrases press **ENTER** so that no passphrase is set  
* After the key has been generated, save it into your Git so you can pull the Bulletin repo    
`ls ./.ssh`  
    * If our keys were generated correctly, you will find files id_ed25519.pub and a id_ed25519 in this folder (.ssh)  
`cat ./.ssh/id_ed25519.pub`  
    * This command prints your key so that you can copy it into GitLab  
    * Make sure you are using the **public key** which name ends in .pub  
* Copy the entire outputted line  
* Go into your **GitLab settings** and into the **SSH Keys** tab  
* Paste the copied key into the big textbox and click **add key**  
* Rail apps require a secret key set in your machine so that it can access encrypted data in the application.   
`./add_masterkey.sh`  
    * You will be asked for your masterkey. Please ask a team member to provide it for you.  
* Clone [The Bulletin](https://gitlab.oit.duke.edu/bulletin/bulletin) into your VM  
    * Check that the clone was successful by using the `ls` command 
* Install Docker  
    * Run `download_docker.sh` 
* Go into the bulletin directory `cd bulletin`
* Checkout the passenger branch `git checkout passenger`
* Run `./add_hostname.sh` to add your VM address to the list of hosts  
    * This is so that the url connects to your server when typed into a browser  
    * When asked for a hostname, use your alias. Otherwise, use the original address of your VM  
    * For example, thegulletin.colab.duke.edu  
    * Or if you don't have an alias, vcm-12345.vm.duke.edu  
* Run `./create_cert.sh` to generate SSL certificates for your site  
    * This will make it so your application can be opened a secure connection
    * You will be prompted for country, state, city, organization, department, name, email
    * The inputs are US, North Carolina, Durham, Duke University, Code Plus, \<hostname-or-alias>, duke email
* Start container by running  
`./start_container.ssh`  
    * This is a bash script that gives ownership of app files to you, builds your Docker container and then runs it  
* Test your server!  
    * Go into your browser and type \<hostname-or-alias>:3000  
    * For example, thegulletin.colab.duke.edu:3000  
    * Or vcm-12345.vm.duke.edu:3000  

## Docker Commands
* To verify that docker is pulling images and running as expected:  
**docker run hello-world**
* To see all docker images:  
**docker images**
* To run ubuntu bash:  
**docker run -it ubuntu bash**
* To see all docker containers:  
**doctor container ls**
* To install ruby:  
**docker run ruby:2.6.6**
* To open interactive ruby console:  
**docker run -it ruby:2.6.6 irb**
* can explore different repositories in dockerhub
* To build container:  
**docker-compose build**
* To start container:  
**docker-compose up**
* To run container in the background (detached mode) and keep terminal clear:  
**docker-compose up -d**
* To move into running container instance (and be able to run rails commands):  
**docker-compose exec app bash**
* To display log output:  
**docker-compose logs**
* To stop container:  
**docker-compose down**
* To debug:  
**docker run -it *IMAGEID* bash**  
(find *IMAGEID* from 'docker images' call)

## Rails Commands
* To open rails console:  
**rails c**
* To add or update versions of gems from Gemfile:
**bundle install**

* Run the following commands in root (access by "docker-compose up -d", followed by "docker-compose exec app bash")
* To generate model:  
**rails g model NAME field:type**
* To run migrations that haven't been run yet:  
**rails db:migrate**
* To run ruby code in db/seeds.rb:  
**rails db:seed**
* To destroy the database:  
**rails db:drop**
* To see all of the routes:  
**rails routes**

## Testing
* Test suites can be found in bulletin/test/models
* To run tests:  
**rails t** -or-  
**dcom exec app rails t**
* Helpful debugging gem:  
**byebug**  
(Stops interpreter and provides interactive console)
* Format:  
```ruby
test "test name" do
    assert #something (verifies true)
    refute #something (verifies false)
end
```
* Can seed test database with test data using fixtures

## Authentication
Before running the Duke authentication, need to do the following:
1. **cd ~**
2. Run **echo $SHELL**
3. If returns /bin/bash, open .bash_profile in a text editor. If zsh, open .zsh file.
4. (Get the keys from the Bulleting Duke Box.) Add to the end of the file, 
**export BULLETIN_OAUTH_SECRET="{Bulletin Key}"**
**export FACEBOOK_OAUTH_SECRET="{Facebook Key}"**
**export GOOGLE_OAUTH_SECRET="{Google Key}"**
**export BULLETIN_MASTER_KEY="{Bulletin Master Key}"**
**export BULLETIN_DUKE_OAUTH_REDIRECT="{Bulletin Duke Redirect}**
**export BULLETIN_FB_OAUTH_REDIRECT="{Bulletin Facebook Redirect}"**
**export BULLETIN_DUKE_OAUTH_HOST="{Bulletin Duke Host}"**
**export TINY_KEY="{Tiny Key}"**
5. Terminate all terminal windows (quit application)
6. Run 
**env | grep BULLETIN**  
**env | grep FACEBOOK**  
**env | grep GOOGLE** 
**env | grep GMAIL**
**env | grep TINY**

## Authorization
To give your account site/org admin privileges:
1. **docker-compose up -d**
2. **docker-compose exec app bash**
3. **rails c**
4. **your_name = User.find_by_email("your_email")**
5. **your_name.update_attribute(:type, "OrgAdmin")**
6. **your_name.update_attribute(:admin, true)**

