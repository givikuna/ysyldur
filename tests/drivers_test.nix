{ helpers, ... }:
let
  inherit (helpers) evalYsyldur evalYsyldurWith;
in
{
  suites."Drivers - GPU & Peripherals" = {
    pos = __curPos;
    tests = [
      {
        name = "amdgpu enables early KMS and Xserver videoDriver without overdrive by default";
        pos = __curPos;
        expected = {
          initrdMods = [ "amdgpu" ];
          videoDrivers = [ "amdgpu" ];
          params = [ ];
        };
        actual =
          let
            cfg =
              (evalYsyldur {
                ysyldur.drivers.amdgpu.enable = true;
              }).config;
          in
          {
            initrdMods = cfg.boot.initrd.kernelModules;
            videoDrivers = cfg.services.xserver.videoDrivers;
            params = cfg.boot.kernelParams;
          };
      }
      {
        name = "amdgpu.overdrive appends amdgpu.ppfeaturemask=0xffffffff";
        pos = __curPos;
        expected = [ "amdgpu.ppfeaturemask=0xffffffff" ];
        actual =
          (evalYsyldur {
            ysyldur.drivers.amdgpu = {
              enable = true;
              overdrive = true;
            };
          }).config.boot.kernelParams;
      }
      {
        name = "nvidia_stable binds hardware.nvidia.package to kernelPackages.nvidiaPackages.stable";
        pos = __curPos;
        expected = "linuxPackages:nvidia-stable";
        actual =
          (evalYsyldur {
            ysyldur.drivers.nvidia_stable.enable = true;
          }).config.hardware.nvidia.package._id;
      }
      {
        name = "nvidia_beta binds hardware.nvidia.package to kernelPackages.nvidiaPackages.beta";
        pos = __curPos;
        expected = "linuxPackages:nvidia-beta";
        actual =
          (evalYsyldur {
            ysyldur.drivers.nvidia_beta.enable = true;
          }).config.hardware.nvidia.package._id;
      }
      {
        name = "nvidia_production binds hardware.nvidia.package to kernelPackages.nvidiaPackages.production";
        pos = __curPos;
        expected = "linuxPackages:nvidia-production";
        actual =
          (evalYsyldur {
            ysyldur.drivers.nvidia_production.enable = true;
          }).config.hardware.nvidia.package._id;
      }
      {
        name = "nvidia_cachyos binds hardware.nvidia.package to kernelPackages.nvidiaPackages.cachyos";
        pos = __curPos;
        expected = "linuxPackages_cachyos-lts:nvidia-cachyos";
        actual =
          (evalYsyldur {
            ysyldur.boot.packages.variant = "cachyos-lts";
            ysyldur.drivers.nvidia_cachyos.enable = true;
          }).config.hardware.nvidia.package._id;
      }
      {
        name = "nvidia_cachyos fails assertion when nvidiaPackages.cachyos is missing";
        pos = __curPos;
        expected = false;
        actual =
          (evalYsyldurWith {
            withCachyNvidia = false;
            module = {
              ysyldur.drivers.nvidia_cachyos.enable = true;
            };
          }).assertionsPassed;
      }
      {
        name = "fails assertion when multiple NVIDIA driver branches are enabled simultaneously";
        pos = __curPos;
        expected = false;
        actual =
          (evalYsyldur {
            ysyldur.drivers.nvidia_stable.enable = true;
            ysyldur.drivers.nvidia_cachyos.enable = true;
          }).assertionsPassed;
      }
      {
        name = "xone and xpadneo enable their respective hardware options";
        pos = __curPos;
        expected = {
          xone = true;
          xpadneo = true;
        };
        actual =
          let
            hw =
              (evalYsyldur {
                ysyldur.drivers = {
                  xone.enable = true;
                  xpadneo.enable = true;
                };
              }).config.hardware;
          in
          {
            xone = hw.xone.enable;
            xpadneo = hw.xpadneo.enable;
          };
      }
    ];
  };
}
