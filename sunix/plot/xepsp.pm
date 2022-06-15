package xepsp;

=head2 SYNOPSIS

PACKAGE NAME: 

AUTHOR:  

DATE:

DESCRIPTION:

Version:

=head2 USE

=head3 NOTES

=head4 Examples

=head2 SYNOPSIS

=head3 SEISMIC UNIX NOTES
 XEPSP - X windows display of Encapsulated PostScript



 Usage:   xepsp < stdin

 

 option=null



 Caveat: your system must have Display PostScript Graphics

 Note:  

 this program is a more advanced version of   xepsb. See also:  xepsp

=head2 User's notes (Juan Lorenzo)
untested

=cut


=head2 CHANGES and their DATES

=cut

use Moose;
our $VERSION = '0.0.1';


=head2 Import packages

=cut

use L_SU_global_constants();

use SeismicUnix qw ($go $in $off $on $out $ps $to $suffix_ascii $suffix_bin $suffix_ps $suffix_segy $suffix_su);
use Project_config;


=head2 instantiation of packages

=cut

my $get					= new L_SU_global_constants();
my $Project				= new Project_config();
my $DATA_SEISMIC_SU		= $Project->DATA_SEISMIC_SU();
my $DATA_SEISMIC_BIN	= $Project->DATA_SEISMIC_BIN();
my $DATA_SEISMIC_TXT	= $Project->DATA_SEISMIC_TXT();

my $PS_SEISMIC      	= $Project->PS_SEISMIC();

my $var				= $get->var();
my $on				= $var->{_on};
my $off				= $var->{_off};
my $true			= $var->{_true};
my $false			= $var->{_false};
my $empty_string	= $var->{_empty_string};

=head2 Encapsulated
hash of private variables

=cut

my $xepsp			= {
	_option					=> '',
	_Step					=> '',
	_note					=> '',

};

=head2 sub Step

collects switches and assembles bash instructions
by adding the program name

=cut

 sub  Step {

	$xepsp->{_Step}     = 'xepsp'.$xepsp->{_Step};
	return ( $xepsp->{_Step} );

 }


=head2 sub note

collects switches and assembles bash instructions
by adding the program name

=cut

 sub  note {

	$xepsp->{_note}     = 'xepsp'.$xepsp->{_note};
	return ( $xepsp->{_note} );

 }



=head2 sub clear

=cut

 sub clear {

		$xepsp->{_option}			= '';
		$xepsp->{_Step}			= '';
		$xepsp->{_note}			= '';
 }


=head2 sub option 


=cut

 sub option {

	my ( $self,$option )		= @_;
	if ( $option ne $empty_string ) {

		$xepsp->{_option}		= $option;
		$xepsp->{_note}		= $xepsp->{_note}.' option='.$xepsp->{_option};
		$xepsp->{_Step}		= $xepsp->{_Step}.' option='.$xepsp->{_option};

	} else { 
		print("xepsp, option, missing option,\n");
	 }
 }


=head2 sub get_max_index

max index = number of input variables -1
 
=cut
 
sub get_max_index {
 	  my ($self) = @_;
	my $max_index = 0;

    return($max_index);
}
 
 
1;
