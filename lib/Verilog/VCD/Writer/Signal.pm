use strict;
use warnings;
use DateTime;
package Verilog::VCD::Writer::Signal;

# ABSTRACT: Signal abstraction layer for Verilog::VCD::Writer
use Verilog::VCD::Writer::Symbol;
use  v5.10;
use Moose;
use namespace::clean;
has name=>(is=>'ro',required=>1);
has type=>(is=>'ro',default=>'wire');
has bitmax=>(is=>'ro');
has bitmin=>(is=>'ro');
has width=>(is=>'ro',lazy=>1,builder=>"_getWidth");
has symbol=>(is=>'ro',builder=>"_getSymbol");
sub _getSymbol{
my $symTable=Verilog::VCD::Writer::Symbol->instance();
return $symTable->symbol;
}
sub _getWidth{
	my $self=shift;
	return 1 if (not defined $self->bitmax or not defined $self->bitmin);
	return 1+$self->bitmax-$self->bitmin if($self->bitmax>$self->bitmin);
	return 1+$self->bitmin - $self->bitmax;
}
sub printScope {
	my $self=shift;
	my $bus='';
	$bus="[$self->{bitmax}:$self->{bitmin}]" if(defined $self->bitmax and defined $self->bitmin);
 say join(' ',('$var ', $self->{type},$self->width,$self->{symbol},$self->{name},$bus,'$end')) ;
}

1
