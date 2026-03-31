{
  window-rules = [
    {
      geometry-corner-radius = {
        top-left = 6.0;
        top-right = 6.0;
        bottom-right = 6.0;
        bottom-left = 6.0;
      };
      clip-to-geometry = true;
    }
    {
      matches = [{ app-id = ''firefox$''; title = ''^Picture-in-Picture$''; }];
      open-floating = true;
    }
  ];
}
