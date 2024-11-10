{ pkgs, lib, config, inputs, ... }:

let
  ruby_version = "3.3.5";
  rails_version = "7.2.2";
  # db = "sqlite";
  db = "postgresql";
  # db = "mysql";
  db_username = "solidus";
  db_password = "test1234";
in
{
  env.DB = db;
  env.RUBY_VERSION = ruby_version;
  env.DB_USERNAME = db_username;
  env.DB_PASSWORD = db_password;
  env.RAILS_VERSION = rails_version;
  env.PAYMENT_METHOD = "none";

  packages = [
    pkgs.imagemagick
    pkgs.libyaml
    pkgs.sqlite
    pkgs.rubyPackages_3_3.ruby-vips
  ];

  languages.ruby.enable = true;
  languages.ruby.version = ruby_version;

  enterShell = "./bin/setup";
  enterTest = "./bin/rspec";

  services.postgres =
    if db == "postgresql"
    then
      {
        enable = true;
        listen_addresses = "127.0.0.1";      
        initialScript =
          "CREATE ROLE "
          + db_username +
          " SUPERUSER LOGIN PASSWORD '"
          + db_password +
          "';";
      }
    else
      {};

  services.mysql =
    if db == "mysql"
    then
      {
        enable = true;
        ensureUsers = [
          {
            name = db_username;
            password = db_password;
            ensurePermissions = {
              "*.*" = "ALL PRIVILEGES";
            };
          }
        ];
      }
    else
      {};
}
