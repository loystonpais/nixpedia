---
title: Asus Linux VFIO Guide
type: docs
prev: docs/articles/
---

Inspired from guide for arch and fedora at https://asus-linux.org/guides/vfio-guide/

It is recommended that you go through both the asus linux's guide and this guide at once.
Think of this guide as a nix mapping for the original guide.

As per https://asus-linux.org/guides/nixos/ install supergfxctl and asusctl

```nix
services.supergfxd.enable = true;

services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
};

# Optionally
systemd.services.supergfxd.path = [ pkgs.pciutils ];
```

### Enable Supergfxctl VFIO Mode

```nix
services.supergfxd.settings.vfio_enable = true;

# Rest of the settings for reference
services.supergfxd.settings = {
  mode = "Hybrid";
  vfio_save = true;
  gfx_vfio_enable = true;
  always_reboot = false;
  no_logind = false;
  logout_timeout_s = 180;
  hotplug_type = "None";
};
```

### Setting up the VM

Now setup libvirtd using this following configuration. We will be using qemu and enabling some functions that are necessary for windows to run

```nix
virtualisation.libvirtd = {
  enable = true;
  qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          })
          .fd
        ];
      };
    };
};
```

Install virt-manager using `programs.virt-manager.enable = true;`

Add your user to the necessary groups

```nix
users.users.<your username>.extraGroups = ["libvirtd" "kvm" "input"];
```

### Setting up evdev

Evdev allows you to pass your keyboard and mouse to the vm seemlessly by pressing both ctrl keys at the same time.
For this you need to add your devices to cgroup.

Lets say our devices are `/dev/input/by-id/usb-SINO_WEALTH_Gaming_KB-event-kbd` and `/dev/input/by-id/usb-Razer_Razer_DeathAdder_Essential-event-mouse`

They can be included using the following configuration. Note: The rest of the devices included are a must, do not remove them.

```nix
virtualisation.libvirtd.qemu.verbatimConfig =
  ''
    user = "<your username>"
    qroup = "kvm"
    cgroup_device_acl = [
        "/dev/input/by-id/usb-SINO_WEALTH_Gaming_KB-event-kbd",
        "/dev/input/by-id/usb-Razer_Razer_DeathAdder_Essential-event-mouse",
        "/dev/null", "/dev/full", "/dev/zero",
        "/dev/random", "/dev/urandom", "/dev/ptmx",
        "/dev/kvm", "/dev/rtc", "/dev/hpet"
    ]
  '';
```

## Quirks

You might need to run (once) `sudo virsh net-autostart default` to enable the network.
See https://nixos.wiki/wiki/Virt-manager

## Extras

### Filesystem passthrough

Add the package `virtiofsd` to allow filesystem passthrough.

`virtualisation.libvirtd.qemu.vhostUserPackages = with pkgs; [ virtiofsd ];`

You can also add it as a system package and set the binary path in the XML.

```nix
environment.systemPackages = [
  pkgs.virtiofsd
];
```

```xml
<filesystem type="mount" accessmode="passthrough">
  <driver type="virtiofs"/>
  <binary path="/run/current-system/sw/bin/virtiofsd"/>
  <source .../>
  <target .../>
  <address .../>
</filesystem>
```

### USB Redirection

You can add this configuration to allow usb redirection at runtime.
`virtualisation.spiceUSBRedirection.enable = true;`

## More

Using virt-manager: https://nixos.wiki/wiki/Virt-manager <br/>
Libvirt, spice, webbrowser setup: https://nixos.wiki/wiki/Libvirt
