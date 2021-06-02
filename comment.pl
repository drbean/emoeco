#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use JSON;

my $ua = LWP::UserAgent->new;

my $VI='7SeqQu2Ckcc';
my $KEY='AIzaSyAFRYuM-4pSfks7_tUEhydomqq-VQqpw_M';

my $url = "https://youtube.googleapis.com/youtube/v3/commentThreads?videoId=$VI&part=id,snippet,replies&maxResults=100&key=$KEY";

my ($req, $res, $content, $next );
open(my $fh, ">>:encoding(UTF-8)", "$VI.txt") or die "No open $VI.txt? $!";

$req = HTTP::Request->new(GET => $url);
$res = $ua->request($req);
if ( $res->is_success ) {
	$content = decode_json $res->content;
	$next = $content->{nextPageToken};
	my $items = $content->{items};
	for my $comment ( @$items ) {
		my $top = $comment->{snippet}->{topLevelComment}->{snippet}->{textOriginal};
		$top =~ s/\n/\\n/g;
		print $fh $top . "\n";
		if ( my $replies = $comment->{replies}->{comments} ) {
			for my $reply ( @$replies ) {
				my $response = $reply->{snippet}->{textOriginal};
				print $fh "->\t$response\n";
			}
		}
	}
} else {
	die "$url failed: $!";
}
# $next = "QURTSl9pM25vTlg2SWwzOThGa3BTQ2lzMWxUdEpSZnJpQWVlZEhIMnRlTHhjZm5SYlIxRTlGbDFYMFQ3enU1QWFwdDgzeVloaTZLN1dzcUFlbi1PbGtndF9FY0hwNXpn";
  $next = "QURTSl9pM09YeDlxb3JjOHhRRE9zSnI2ZkU1NmNDYjBXbjlpdjE5X3psdHM3R3VzQVh2aDF0SjFWN2F2eG5QbzVocXJ1QVRya2dSVGU2aU5JYzU0UkkycEswOW5lRVJ5";
while ( $next ) {
	sleep 2;
	$url = "https://youtube.googleapis.com/youtube/v3/commentThreads?videoId=$VI&part=id,snippet,replies&maxResults=100&key=$KEY&pageToken=$next";
	$req = HTTP::Request->new(GET => $url);
	$res = $ua->request($req);
	if ( $res->is_success ) {
		$next = $content->{nextPageToken} ? $content->{nextPageToken} : 0;
		my $items = $content->{items};
		for my $comment ( @$items ) {
			my $top = $comment->{snippet}->{topLevelComment}->{snippet}->{textOriginal};
			$top =~ s/\n/\\n/g;
			print $fh $top . "\n";
			if ( my $replies = $comment->{replies}->{comments} ) {
				for my $reply ( @$replies ) {
					my $response = $reply->{snippet}->{textOriginal};
					print $fh "->\t$response\n";
				}
			}
		}
	} else {
		die "$url failed on $next page: $!";
	}
	}
