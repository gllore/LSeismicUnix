package App::SeismicUnixGui::sunix::datum::sudatumk2ds;

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
SUDATUMK2DS - Kirchhoff datuming of sources for 2D prestack data	

 		(input data are receiver gathers) 			



    sudatumk2ds  infile=  outfile=  [parameters] 			



 Required parameters:							

 infile=stdin		file for input seismic traces			

 outfile=stdout	file for common offset migration output  	

 ttfile=		file for input traveltime tables		

   The following 9 parameters describe traveltime tables:		

 fzt=			first depth sample in traveltime table		

 nzt= 			number of depth samples in traveltime table	

 dzt=			depth interval in traveltime table		

 fxt=			first lateral sample in traveltime table	

 nxt=			number of lateral samples in traveltime table	

 dxt=			lateral interval in traveltime table		

 fs= 			x-coordinate of first source			

 ns= 			number of sources				

 ds= 			x-coordinate increment of sources		



 fxi=                   x-coordinate of the first surface location      

 dxi=                   horizontal spacing on surface                   

 nxi=                   number of input surface locations               

 sgn=                   Sign of the datuming process (up=-1 or down=1)  



 Optional Parameters:							

 dt= or from header (dt) 	time sampling interval of input data	

 ft= or from header (ft) 	first time sample of input data		

 surf="0,0;99999,0"  The first surface defined the recording surface 

 surf="0,0;99999,0"  and the second one, the new datum.              

                       "x1,z1;x2,z2;x3,z3;...

 fzo=fzt		z-coordinate of first point in output trace 	

 dzo=0.2*dzt		vertical spacing of output trace 		

 nzo=5*(nzt-1)+1 	number of points in output trace		",	

 fxso=fxt		x-coordinate of first shot	 		

 dxso=0.5*dxt		shot horizontal spacing		 		

 nxso=2*(nxt-1)+1  	number of shots 				

 fxgo=fxt		x-coordinate of first receiver			

 exgo=fxgo+(nxgo-1)*dxgo	x-coordinate of the last receiver	

 dxgo=0.5*dxt		receiver horizontal spacing			

 nxgo=nxso		number of receivers per shot			

 fmax=0.25/dt		frequency-highcut for input traces		

 offmax=99999		maximum absolute offset allowed in migration 	

 aperx=nxt*dxt/2  	migration lateral aperature 			

 angmax=60		migration angle aperature from vertical 	

 v0=1500(m/s)		reference velocity value at surface		

 dvz=0.0  		reference velocity vertical gradient		

 antiali=1             Antialiase filter (no-filter = 0)               

 jpfile=stderr		job print file name 				

 mtr=100  		print verbal information at every mtr traces	

 ntr=100000		maximum number of input traces to be migrated	



 Notes:								

 1. Traveltime tables were generated by program rayt2d (or other ones)	

    on relatively coarse grids, with dimension ns*nxt*nzt. In the	

    migration process, traveltimes are interpolated into shot/gephone 	

    positions and output grids.					

 2. Input traces must be SU format and organized in common shot gathers

 3. If the offset value of an input trace is not in the offset array 	

    of output, the nearest one in the array is chosen. 		

 4. Amplitudes are computed using the reference velocity profile, v(z),

    specified by the parameters v0= and dvz=.				

 5. Input traces must specify source and receiver positions via the header

    fields tr.sx and tr.gx. Offset is computed automatically.		





 Author:  Trino Salinas, 05/01/96,  Colorado School of Mines



 This code is based on sukzmig2d.c written by Zhenyue Liu, 03/01/95.

 Subroutines from Dave Hale's modeling library were adapted in

 this code to define topography using cubic splines.



 This code implements a Kirchhoff extraplolation operator that allows to

 transfer data from one reference surface to another.  The formula used in

 this application is a far field approximation of the Berryhill's original

 formula (Berryhill, 1979).  This equation is the result of a stationary

 phase analysis to get an analog asymptotic expansion for the two-and-one

 half dimensional extrapolation formula (Bleistein, 1984).



 The extrapolation formula permits the downward continuation of upgoing

 waves  and  upward  continuation  of  downgoing waves.  For upward conti-

 nuation of upgoing waves and downward continuation of downgoing waves,

 the conjugate transpose of the equation is used (Bevc, 1993).



 References :



 Berryhill, J.R., 1979, Wave equation datuming: Geophysics,

   44, 1329--1344.



 _______________, 1984, Wave equation datuming before stack

   (short note) : Geophysics, 49, 2064--2067.



 Bevc, D., 1993, Data parallel wave equation datuming with

   irregular acquisition topography :  63rd Ann. Internat.

   Mtg., SEG, Expanded Abstracts, 197--200.



 Bleistein, N., 1984, Mathematical methods for wave phenomena,

   Academic Press Inc. (Harcourt Brace Jovanovich Publishers),

   New York.



