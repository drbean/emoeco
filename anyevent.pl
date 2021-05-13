use AnyEvent;
use AnyEvent::Handle;
use AnyEvent::HTTP;
 
my $loop = AnyEvent->condvar;

#use AnyEvent;
#use AnyEvent::Socket;
# 
#sub finger($$) {
#   my ($user, $host) = @_;
# 
#   # use a condvar to return results
#   my $cv = AnyEvent->condvar;
# 
#   # first, connect to the host
#   tcp_connect $host, "http", sub {
#      # the callback receives the socket handle - or nothing
#      my ($fh) = @_
#         or return $cv->send;
# 
#      # now write the username
#      # syswrite $fh, "$user\015\012";
# 
#      my $response;
# 
#      # register a read watcher
#      my $read_watcher; $read_watcher = AnyEvent->io (
#         fh   => $fh,
#         poll => "r",
#         cb   => sub {
#            my $len = sysread $fh, $response, 1024, length $response;
# 
#            if ($len <= 0) {
#               # we are done, or an error occured, lets ignore the latter
#               undef $read_watcher; # no longer interested
#               $cv->send ($response); # send results
#            }
#         },
#      );
#   };
# 
#   # pass $cv to the caller
#   $cv
#}
#
#my $f1 = finger "icculus?listarchives=1", "drbean.sdf.org";
#my $f2 = finger "kuriyama", "freebsd.org";
#my $f3 = finger "mikachu", "icculus.org";
# 
#print "kuriyama's gpg key\n"    , $f1->recv, "\n";
#print "icculus' plan archive\n" , $f2->recv, "\n";
#print "mikachu's plan zomgn\n"  , $f3->recv, "\n";

#$| = 1; print "enter your name> ";
# 
#my $name_ready = AnyEvent->condvar;
#my $too_slow = AnyEvent->condvar;
#my $quit_program = AnyEvent->condvar;
# 
#my $wait_for_input = AnyEvent->io (
#   fh => \*STDIN, poll => "r",
#   cb => sub { $name_ready->send (scalar <STDIN>, AE::time) }
#);
# 
## do something else here
#
#my $wait_four_and_a_half_seconds = AnyEvent->timer (
#	   after => 4.5,  # after how many seconds to invoke the cb?
#	      cb    => sub { # the callback to invoke
#	            $too_slow->send (EV::time);
#		    exit;
#
#	       },
#       );
# 
## now wait and fetch the name
#
#my $name = $name_ready->recv;
# 
#undef $wait_for_input; # watcher no longer needed
# 
#print "your name is $name";
#
## too slow
#
#my $slow = $too_slow->recv;
#
#print "Too slow: $slow";
#
#$quit_program->recv;

sub http_get ($@) {
   my ($host, $uri, $cb) = @_;
 
   # store results here
   my ($response, $header, $body);
 
   my $handle; $handle = new AnyEvent::Handle
      connect  => [$host => 'http'],
      on_error => sub {
         $cb->("HTTP/1.0 500 $!");
         # $handle->destroy; # explicitly destroy handle
      },
      on_eof   => sub {
         $cb->($response, $header, $body);
         # $handle->destroy; # explicitly destroy handle
      };
 
   $handle->push_write ("GET $uri HTTP/1.0\015\012\015\012");
 
   # now fetch response status line
   $handle->push_read (line => sub {
      my ($handle, $line) = @_;
      $response = $line;
   });
 
   # then the headers
   $handle->push_read (line => "\015\012\015\012", sub {
      my ($handle, $line) = @_;
      $header = $line;
   });
 
   # and finally handle any remaining data as body
   $handle->on_read (sub {
      $body .= $_[0]->rbuf;
      $_[0]->rbuf = "";
   });
}

http_get "http://news.google.com", "/?hl=zh", sub {
   my ($response, $header, $body) = @_;
 
   print
      $response, "\n",
      $body;
};

my $f1 = http_get "icculus?listarchives=1", "drbean.sdf.org";
my $f2 = http_get "kuriyama", "freebsd.org";
my $f3 = http_get "mikachu", "icculus.org";

print "kuriyama's gpg key\n"    , $f1->recv, "\n";
print "icculus' plan archive\n" , $f2->recv, "\n";
print "mikachu's plan zomgn\n"  , $f3->recv, "\n";

$loop->recv;
