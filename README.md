# A WordPress Deploy Setup Catered to WP Engine Hosting
## or "DepLizard"

### Updating files 

The following files have project-specific values, so update them accordingly before you `vagrant up`! By default, everything will fall under the "Bocoup WP Engine" project at http://bocoup-wpengine.loc.

#### /

Vagrantfile
* line 21 - host alias
  
.gitignore
* line 4 - theme directory

#### /deploy

setup-remotes.sh 
* line 13 - production remote
* line 14 - staging remote

test-redirects
* line 6 - wpengine project page 
* line 10 - domain
* line 11 - auth

#### /deploy/ansible/group_vars

all.yml
* line 11 - project name (needs to match host alias in /Vagrantfile)
* line 16 - vagrant hostname
* lines 86-88 - smtp information
* line 125 - wordpress version
* line 126 - wordpress md5 for wordpress version (copied from https://wordpress.org/download/release-archive/)
* line 141 - theme directory (needs to match theme directory in /.gitignore)
* lines 148-156 - salt keys (generate from https://api.wordpress.org/secret-key/1.1/salt/)

#### /deploy/ansible/inventory

vagrant
* line 6 - host alias (needs to match host alias in /Vagrantfile)

### Updating the database

WordPress saves permalinks in the database. If you update the files with your host alias and domains, you can `vagrant up` but will not be able to log in, since "bocoup-wpengine.loc" is set as the alias. You'll need to use ssh to go into mysql and manually drop and create a WordPress database. You can enter the following commands to do just that:

1. `vagrant ssh`
2. `mysql -u root -p`
3. when password is requested, type `test123` and you'll be in mysql
4. `drop database wordpress;`
5. `create database wordpress;`
6. go to the host alias in your browser and follow the directions to create your site
7. go back to the terminal and type `exit` to leave mysql
8. `exit` to leave vagrant ssh
9. `./deploy/run-playbook.sh ./deploy/ansible/db-dump.yml vagrant` to dump your new database into the project

Note that mysql commands have to end with a semi-colon.

### Dependencies

The following will need to be installed on your local development machine before
you can run any of this. All versions should be the latest available, as some
required features may not be available in older versions.

* **[Ansible](http://docs.ansible.com/) 1.9.2**
  - Install `ansible` via apt (Ubuntu), yum (Fedora), [homebrew][homebrew] (OS
    X), etc. See the [Ansible installation
    instructions](http://docs.ansible.com/intro_installation.html) for detailed,
    platform-specific information.
* **[VirtualBox](https://www.virtualbox.org/)**
  - [Download](https://www.virtualbox.org/wiki/Downloads) (All platforms)
  - Install `virtualbox` via [homebrew cask][cask] (OS X)
* **[Vagrant](https://www.vagrantup.com/)**
  - [Download](http://docs.vagrantup.com/v2/installation/) (All platforms)
  - Install `vagrant` via [homebrew cask][cask] (OS X)
* **[vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)**
  - Install with `vagrant plugin install vagrant-hostsupdater` (All platforms)

[homebrew]: http://brew.sh/
[cask]: http://caskroom.io/

### Running specific Ansible playbooks

#### Configuration

* [deploy/ansible/group_vars/all.yml][all] - Global variables. These settings
  are available to all playbooks and roles.

[all]: deploy/ansible/group_vars/all.yml

#### Playbooks and Roles:

* [provision](deploy/ansible/provision.yml) - Install all dependencies required
  to build the base box.
  * [base](deploy/ansible/roles/base) role - Install Apt packages.
* [configure](deploy/ansible/configure.yml) - Configure the box and get services
  set up. _The following roles may be run individually via a role-named tag, eg.
  `--tags=wordpress`:_
  * [configure](deploy/ansible/roles/configure) role - Basic server
    configuration.
  * [users](deploy/ansible/roles/users) role - Enable user account for the
    currently logged-in user so that playbooks may be run manually via
    `run-playbook.sh` or `ansible-playbook`.
  * [nginx](deploy/ansible/roles/nginx) role - Enable SSL (if specified) and
    configure nginx.
  * [php](deploy/ansible/roles/php) role - Update php configuration.
  * [mysql](deploy/ansible/roles/mysql) role - Harden MySQL installation.
  * [wordpress](deploy/ansible/roles/wordpress) role - Download and install
    WordPress `wp_version` and set up its configuration, linking the
    [wp-content](wp-content) directory. Use the `wp_force=true` extra var to
    force the currently-installed version of WordPress to be reinstalled.
  * [postfix](deploy/ansible/roles/postfix) role - Configure the SMTP email
    server.
* [db-dump](deploy/ansible/db-dump.yml) - Dump `wp_db_name` database to db-named
  file in `wp-database`.
* [db-restore](deploy/ansible/db-restore.yml) - Restore `wp_db_name` database
  from db-named file in `wp-database`.
* [init](deploy/ansible/init.yml) - Run `provision`, `configure` and
  `db-restore` playbooks. Runs on `vagrant up`.

#### Examples:

```bash
# Run all configure playbook roles:

$ ./deploy/run-playbook.sh configure vagrant


# Run configure playbook role tagged "wordpress":
# (valid tags are: configure, mysql, nginx, php, users, wordpress, postfix)

$ ./deploy/run-playbook.sh configure vagrant --tags=wordpress
```