=head2 User's notes (Juan Lorenzo)
untested

=cut


=head2 CHANGES and their DATES

=cut

use Moose;
our $VERSION = '0.0.1';


=head2 Import packages

=cut

use aliased 'App::SeismicUnixGui::misc::L_SU_global_constants';

use App::SeismicUnixGui::misc::SeismicUnix qw($in $out $on $go $to $suffix_ascii $off $suffix_su $suffix_bin);
use aliased 'App::SeismicUnixGui::configs::big_streams::Project_config';


=head2 instantiation of packages

=cut

my $get					= L_SU_global_constants->new();
my $Project				= Project_config->new();
my $DATA_SEISMIC_SU		= $Project->DATA_SEISMIC_SU();
my $DATA_SEISMIC_BIN	= $Project->DATA_SEISMIC_BIN();
my $DATA_SEISMIC_TXT	= $Project->DATA_SEISMIC_TXT();

my $var				= $get->var();
my $on				= $var->{_on};
my $off				= $var->{_off};
my $true			= $var->{_true};
my $false			= $var->{_false};
my $empty_string	= $var->{_empty_string};

=head2 Encapsulated
hash of private variables

=cut

my $sudatumk2ds			= {
	_angmax					=> '',
	_antiali					=> '',
	_aperx					=> '',
	_ds					=> '',
	_dt					=> '',
	_dvz					=> '',
	_dxgo					=> '',
	_dxi					=> '',
	_dxso					=> '',
	_dxt					=> '',
	_dzo					=> '',
	_dzt					=> '',
	_exgo					=> '',
	_fmax					=> '',
	_fs					=> '',
	_ft					=> '',
	_fxgo					=> '',
	_fxi					=> '',
	_fxso					=> '',
	_fxt					=> '',
	_fzo					=> '',
	_fzt					=> '',
	_infile					=> '',
	_jpfile					=> '',
	_mtr					=> '',
	_ns					=> '',
	_ntr					=> '',
	_nxgo					=> '',
	_nxi					=> '',
	_nxso					=> '',
	_nxt					=> '',
	_nzo					=> '',
	_nzt					=> '',
	_offmax					=> '',
	_outfile					=> '',
	_sgn					=> '',
	_surf					=> '',
	_ttfile					=> '',
	_v0					=> '',
	_Step					=> '',
	_note					=> '',

};

=head2 sub Step

collects switches and assembles bash instructions
by adding the program name

=cut

 sub  Step {

	$sudatumk2ds->{_Step}     = 'sudatumk2ds'.$sudatumk2ds->{_Step};
	return ( $sudatumk2ds->{_Step} );

 }


=head2 sub note

collects switches and assembles bash instructions
by adding the program name

=cut

 sub  note {

	$sudatumk2ds->{_note}     = 'sudatumk2ds'.$sudatumk2ds->{_note};
	return ( $sudatumk2ds->{_note} );

 }



=head2 sub clear

=cut

 sub clear {

		$sudatumk2ds->{_angmax}			= '';
		$sudatumk2ds->{_antiali}			= '';
		$sudatumk2ds->{_aperx}			= '';
		$sudatumk2ds->{_ds}			= '';
		$sudatumk2ds->{_dt}			= '';
		$sudatumk2ds->{_dvz}			= '';
		$sudatumk2ds->{_dxgo}			= '';
		$sudatumk2ds->{_dxi}			= '';
		$sudatumk2ds->{_dxso}			= '';
		$sudatumk2ds->{_dxt}			= '';
		$sudatumk2ds->{_dzo}			= '';
		$sudatumk2ds->{_dzt}			= '';
		$sudatumk2ds->{_exgo}			= '';
		$sudatumk2ds->{_fmax}			= '';
		$sudatumk2ds->{_fs}			= '';
		$sudatumk2ds->{_ft}			= '';
		$sudatumk2ds->{_fxgo}			= '';
		$sudatumk2ds->{_fxi}			= '';
		$sudatumk2ds->{_fxso}			= '';
		$sudatumk2ds->{_fxt}			= '';
		$sudatumk2ds->{_fzo}			= '';
		$sudatumk2ds->{_fzt}			= '';
		$sudatumk2ds->{_infile}			= '';
		$sudatumk2ds->{_jpfile}			= '';
		$sudatumk2ds->{_mtr}			= '';
		$sudatumk2ds->{_ns}			= '';
		$sudatumk2ds->{_ntr}			= '';
		$sudatumk2ds->{_nxgo}			= '';
		$sudatumk2ds->{_nxi}			= '';
		$sudatumk2ds->{_nxso}			= '';
		$sudatumk2ds->{_nxt}			= '';
		$sudatumk2ds->{_nzo}			= '';
		$sudatumk2ds->{_nzt}			= '';
		$sudatumk2ds->{_offmax}			= '';
		$sudatumk2ds->{_outfile}			= '';
		$sudatumk2ds->{_sgn}			= '';
		$sudatumk2ds->{_surf}			= '';
		$sudatumk2ds->{_ttfile}			= '';
		$sudatumk2ds->{_v0}			= '';
		$sudatumk2ds->{_Step}			= '';
		$sudatumk2ds->{_note}			= '';
 }


