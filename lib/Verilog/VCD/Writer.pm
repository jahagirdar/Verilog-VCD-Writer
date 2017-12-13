use strict;
use warnings;
package Verilog::VCD::Writer;

use DateTime;
use Verilog::VCD::Writer::Module;

# ABSTRACT: VCD waveform File creation module.
 
=head1 SYNOPSIS

    use Verilog::VCD::Writer;

    my $writer = Verilog::VCD::Writer->new(timescale=>'1 ns',vcdfile=>"test.vcd");
    $writer->addComment("Author:Vijayvithal");

    my $top = $writer->addModule("top"); # Create toplevel module
    my $TX  = $top->addSignal("TX",7,0); #Add Signals to top
    my $RX  = $top->addSignal("RX",7,0);

    my $dut = $writer->addModule("DUT");  #Create SubModule
    $dut->dupSignal($TX,"TX",7,0); #Duplicate signals from Top in submodule
    $dut->dupSignal($RX,"RX",7,0);

    $writer->writeHeaders(); # Output the VCD Header.
    $writer->setTime(0); # Time 0
    $writer->addValue($TX,0); # Record Transition
    $writer->addValue($RX,0);
    $writer->setTime(5); # Time 1ns
    $writer->addValue($TX,1);
    $writer->addValue($RX,0);


=cut 

=head1 DESCRIPTION

This module originated out of my need to view the <Time,Voltage> CSV dump from the scope using GTKWave. 

This module provides an interface for creating a VCD (Value change Dump) file.

Please see examples/serial.pl for a complete example



=cut

use  v5.10;
use Moose;
use namespace::clean;

=head2 new (timescale=>'1ps',vcdfile=>'test.vcd',date=>DateTime->now());

The constructor takes the following options

=for :list
* timescale: default is '1ps'
* vcdfile: default is STDOUT, if a filename is given the VCD output will be written to it.
* Date: a DateTime object, default is current date.


=cut

has timescale =>(is =>'ro',default=>'1ps');
has vcdfile =>(is =>'ro');
has date =>(is=>'ro',isa=>'DateTime',default=>sub{DateTime->now()});
has _modules=>(is=>'ro',isa=>'ArrayRef[Verilog::VCD::Writer::Module]',
	default=>sub{[]},
	traits=>['Array'],
	handles=>{modules_push=>'push',
		modules_all=>'elements'}
);
has _comments=>(is=>'ro',isa=>'ArrayRef',
	default=>sub{[]},
	traits=>['Array'],
	handles=>{comments_push=>'push',
		comments_all=>'elements'}
);
has _fh=>(is=>'ro',lazy=>1,builder=>"_redirectSTDOUT");

sub _redirectSTDOUT{
	my $self=shift;
	my $fh;
		if(defined $self->vcdfile){
		   open($fh, ">", $self->vcdfile) or die "unable to write to $self->vcdfile";
	   }else{
		   open($fh, ">-") or die "unable to write to STDOUT";
	   }
	   return $fh;
	}

=head2 writeHeaders()

This method should be called after all the modules and signals are declared.
This method outputs the header of the VCD file


=cut

sub writeHeaders{
my $self=shift;
my $fh=$self->_fh;
say  $fh '$date';
say $fh $self->date;
say $fh '$end
$version
   Perl VCD Writer Version '.$Verilog::VCD::Writer::VERSION.'
$end
$comment';
say $fh join("::\n",$self->comments_all);
say $fh '$end
$timescale '.$self->timescale.' $end';
$_->printScope($fh) foreach ($self->modules_all);
say $fh '$enddefinitions $end
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
	my $fh=$self->_fh;
	say $fh '#'.$time;
	
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
	my $fh=$self->_fh;
	#say  STDERR "Adding Values $sig $value";
	if ($sig->width == 1){
	say $fh $value.$sig->symbol;
	}else {
	say $fh  "b"._dec2bin($value)." ". $sig->symbol;
}
}

=method addComment(comment)

Adds a comment to the VCD file header. This method should be called before writeHeaders();

=cut

sub addComment{
	my ($self,$comment)=@_;
	$self->comments_push("   ".$comment);
}

=method flush()

Flushes the output buffer.

=cut

sub flush{
	my ($self)=shift;
	my$fh=$self->_fh;
	$fh->autoflush(1);

}



1;
