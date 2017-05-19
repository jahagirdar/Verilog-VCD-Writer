use strict;
use warnings;
use DateTime;
package Verilog::VCD::Writer;

use Verilog::VCD::Writer::Module;

# ABSTRACT: VCD waveform File creation module.
 
=head1 SYNOPSIS

use Verilog::VCD::Writer;

my $writer=Verilog::VCD::Writer->new(timescale=>'1 ns',vcdfile=>"test.vcd");
$writer->addModule("top);
my $TX=$writer->addSignal("wire","8:0","TX");
my $RX=$writer->addSignal("wire","8:0","RX");
$writer->addModule("UART");
$writer->dupSignal("wire","8:0",$TX);
$writer->dupSignal("wire","8:0",$RX);

$writer->writeHeaders();
$writer->setTime(0);
$writer->addValue($TX,0);
$writer->addValue($RX,0);
$writer->setTime(5);
$writer->addValue($TX,1);
$writer->addValue($RX,0);


=cut 

=head1 DESCRIPTION
This module originated out of my need to view the <Time,Voltage> CSV dump from the scope using GTKWave. So the current version does not support features like hierarchial modules, tasks, functions etc. It assumes that all the signals are at the top level of the design.

=head2 Functions
 new
 addModule
 addSignal
 writeHeader
 setTime
 addValue
=cut 

use  v5.10;
use Moose;
use namespace::clean;

has timescale =>(is =>'ro',default=>'1ps');
has vcdfile =>(is =>'ro',
	trigger=>\&_redirectSTDOUT);
has date =>(is=>'ro',isa=>'DateTime',default=>sub{DateTime->now()});
has modules=>(is=>'ro',isa=>'ArrayRef[Verilog::VCD::Writer::Module]',
	default=>sub{[]},
	traits=>['Array'],
	handles=>{modules_push=>'push',
		modules_all=>'elements'}
);
sub _redirectSTDOUT{
	my $self=shift;
	say "Reopening STDOUT";
		if(defined $self->vcdfile){
		   open(STDOUT, ">", $self->vcdfile) or die "unable to write to $self->vcdfile";
	   }
	}

sub writeHeaders{
my $self=shift;
say '$date';
say $self->date;
say '$end
$version
   Perl VCD Writer Version '.$Verilog::VCD::Writer::VERSION.'
$end
$comment
   Author:Vijayvithal
$end
$timescale '.$self->timescale.' $end';
$_->printScope foreach ($self->modules_all);
say '$enddefinitions $end
$dumpvars
';
}
sub addModule{
	my ($self,$modulename)=@_;
	my $m=Verilog::VCD::Writer::Module->new(name=>$modulename,type=>"module");
	$self->modules_push($m);
	return $m;
}
sub setTime {
	my ($self,$time)=@_;
	say '#'.$time;
	
}
sub dec2bin {
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}
sub addValue {
	my ($self,$sig,$value)=@_;
	#say  STDERR "Adding Values $sig $value";
	if ($sig->width == 1){
	say $value.$sig->symbol;
	}else {
	say "b".dec2bin($value)." ". $sig->symbol;
}
}


1;
