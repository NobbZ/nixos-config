{ pkgs, config, lib, ... }:
let
  packet-block-storage =
    pkgs.stdenv.mkDerivation {
      name = "packet-block-storage";
      src = pkgs.fetchFromGitHub {
        owner = "packethost";
        repo = "packet-block-storage";
        rev = "4be27cbca7a924b4de7af059d5ac30c2aa5c9e6f";
        sha256 = "0h4lpvz7v6xhl14kkwrjp202lbagj6wp2wqgrqdc6cfb4h0mf9fq";
      };
      nativeBuildInputs = [ pkgs.makeWrapper ];
      installPhase =
        let
          deps = with pkgs; [
            which
            jq
            curl
            gawk
            kmod
            openiscsi
            multipath-tools
          ];
          wrapIt = prog: ''
            cp ${prog} $out/bin
            chmod ugo+rx $out/bin/${prog}
            substituteInPlace $out/bin/${prog} --replace /lib/udev/scsi_id ${pkgs.udev}/lib/udev/scsi_id
            wrapProgram $out/bin/${prog} --prefix PATH : ${lib.makeBinPath deps}
          '';
        in
        ''
          mkdir -p $out/bin
          ${wrapIt "packet-block-storage-attach"}
          ${wrapIt "packet-block-storage-detach"}
        '';
    };

in
{
  environment.systemPackages = [ packet-block-storage pkgs.multipath-tools pkgs.openiscsi ];

  systemd.sockets.multipathd = {
    description = "multipathd control socket";
    before = [ "sockets.target" ];

    listenStreams = [ "@/org/kernel/linux/storage/multipathd" ];
  };

  systemd.services.multipathd = {
    description = "Device-Mapper Multipath Device Controller";
    before = [
      "iscsi.service"
      "iscsid.service"
    ];
    after = [ "multipathd.socket" "systemd-udevd.service" ];
    unitConfig = {
      DefaultDependencies = false;
    };
    wants = [ "multipathd.socket" "blk-availability.service" ];
    conflicts = [ "shutdown.target" ];
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "main";
      LimitCORE = "infinity";
      ExecStartPre = "${pkgs.kmod}/bin/modprobe -a dm-multipath";
      ExecStart = "${pkgs.multipath-tools}/bin/multipathd -d -s";
      ExecReload = "${pkgs.multipath-tools}/bin/multipathd reconfigure";
    };
  };

  systemd.targets.iscsi = {
    description = "iSCSI mounts";
    wants = [ "iscsid.service" "attach-block-storage.service" ];
    wantedBy = [ "remote-fs.target" ];
  };

  systemd.services.iscsid = {
    description = "iSCSI daemon";
    path = [ pkgs.openiscsi ];
    script = "iscsid -f";
  };

  systemd.services.attach-block-storage = {
    description = "Attach Packet.net block storage";
    requires = [ "network-online.target" "iscsid.service" "multipathd.service" ];
    after = [ "network-online.target" "iscsid.service" "multipathd.service" ];
    before = [ ];
    script = ''
      ${packet-block-storage}/bin/packet-block-storage-attach
    '';
  };
}
