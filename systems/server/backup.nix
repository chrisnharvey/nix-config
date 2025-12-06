{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Install restic
  environment.systemPackages = with pkgs; [
    restic
  ];

  # Restic Prometheus Exporter
  services.prometheus.exporters.restic = {
    enable = true;
    repository = "s3:x3y4.ldn.idrivee2-20.com/harvey-backups-restic";
    passwordFile = "/root/restic/.encryption-key";
    environmentFile = "/root/restic/.env";
    refreshInterval = 300;
  };

  # Restic backup service
  services.restic.backups = {
    daily-backup = {
      # Paths to backup
      paths = [
        "/data/data/files"
        "/vms/data"
      ];

      # S3 repository
      repository = "s3:x3y4.ldn.idrivee2-20.com/harvey-backups-restic";

      # Encryption key file path
      passwordFile = "/root/restic/.encryption-key";

      # S3 credentials
      # Format:
      # AWS_ACCESS_KEY_ID=your-access-key-id
      # AWS_SECRET_ACCESS_KEY=your-secret-access-key
      environmentFile = "/root/restic/.env";

      # Backup schedule (daily at 1am)
      timerConfig = {
        OnCalendar = "01:00";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };

      # Pruning configuration
      pruneOpts = [
        "--keep-daily 7" # Keep 7 daily backups
        "--keep-weekly 2" # Keep 4 weekly backups
      ];

      # Additional backup options
      extraBackupArgs = [
        "--verbose"
        "--exclude-caches"
        "--exclude-if-present .nobackup"
      ];

      # Check repository integrity monthly
      checkOpts = [
        "--with-cache"
      ];

      # Initialize the repository if it doesn't exist
      initialize = true;
    };
  };
}
