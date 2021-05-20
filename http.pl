# use AnyEvent;
use AnyEvent::HTTP;
 
my $loop = AnyEvent->condvar;

my $B='AAAAAAAAAAAAAAAAAAAAAKUUOgEAAAAAMWeLE6TKmaiWRf0P5iim8zTu7Zw%3DXBk8asJuXVq05Hun6E4zQELvQA6fDoebo9Cf0q2pBMdmSCK6vy';

my $watcher = http_post "https://api.twitter.com/2/tweets/search/stream/rules"
	, headers => {"Authorization" => "Bearer $B"
			, "Content-type" => "application/json"
	}
	, body =>
	#'{"delete":{"ids":["1395276321266159619"]}}'
	  '{
	    "add": [
	      {"value": "\uD83D\uDE01 lang:en", "tag": "😀"},
	    ]
	  }'
	, sub {
   my ($body, $hdr) = @_;
 
   if ($hdr->{Status} =~ /^2/) {
      print $body . "\n";
   } else {
      print "error, $hdr->{Status} $hdr->{Reason}\n$body\n";
   }
};

# $watcher->push_write( json => {"delete" => {"ids" => ["1394519411847954437"]}});
$loop->recv;
