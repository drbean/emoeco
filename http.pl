# use AnyEvent;
use AnyEvent::HTTP;
 
my $loop = AnyEvent->condvar;

my $B='';

my $watcher = http_get "https://api.twitter.com/2/tweets/search/stream?tweet.fields=conversation_id&expansions=author_id&user.fields=created_at"
	, headers => {"Authorization" => "Bearer $B"}
	, sub {
   my ($body, $hdr) = @_;
 
   if ($hdr->{Status} =~ /^2/) {
      print $body . "\n";
   } else {
      print "error, $hdr->{Status} $hdr->{Reason}\n$body\n";
   }
};

$loop->recv;
