{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;

    package = pkgs.wrapFirefox pkgs.unstable.firefox-unwrapped {
      extraPolicies = {
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;

        FirefoxHome = {
          Search = true;
          Pocket = false;
          Snippets = false;
          TopSites = false;
          Highlights = false;
        };

        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      };
    };

    profiles = {
      phil = {
        id = 0;
        name = "phil";

        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          consent-o-matic
          container-proxy
          decentraleyes
          don-t-fuck-with-paste
          ff2mpv
          link-cleaner
          onepassword-password-manager
          return-youtube-dislikes
          sponsorblock
          theater-mode-for-youtube
          ublock-origin
        ];

        search = {
          force = true;
          default = "Kagi";

          engines = {
            "Kagi" = {
              urls = [{
                template = "https://links.kulak.us";
                params = [{
                  name = "q";
                  value = "{searchTerms}";
                }];
              }];
            };

            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }];
              icon =
                "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };

            "NixOS Wiki" = {
              urls = [{
                template = "https://nixos.wiki/index.php?search={searchTerms}";
              }];
              icon = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@nw" ];
            };

            "wikipedia".metaData.alias = "@wiki";
            "google".metaData.hidden = true;
            "amazondotcom-us".metaData.hidden = true;
            "ebay".metaData.hidden = true;
          };
        };

        settings = {
          "general.smoothScroll" = true;
          "signon.rememberSignons" = false; # disable built-in password manager
        };

        extraConfig = ''
          user_pref("browser.tabs.closeWindowWithLastTab", false);
          user_pref("browser.toolbars.bookmarks.visibility", "never");
          user_pref("media.hardwaremediakeys.enabled", false);
          user_pref("media.ffmpeg.vaapi.enabled", true);
          user_pref("privacy.clearOnShutdown.cache", false);
          user_pref("privacy.clearOnShutdown.cookies", false);
          user_pref("privacy.clearOnShutdown.sessions", false);
          user_pref("privacy.history.custom", true);
          user_pref("gfx.webrender.compositor.force-enabled", true);
          user_pref("browser.ml.chat.enabled", false);
          user_pref("geo.provider.network.url", 'data:application/json,{"location": {"lat": 45.568259, "lng": -122.631719}, "accuracy": 128.0}');
        '';

        userContent = "";
      };
    };
  };
}
