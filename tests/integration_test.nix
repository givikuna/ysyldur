{
  inputs,
  pkgs,
  self,
  ...
}:
let
  evalRealNixos =
    extraConfig:
    inputs.nixpkgs.lib.nixosSystem {
      system = pkgs.stdenv.hostPlatform.system;
      modules = [
        self.nixosModules.default
        {
          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "/dev/sda1";
            fsType = "ext4";
          };
          system.stateVersion = "25.05";
        }
        extraConfig
      ];
    };
in
{
  suites."Full NixOS System Integration" = {
    pos = __curPos;
    tests = [
      {
        name = "evaluates full nixosSystem with zen variant, gaming profile, scx_bpfland, and params";
        pos = __curPos;
        expected = {
          kernelPname = pkgs.linuxPackages_zen.kernel.pname;
          swappiness = 10;
          scxEnabled = true;
          scxScheduler = "scx_bpfland";
          hasSplitLockParam = true;
        };
        actual =
          let
            sys = evalRealNixos {
              ysyldur = {
                boot = {
                  packages.variant = "zen";
                  params.split_lock_detect = "off";
                  sysctl.profiles.gaming-minotaur.enable = true;
                };
                services.scx = {
                  enable = true;
                  scheduler.bpfland.enable = true;
                };
              };
            };
          in
          {
            kernelPname = sys.config.boot.kernelPackages.kernel.pname;
            swappiness = sys.config.boot.kernel.sysctl."vm.swappiness";
            scxEnabled = sys.config.services.scx.enable;
            scxScheduler = sys.config.services.scx.scheduler;
            hasSplitLockParam = builtins.elem "split_lock_detect=off" sys.config.boot.kernelParams;
          };
      }
      # {
      #   name = "evaluates full nixosSystem with hardened variant and security profile";
      #   pos = __curPos;
      #   expected = {
      #     kernelPname = pkgs.linuxPackages_hardened.kernel.pname;
      #     ptraceScope = 1;
      #     kptrRestrict = 2;
      #   };
      #   actual =
      #     let
      #       sys = evalRealNixos {
      #         ysyldur.boot = {
      #           packages.variant = "hardened";
      #           sysctl.profiles.security-nomad.enable = true;
      #         };
      #       };
      #     in
      #     {
      #       kernelPname = sys.config.boot.kernelPackages.kernel.pname;
      #       ptraceScope = sys.config.boot.kernel.sysctl."kernel.yama.ptrace_scope";
      #       kptrRestrict = sys.config.boot.kernel.sysctl."kernel.kptr_restrict";
      #     };
      # }
    ];
  };
}
