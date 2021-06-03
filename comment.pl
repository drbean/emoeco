#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use JSON;
use Encode qw/encode decode/;

my $ua = LWP::UserAgent->new;

my $VI='BvJ1BuEtZEo';
my $KEY='';

my $url = "https://youtube.googleapis.com/youtube/v3/commentThreads?videoId=$VI&part=id,snippet,replies&maxResults=100&key=$KEY";

my ($req, $res, $content, $next );
open(my $fh, ">>:encoding(UTF-8)", "$VI.txt") or die "No open $VI.txt? $!";
$next = 1;

sub fetching {
	sleep 2;
	my $next_url = $next>1? $url . "&pageToken=$content->{nextPageToken}" : $url;
	$req = HTTP::Request->new(GET => $next_url);
	$res = $ua->request($req);
	if ( $res->is_success ) {
		$content = decode_json $res->content;
		$next++;
		my $items = $content->{items};
		for my $comment ( @$items ) {
			my $data = $comment->{snippet}->{topLevelComment}->{snippet};
			my $top = $data->{textOriginal};
			my $line;
			$top =~ s/\n/\x{21B2} /g;
			$line = $top . "\n";
			if ( my $replies = $comment->{replies}->{comments} ) {
				$line = "$data->{publishedAt}  $data->{authorDisplayName}:\t$line";
				my @reply_line;
				for my $reply ( @$replies ) {
					my $data = $reply->{snippet};
					my $response = $data->{textOriginal};
					$response =~ s/\n/\x{21B2} /g;
					unshift @reply_line, "\x{21B3} $data->{publishedAt} $data->{authorDisplayName}:\t$response\n";
				}
				$line = join "", $line, @reply_line;
			}
			my $out = encode( "utf-8", $line );
			# print $fh $out;
			print $fh $line;
		}
	} else {
		die "$url failed on $next page: $!";
	}
	&fetching if $content->{nextPageToken};
}
&fetching;
