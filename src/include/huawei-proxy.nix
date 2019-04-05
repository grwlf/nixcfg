{ config, pkgs, ... } :
let

  # FIXME: find out how to pass it as a parameter from main config
  ip_addr = "10.199.192.149";
  port = "3128";

  cntlm_ini = pkgs.writeText "cntlm.ini" ''
    Username    mwx579795
    Domain      CHINA
    Proxy       proxyru.huawei.com:8080
    Auth        NTLM
    PassLM      7B4AD4F417B80BCCD4169DD66E4838D5
    PassNT      6127180564B5CF450875219084A134BC
    PassNTLMv2  A363AB844E34D374406B62427D472919    # Only for user 'mWX579795', domain 'CHINA'
    NoProxy     localhost,127.0.0.*,*.huawei.com,*.fi-git-rd.huawei.com,10.122.225.21,10.175.100.97,10.175.100.76,internal.domain
  '';

  huawei-proxy = pkgs.writeShellScriptBin "huawei-proxy" ''
    ${pkgs.cntlm}/bin/cntlm -c ${cntlm_ini} -l "${ip_addr}:${port}" -f
  '';
in
{
  security.pki.certificateFiles = [
    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ./../certs/huawei.crt
  ];

  networking.proxy.default = "http://${ip_addr}:${port}";
  networking.proxy.noProxy = "fi-git-rd.huawei.com,10.122.225.21,10.175.100.97,10.175.100.76,127.0.0.1,localhost,internal.domain";

  systemd.services.huawei-proxy = {
    description = "Huawei proxy service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = ''${huawei-proxy}/bin/huawei-proxy'';
      # ExecStop = ''${pkgs.procps}/bin/pkill cntlm'';
      Restart = "on-failure";
    };
  };

  #systemd.services.huawei-proxy.enable = true;

  environment.systemPackages = with pkgs; [
    cntlm
    huawei-proxy
  ];
}

