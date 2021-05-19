# use AnyEvent;
use AnyEvent::HTTP;
 
my $loop = AnyEvent->condvar;

my $B='';

my $watcher = http_get "https://api.twitter.com/2/tweets/search/stream/rules"
	, headers => {"Authorization" => "Bearer $B", "Content-type" => "application/json"}
	, {"delete" => {"ids" => ["1394519411847954437"]}}
	, sub {
   my ($body, $hdr) = @_;
 
   if ($hdr->{Status} =~ /^2/) {
      print $body . "\n";
   } else {
      print "error, $hdr->{Status} $hdr->{Reason}\n$body\n";
   }
};

$loop->recv;
