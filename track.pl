#!/usr/bin/perl
use strict;
use AnyEvent::Twitter::Stream;

if ($ENV{FIREHOSE_SERVER}) {
    $AnyEvent::Twitter::Stream::STREAMING_SERVER = $ENV{FIREHOSE_SERVER};
}

my $done = AE::cv;

my($user, $password, $method, %args) = @ARGV;

binmode STDOUT, ":utf8";

my $streamer = AnyEvent::Twitter::Stream->new(
    username => $user,
    password => $password,
    method   => $method || "sample",
    %args,
    use_compression => 1,
    on_tweet => sub {
        my $tweet = shift;
        print "$tweet->{user}{screen_name}: $tweet->{text}\n";
    },
    on_error => sub {
        my $error = shift;
        # warn "ERROR: $error";
        $done->send;
    },
    on_eof   => sub {
        $done->send;
    },
);

# # uncomment to test undef $streamer
# my $t = AE::timer 1, 0, sub { undef $streamer };

$done->recv;
