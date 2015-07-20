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
	'sys_essential_system_info'                   => "sys\n",
	'sys-c_system_call_table'                     => "sys -c\n",
	'mach_machine_specific_data'                  => "mach\n",
	'mach-m_physical_memory_map'                  => "mach -m\n",
	'mach-c_cpuinfo_from_each_cpu'                => "mach -c\n",
	'log' 	                                     => "log\n",
	'kmem-i_basic_kernel_memory_usage'            => "kmem -i\n",
	'kmem-s_kmalloc_slab_data'                    => "kmem -s\n",
	'kmem-V_vm_table_contents'                    => "kmem -V\n",
	'kmem-f_free_memory_contents'                 => "kmem -f\n",
	'dev'                                         => "dev\n",
	'dev-d_diskio'                                => "dev\n",
	'irq'                                         => "irq\n",
	'mod'                                         => "mod\n",
	'mod-t_tainted_modules'                       => "mod -t\n",
	'mount'                                       => "mount\n",
	'ps'                                          => "ps\n",
	'runq'                                        => "runq\n",
	'timer'                                       => "timer\n",
	'bt'                                          => "foreach bt\n",
	'bt-f'                                        => "foreach bt -f\n",
	'files'                                       => "foreach files\n",
	'net'                                         => "foreach net\n",
	'sig'                                         => "foreach sig\n"
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
for my $logfile (sort keys %commands) {
	print "\n\n\n",$logfile, "\n";
	$exp->send("gdb set logging on\n");
	$exp->send("gdb set logging file $logfile\n");
	$exp->send($commands{$logfile});
	$exp->expect($timeout, [ /(.+)/ => sub { my $exp = shift; my $str = $1; $str =~ s/\r$/\n/g; print $str, "\n\n"; exp_continue; } ]);
}

# Shut down the expect process
$exp->hard_close();

