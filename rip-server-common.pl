#!/usr/bin/perl


$|=1;

use strict;
use Switch;
use DVD::Read::Title;
use Fcntl qw(O_RDONLY O_NONBLOCK); 
require "sys/ioctl.ph";

my $title = DVD::Read::Title->new('/dev/sr0', 1);
print $title->video_format_txt . "\n";


use constant {
  CDS_NO_INFO => 0,
  CDS_NO_DISC => 1,
  CDS_TRAY_OPEN => 2,
  CDS_DRIVE_NOT_READY => 3,
  CDS_DISC_OK => 4
};

driveStatus("/dev/sr0");
getDvdTitle("/dev/sr0");


#
# Using the Table of Contents ioctl functions, we will read the name of the dvd
# to use as the name of the file (not the best name, but hopefully recognisable for a rename manually later by the user)
#
sub getDvdTitle {
  my $device = @_[0];
  print "Reading title from [".$device."]\n";
  my $tochdr=chr(0) x 16;

  my $CDROM_READ_TOCHDR=0x5305;
  sysopen(_DEV, $device, O_RDONLY | O_NONBLOCK) ;
  my $retval = ioctl(_DEV, $CDROM_READ_TOCHDR,$tochdr) || -1;
  my ($start,$end)=unpack "CC",$tochdr;
  print $retval . "\n";
  print $tochdr . "\n";
  print $start . "\n";
  print $end . "\n";
   
}

#
#  A function which takes one argument, the unix device filename of the DVD drive.
#  it will then read the drive and assess if there is a DVD ready to be read.
# 
sub driveStatus {
  my $device = @_[0];
  print "Checking drive status of [".$device."]\n";

  my $CDROM_DRIVE_STATUS=0x5326;

  sysopen(_DEV, $device, O_RDONLY | O_NONBLOCK) ;
  my $retval = ioctl(_DEV, $CDROM_DRIVE_STATUS,0) || -1;
  switch($retval) {
    case (CDS_NO_INFO) { print "CDS_NO_INFO" }
    case (CDS_NO_DISC) { print "CDS_NO_DISC"; }
    case (CDS_TRAY_OPEN) { print "CDS_TRAY_OPEN"; }
    case (CDS_DRIVE_NOT_READY) { print "CDS_DRIVE_NOT_READY"; }
    case (CDS_DISC_OK) { print "CDS_DISC_OK"; }
    else { die "error" }
  }
  print "\n";

  close _DEV;

}

