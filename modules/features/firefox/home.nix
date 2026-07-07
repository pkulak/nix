{ pkgs, ... }:

let
  firefoxAddons = pkgs.nur.repos.rycee.firefox-addons;

  amazonBrandFilter = firefoxAddons.buildFirefoxXpiAddon {
    pname = "amazonbrandfilter";
    version = "0.8.0";
    addonId = "abf@mosley.xyz";
    url = "https://addons.mozilla.org/firefox/downloads/file/4607441/amazonbrandfilter-0.8.0.xpi";
    sha256 = "sha256-CUXnBnG0v71c+Ysc9rtzSh4YOoKdh+Gapr1mrlnHHFs=";
    meta = with pkgs.lib; {
      homepage = "https://github.com/chris-mosley/AmazonBrandFilter";
      description = "Filters unknown brands from Amazon search results";
      license = licenses.mit;
      mozPermissions = [
        "storage"
        "activeTab"
        "*://*.amazon.com/*"
        "*://*.amazon.ca/*"
        "*://*.amazon.cn/*"
        "*://*.amazon.co.jp/*"
        "*://*.amazon.com.au/*"
        "*://*.amazon.com.mx/*"
        "*://*.amazon.co.uk/*"
        "*://*.amazon.de/*"
        "*://*.amazon.es/*"
        "*://*.amazon.fr/*"
        "*://*.amazon.in/*"
        "*://*.amazon.it/*"
        "*://*.amazon.nl/*"
      ];
      platforms = platforms.all;
    };
  };
in
{
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";

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

        extensions.packages = with firefoxAddons; [
          adsum-notabs
          amazonBrandFilter
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
              urls = [
                {
                  template = "https://links.kulak.us";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            "Nix Packages" = {
              urls = [
                {
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
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };

            "NixOS Wiki" = {
              urls = [
                {
                  template = "https://nixos.wiki/index.php?search={searchTerms}";
                }
              ];
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
          user_pref("browser.toolbars.bookmarks.visibility", "never");
          user_pref("media.hardwaremediakeys.enabled", false);
          user_pref("privacy.clearOnShutdown.cache", false);
          user_pref("privacy.clearOnShutdown.cookies", false);
          user_pref("privacy.clearOnShutdown.sessions", false);
          user_pref("privacy.history.custom", true);
          user_pref("browser.ml.chat.enabled", false);
          user_pref("browser.link.open_newwindow.override.external", 2);
          user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
          user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
          user_pref("geo.provider.network.url", 'data:application/json,{"location": {"lat": 45.568259, "lng": -122.631719}, "accuracy": 128.0}');
        '';

        userChrome = ''
          /* Hide tab bar */
          #TabsToolbar {
            visibility: collapse !important;
          }
        '';
      };
    };
  };

  home.file = {
    ".mozilla/native-messaging-hosts/ff2mpv.json".source =
      "${pkgs.ff2mpv}/lib/mozilla/native-messaging-hosts/ff2mpv.json";
  };
}
