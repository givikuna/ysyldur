# ysyldur

A Nix flake for declaratively managing your kernel variant, version, command-line parameters, sysctl, modules, drivers, and sched_ext (scx) configuration.

---

## Table of Contents

- [What is ysyldur](#what-is-ysyldur)
- [Quick Start](#quick-start)
- [Using the flake](#using-the-flake)
- [Module overview](#module-overview)
- [Boot](#boot)
  - [Kernel variants](#kernel-variants-ysyldurbootpackageskernel-variant--ysyldurbootpackagesvariant)
  - [Kernel versions](#kernel-versions-ysyldurbootversion)
  - [Extra kernel module packages](#extra-kernel-module-packages-ysyldurbootpackagesextra-packages)
  - [Kernel config & patches](#kernel-config--patches-ysyldurbootconfig)
  - [Kernel modules](#kernel-modules-ysyldurbootmodules)
  - [Blacklisting modules](#blacklisting-modules-ysyldurbootmodulesblacklist)
  - [Initrd modules](#initrd-modules-ysyldurbootmodulesinitrd)
  - [Modprobe options](#modprobe-options-ysyldurbootmodulesmodprobe)
  - [Kernel parameters](#kernel-parameters-ysyldurbootparams)
  - [Sysctl parameters](#sysctl-parameters-ysyldurbootsysctlparams)
  - [Sysctl profiles](#sysctl-profiles-ysyldurbootsysctlprofiles)
  - [Block I/O schedulers](#block-io-schedulers-ysyldurbootio-scheduler)
  - [Core dumps](#core-dumps-ysyldurbootcoredump)
- [Drivers](#drivers)
- [Services](#services)
  - [sched_ext (scx)](#sched_ext-scx-ysyldurservicesscx)
- [Chaotic-Nyx integration](#chaotic-nyx-integration)
- [Full options reference](#full-options-reference)
- [Development](#development)

---

## What is ysyldur

Ysyldur is mainly a flake for managing your NixOS kernel information.

There are a lot of things it can do.

These are some of the following:

- **Kernel variants & version pinning** with conflict assertions and shorthand selectors (`"zen"`, `"cachyos-lts"`, `"6.6"`, `"latest"`, …).

- **Structured kernel config** (Kconfig `=y` / `=m` / `=n` and freeform) compiled into `boot.kernelPatches`.

- **Kernel parameters** grouped by concern (CPU, IOMMU, memory, power, graphics, security).

- **Sysctl options** and prebuilt profiles (`gaming-minotaur`, `security-nomad`).

- **Block I/O scheduler udev rules** per device type (NVMe / SSD / HDD).

- **Kernel module helpers**: blacklist presets, load presets, initrd, structured modprobe options.

- **Extra kernel module packages** (acpi_call, bbswitch, ddcci, evdi, v4l2loopback, zenpower) with a name-based escape hatch.

- **GPU drivers**: amdgpu (with overdrive), NVIDIA branches (stable/beta/production/cachyos), xone, xpadneo.

- **sched_ext (scx)** scheduler selection with mutual-exclusion assertions.

- **Chaotic-Nyx** integration: auto-injects the overlay when a CachyOS kernel or driver is selected (but otherwise does not, because that would be bloatware :3)

---

## Quick Start

In your `flake.nix` file:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ysyldur.url = "github:givikuna/ysyldur";

    # optional for chaotic nyx
    # ysyldur.inputs.chaotic.follows = "chaotic";
    # chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, ysyldur, ... }@inputs: {
    nixosConfigurations.LarryTheSkeleton = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit ysyldur;
        inherit (inputs) chaotic;
      };

      modules = [
        ysyldur.nixosModules.default
        # with chaotic nyx
        # ysyldur.nixosModules.withChaotic

        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };
  };
}
```

You can now import `ysyldur` into any NixOS module:

```nix
{ pkgs, ysyldur, lib, ... }:
{
  ysyldur = {
    boot.packages.variant = "zen";
    boot.sysctl.profiles.gaming-minotaur.enable = true;
  };
}
```

---

## Using the flake

### NixOS modules exposed

| Attribute                  | Description                                                                                          |
| -------------------------- | ---------------------------------------------------------------------------------------------------- |
| `nixosModules.default`     | The ysyldur module.                                                                                  |
| `nixosModules.ysyldur`     | Alias of `default`.                                                                                  |
| `nixosModules.withChaotic` | `default` **plus** the upstream Chaotic-Nyx NixOS module (only if the `chaotic` input is available). |

### Overlays exposed

| Attribute          | Description                                         |
| ------------------ | --------------------------------------------------- |
| `overlays.default` | The Chaotic-Nyx overlay (only if `chaotic` exists). |

### Packages / Checks

- `packages.${system}.tests` — the nixtest test runner.
- `checks.${system}.tests` — a derivation that runs the test suite.

---

## Module overview

The module tree is imported through `modules/default.nix`:

```
ysyldur
├── boot
│   ├── version         # kernel version pinning
│   ├── packages        # kernel variant selection, extra module packages
│   ├── modules         # load / initrd / blacklist / modprobe
│   ├── config          # Kconfig structured config + kernel patches
│   ├── params          # kernel command-line params
│   ├── sysctl          # sysctls & profiles
│   ├── io-scheduler    # udev rules for I/O schedulers
│   └── coredump        # core dump controls
├── drivers             # amdgpu, NVIDIA branches, xone, xpadneo
├── services
│   └── scx             # sched_ext scheduler selection
└── chaotic             # Chaotic-Nyx overlay auto-injection
```

---

## Boot

### Kernel variants (`ysyldur.boot.packages.kernel-variant` + `ysyldur.boot.packages.variant`)

Selecting a kernel variant can be done in two equivalent ways:

- **Shorthand:** `ysyldur.boot.packages.variant = "zen";`
- **Toggle:** `ysyldur.boot.packages.kernel-variant.zen.enable = true;`

Only one variant may be enabled at a time; enabling two (via either mechanism) fails an assertion.

Available variants:

| Name               | Underlying nixpkgs attribute             | Notes                                    |
| ------------------ | ---------------------------------------- | ---------------------------------------- |
| `default`          | `linuxPackages`                          |                                          |
| `latest`           | `linuxPackages_latest`                   |                                          |
| `libre`            | `linuxPackages-libre`                    |                                          |
| `testing`          | `linuxPackages_testing`                  |                                          |
| `testing-bcachefs` | `linuxPackages_testing_bcachefs`         | May be `null` on some nixpkgs revisions. |
| `rt`               | `linuxPackages-rt`                       |                                          |
| `tinyconfig`       | `linuxPackages_custom_tinyconfig_kernel` |                                          |
| `zen`              | `linuxPackages_zen`                      |                                          |
| `lqx`              | `linuxPackages_lqx`                      |                                          |
| `rpi0`             | `linuxPackages_rpi0`                     |                                          |
| `rpi02w`           | `linuxPackages_rpi02w`                   |                                          |
| `rpi1`             | `linuxPackages_rpi1`                     |                                          |
| `rpi2`             | `linuxPackages_rpi2`                     |                                          |
| `rpi3`             | `linuxPackages_rpi3`                     |                                          |
| `rpi4`             | `linuxPackages_rpi4`                     |                                          |
| `cachyos`          | `linuxPackages_cachyos`                  | Requires Chaotic-Nyx overlay.            |
| `cachyos-gcc`      | `linuxPackages_cachyos-gcc`              | Requires Chaotic-Nyx overlay.            |
| `cachyos-lts`      | `linuxPackages_cachyos-lts`              | Requires Chaotic-Nyx overlay.            |
| `cachyos-server`   | `linuxPackages_cachyos-server`           | Requires Chaotic-Nyx overlay.            |
| `cachyos-hardened` | `linuxPackages_cachyos-hardened`         | Requires Chaotic-Nyx overlay.            |
| `cachyos-rc`       | `linuxPackages_cachyos-rc`               | Requires Chaotic-Nyx overlay.            |
| `cachyos-lto`      | `linuxPackages_cachyos-lto`              | Requires Chaotic-Nyx overlay.            |
| `cachyos-bore`     | `linuxPackages_cachyos-bore`             | Requires Chaotic-Nyx overlay.            |
| `xanmod-default`   | `linuxPackages_xanmod`                   |                                          |
| `xanmod-latest`    | `linuxPackages_xanmod_latest`            |                                          |
| `xanmod-stable`    | `linuxPackages_xanmod_stable`            |                                          |
| `xen_dom0`         | `linuxPackages_xen_dom0`                 |                                          |

**Read-only helpers on `ysyldur.boot.packages`:**

- `selectedVariantName` — internal resolved name of the active variant (or `null`).
- `resolvedBaseKernelPackages` — the resolved base `boot.kernelPackages` set before version pinning.
- `kernel-variant.<name>.package` — the raw package set for each variant.

### Kernel versions (`ysyldur.boot.version`)

Pin a specific kernel version from nixpkgs alongside a variant:

```nix
ysyldur.boot.version.version = "6.6";     # dotted form
ysyldur.boot.version.version = "6.6";     # underscore form also accepted
ysyldur.boot.version.versions."6_6".enable = true;  # toggle form
```

Only one version may be selected at a time. Not every variant supports version pinning — the module asserts and errors out if you request an unsupported combination (e.g. `zen` + `6.6`). Supported combinations:

- Plain numbered versions: `<version>` → `linuxPackages_<version>`
- Variant `rt` + version `latest` → `linuxPackages-rt_latest`
- Variant `rt` + version `N_M` → `linuxPackages_rt_N_M`
- Variant `libre` + `latest` → `linuxPackages_latest-libre`
- Variant `xen_dom0` + `latest` → `linuxPackages_latest_xen_dom0`
- Variant `xanmod-default` + `latest` → `linuxPackages_xanmod_latest`

Available version keys: `4_9`, `4_14`, `4_19`, `5_4`, `5_10`, `5_15`, `5_18`, `5_19`, `6_0` … `6_19`, and `latest`.

### Extra kernel module packages (`ysyldur.boot.packages.extra-packages`)

Convenience toggles that add an out-of-tree kernel module package to `boot.extraModulePackages` and load its module(s) automatically.

| Option                                                     | Package attribute            | Modules loaded                           |
| ---------------------------------------------------------- | ---------------------------- | ---------------------------------------- |
| `ysyldur.boot.packages.extra-packages.acpi_call.enable`    | `linuxPackages.acpi_call`    | `acpi_call`                              |
| `ysyldur.boot.packages.extra-packages.bbswitch.enable`     | `linuxPackages.bbswitch`     | `bbswitch` (unless `loadModule = false`) |
| `ysyldur.boot.packages.extra-packages.ddcci.enable`        | `linuxPackages.ddcci-driver` | `ddcci`, `ddcci_backlight`               |
| `ysyldur.boot.packages.extra-packages.evdi.enable`         | `linuxPackages.evdi`         | `evdi`                                   |
| `ysyldur.boot.packages.extra-packages.v4l2loopback.enable` | `linuxPackages.v4l2loopback` | `v4l2loopback`                           |
| `ysyldur.boot.packages.extra-packages.zenpower.enable`     | `linuxPackages.zenpower`     | `zenpower` + blacklists `k10temp`        |

For arbitrary module packages by name:

```nix
ysyldur.boot.packages.extraModulePackageNames = [ "v4l2loopback" "acpi_call" ];
```

This maps each name to `config.boot.kernelPackages.<name>` and appends to `boot.extraModulePackages`. This is useful for module packages not covered by the presets.

### Kernel config & patches (`ysyldur.boot.config`)

Structured Kconfig: build a single `boot.kernelPatches` entry that sets Kconfig symbols.

```nix
ysyldur.boot.config = {
  yes = [ "NTSYNC" "LRU_GEN" ];         # -> =y
  no = [ "DEBUG_KERNEL" ];              # -> =n
  module = [ "V4L2_LOOPBACK" ];         # -> =m
  freeform = { HZ = "1000"; };          # arbitrary
  patches = [
    { name = "my-patch"; patch = ./my.patch; }
  ];
};
```

| Option     | Type           | Description                                              |
| ---------- | -------------- | -------------------------------------------------------- |
| `yes`      | `listOf str`   | Symbols to set to `=y`.                                  |
| `no`       | `listOf str`   | Symbols to set to `=n`.                                  |
| `module`   | `listOf str`   | Symbols to set to `=m`.                                  |
| `freeform` | `attrsOf str`  | Symbols to set to a specific string value.               |
| `patches`  | `listOf attrs` | Additional patch items appended to `boot.kernelPatches`. |

When any of these are set, a patch named `ysyldur-structured-kconfig` is prepended to `boot.kernelPatches`.

### Kernel modules (`ysyldur.boot.modules`)

Load kernel modules at boot (maps to `boot.kernelModules`).

```nix
ysyldur.boot.modules = {
  load = [ "custom_mod" ];
  presets = {
    kvm-intel.enable = true;
    kvm-amd.enable = true;
    ntsync.enable = true;
    uhid.enable = true;
    uinput.enable = true;
  };
};
```

| Option                     | Module loaded |
| -------------------------- | ------------- |
| `presets.kvm-intel.enable` | `kvm-intel`   |
| `presets.kvm-amd.enable`   | `kvm-amd`     |
| `presets.ntsync.enable`    | `ntsync`      |
| `presets.uhid.enable`      | `uhid`        |
| `presets.uinput.enable`    | `uinput`      |

### Blacklisting modules (`ysyldur.boot.modules.blacklist`)

Maps to `boot.blacklistedKernelModules`.

```nix
ysyldur.boot.modules.blacklist = {
  modules = [ "custom_bad_mod" ];
  presets = {
    pcspkr.enable = true;
    nouveau.enable = true;
    firewire.enable = true;
    thunderbolt.enable = true;
    webcam.enable = true;
    bluetooth.enable = true;
  };
};
```

| Preset        | Blacklisted modules                                                   |
| ------------- | --------------------------------------------------------------------- |
| `pcspkr`      | `pcspkr`, `snd_pcsp`                                                  |
| `nouveau`     | `nouveau`                                                             |
| `firewire`    | `firewire-core`, `firewire-ohci`, `firewire-sbp2`, `ohci1394`, `sbp2` |
| `thunderbolt` | `thunderbolt`                                                         |
| `webcam`      | `uvcvideo`                                                            |
| `bluetooth`   | `btusb`, `bluetooth`                                                  |

### Initrd modules (`ysyldur.boot.modules.initrd`)

```nix
ysyldur.boot.modules.initrd = {
  available = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  load = [ "amdgpu" "dm-snapshot" ];
};
```

| Option      | Maps to                              |
| ----------- | ------------------------------------ |
| `available` | `boot.initrd.availableKernelModules` |
| `load`      | `boot.initrd.kernelModules`          |

### Modprobe options (`ysyldur.boot.modules.modprobe`)

Structured modprobe config rendered into `boot.extraModprobeConfig`.

```nix
ysyldur.boot.modules.modprobe = {
  options = {
    nvidia = {
      NVreg_PreserveVideoMemoryAllocations = 1;
      NVreg_UsePageAttributeTable = 1;
    };
    snd_hda_intel = { power_save = 0; };
  };
  extraConfig = "softdep amdgpu pre: vfio-pci";
};
```

`options` accepts an attribute set of module names → attribute sets of key/value pairs (values may be `str`, `int`, or `bool`). `extraConfig` is appended verbatim as `lines`.

### Kernel parameters (`ysyldur.boot.params`)

All kernel params are appended to `boot.kernelParams`. Options are grouped per file. Unset (`null`) options do nothing.

#### `ysyldur.boot.params.split_lock_detect`

- Type: `nullOr (enum [ "off" "warn" "fatal" ])`.
- `"off"` reduces stuttering in some games. `null` lets the kernel decide.

#### `ysyldur.boot.params` (CPU)

| Option         | Values                                         | Emits                                            |
| -------------- | ---------------------------------------------- | ------------------------------------------------ |
| `mitigations`  | `off` \| `auto` \| `auto,nosmt`                | `mitigations=<value>`                            |
| `preempt`      | `none` \| `voluntary` \| `full`                | `preempt=<value>`                                |
| `amd_pstate`   | `active` \| `passive` \| `guided` \| `disable` | `amd_pstate=<value>`                             |
| `intel_pstate` | `active` \| `passive` \| `disable` \| `no_hwp` | `intel_pstate=<value>`                           |
| `nowatchdog`   | `bool`                                         | `nowatchdog`, `nmi_watchdog=0`, `tsc=nowatchdog` |

#### `ysyldur.boot.params` (graphics)

| Option               | Values        | Emits                                                          |
| -------------------- | ------------- | -------------------------------------------------------------- | --- |
| `nvidia_drm_modeset` | `nullOr bool` | `nvidia-drm.modeset=1                                          | 0`  |
| `nvidia_drm_fbdev`   | `nullOr bool` | `nvidia-drm.fbdev=1                                            | 0`  |
| `quietSplash`        | `bool`        | `quiet`, `splash`, `loglevel=3`, `rd.systemd.show_status=auto` |

#### `ysyldur.boot.params` (IOMMU)

| Option        | Values                                        | Emits                 |
| ------------- | --------------------------------------------- | --------------------- |
| `iommu`       | `pt` \| `on` \| `off` \| `force` \| `noforce` | `iommu=<value>`       |
| `intel_iommu` | `on` \| `off` \| `igfx_off` \| `forcedac`     | `intel_iommu=<value>` |
| `amd_iommu`   | `on` \| `off` \| `force_isolation` \| `pt`    | `amd_iommu=<value>`   |

#### `ysyldur.boot.params` (memory / zswap)

| Option                   | Values                                           | Emits                          |
| ------------------------ | ------------------------------------------------ | ------------------------------ | --- |
| `transparent_hugepage`   | `always` \| `madvise` \| `never`                 | `transparent_hugepage=<value>` |
| `zswap.enable`           | `nullOr bool`                                    | `zswap.enabled=1               | 0`  |
| `zswap.compressor`       | `zstd` \| `lz4` \| `lzo` \| `lz4hc` \| `deflate` | `zswap.compressor=<value>`     |
| `zswap.max_pool_percent` | `nullOr int`                                     | `zswap.max_pool_percent=<int>` |
| `zswap.zpool`            | `zsmalloc` \| `zbud` \| `z3fold`                 | `zswap.zpool=<value>`          |

#### `ysyldur.boot.params` (power)

| Option                                | Values                                                                            | Emits                                       |
| ------------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------- |
| `pcie_aspm`                           | `default` \| `powersave` \| `powersupersave` \| `performance` \| `off` \| `force` | `pcie_aspm=<value>`                         |
| `nvme_core_default_ps_max_latency_us` | `nullOr int`                                                                      | `nvme_core.default_ps_max_latency_us=<int>` |

Setting `nvme_core_default_ps_max_latency_us = 0` disables APST, which often fixes NVMe freeze issues.

#### `ysyldur.boot.params` (security)

| Option          | Values                                     | Emits              |
| --------------- | ------------------------------------------ | ------------------ | --- |
| `lockdown`      | `none` \| `integrity` \| `confidentiality` | `lockdown=<value>` |
| `init_on_alloc` | `nullOr bool`                              | `init_on_alloc=1   | 0`  |
| `init_on_free`  | `nullOr bool`                              | `init_on_free=1    | 0`  |
| `slab_nomerge`  | `bool`                                     | `slab_nomerge`     |
| `pti`           | `on` \| `off` \| `auto`                    | `pti=<value>`      |

#### `ysyldur.boot.params.extra`

Freeform list of extra kernel params:

```nix
ysyldur.boot.params.extra = [ "tsc=reliable" "clocksource=tsc" ];
```

### Sysctl parameters (`ysyldur.boot.sysctl.params`)

Each option writes directly to `boot.kernel.sysctl."<name>"` when non-null.

| Option                                 | Type         | Notes                                                       |
| -------------------------------------- | ------------ | ----------------------------------------------------------- |
| `fs.inotify.max_user_watches`          | `nullOr int` | Useful for IDEs / indexers.                                 |
| `kernel.dmesg_restrict`                | `nullOr int` | 0 or 1.                                                     |
| `kernel.kptr_restrict`                 | `nullOr int` | 0, 1, or 2.                                                 |
| `kernel.nmi_watchdog`                  | `nullOr int` | 0 or 1.                                                     |
| `kernel.split_lock_mitigate`           | `nullOr int` | 0 to disable runtime mitigation (gaming).                   |
| `kernel.unprivileged_bpf_disabled`     | `nullOr int` | 0, 1, or 2.                                                 |
| `kernel.yama.ptrace_scope`             | `nullOr int` |                                                             |
| `net.core.default_qdisc`               | `nullOr str` | E.g. `fq`, `fq_codel`, `cake`.                              |
| `net.ipv4.conf.all.accept_redirects`   | `nullOr int` |                                                             |
| `net.ipv4.conf.all.rp_filter`          | `nullOr int` |                                                             |
| `net.ipv4.conf.default.rp_filter`      | `nullOr int` |                                                             |
| `net.ipv4.icmp_echo_ignore_broadcasts` | `nullOr int` |                                                             |
| `net.ipv4.tcp_congestion_control`      | `nullOr str` | Setting `bbr` auto-loads `tcp_bbr` in `boot.kernelModules`. |
| `net.ipv4.tcp_fastopen`                | `nullOr int` | `3` enables for client + server.                            |
| `net.ipv4.tcp_syncookies`              | `nullOr int` |                                                             |
| `net.ipv6.conf.all.accept_redirects`   | `nullOr int` |                                                             |
| `vm.dirty_background_ratio`            | `nullOr int` |                                                             |
| `vm.dirty_ratio`                       | `nullOr int` |                                                             |
| `vm.max_map_count`                     | `nullOr int` |                                                             |
| `vm.swappiness`                        | `nullOr int` |                                                             |
| `vm.vfs_cache_pressure`                | `nullOr int` |                                                             |

Plus:

- `ysyldur.boot.sysctl.params.extra` — `attrsOf (int | str | bool)` — arbitrary sysctls merged into `boot.kernel.sysctl`.

### Sysctl profiles (`ysyldur.boot.sysctl.profiles`)

Profiles are groups of `mkDefault` sysctls that you can override per-option by setting the corresponding `params.*` value (which will take precedence).

| Option                   | Effect                                 |
| ------------------------ | -------------------------------------- |
| `gaming-minotaur.enable` | Gaming-leaning defaults.               |
| `gaming.enable`          | Same defaults as `gaming-minotaur`.    |
| `security-nomad.enable`  | Hardened networking / kernel defaults. |
| `security.enable`        | Same defaults as `security-nomad`.     |

**`gaming-minotaur` defaults:**

| Sysctl                       | Value |
| ---------------------------- | ----- |
| `vm.swappiness`              | 10    |
| `vm.vfs_cache_pressure`      | 50    |
| `kernel.split_lock_mitigate` | 0     |
| `kernel.nmi_watchdog`        | 0     |

**`security-nomad` defaults:**

| Sysctl                                 | Value |
| -------------------------------------- | ----- |
| `vm.swappiness`                        | 100   |
| `net.ipv4.icmp_echo_ignore_broadcasts` | 1     |
| `net.ipv4.tcp_syncookies`              | 1     |
| `net.ipv4.conf.all.rp_filter`          | 1     |
| `net.ipv4.conf.default.rp_filter`      | 1     |
| `net.ipv4.conf.all.accept_redirects`   | 0     |
| `net.ipv6.conf.all.accept_redirects`   | 0     |
| `kernel.yama.ptrace_scope`             | 1     |
| `kernel.kptr_restrict`                 | 2     |
| `kernel.dmesg_restrict`                | 1     |
| `kernel.unprivileged_bpf_disabled`     | 1     |

### Block I/O schedulers (`ysyldur.boot.io-scheduler`)

Writes udev rules (`services.udev.extraRules`) to set per-device `queue/scheduler`.

```nix
ysyldur.boot.io-scheduler = {
  nvme = "none";
  ssd = "mq-deadline";
  hdd = "bfq";
};
```

| Option | Applies to                               | Values                                      |
| ------ | ---------------------------------------- | ------------------------------------------- |
| `nvme` | `nvme[0-9]*n[0-9]*`                      | `none` \| `mq-deadline` \| `kyber` \| `bfq` |
| `ssd`  | `sd[a-z]` / `mmcblk[0-9]*`, rotational=0 | same                                        |
| `hdd`  | `sd[a-z]`, rotational=1                  | same                                        |

### Core dumps (`ysyldur.boot.coredump`)

| Option         | Type                    | Effect                                                   |
| -------------- | ----------------------- | -------------------------------------------------------- | ------------------------------------------------ |
| `disable`      | `bool`                  | Disables `systemd.coredump`, sets `kernel.core_pattern = | /bin/false`, and adds a PAM hard limit `core=0`. |
| `suidDumpable` | `nullOr (enum [0 1 2])` | Sets `fs.suid_dumpable`.                                 |

---

## Drivers

### `ysyldur.drivers.amdgpu`

| Option      | Type   | Effect                                                                                             |
| ----------- | ------ | -------------------------------------------------------------------------------------------------- |
| `enable`    | `bool` | Adds `amdgpu` to `boot.initrd.kernelModules`; sets `services.xserver.videoDrivers = [ "amdgpu" ]`. |
| `overdrive` | `bool` | Adds `amdgpu.ppfeaturemask=0xffffffff` to `boot.kernelParams`.                                     |

### NVIDIA branches

Exactly one branch may be enabled. Each sets `hardware.nvidia.package` to `config.boot.kernelPackages.nvidiaPackages.<branch>`.

| Option                                     | Branch                                         |
| ------------------------------------------ | ---------------------------------------------- |
| `ysyldur.drivers.nvidia_stable.enable`     | `stable`                                       |
| `ysyldur.drivers.nvidia_beta.enable`       | `beta`                                         |
| `ysyldur.drivers.nvidia_production.enable` | `production`                                   |
| `ysyldur.drivers.nvidia_cachyos.enable`    | `cachyos` (from Chaotic-Nyx; asserts presence) |

### Game controllers

| Option                           | Effect                                 |
| -------------------------------- | -------------------------------------- |
| `ysyldur.drivers.xone.enable`    | Sets `hardware.xone.enable = true`.    |
| `ysyldur.drivers.xpadneo.enable` | Sets `hardware.xpadneo.enable = true`. |

---

## Services

### sched_ext (scx) (`ysyldur.services.scx`)

Enables the `scx` framework and selects a scheduler. Only one scheduler may be enabled at a time.

```nix
ysyldur.services.scx = {
  enable = true;
  scheduler.bpfland.enable = true;
  extraArgs = [ "--autopower" ];
};
```

| Option                    | Type         | Effect                                               |
| ------------------------- | ------------ | ---------------------------------------------------- |
| `enable`                  | `bool`       | Sets `services.scx.enable = true`.                   |
| `extraArgs`               | `listOf str` | Forwards to `services.scx.extraArgs` when non-empty. |
| `scheduler.<name>.enable` | `bool`       | Sets `services.scx.scheduler = "scx_<name>"`.        |

Available schedulers: `bpfland`, `cosmos`, `flash`, `lavd`, `layered`, `nest`, `p2dq`, `rustland`, `rusty`, `tickless`. Enabling more than one fails an assertion.

---

## Chaotic-Nyx integration

The `ysyldur.chaotic` options control whether the Chaotic-Nyx overlay is injected into `nixpkgs.overlays`.

| Option                        | Default | Description                                                                           |
| ----------------------------- | ------- | ------------------------------------------------------------------------------------- |
| `ysyldur.chaotic.enable`      | `false` | Unconditionally inject the overlay.                                                   |
| `ysyldur.chaotic.autoOverlay` | `true`  | Auto-inject the overlay when a CachyOS kernel variant or `nvidia_cachyos` is enabled. |

If the overlay is required (via either path) but the `chaotic` flake input is not available, an assertion fails with a helpful message.

---

## Full options reference

Below is a compact reference of every option exposed by `ysyldur.*`.

### `ysyldur.boot`

```
ysyldur.boot.config.yes                      -> listOf str
ysyldur.boot.config.no                       -> listOf str
ysyldur.boot.config.module                   -> listOf str
ysyldur.boot.config.freeform                 -> attrsOf str
ysyldur.boot.config.patches                  -> listOf attrs

ysyldur.boot.coredump.disable                -> bool
ysyldur.boot.coredump.suidDumpable           -> nullOr (enum [ 0 1 2 ])

ysyldur.boot.io-scheduler.nvme               -> nullOr (enum [ "none" "mq-deadline" "kyber" "bfq" ])
ysyldur.boot.io-scheduler.ssd                -> nullOr (enum [ "none" "mq-deadline" "kyber" "bfq" ])
ysyldur.boot.io-scheduler.hdd                -> nullOr (enum [ "none" "mq-deadline" "kyber" "bfq" ])

ysyldur.boot.modules.load                    -> listOf str
ysyldur.boot.modules.presets.kvm-intel.enable
ysyldur.boot.modules.presets.kvm-amd.enable
ysyldur.boot.modules.presets.ntsync.enable
ysyldur.boot.modules.presets.uhid.enable
ysyldur.boot.modules.presets.uinput.enable

ysyldur.boot.modules.blacklist.modules       -> listOf str
ysyldur.boot.modules.blacklist.presets.pcspkr.enable
ysyldur.boot.modules.blacklist.presets.nouveau.enable
ysyldur.boot.modules.blacklist.presets.firewire.enable
ysyldur.boot.modules.blacklist.presets.thunderbolt.enable
ysyldur.boot.modules.blacklist.presets.webcam.enable
ysyldur.boot.modules.blacklist.presets.bluetooth.enable

ysyldur.boot.modules.initrd.available        -> listOf str
ysyldur.boot.modules.initrd.load             -> listOf str

ysyldur.boot.modules.modprobe.options        -> attrsOf (attrsOf (str | int | bool))
ysyldur.boot.modules.modprobe.extraConfig    -> lines

ysyldur.boot.params.mitigations              -> nullOr (enum [ "off" "auto" "auto,nosmt" ])
ysyldur.boot.params.preempt                  -> nullOr (enum [ "none" "voluntary" "full" ])
ysyldur.boot.params.amd_pstate               -> nullOr (enum [ "active" "passive" "guided" "disable" ])
ysyldur.boot.params.intel_pstate             -> nullOr (enum [ "active" "passive" "disable" "no_hwp" ])
ysyldur.boot.params.nowatchdog               -> bool

ysyldur.boot.params.nvidia_drm_modeset       -> nullOr bool
ysyldur.boot.params.nvidia_drm_fbdev         -> nullOr bool
ysyldur.boot.params.quietSplash              -> bool

ysyldur.boot.params.iommu                    -> nullOr (enum [ "pt" "on" "off" "force" "noforce" ])
ysyldur.boot.params.intel_iommu              -> nullOr (enum [ "on" "off" "igfx_off" "forcedac" ])
ysyldur.boot.params.amd_iommu                -> nullOr (enum [ "on" "off" "force_isolation" "pt" ])

ysyldur.boot.params.transparent_hugepage     -> nullOr (enum [ "always" "madvise" "never" ])
ysyldur.boot.params.zswap.enable             -> nullOr bool
ysyldur.boot.params.zswap.compressor         -> nullOr (enum [ "zstd" "lz4" "lzo" "lz4hc" "deflate" ])
ysyldur.boot.params.zswap.max_pool_percent   -> nullOr int
ysyldur.boot.params.zswap.zpool              -> nullOr (enum [ "zsmalloc" "zbud" "z3fold" ])

ysyldur.boot.params.pcie_aspm                -> nullOr (enum [ "default" "powersave" "powersupersave" "performance" "off" "force" ])
ysyldur.boot.params.nvme_core_default_ps_max_latency_us -> nullOr int

ysyldur.boot.params.lockdown                 -> nullOr (enum [ "none" "integrity" "confidentiality" ])
ysyldur.boot.params.init_on_alloc            -> nullOr bool
ysyldur.boot.params.init_on_free             -> nullOr bool
ysyldur.boot.params.slab_nomerge             -> bool
ysyldur.boot.params.pti                      -> nullOr (enum [ "on" "off" "auto" ])

ysyldur.boot.params.split_lock_detect        -> nullOr (enum [ "off" "warn" "fatal" ])
ysyldur.boot.params.extra                    -> listOf str

ysyldur.boot.sysctl.params.<name>            -> per-option types, see table above
ysyldur.boot.sysctl.params.extra             -> attrsOf (int | str | bool)

ysyldur.boot.sysctl.profiles.gaming-minotaur.enable
ysyldur.boot.sysctl.profiles.gaming.enable
ysyldur.boot.sysctl.profiles.security-nomad.enable
ysyldur.boot.sysctl.profiles.security.enable

ysyldur.boot.packages.variant                -> nullOr (enum <variantNames>)
ysyldur.boot.packages.kernel-variant.<name>.enable
ysyldur.boot.packages.selectedVariantName    -> readOnly nullOr str
ysyldur.boot.packages.resolvedBaseKernelPackages -> readOnly nullOr raw
ysyldur.boot.packages.extraModulePackageNames -> listOf str

ysyldur.boot.packages.extra-packages.acpi_call.enable
ysyldur.boot.packages.extra-packages.bbswitch.enable
ysyldur.boot.packages.extra-packages.bbswitch.loadModule -> bool
ysyldur.boot.packages.extra-packages.ddcci.enable
ysyldur.boot.packages.extra-packages.evdi.enable
ysyldur.boot.packages.extra-packages.v4l2loopback.enable
ysyldur.boot.packages.extra-packages.zenpower.enable

ysyldur.boot.version.version                 -> nullOr str
ysyldur.boot.version.versions.<key>.enable
ysyldur.boot.version.selectedVersion         -> readOnly nullOr str
```

### `ysyldur.drivers`

```
ysyldur.drivers.amdgpu.enable                -> bool
ysyldur.drivers.amdgpu.overdrive             -> bool

ysyldur.drivers.nvidia_stable.enable         -> bool
ysyldur.drivers.nvidia_beta.enable           -> bool
ysyldur.drivers.nvidia_production.enable     -> bool
ysyldur.drivers.nvidia_cachyos.enable        -> bool

ysyldur.drivers.xone.enable                  -> bool
ysyldur.drivers.xpadneo.enable               -> bool
```

### `ysyldur.services.scx`

```
ysyldur.services.scx.enable                  -> bool
ysyldur.services.scx.extraArgs               -> listOf str
ysyldur.services.scx.scheduler.<name>.enable -> bool
```

### `ysyldur.chaotic`

```
ysyldur.chaotic.enable                       -> bool
ysyldur.chaotic.autoOverlay                  -> bool (default: true)
```

---

## Development

### Running the tests

The flake ships with a nixtest suite covering every module:

```sh
nix flake check
# or specifically
nix build .#checks.x86_64-linux.tests
```

Tests live under `tests/` and cover boot config, coredump, extra packages, IO scheduler, kernel variants, modules, params, sysctl, version, drivers, scx, chaotic integration, and a full NixOS system integration test.

### Adding a new kernel variant

1. Add the attribute in `modules/boot/packages/kernel-variant/variants.nix` (use `or null` for optional attributes).
2. If it belongs to Chaotic-Nyx, make sure the Chaotic auto-overlay logic in `modules/chaotic/default.nix` recognizes it (currently anything starting with `cachyos`).
3. Add a test entry in `tests/boot/kernel_variant_test.nix` and a mock set in `tests/helpers.nix` if it requires extra inputs.

### Adding a new sysctl option

1. Drop a new file in `modules/boot/sysctl/params/options/<name>.nix` following the existing pattern (a `nullOr` option that writes to `boot.kernel.sysctl` when non-null).
2. Import it from `modules/boot/sysctl/params/default.nix`.
3. Add a test in `tests/boot/sysctl_test.nix`.
