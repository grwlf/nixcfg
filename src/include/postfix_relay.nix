{ config, pkgs, ... } :

with pkgs;
{
  services.postfix = {
    enable = true;
    setSendmail = true;

    networks = ["127.0.0.1/24"];

    # Thanks to http://rs20.mine.nu/w/2011/07/gmail-as-relay-host-in-postfix/
    extraConfig = ''
      inet_interfaces = loopback-only
      relayhost=[smtp.gmail.com]:587
      smtp_use_tls=yes
      smtp_tls_CAfile=${cacert}/etc/ssl/certs/ca-bundle.crt
      smtp_sasl_auth_enable=yes
      smtp_sasl_password_maps=hash:/etc/postfix.local/sasl_passwd
      smtp_sasl_security_options=noanonymous
    '';
  };

  jobs.postfix.preStart =
    let
        saslpwd = callPackage ./sasl_passwd.nix {};
    in ''
      ${coreutils}/bin/mkdir -pv /etc/postfix.local
      ${coreutils}/bin/cp ${saslpwd}/sasl_passwd /etc/postfix.local/sasl_passwd
      ${postfix}/sbin/postmap /etc/postfix.local/sasl_passwd
    '';
}

