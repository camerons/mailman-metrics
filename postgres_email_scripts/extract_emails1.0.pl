#!/usr/bin/perl

################################################################################
# Search through postgres already downloaded postgres email archives and extract
# email addresses from Australia and New Zealand.
################################################################################

my $subject="";
my $from="";
my $match=0;

# loop through most files in current directory
opendir(DIR, ".") or die $!;
while (my $file = readdir(DIR)) {
  # skip some filenames
  $file =~ m/.pl$/ && next;
  $file =~ m/.sh$/ && next;
  $file =~ m/x$/ && next;
  $file =~ m/y$/ && next;
  $file =~ m/z$/ && next;

  open FILE, "<", $file or die $!;
  while (my $line = <FILE>) {
    chomp($line);
    if ($line =~ "^Subject:") { $subject=$line; }
    if ($line =~ "^From:") { $from=$line; }
    if (
      $line =~ '\+61 ' ||
      $line =~ '\+64 '

    ) {
      $phone.=$line;
      $phone.=" ";
    }

    if (
      $line =~ "^From:.*\.au>" ||
      $line =~ "^From:.*\.nz>" ||
      $line =~ '\+61 ' ||
      $line =~ '\+64 ' ||
      $line =~ "New Zealand" ||
      $line =~ "NEW ZEALAND" ||
      $line =~ "Australia" ||
      $line =~ "AUSTRALIA"

    ) {
      $match=$line;
    }

    # Match first line of an email. Print out previously matched email.
    if ($match && $line =~ "^From .*\@postgresql.org") {
      print $from, "|", $file, "|", $subject, "|", $phone, "|", $match;
      print "$from|$file|$subject|$phone|$match\n";
      $match=0;
      $phone="";
    }
  }
}

# Check last email
# Match first line of an email. Print out previously matched email.
if ($match && $line =~ "^From .*\@postgresql.org") {
  print "$from|$file|$subject|$phone|$match\n";
}