=head2 sub angmax 


=cut

 sub angmax {

	my ( $self,$angmax )		= @_;
	if ( $angmax ne $empty_string ) {

		$sudatumk2ds->{_angmax}		= $angmax;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' angmax='.$sudatumk2ds->{_angmax};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' angmax='.$sudatumk2ds->{_angmax};

	} else { 
		print("sudatumk2ds, angmax, missing angmax,\n");
	 }
 }


=head2 sub antiali 


=cut

 sub antiali {

	my ( $self,$antiali )		= @_;
	if ( $antiali ne $empty_string ) {

		$sudatumk2ds->{_antiali}		= $antiali;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' antiali='.$sudatumk2ds->{_antiali};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' antiali='.$sudatumk2ds->{_antiali};

	} else { 
		print("sudatumk2ds, antiali, missing antiali,\n");
	 }
 }


=head2 sub aperx 


=cut

 sub aperx {

	my ( $self,$aperx )		= @_;
	if ( $aperx ne $empty_string ) {

		$sudatumk2ds->{_aperx}		= $aperx;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' aperx='.$sudatumk2ds->{_aperx};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' aperx='.$sudatumk2ds->{_aperx};

	} else { 
		print("sudatumk2ds, aperx, missing aperx,\n");
	 }
 }


=head2 sub ds 


=cut

 sub ds {

	my ( $self,$ds )		= @_;
	if ( $ds ne $empty_string ) {

		$sudatumk2ds->{_ds}		= $ds;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' ds='.$sudatumk2ds->{_ds};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' ds='.$sudatumk2ds->{_ds};

	} else { 
		print("sudatumk2ds, ds, missing ds,\n");
	 }
 }


=head2 sub dt 


=cut

 sub dt {

	my ( $self,$dt )		= @_;
	if ( $dt ne $empty_string ) {

		$sudatumk2ds->{_dt}		= $dt;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' dt='.$sudatumk2ds->{_dt};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' dt='.$sudatumk2ds->{_dt};

	} else { 
		print("sudatumk2ds, dt, missing dt,\n");
	 }
 }


=head2 sub dvz 


=cut

 sub dvz {

	my ( $self,$dvz )		= @_;
	if ( $dvz ne $empty_string ) {

		$sudatumk2ds->{_dvz}		= $dvz;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' dvz='.$sudatumk2ds->{_dvz};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' dvz='.$sudatumk2ds->{_dvz};

	} else { 
		print("sudatumk2ds, dvz, missing dvz,\n");
	 }
 }


=head2 sub dxgo 


=cut

 sub dxgo {

	my ( $self,$dxgo )		= @_;
	if ( $dxgo ne $empty_string ) {

		$sudatumk2ds->{_dxgo}		= $dxgo;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' dxgo='.$sudatumk2ds->{_dxgo};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' dxgo='.$sudatumk2ds->{_dxgo};

	} else { 
		print("sudatumk2ds, dxgo, missing dxgo,\n");
	 }
 }


=head2 sub dxi 


=cut

 sub dxi {

	my ( $self,$dxi )		= @_;
	if ( $dxi ne $empty_string ) {

		$sudatumk2ds->{_dxi}		= $dxi;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' dxi='.$sudatumk2ds->{_dxi};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' dxi='.$sudatumk2ds->{_dxi};

	} else { 
		print("sudatumk2ds, dxi, missing dxi,\n");
	 }
 }


=head2 sub dxso 


