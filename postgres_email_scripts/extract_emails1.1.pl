#!/usr/bin/perl

################################################################################
# Search through postgres already downloaded postgres email archives and extract
# email addresses from Australia and New Zealand.
################################################################################

my $subject="";
my $thread_start="";
my $from="";
my $email="";
my $first="";
my $name="";
my $match=0;
#my $file="pgsql-general.2012-06";

# loop through most files in current directory
opendir(DIR, ".") or die $!;
while (my $file = readdir(DIR)) {
  # skip some filenames
  $file =~ m/.pl$/ && next;
  $file =~ m/.sh$/ && next;
  $file =~ m/.csv$/ && next;
  $file =~ m/x$/ && next;
  $file =~ m/y$/ && next;
  $file =~ m/z$/ && next;

  open FILE, "<", $file or die $!;
  while (my $line = <FILE>) {
    chomp($line);
    if ($line =~ "^Subject:") {
      $subject=$line;
      if ($subject =~ "^Subject: Re: ") {
        $thread_start="";
      } else {
        $thread_start=$subject;
      }
    }
    if ($line =~ "^From:") {
      # Strip "From:"
      $from=$line;
      $from=~ s/^From: //;

      # Extract out email address
      $email=$from;
      $email=~ s/^.*<//;
      $email=~ s/>.*$//;

      # Extract out names
      $name=$from;
      $name=~ s/\w*<.*$//; # remove email
      chomp($name);
      # Remove Quotes
      $name=~s/"//g;
      
      # If in "Last, First" format, then reverse order
      if ($name=~/,/) {
        my @names=split(", ",$name);
        $first="$names[1]";
        $name="$names[1] $names[0]";
      } else {
        my @names=split(" ",$name);
        $first="$names[0]";
      }
    }
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
      print "$from|$first|$name|$email|$file|$subject|$thread_start|$phone|$match\n";
      $match=0;
      $phone="";
    }
  }
}

# Check last email
# Match first line of an email. Print out previously matched email.
if ($match && $line =~ "^From .*\@postgresql.org") {
  print "$from|$first|$name|$email|$file|$subject|$thread_start|$phone|$match\n";
}
