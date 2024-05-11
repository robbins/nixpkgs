{ pkgs, lib, config, ... }:

let
  cfg = config.programs.cuttlefish-base;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options = {
    programs.cuttlefish-base = {
      enable = mkEnableOption "CHANGE";

      package = mkOption {
        type = types.package;
        default = pkgs.cuttlefish-base;
        defaultText = "pkgs.cuttlefish-base";
        description = "Set version of cuttlefish-base package to use.";
      };

      numCvdAccounts = mkOption {
        type = types.number;
        default = 10;
        description = "";
      };
      bridgeInterface = mkOption {
        type = types.str;
        default = "";
        description = "";
      };
      wifiBridgeInterface = mkOption {
        type = types.str;
        default = "cvd-wbr";
        description = "";
      };
      ethernetBridgeInterface = mkOption {
        type = types.str;
        default = "cvd-ebr";
        description = "";
      };
      ipv4Bridge = mkOption {
        type = types.bool;
        default = true;
        description = "";
      };
      ipv6Bridge = mkOption {
        type = types.bool;
        default = true;
        description = "";
      };
      dns_servers = mkOption {
        type = types.str;
        default = "8.8.8.8,8.8.4.4";
        description = "";
      };
      dns6_servers = mkOption {
        type = types.str;
        default = "2001:4860:4860::8888,2001:4860:4860::8844";
        description = "";
      };
    };
  };

  config = mkIf cfg.enable {
    # /etc/security/limits.d/1_cuttlefish.conf
    security.pam.loginLimits = [
      {
        domain = "@cvdnetwork";
        item = "nofile";
        type = "soft";
        value = "4096";
      }
    ];

    # /etc/modules-load.d/cuttlefish-common.conf
    boot.kernelModules = [ "vhci-hcd" "vhost_net" "vhost_vsock" ];

    users.groups = {
      cvdnetwork = {};
      render = {};
      kvm = {};
    };

    # /etc/NetworkManager/conf.d/99-cuttlefish.conf
    networking.networkmanager.unmanaged = [
      "interface-name:cvd-*"
    ];

    # /lib/udev/rules.d/60-cuttlefish-base.rules
    services.udev.packages = [
      cfg.package
    ];

    systemd.services.cuttlefish-host-resources = {
      description = "Set up initial cuttlefish environment";

      before = [ "multi-user.target" "graphical.target" ];
      after = [ "network-online.target" "remote-fs.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "forking";
        Restart = "no";
        TimeoutSec = "5min";
        IgnoreSIGPIPE= "no";
        KillMode = "process";
        GuessMainPID = "no";
        RemainAfterExit = "yes";
        SuccessExitStatus = "5 6";
        ExecStart = "${cfg.package}/etc/init.d/cuttlefish-base.cuttlefish-host-resources.init start";
        ExecStop = "${cfg.package}/etc/init.d/cuttlefish-base.cuttlefish-host-resources.init stop";
      };
    };

  };

  meta.maintainers = with lib.maintainers; [ robbins ];
}