=cut

 sub dxso {

	my ( $self,$dxso )		= @_;
	if ( $dxso ne $empty_string ) {

		$sudatumk2ds->{_dxso}		= $dxso;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' dxso='.$sudatumk2ds->{_dxso};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' dxso='.$sudatumk2ds->{_dxso};

	} else { 
		print("sudatumk2ds, dxso, missing dxso,\n");
	 }
 }


=head2 sub dxt 


=cut

 sub dxt {

	my ( $self,$dxt )		= @_;
	if ( $dxt ne $empty_string ) {

		$sudatumk2ds->{_dxt}		= $dxt;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' dxt='.$sudatumk2ds->{_dxt};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' dxt='.$sudatumk2ds->{_dxt};

	} else { 
		print("sudatumk2ds, dxt, missing dxt,\n");
	 }
 }


=head2 sub dzo 


=cut

 sub dzo {

	my ( $self,$dzo )		= @_;
	if ( $dzo ne $empty_string ) {

		$sudatumk2ds->{_dzo}		= $dzo;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' dzo='.$sudatumk2ds->{_dzo};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' dzo='.$sudatumk2ds->{_dzo};

	} else { 
		print("sudatumk2ds, dzo, missing dzo,\n");
	 }
 }


=head2 sub dzt 


=cut

 sub dzt {

	my ( $self,$dzt )		= @_;
	if ( $dzt ne $empty_string ) {

		$sudatumk2ds->{_dzt}		= $dzt;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' dzt='.$sudatumk2ds->{_dzt};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' dzt='.$sudatumk2ds->{_dzt};

	} else { 
		print("sudatumk2ds, dzt, missing dzt,\n");
	 }
 }


=head2 sub exgo 


=cut

 sub exgo {

	my ( $self,$exgo )		= @_;
	if ( $exgo ne $empty_string ) {

		$sudatumk2ds->{_exgo}		= $exgo;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' exgo='.$sudatumk2ds->{_exgo};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' exgo='.$sudatumk2ds->{_exgo};

	} else { 
		print("sudatumk2ds, exgo, missing exgo,\n");
	 }
 }


=head2 sub fmax 


=cut

 sub fmax {

	my ( $self,$fmax )		= @_;
	if ( $fmax ne $empty_string ) {

		$sudatumk2ds->{_fmax}		= $fmax;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' fmax='.$sudatumk2ds->{_fmax};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' fmax='.$sudatumk2ds->{_fmax};

	} else { 
		print("sudatumk2ds, fmax, missing fmax,\n");
	 }
 }


=head2 sub fs 


=cut

 sub fs {

	my ( $self,$fs )		= @_;
	if ( $fs ne $empty_string ) {

		$sudatumk2ds->{_fs}		= $fs;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' fs='.$sudatumk2ds->{_fs};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' fs='.$sudatumk2ds->{_fs};

	} else { 
		print("sudatumk2ds, fs, missing fs,\n");
	 }
 }


=head2 sub ft 


=cut

 sub ft {

	my ( $self,$ft )		= @_;
	if ( $ft ne $empty_string ) {

		$sudatumk2ds->{_ft}		= $ft;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' ft='.$sudatumk2ds->{_ft};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' ft='.$sudatumk2ds->{_ft};

	} else { 
		print("sudatumk2ds, ft, missing ft,\n");
	 }
 }


=head2 sub fxgo 


=cut

 sub fxgo {

	my ( $self,$fxgo )		= @_;
	if ( $fxgo ne $empty_string ) {

		$sudatumk2ds->{_fxgo}		= $fxgo;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' fxgo='.$sudatumk2ds->{_fxgo};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' fxgo='.$sudatumk2ds->{_fxgo};

	} else { 
		print("sudatumk2ds, fxgo, missing fxgo,\n");
	 }
 }


=head2 sub fxi 


=cut

 sub fxi {

	my ( $self,$fxi )		= @_;
	if ( $fxi ne $empty_string ) {

		$sudatumk2ds->{_fxi}		= $fxi;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' fxi='.$sudatumk2ds->{_fxi};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' fxi='.$sudatumk2ds->{_fxi};

	} else { 
		print("sudatumk2ds, fxi, missing fxi,\n");
	 }
 }


=head2 sub fxso 


=cut

 sub fxso {

	my ( $self,$fxso )		= @_;
	if ( $fxso ne $empty_string ) {

		$sudatumk2ds->{_fxso}		= $fxso;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' fxso='.$sudatumk2ds->{_fxso};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' fxso='.$sudatumk2ds->{_fxso};

	} else { 
		print("sudatumk2ds, fxso, missing fxso,\n");
	 }
 }


