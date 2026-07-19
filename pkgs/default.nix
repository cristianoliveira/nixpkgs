# NUR packages
# This file exports all custom packages for the NUR repository
pkgs:
{
  # Import all packages using the standard pattern
  inherit (import ./opencode pkgs) opencode;
  inherit (import ./codex pkgs) codex;
  inherit (import ./ferrite pkgs) ferrite;
  inherit (import ./gob pkgs) gob;
  inherit (import ./beads pkgs) beads;
  inherit (import ./beads_viewer pkgs) beads_viewer;
  inherit (import ./confluence-cli pkgs) confluence-cli;
  inherit (import ./mcp-cli pkgs) mcp-cli;
  inherit (import ./putio-cli pkgs) putio-cli;
  inherit (import ./qmd pkgs) qmd;
  inherit (import ./gogcli pkgs) gogcli;
  inherit (import ./goplaces pkgs) goplaces;
  inherit (import ./funzzy pkgs) funzzy funzzyNightly;
  inherit (import ./pi pkgs) pi;
  inherit (import ./playwright-cli pkgs) playwright-cli;
  inherit (import ./zeroclaw pkgs) zeroclaw;
  inherit (import ./zclaw pkgs) zclaw;
  inherit (import ./opensubtitles pkgs) opensubtitles;
  inherit (import ./teamcity-cli pkgs) teamcity-cli;
  inherit (import ./deltoids pkgs) deltoids;
  inherit (import ./surf-cli pkgs) surf-cli;
  inherit (import ./sonarqube-cli pkgs) sonarqube-cli;
  inherit (import ./huggingface-hub pkgs) huggingface-hub;
  inherit (import ./websearch pkgs) websearch;
  inherit (import ./toon pkgs) toon;
}
// pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
  inherit (import ./pi-node pkgs) pi-node;
}
  // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
  inherit (import ./aerospace pkgs) aerospace;
  inherit (import ./cornerfix pkgs) cornerfix;
}
