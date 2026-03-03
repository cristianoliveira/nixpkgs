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
  inherit (import ./qmd pkgs) qmd;
  inherit (import ./gogcli pkgs) gogcli;
  inherit (import ./funzzy pkgs) funzzy funzzyNightly;
  inherit (import ./pi pkgs) pi;
}
