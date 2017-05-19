use strict;
use warnings;
use Data::Dumper;
use DateTime;
package Verilog::VCD::Writer::Module;

# ABSTRACT: Module abstraction layer for Verilog::VCD::Writer

use Verilog::VCD::Writer::Signal;
use  v5.10;
use Moose;
use namespace::clean;

has name => (is=>'ro');
has type => (is=>'ro',default=>'module');
has signals=>(is=>'rw',isa=>'ArrayRef[Verilog::VCD::Writer::Signal]',
	default=>sub{[]},
	traits=>['Array'],
	handles=>{signals_push=>'push',
		signals_all=>'elements'}
);
has modules=>(is=>'rw',isa=>'ArrayRef[Verilog::VCD::Writer::Module]',
	default=>sub{[]},
	traits=>['Array'],
	handles=>{modules_push=>'push',
		modules_all=>'elements'}
);
#has modules=>(is=>'rw',isa=>'ArrayRef');

#my @signals;
#my $modules;

sub addSignal {
	my ($self,$name,$bitmax,$bitmin)=@_;
	my $s=Verilog::VCD::Writer::Signal->new(
		name=>$name,
		bitmax=>$bitmax,
		bitmin=>$bitmin
	);
	$self->signals_push($s);
	return $s;
}
sub dupSignal {
	my ($self,$signal,$name,$bitmax,$bitmin)=@_;
	my $s=Verilog::VCD::Writer::Signal->new(
		name=>$name,
		bitmax=>$bitmax,
		bitmin=>$bitmin,
		symbol=>$signal->symbol
	);
	$self->signals_push($s);
	#push @signals,$s;
	return $s;
}
sub addSubModule {
	my ($self,$name,$type)=@_;
	my $m=Verilog::VCD::Writer::Module->new(
		name=>$name,
		type=>$type # Module,Function,Task etc.
	);
	$self->modules_push($m);
	return $m;
}
sub printScope {
	my $self=shift;
	say '$scope '.$self->type.' '.$self->name.' $end';
	map{$_->printScope}  $self->signals_all;
	map{$_->printScope}  $self->modules_all;
	say '$upscope $end';
}


1
