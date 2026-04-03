{
  description = "Phil's Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matui = {
      url = "github:pkulak/matui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = ""; # don't download OSX deps
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-claude = {
      url = "github:NixOS/nixpkgs/7a17139823551e1fb824ccca70540ff99dea0ea2";
    };

    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs:
    let match = inputs.import-tree.match ".*/default\\.nix";
    in inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ (match ./modules) (match ./hosts) ];
    };
}
