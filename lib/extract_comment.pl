#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use File::Basename;
use File::Find;
use File::Path qw( make_path );
use FindBin;

my $top_dir = "t";
my @exts = qw(.txt .php .js);

#recursive execution
my $hoge;
find( \&set_file_name, $top_dir );

for my $rec (@$hoge){
  extract_comment($rec->{dir}, $rec->{file});
}

sub set_file_name {
  my $file = $File::Find::dir."/".$_;
  (my $base, my $dir, my $ext) = fileparse($file, @exts);
  push(@$hoge, {dir => $dir, file =>$file}) if $ext;
}

sub extract_comment {
  my ($dir, $file_in) = @_;
  my $OUTPUT_DIR = Cwd::abs_path($FindBin::Bin . "/..")."/dump";

  my $dir_err;
  make_path( $OUTPUT_DIR."/".$dir, {
      verbose => 1,   # log output on
      error => \$dir_err  # error info
  });
  print 'Create path error' if @{$dir_err};

  my $file_out = $OUTPUT_DIR."/".$file_in.".out";

  open my $fh_in, "<", $file_in or die "$file_in: $!"
    or die qq/Can't open file "$file_in" : $!/;
  open my $fh_out, '>', $file_out
    or die qq/Can't open file "$file_out" : $!/;

  while (my $line = <$fh_in>) {
    print $fh_out $1,"\n" if $line =~ /(\/\/.*)/;
  }

  close $fh_out;
  close $fh_in;
}

