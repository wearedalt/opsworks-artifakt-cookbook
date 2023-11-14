name        "artifakt_sftp_users"
description "Artifakt SFTP users Recipes"
maintainer  "Artifakt"
license     "Apache 2.0"
version     "1.0.0"

depends "artifakt"
depends "artifakt_efs"

recipe "artifakt_sftp_users::default", "Update SFTP users"