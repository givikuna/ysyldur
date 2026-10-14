{ ... }:
{
  imports = [
    ./options/nvidia_cachyos.nix
    ./options/nvidia_stable.nix
    ./options/nvidia_beta.nix
    ./options/nvidia_production.nix
    ./options/amdgpu.nix
    ./options/xpadneo.nix
    ./options/xone.nix
  ];
}
