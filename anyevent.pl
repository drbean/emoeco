use AnyEvent;
 
$| = 1; print "enter your name> ";
 
my $name_ready = AnyEvent->condvar;
my $too_slow = AnyEvent->condvar;
 
my $wait_for_input = AnyEvent->io (
   fh => \*STDIN, poll => "r",
   cb => sub { $name_ready->send (scalar <STDIN>, AE::time) }
);
 
# do something else here

my $wait_four_and_a_half_seconds = AnyEvent->timer (
	   after => 4.5,  # after how many seconds to invoke the cb?
	      cb    => sub { # the callback to invoke
	            $too_slow->send (EV::time);
	       },
       );
 
# too slow

my $slow = $too_slow->recv;

print "Too slow: $slow";

# now wait and fetch the name

my $name = $name_ready->recv;
 
undef $wait_for_input; # watcher no longer needed
 
print "your name is $name";
