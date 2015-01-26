#!/usr/bin/perl

$|=1;

# use strict;
use Switch;
use Fcntl qw(O_RDONLY O_NONBLOCK); 
require "sys/ioctl.ph";

my ($drive, $outputDir) = @ARGV;

my $MAKEMKVEXTRACTOR="/opt/dvd-extraction-scripts/makemkv-extractor.sh";

use constant {
  CDS_NO_INFO => 0,
  CDS_NO_DISC => 1,
  CDS_TRAY_OPEN => 2,
  CDS_DRIVE_NOT_READY => 3,
  CDS_DISC_OK => 4
};

if ( -f "/var/run/rip-dvd.pid" ) {
 exit 0;
}

my $driveStatus = driveStatus("/dev/sr0");
if ($driveStatus eq "OK") {
  system("echo $$ > /var/run/rip-dvd.pid");
  my $title = getDvdTitle("/dev/sr0");
  my @cmd = ($MAKEMKVEXTRACTOR, $drive, $outputDir, $title);
  print "//running [".join(' ',@cmd)."]\n";
  system(@cmd);
  system(('eject',$drive));
  unlink('/var/run/rip-dvd.pid');
}


#
# Using volname
#
sub getDvdTitle {
  my $device = @_[0];
  my $cmd = 'volname '. $device;
  my $title = `$cmd`;
  chomp($title);
  return $title;
}

#
#  A function which takes one argument, the unix device filename of the DVD drive.
#  it will then read the drive and assess if there is a DVD ready to be read.
# 
sub driveStatus {
  my $device = @_[0];
#  print "Checking drive status of [".$device."]\n";

  my $CDROM_DRIVE_STATUS=0x5326;

  sysopen(_DEV, $device, O_RDONLY | O_NONBLOCK) ;
  my $retval = ioctl(_DEV, $CDROM_DRIVE_STATUS,0) || -1;
  my $response = "NOTREADY";
  switch($retval) {
    case (CDS_NO_INFO) {}; # { print "CDS_NO_INFO" }
    case (CDS_NO_DISC) {}; # { print "CDS_NO_DISC"; }
    case (CDS_TRAY_OPEN) {}; # { print "CDS_TRAY_OPEN"; }
    case (CDS_DRIVE_NOT_READY) {}; # { print "CDS_DRIVE_NOT_READY"; }
    case (CDS_DISC_OK) { $response = "OK"; }
    else {}; # { die "error" }
  }
  close _DEV;
  return $response;

}

