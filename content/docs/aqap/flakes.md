---
title: Flakes AQAP
type: docs
sidebar:
  open: true
---

> [!IMPORTANT]
> Learn how to use `nix-shell` first.

Flakes allow for nix operations to be fully reproducible by creating a lock file (`flake.lock`) in the same directory as the `flake.nix` file.

`flake.nix` files contains two main attributes, `inputs` and `outputs`.

```nix {filename=flake.nix}
{
  description = "This is an example flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # ...
  };

  outputs = { self, nixpkgs, ... }: {
    devShells = ...;
    packages = ...;
    # ...
  };
}
```

When a flake is run, its inputs are evaluated and passed to `outputs`. As you might have already guessed, the `nixpkgs` present within `inputs` is passed to `outputs` as an argument after evaluation.

The inputs are typically other flakes but they need not be.

These inputs are locked with their respective hash in the `flake.lock` file.

> [!TIP]
> It is not a good idea to edit the lock file manually. Use `nix flake` command for ease.

## Inputs

`nixpkgs` is the conventional name for the main nix package source. It can be pointed to any branch or revision you want. Typically `nixos-unstable` is used if you want an archlinux like experience, gaining access to bleeding edge packages. Or you can stick to the latest release if you care of stability more than anything. As of writing this article, the latest release is `nixos-24.11`.

## Quick Usage

Create a directory and in the root of the directory, create a `flake.nix` file with the content provided here:

```nix {filename=flake.nix}
{
  description = "This is an example flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # ...
  };

  outputs = { self, nixpkgs, ... }:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
  in
  {
    devShells."x86_64-linux".default = pkgs.mkShell {
        buildInputs = [ pkgs.hello ];
    };
  };
}
```

Explanation:

  1. Within outputs, `pkgs` is brought to scope which contains all the x86_64 packages for linux.
  2. A development shell is defined for x86_64 containing the package `hello`.
  3. Notic how both `hello` and `mkShell` are from nixpkgs / pkgs.

Enter the shell environment using `nix develop`. It is similar to `nix-shell` but for flakes.

> [!NOTE]
> Do not confuse `nix-shell` with `nix shell`. The flake version of `nix-shell` is `nix develop`.
