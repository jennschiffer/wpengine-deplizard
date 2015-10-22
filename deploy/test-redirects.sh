#!/usr/bin/env bash

# Ensure the "Hide development files" redirect rule:
# ^/((README.md|Vagrantfile|ansible.cfg)$|(wp-database|deploy)(/?$|/))
# is working at:
# https://my.wpengine.com/installs/bocoup/redirect_rules

function base_url() {
  local scheme='https://'
  local domain='www.bocoup.com'
  local auth='bocoup:pr3v13w!'
  if [[ "$1" ]]; then
    echo "$scheme$auth@$domain"
  else
    echo "$scheme$domain"
  fi
}

redirect_to_root=(
  /README.md
  /Vagrantfile
  /ansible.cfg
  /deploy
  /deploy/
  /deploy/run-playbook.sh
  /deploy/ansible
  /deploy/ansible/
  /deploy/ansible/init.yml
  /wp-database
  /wp-database/
  /wp-database/wordpress.sql.bz2
)

no_redirect=(
  /
  /dashboard/
  /deploy-shouldnt-redirect
  /wp-database-shouldnt-redirect
)

errors=

function success() {
  echo "Success: $@"
}

function error() {
  echo "Error: $@"
  errors=1
}

function curl_path() {
  curl --silent --head "$(base_url 1)$1" | awk '/Location:/ {print $2}' | tr -d '\r'
}

for p in "${redirect_to_root[@]}"; do
  result="$(curl_path $p)"
  if [[ "$result" == "$(base_url)/" ]]; then
    success "$p redirects to /"
  else
    error "$p should redirect to / but does not"
  fi
done

for p in "${no_redirect[@]}"; do
  result="$(curl_path $p)"
  if [[ ! "$result" ]]; then
    success "$p should not redirect"
  else
    error "$p redirects to ${result#$(base_url)} but should not"
  fi
done

echo
if [[ "$errors" ]]; then
  echo "Errors were found!"
  exit 1
else
  echo "All tests were successful."
fi
