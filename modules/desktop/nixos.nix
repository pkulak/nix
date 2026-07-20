{ self, ... }:
{
  flake.nixosModules.desktop =
    { pkgs, ... }:
    {
      imports = [ self.nixosModules.vm ];

      environment.systemPackages = with pkgs; [
        (mpv.override { scripts = [ mpvScripts.sponsorblock ]; })

        amber
        cmatrix
        cowsay
        distrobox
        fastfetch.minimal
        file
        imv
        libinput
        llm-agents.claude-code
        masterpdfeditor
        sublime-merge
        via
        woeusb
        zathura
        zoom-us
      ];

      programs = {
        dconf.enable = true;
        seahorse.enable = true;
      };

      services = {
        printing.enable = true;
        earlyoom = {
          enable = true;
          enableNotifications = true;
        };
        gnome = {
          gnome-keyring.enable = true;
          gcr-ssh-agent.enable = false;
        };
        flatpak.enable = true;
      };

      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          cantarell-fonts
          font-awesome
          nerd-fonts.fantasque-sans-mono
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          ubuntu-classic
        ];
        fontconfig = {
          defaultFonts = {
            serif = [ "Noto Serif" ];
            sansSerif = [ "Cantarell" ];
            monospace = [ "FantasqueSansM Nerd Font Mono" ];
          };
        };
      };

      environment.etc = with pkgs; {
        "jdk25".source = "${jdk25}/lib/openjdk";
        "jdk17".source = "${jdk17}/lib/openjdk";
      };

      virtualisation = {
        docker.rootless = {
          enable = true;
          setSocketVariable = true;
          daemon.settings = {
            dns = [
              "1.1.1.1"
              "8.8.8.8"
            ];
          };
        };
        podman.enable = true;
      };
    };
}