=head2 sub fxt 


=cut

 sub fxt {

	my ( $self,$fxt )		= @_;
	if ( $fxt ne $empty_string ) {

		$sudatumk2ds->{_fxt}		= $fxt;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' fxt='.$sudatumk2ds->{_fxt};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' fxt='.$sudatumk2ds->{_fxt};

	} else { 
		print("sudatumk2ds, fxt, missing fxt,\n");
	 }
 }


=head2 sub fzo 


=cut

 sub fzo {

	my ( $self,$fzo )		= @_;
	if ( $fzo ne $empty_string ) {

		$sudatumk2ds->{_fzo}		= $fzo;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' fzo='.$sudatumk2ds->{_fzo};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' fzo='.$sudatumk2ds->{_fzo};

	} else { 
		print("sudatumk2ds, fzo, missing fzo,\n");
	 }
 }


=head2 sub fzt 


=cut

 sub fzt {

	my ( $self,$fzt )		= @_;
	if ( $fzt ne $empty_string ) {

		$sudatumk2ds->{_fzt}		= $fzt;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' fzt='.$sudatumk2ds->{_fzt};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' fzt='.$sudatumk2ds->{_fzt};

	} else { 
		print("sudatumk2ds, fzt, missing fzt,\n");
	 }
 }


=head2 sub infile 


=cut

 sub infile {

	my ( $self,$infile )		= @_;
	if ( $infile ne $empty_string ) {

		$sudatumk2ds->{_infile}		= $infile;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' infile='.$sudatumk2ds->{_infile};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' infile='.$sudatumk2ds->{_infile};

	} else { 
		print("sudatumk2ds, infile, missing infile,\n");
	 }
 }


=head2 sub jpfile 


=cut

 sub jpfile {

	my ( $self,$jpfile )		= @_;
	if ( $jpfile ne $empty_string ) {

		$sudatumk2ds->{_jpfile}		= $jpfile;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' jpfile='.$sudatumk2ds->{_jpfile};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' jpfile='.$sudatumk2ds->{_jpfile};

	} else { 
		print("sudatumk2ds, jpfile, missing jpfile,\n");
	 }
 }


=head2 sub mtr 


=cut

 sub mtr {

	my ( $self,$mtr )		= @_;
	if ( $mtr ne $empty_string ) {

		$sudatumk2ds->{_mtr}		= $mtr;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' mtr='.$sudatumk2ds->{_mtr};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' mtr='.$sudatumk2ds->{_mtr};

	} else { 
		print("sudatumk2ds, mtr, missing mtr,\n");
	 }
 }


=head2 sub ns 


=cut

 sub ns {

	my ( $self,$ns )		= @_;
	if ( $ns ne $empty_string ) {

		$sudatumk2ds->{_ns}		= $ns;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' ns='.$sudatumk2ds->{_ns};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' ns='.$sudatumk2ds->{_ns};

	} else { 
		print("sudatumk2ds, ns, missing ns,\n");
	 }
 }


=head2 sub ntr 


=cut

 sub ntr {

	my ( $self,$ntr )		= @_;
	if ( $ntr ne $empty_string ) {

		$sudatumk2ds->{_ntr}		= $ntr;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' ntr='.$sudatumk2ds->{_ntr};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' ntr='.$sudatumk2ds->{_ntr};

	} else { 
		print("sudatumk2ds, ntr, missing ntr,\n");
	 }
 }


=head2 sub nxgo 


=cut

 sub nxgo {

	my ( $self,$nxgo )		= @_;
	if ( $nxgo ne $empty_string ) {

		$sudatumk2ds->{_nxgo}		= $nxgo;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' nxgo='.$sudatumk2ds->{_nxgo};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' nxgo='.$sudatumk2ds->{_nxgo};

	} else { 
		print("sudatumk2ds, nxgo, missing nxgo,\n");
	 }
 }


=head2 sub nxi 


=cut

 sub nxi {

	my ( $self,$nxi )		= @_;
	if ( $nxi ne $empty_string ) {

		$sudatumk2ds->{_nxi}		= $nxi;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' nxi='.$sudatumk2ds->{_nxi};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' nxi='.$sudatumk2ds->{_nxi};

	} else { 
		print("sudatumk2ds, nxi, missing nxi,\n");
	 }
 }


=head2 sub nxso 


