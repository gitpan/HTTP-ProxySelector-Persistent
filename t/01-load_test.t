#!perl -T

use Test::More tests => 53;

BEGIN {
  use_ok( 'LWP::UserAgent' );
  use_ok( 'BerkeleyDB' );
  use_ok( 'Date::Manip' );
  use_ok( 'HTTP::ProxySelector::Persistent' );
  use_ok( 'Cwd' );
}

diag( "Testing HTTP::ProxySelector::Persistent $HTTP::ProxySelector::Persistent::VERSION, Perl $], $^X" );

my $db_file = getcwd() . "/proxy_cache.bdb";
( $db_file ) = ( $db_file =~ /(.*)/s ); # untaint the cache database filename so I can delete it later
# Remove the cache database file if it is present
if (-e $db_file ) { unlink $db_file; }

my @testsites = ( "http://www.altavista.com", "http://www.yahoo.com", "http://www.google.com", "http://www.ask.com" );
my $num_tests = 15;
my $ua = LWP::UserAgent->new( timeout => 2 );

# download a proxylist that contains a mix of IP and dns named proxy servers and verify that we parsed it correctly
ok( my $selector = HTTP::ProxySelector::Persistent->new( db_file => $db_file ), 
    "Instantiated the HTTP::ProxySelector::Persistent object for the proxylist parsing test" );
isa_ok( $selector, HTTP::ProxySelector::Persistent, "HTTP::ProxySelector::Persistent->new(): Errors: $selector" );
ok( -e $db_file, "The HTTP::ProxySelector::Persistent->new() call created a new proxy database file" );

for ( my $i = 0; $i < $num_tests; $i++ ) {
  ok( $selector = HTTP::ProxySelector::Persistent->new( db_file => $db_file ), "Loop $i: Instantiate the ProxySelector in cache mode.\n\tError: $selector" );
  is( $selector->set_proxy( $ua ), 0, "Loop $i: Set the proxy on the useragent" );
  my $result = $ua->get( $testsites[ int( rand( $#testsites ) ) ] );
  ok( $result->is_success(), "Loop $i: Passed external proxy useragent test" );
}

unlink( $db_file );
