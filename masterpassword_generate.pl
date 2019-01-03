#!/usr/bin/perl
# by Ian Vitek
# 
# Takes 2 arguments.
# The first argument is the masterpassword that creates the encrypted code
# for masterpassword.pl.
# The second argument is the supersecret string that will be concatenated
# to the unique identifier for the masterpassword.pl generating script.
#

use Crypt::CBC;
use Getopt::Std;
use Term::ReadKey;

getopts('m:s:hv');
$ktemp="a";
$mtemp="a";

die "usage: $0 -m masterpassword -s supersecret_string\n" if($opt_h);

if (length($opt_m)>0) {
  $k=$opt_m;
} else {
  while($ktemp ne $k) {
    ReadMode 2; 
    print "Enter encryption password: ";
    chomp($ktemp = <STDIN>);
    print "\n";
    print "Enter encryption password again: ";
    chomp($k = <STDIN>);
    print "\n";
    ReadMode 0;
  }
}

if (length($opt_s)>0) {
  $m=$opt_s;
} else {
  while($mtemp ne $m) {
    ReadMode 2; 
    print "Enter supersecret password: ";
    chomp($mtemp = <STDIN>);
    print "\n";
    print "Enter supersecret again: ";
    chomp($m = <STDIN>);
    print "\n";
    ReadMode 0;
  }
}

while (length $k<32) { $k=$k . "\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04";}
$key=substr $k,0,32;

$c = Crypt::CBC->new( -key    => $key,
                      -cipher => 'Blowfish'
                    );
$m=~s/\'/\\\'/g;
                    
$text='$mp=\'' . $m .'\';$pass=sha256_base64($mp . $m);';
$encrypted=$c->encrypt_hex($text);
warn "Debug:\n$key\n$text\n$encrypted\n\n" if $opt_v;

$mps=<<'EOT1';
#!/usr/bin/perl
# by Ian Vitek
# 
# Takes 2 arguments.
# First argument is the masterpassword that decrypts the hidden encryption
# algorithm to generate a unique password for argument 2 (e.g IP-address)
#

use Crypt::CBC;
use Digest::SHA qw(sha256_base64);
use Getopt::Std;
use Term::ReadKey;

getopts('m:u:hv');

die "usage: $0 -m masterpassword -u unique_string\n" if($opt_h);

if (length($opt_m)>0) {
  $k=$opt_m;
} else {
    ReadMode 2; 
    print "Enter encryption password: ";
    chomp($k = <STDIN>);
    print "\n";
    ReadMode 0;
}

if (length($opt_u)>0) {
  $m=$opt_u;
} else {
    print "Enter unique string (e.g. IP): ";
    chomp($m = <STDIN>);
    print "\n";
}

EOT1

$mps=$mps . '$code="' . $encrypted . '";';

$mps=$mps . <<'EOT2';

while (length $k<32) { $k=$k . "\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04\x01\x02\x03\x04";}
$key=substr $k,0,32;

$c = Crypt::CBC->new( -key    => $key,
                      -cipher => 'Blowfish'
                    );

eval $c->decrypt_hex($code);
$password=substr $pass,0,24;
print "$password\n";
EOT2

open(MP,">masterpassword.pl");
print MP $mps;