=cut

 sub nxso {

	my ( $self,$nxso )		= @_;
	if ( $nxso ne $empty_string ) {

		$sudatumk2ds->{_nxso}		= $nxso;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' nxso='.$sudatumk2ds->{_nxso};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' nxso='.$sudatumk2ds->{_nxso};

	} else { 
		print("sudatumk2ds, nxso, missing nxso,\n");
	 }
 }


=head2 sub nxt 


=cut

 sub nxt {

	my ( $self,$nxt )		= @_;
	if ( $nxt ne $empty_string ) {

		$sudatumk2ds->{_nxt}		= $nxt;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' nxt='.$sudatumk2ds->{_nxt};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' nxt='.$sudatumk2ds->{_nxt};

	} else { 
		print("sudatumk2ds, nxt, missing nxt,\n");
	 }
 }


=head2 sub nzo 


=cut

 sub nzo {

	my ( $self,$nzo )		= @_;
	if ( $nzo ne $empty_string ) {

		$sudatumk2ds->{_nzo}		= $nzo;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' nzo='.$sudatumk2ds->{_nzo};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' nzo='.$sudatumk2ds->{_nzo};

	} else { 
		print("sudatumk2ds, nzo, missing nzo,\n");
	 }
 }


=head2 sub nzt 


=cut

 sub nzt {

	my ( $self,$nzt )		= @_;
	if ( $nzt ne $empty_string ) {

		$sudatumk2ds->{_nzt}		= $nzt;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' nzt='.$sudatumk2ds->{_nzt};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' nzt='.$sudatumk2ds->{_nzt};

	} else { 
		print("sudatumk2ds, nzt, missing nzt,\n");
	 }
 }


=head2 sub offmax 


=cut

 sub offmax {

	my ( $self,$offmax )		= @_;
	if ( $offmax ne $empty_string ) {

		$sudatumk2ds->{_offmax}		= $offmax;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' offmax='.$sudatumk2ds->{_offmax};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' offmax='.$sudatumk2ds->{_offmax};

	} else { 
		print("sudatumk2ds, offmax, missing offmax,\n");
	 }
 }


=head2 sub outfile 


=cut

 sub outfile {

	my ( $self,$outfile )		= @_;
	if ( $outfile ne $empty_string ) {

		$sudatumk2ds->{_outfile}		= $outfile;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' outfile='.$sudatumk2ds->{_outfile};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' outfile='.$sudatumk2ds->{_outfile};

	} else { 
		print("sudatumk2ds, outfile, missing outfile,\n");
	 }
 }


=head2 sub sgn 


=cut

 sub sgn {

	my ( $self,$sgn )		= @_;
	if ( $sgn ne $empty_string ) {

		$sudatumk2ds->{_sgn}		= $sgn;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' sgn='.$sudatumk2ds->{_sgn};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' sgn='.$sudatumk2ds->{_sgn};

	} else { 
		print("sudatumk2ds, sgn, missing sgn,\n");
	 }
 }


=head2 sub surf 


=cut

 sub surf {

	my ( $self,$surf )		= @_;
	if ( $surf ne $empty_string ) {

		$sudatumk2ds->{_surf}		= $surf;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' surf='.$sudatumk2ds->{_surf};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' surf='.$sudatumk2ds->{_surf};

	} else { 
		print("sudatumk2ds, surf, missing surf,\n");
	 }
 }


=head2 sub ttfile 


=cut

 sub ttfile {

	my ( $self,$ttfile )		= @_;
	if ( $ttfile ne $empty_string ) {

		$sudatumk2ds->{_ttfile}		= $ttfile;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' ttfile='.$sudatumk2ds->{_ttfile};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' ttfile='.$sudatumk2ds->{_ttfile};

	} else { 
		print("sudatumk2ds, ttfile, missing ttfile,\n");
	 }
 }


=head2 sub v0 


=cut

 sub v0 {

	my ( $self,$v0 )		= @_;
	if ( $v0 ne $empty_string ) {

		$sudatumk2ds->{_v0}		= $v0;
		$sudatumk2ds->{_note}		= $sudatumk2ds->{_note}.' v0='.$sudatumk2ds->{_v0};
		$sudatumk2ds->{_Step}		= $sudatumk2ds->{_Step}.' v0='.$sudatumk2ds->{_v0};

	} else { 
		print("sudatumk2ds, v0, missing v0,\n");
	 }
 }


=head2 sub get_max_index

max index = number of input variables -1
 
=cut
 
sub get_max_index {
 	  my ($self) = @_;
	my $max_index = 38;

    return($max_index);
}
 
 
1;
