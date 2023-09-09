{
  environment.variables.EDITOR = "nvim";

  programs.nixvim.enable = true;

  programs.nixvim.options = {
    number = true;

    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;

    smartindent = true;
  };

  programs.nixvim.plugins = {
    lsp = {
      enable = true;
      servers.nil_ls.enable = true;
    };

    noice = {
      enable = true;
    };

    neo-tree = {
      enable = true;
    };

    neogit = {
      enable = true;
    };
  };
}
