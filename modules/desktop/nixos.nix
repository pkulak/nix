{ self, inputs, ... }:
{
  flake.nixosModules.desktop =
    { config, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        (mpv.override { scripts = [ mpvScripts.sponsorblock ]; })

        amber
        cmatrix
        cowsay
        distrobox
        fastfetchMinimal
        ffmpegthumbnailer
        file
        imv
        libinput
        masterpdfeditor
        unstable.claude-code
        unstable.opencode
        sublime-merge
        woeusb
        zathura
        zenity
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
            monospace = [ "Ubuntu Mono" ];
          };
        };
      };

      environment.etc = with pkgs; {
        "jdk17".source = jdk17;
        "jdk11".source = jdk11;
      };

      virtualisation = {
        docker.rootless = {
          enable = true;
          setSocketVariable = true;
        };
        podman.enable = true;
      };
    };
}
