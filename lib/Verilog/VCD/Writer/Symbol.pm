package Verilog::VCD::Writer::Symbol;

# ABSTRACT: Signal name to symbol mapper. Private class nothing to see here.
use Math::BaseCalc;

use MooseX::Singleton;
 
has count => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);
sub symbol{
	my $self=shift;
	my $conv=new Math::BaseCalc(digits=> [
        '!','"','#','$','%','&',"'",'(',')',
        '*','+',',','-','.','/',
        '0','1','2','3','4','5','6','7','8','9',
        ':',';','<','=','>','?','@',
        'A','B','C','D','E','F','G','H','I','J','K','L','M',
        'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
        '[','\\',']','^','_','`',
        'a','b','c','d','e','f','g','h','i','j','k','l','m',
        'n','o','p','q','r','s','t','u','v','w','x','y','z',
        '{','|','}','~']);
my $rval= $conv->to_base($self->count);
$self->count($self->count+1);
return $rval;
}
1
