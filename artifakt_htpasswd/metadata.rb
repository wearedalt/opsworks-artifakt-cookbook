name        "artifakt_htpasswd"
description "Artifakt htpasswd Recipes"
maintainer  "Artifakt"
license     "Apache 2.0"
version     "1.0.0"

depends "mod_php5_apache2"

recipe "artifakt_htpasswd::disabled", "Disabled htpasswd"
recipe "artifakt_htpasswd::enabled", "Enabled htpasswd"
recipe "artifakt_htpasswd::setup", "Setup htpasswd"