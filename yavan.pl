#!/usr/bin/perl -w

use strict;
use diagnostics;
use Expect;

#
# Check usage
#
if ($#ARGV < 1) {
	print "Usage: ./yavan.pl <debuginfo vmlinux> <core>\n";
	exit(2);
}

my $timeout = 60;
my $c = "/usr/bin/crash" ;
my %commands = (
	'A. SYS' 	=> "sys\n",
	'B. MACH' 	=> "mach\n",
	'C. LOG' 	=> "log\n",
	'D. MEM' 	=> "kmem -i\n",
	'E. DEV' 	=> "dev\n",
	'F. IRQ' 	=> "irq\n",
	'G. MOD' 	=> "mod\n",
	'H. MOUNT'	=> "mount\n",
	'I. PS'		=> "ps\n",
	'J. RUNQ'	=> "runq\n",
	'K. TIMER'	=> "timer\n",
	'L. BT'		=> "foreach bt\n",
	'M. BT-F'	=> "foreach bt -f\n",
	'N. FILES'	=> "foreach files\n",
	'O. NET'	=> "foreach net\n",
	'P. SIG'	=> "foreach sig\n"
	);

#my @params = ("/usr/lib/debug/lib/modules/2.6.9-22.ELsmp/vmlinux", "/root/IT/117649/vmcore_1374202");

my @params = @ARGV;

# create an Expect object by spawning another process
my $exp = new Expect;
$exp->raw_pty(1);
$exp->spawn($c, @params)
    or die "Cannot spawn $c: $!\n";

$exp->send("set scroll off\n");
$exp->send("mod -S\n");
for (sort keys %commands) {
	print "\n\n\n",$_, "\n";
	$exp->send($commands{$_});
	$exp->expect($timeout, [ /(.+)/ => sub { my $exp = shift; my $str = $1; $str =~ s/\r$/\n/g; print $str, "\n\n"; exp_continue; } ]);
}

# Shut down the expect process
$exp->hard_close();

