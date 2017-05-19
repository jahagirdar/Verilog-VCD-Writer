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

=cut

use  v5.10;
use Moose;
use namespace::clean;

=head2 new (timescale=>'1ps',vcdfile=>'test.vcd',date=>DateTime->now());

The constructor takes the following options

* timescale: default is '1ps'
* vcdfile: default is STDOUT, if a filename is given the VCD output will be written to it.
* Date: a DateTime object, default is current date.


=cut

has timescale =>(is =>'ro',default=>'1ps');
has vcdfile =>(is =>'ro',
	trigger=>\&_redirectSTDOUT);
has date =>(is=>'ro',isa=>'DateTime',default=>sub{DateTime->now()});
has _modules=>(is=>'ro',isa=>'ArrayRef[Verilog::VCD::Writer::Module]',
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

=head2 writeHeaders()

This method should be called after all the modules and signals are declared.
This method outputs the header of the VCD file


=cut

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

=head2 addModule(ModuleName)


This method takes the module name as an input string and returns the corresponding Verilog::VCD::Writer::Module object.


=cut

sub addModule{
	my ($self,$modulename)=@_;
	my $m=Verilog::VCD::Writer::Module->new(name=>$modulename,type=>"module");
	$self->modules_push($m);
	return $m;
}

=head2 setTime(time)

This module takes the time information as an integer value and writes it out to the VCD file.


=cut


sub setTime {
	my ($self,$time)=@_;
	say '#'.$time;
	
}
sub _dec2bin {
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}

=head2 addValue(Signal,Value)

This method takes two parameters, an Object of the type Verilog::VCD::Writer::Signal and the decimal value of the signal at the current time.
This module prints the <Signal,Value> information as a formatted line to the VCD file


=cut

sub addValue {
	my ($self,$sig,$value)=@_;
	#say  STDERR "Adding Values $sig $value";
	if ($sig->width == 1){
	say $value.$sig->symbol;
	}else {
	say "b"._dec2bin($value)." ". $sig->symbol;
}
}


1;
