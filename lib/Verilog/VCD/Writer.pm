use strict;
use warnings;
use DateTime;
package Verilog::VCD::Writer;
# ABSTRACT: A Very Basic and Simple VCD waveform File creation module.
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
#use constant VERSION => '0.0.1';
use namespace::clean;

has timescale =>(is =>'ro',default=>'1ps');
has vcdfile =>(is =>'ro',required=>1);
has date =>(is=>'ro',isa=>'DateTime',default=>sub{DateTime->now()});

my $module;
my $currentModule;
my $sigcount=0;
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
foreach my $moduleName (keys %{$self->module}){
	_printScope($self->module->{$moduleName},$moduleName);
}

say '$enddefinitions $end
$dumpvars
';
}
sub _printScope {
	my ($self,$scope,$scopeName)=@_;
	# $scope module DUT $end
	say '$scope '.$scope->{scopeType}.' '.$scopeName.' $end';
	foreach my $signalName (keys %{$scope->{signals}}){
		my $signal=$scope->{signals}{$signalName};
		my $bus=($signal->{width}>1)?'['.$signal->{width}-1 . ': 0] ':'';
		say '$var '. " $signal->{type} $signal->{width} $signal->{alias} $signalName $bus".'  $end' ;
		foreach my $scopeName (keys %{$scope->{scopes}}){
			_printScope($scope->{scopes}{$scopeName},$scopeName);
		}
		say '$upscope $end';
	}
}
sub addModule{
	my ($self,$modulename)=@_;
	if (not defined $self->module){
		$self->module->{$modulename}=undef;
		$self->currentModule=$self->module->{$modulename};
	}
	#$self->module->{module}=$modulename;
	$self->currentModule=$modulename;

}
sub addSignal {
	say STDERR "Adding Signals @_";
	my ($self,$type,$width,$name)=@_;
	my $signal=$self->module->{$self->currentModule};
	$signal->{$name}{type}=$type;
	$signal->{$name}{width}=$width;
	$signal->{$name}{alias}=';'.$sigcount++;
	return $signal->{$name};
}
sub setTime {
	my ($self,$time)=@_;
	say '#'.$time;
}
sub addValue {
	my ($self,$sig,$value)=@_;
	say  STDERR "Adding Values $sig $value";
	if ($sig->{width} == 0){
	say $value.$sig->{alias};
	}else {
	say "b".dec2bin($value)." $sig->{alias}";
}
	
}
sub dec2bin {
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}


1;
