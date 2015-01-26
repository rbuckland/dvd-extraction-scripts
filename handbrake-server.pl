#!/usr/bin/perl

#
# Ramon Buckland ramon@thebuckland.com
#
#
# This is the handbrake-server .. it contiually watches the source folder (-s)
# and expects a Directory with "DVD_NAME"
#
#  some/source/folder/MY_DVD_NAME
#                     MY_OTHER_DVD
#
#  Each DVD Folder is a raw extracted "dump". Or the folder contains 1 or more .mkv files
#  It detects the DVD extracted folder as having a VIDEO_TS folder
#
# The script will skip folder that have a file called "COMPLETE" .. eg some/source/folder/MyHomeVideos/COMPLETE
# The script will skip folder that have a file called "PROCESSING" .. eg some/source/folder/MyHomeVideos/PROCESSING
#    - this signifies that the handbrake-server.pl (another one) is working on this folder 
#    
# Usage: perl handbrake-server.pl -s path/to/dvd-dumps -d path/to/where/you/want/m4v_files

use Getopt::Std;

$|=1;
$HANDBRAKECLI="/usr/bin/HandBrakeCLI";

  getopts('mvs:d:', \%opts);  # options as above. Values in %opts

  $sourceDir = $opts{'s'};
  $destDir = $opts{'d'};
  $mkvonly = $opts{'m'};
  $vidtsonly = $opts{'v'};

&log("Source folder is: " . $sourceDir);
&log("Destination folder is: " . $sourceDir);
&log("MKV ONLY is set") if $mkvonly;
&log("VIDEO_TS ONLY is set") if $vidtsonly;



while (1)  {

  opendir my $dh1, $sourceDir or die "$0: opendir: $!";
  while (defined(my $name = readdir $dh1)) {
    next unless -d "$sourceDir/$name";
    next if $name =~ /^\.\.?+$/;

    # we have one directory of a DVD Dump ..  or an MKV
    $fullpathSource = "$sourceDir/$name";

    $haveMkv = (`find "$fullpathSource" -name '*.mkv'`);
    $haveVideoTS = (-d "$fullpathSource/VIDEO_TS");

    next if ($mkvonly and $haveVideoTS);
    next if ($vidtsonly and $haveMkv);
    next if (! $haveMkv  and ! $haveVideoTS);

    
    # if there is a COMPLETE file then we will skip the dir
    if (-f "$fullpathSource/COMPLETE") { 
     &log("Marked as Complete :: " . $fullpathSource);
     next
    }

    if (-f "$fullpathSource/PROCESSING") { 
     &log("Another $0 is processing the directory.. skipping :: " . $fullpathSource);
     next
    }
 
    # if the size of the directory is stable over 20 seconds
    # the we will assume it is complete
 
    $dirSize1 = `du -s '$fullpathSource' | awk '{print \$1}'`;
    chomp $dirSize1;
    &log("[$name] directory size checking $dirSize1");
    next if $dirSize1 == 0;
    sleep 20 ;
    $dirSize2 = `du -s '$fullpathSource' | awk '{print \$1}'`;
    chomp $dirSize2;
 
    if ($dirSize1 != $dirSize2)  { 
      &log("[$name] files are still coming $dirSize1 (20secs) $dirSize2");
      next;
    }

    if (-d "$fullpathSource/VIDEO_TS") { 

       &log("RAW DVD Dump");
       system("touch '$fullpathSource/PROCESSING'");
       &ripTitle($fullpathSource,$sourceDir.'/'.$name.'.m4v');
       system("touch '$fullpathSource/COMPLETE'");
       unlink("$fullpathSource/PROCESSING");

    } else {

      next unless `find '$fullpathSource' -name '*.mkv'`;

      # we will name the m4v from the dir .. if there i more than 1 mkv .. the subsequnet ones
      # will ha=ve _2 etc
      &log("Checking as a MAKEMKV dir");
      opendir my $dh2, $fullpathSource, or die "$0: opendir: $!";
      system("touch '$fullpathSource/PROCESSING'");
      $count = 1;
      while (defined(my $mkvname = readdir $dh2)) {
         next unless -f "$fullpathSource/$mkvname" && $mkvname =~ /\.mkv$/;
         if ($count > 1) {
           $filename = $name.'_'.$count.'.m4v';
         } else {
           $filename = $name.'.m4v';
         }
         &ripTitle($fullpathSource.'/'.$mkvname,$sourceDir.'/'.$filename);
         $count = $count + 1;
      }
      unlink("$fullpathSource/PROCESSING");
      system("touch '$fullpathSource/COMPLETE'");
      closedir $dh2

    }
  }
  closedir $dh1;
  &log("next directory scan " . (time() + 30));
  sleep 30
}

sub log { 
 $message = shift;
 $time = localtime();
 print $time . " :: " . $message . "\n";
}


sub ripTitle {
   $source = shift;
   $dest = shift;
   &log( "$HANDBRAKECLI -i '$source' -o '$dest' --preset=\"High Profile\"");
   system("$HANDBRAKECLI -i '$source' -o '$dest' --preset=\"High Profile\"");
}


sub HELP_MESSAGE() { 

print <<EOHELP
 -s source_folder
 -o output_folder
EOHELP
;

}

