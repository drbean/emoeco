use AnyEvent::Twitter::Stream;
 
my $done = AE::cv;

my $user = 'beancounterbean';
my $password = '19491949';
my $token = 'bHSrhpFZ9uzpXzqthQkqUjprI';
my $token_secret = 'sLUR0M8FVLfeTbrKD9eeLh3zEITPfoNZCg9o8xupPK2fpnolvN';
 
# receive updates from @following_ids
my $listener = AnyEvent::Twitter::Stream->new(
    # consumer_key    => $consumer_key,
    # consumer_secret => $consumer_secret,
    token           => $token,
    token_secret    => $token_secret,
    method          => "filter",
    username => $user,
    password => $password,
    method   => "filter",  # "firehose" for everything, "sample" for sample timeline
    follow   => join(",", @following_ids), # numeric IDs
    on_tweet => sub {
        my $tweet = shift;
        warn "$tweet->{user}{screen_name}: $tweet->{text}\n";
    },
    on_keepalive => sub {
        warn "ping\n";
    },
    on_delete => sub {
        my ($tweet_id, $user_id) = @_; # callback executed when twitter send a delete notification
        ...
    },
    timeout => 45,
);
 
# track keywords
my $guard = AnyEvent::Twitter::Stream->new(
    username => $user,
    password => $password,
    method   => "filter",
    track    => "Perl,Test,Music",
    on_tweet => sub { },
);
 
## to use OAuth authentication
#my $listener = AnyEvent::Twitter::Stream->new(
#    consumer_key    => $consumer_key,
#    consumer_secret => $consumer_secret,
#    token           => $token,
#    token_secret    => $token_secret,
#    method          => "filter",
#    track           => "...",
#    on_tweet        => sub { ... },
#);
 
$done->recv;
