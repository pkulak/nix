{ self, inputs, lib, ... }: {
  flake.lib.mkHost = { 
    host, 
    system ? "x86_64-linux", 
    profile ? null, 
    nixosModules ? [], 
    homeModules ? [] 
  }: 
  inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit host; };
    modules = 
      lib.optional (profile != null) self.nixosModules.${profile} 
      ++ nixosModules 
      ++ [
        {
          home-manager.users.phil.imports = 
            lib.optional (profile != null) self.homeModules.${profile} 
            ++ homeModules;
        }
      ];
  };
}
