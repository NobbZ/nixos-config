{
  services.monit.enable = true;

  services.monit.config = ''
    set daemon 30

    set httpd port 2812
      allow localhost
      allow 100.0.0.0/8
  '';
}
