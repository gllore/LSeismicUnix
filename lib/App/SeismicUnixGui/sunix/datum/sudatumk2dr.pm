package App::SeismicUnixGui::sunix::datum::sudatumk2dr;

=head1 DOCUMENTATION

=head2 SYNOPSIS

 PACKAGE NAME: SUDATUMK2DR - Kirchhoff datuming of receivers for 2D prestack data	
 AUTHOR: Juan Lorenzo
 DATE:   
 DESCRIPTION:
 Version: 

=head2 USE

=head3 NOTES

=head4 Examples

=head3 SEISMIC UNIX NOTES

SUDATUMK2DR - Kirchhoff datuming of receivers for 2D prestack data	
		(shot gathers are the input)				

    sudatumk2dr  infile=  outfile=  [parameters] 			

 Required parameters:							
 infile=stdin		file for input seismic traces			
 outfile=stdout	file for common offset migration output  	
 ttfile=		file for input traveltime tables		
   The following 9 parameters describe traveltime tables:		
 fzt= 			first depth sample in traveltime table		
 nzt= 			number of depth samples in traveltime table	
 dzt=			depth interval in traveltime table		
 fxt=			first lateral sample in traveltime table	
 nxt=			number of lateral samples in traveltime table	
 dxt=			lateral interval in traveltime table		
 fs= 			x-coordinate of first source			
 ns= 			number of sources				
 ds= 			x-coordinate increment of sources		

 fxi=                  x-coordinate of the first surface location      
 dxi=                  horizontal spacing on surface                   
 nxi=                  number of input surface locations               
 sgn=			Sign of the datuming process (up=-1 or down=1)  

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

 verbose=0		silent, =1 chatty				

 Notes:								
 1. Traveltime tables were generated by program rayt2d (or other ones)	
    on relatively coarse grids, with dimension ns*nxt*nzt. In the	
    datuming process, traveltimes are interpolated into shot/gephone 	
    positions and output grids.					
 2. Input traces must be SU format and organized in common rec. gathers
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

=head2 CHANGES and their DATES

=cut

use Moose;
our $VERSION = '0.0.1';
use aliased 'App::SeismicUnixGui::misc::L_SU_global_constants';

my $get = L_SU_global_constants->new();

my $var          = $get->var();
my $empty_string = $var->{_empty_string};

my $sudatumk2dr = {
    _angmax   => '',
    _antiali  => '',
    _aperx    => '',
    _ds       => '',
    _dt       => '',
    _dvz      => '',
    _dxgo     => '',
    _dxi      => '',
    _dxso     => '',
    _dxt      => '',
    _dzo      => '',
    _dzt      => '',
    _fmax     => '',
    _fs       => '',
    _ft       => '',
    _fxgo     => '',
    _fxi      => '',
    _fxso     => '',
    _fxt      => '',
    _fzo      => '',
    _fzt      => '',
    _jpfile   => '',
    _mtr      => '',
    _ns       => '',
    _ntr      => '',
    _nxgo     => '',
    _nxi      => '',
    _nxso     => '',
    _nxt      => '',
    _nzo      => '',
    _nzt      => '',
    _offmax   => '',
    _par_file => '',
    _sgn      => '',
    _surf     => '',
    _ttfile   => '',
    _v0       => '',
    _verbose  => '',
    _Step     => '',
    _note     => '',
};

=head2 sub Step

collects switches and assembles bash instructions
by adding the program name

=cut

sub Step {

    $sudatumk2dr->{_Step} = 'sudatumk2dr' . $sudatumk2dr->{_Step};
    return ( $sudatumk2dr->{_Step} );

}

=head2 sub note

collects switches and assembles bash instructions
by adding the program name

=cut

sub note {

    $sudatumk2dr->{_note} = 'sudatumk2dr' . $sudatumk2dr->{_note};
    return ( $sudatumk2dr->{_note} );

}

=head2 sub clear

=cut

sub clear {

    $sudatumk2dr->{_angmax}   = '';
    $sudatumk2dr->{_antiali}  = '';
    $sudatumk2dr->{_aperx}    = '';
    $sudatumk2dr->{_ds}       = '';
    $sudatumk2dr->{_dt}       = '';
    $sudatumk2dr->{_dvz}      = '';
    $sudatumk2dr->{_dxgo}     = '';
    $sudatumk2dr->{_dxi}      = '';
    $sudatumk2dr->{_dxso}     = '';
    $sudatumk2dr->{_dxt}      = '';
    $sudatumk2dr->{_dzo}      = '';
    $sudatumk2dr->{_dzt}      = '';
    $sudatumk2dr->{_fmax}     = '';
    $sudatumk2dr->{_fs}       = '';
    $sudatumk2dr->{_ft}       = '';
    $sudatumk2dr->{_fxgo}     = '';
    $sudatumk2dr->{_fxi}      = '';
    $sudatumk2dr->{_fxso}     = '';
    $sudatumk2dr->{_fxt}      = '';
    $sudatumk2dr->{_fzo}      = '';
    $sudatumk2dr->{_fzt}      = '';
    $sudatumk2dr->{_jpfile}   = '';
    $sudatumk2dr->{_mtr}      = '';
    $sudatumk2dr->{_ns}       = '';
    $sudatumk2dr->{_ntr}      = '';
    $sudatumk2dr->{_nxgo}     = '';
    $sudatumk2dr->{_nxi}      = '';
    $sudatumk2dr->{_nxso}     = '';
    $sudatumk2dr->{_nxt}      = '';
    $sudatumk2dr->{_nzo}      = '';
    $sudatumk2dr->{_nzt}      = '';
    $sudatumk2dr->{_offmax}   = '';
    $sudatumk2dr->{_par_file} = '';
    $sudatumk2dr->{_sgn}      = '';
    $sudatumk2dr->{_surf}     = '';
    $sudatumk2dr->{_ttfile}   = '';
    $sudatumk2dr->{_v0}       = '';
    $sudatumk2dr->{_verbose}  = '';
    $sudatumk2dr->{_Step}     = '';
    $sudatumk2dr->{_note}     = '';
}

=head2 sub angmax 


=cut

sub angmax {

    my ( $self, $angmax ) = @_;
    if ( $angmax ne $empty_string ) {

        $sudatumk2dr->{_angmax} = $angmax;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' angmax=' . $sudatumk2dr->{_angmax};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' angmax=' . $sudatumk2dr->{_angmax};

    }
    else {
        print("sudatumk2dr, angmax, missing angmax,\n");
    }
}

=head2 sub antiali 


=cut

sub antiali {

    my ( $self, $antiali ) = @_;
    if ( $antiali ne $empty_string ) {

        $sudatumk2dr->{_antiali} = $antiali;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' antiali=' . $sudatumk2dr->{_antiali};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' antiali=' . $sudatumk2dr->{_antiali};

    }
    else {
        print("sudatumk2dr, antiali, missing antiali,\n");
    }
}

=head2 sub aperx 


=cut

sub aperx {

    my ( $self, $aperx ) = @_;
    if ( $aperx ne $empty_string ) {

        $sudatumk2dr->{_aperx} = $aperx;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' aperx=' . $sudatumk2dr->{_aperx};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' aperx=' . $sudatumk2dr->{_aperx};

    }
    else {
        print("sudatumk2dr, aperx, missing aperx,\n");
    }
}

=head2 sub ds 


=cut

sub ds {

    my ( $self, $ds ) = @_;
    if ( $ds ne $empty_string ) {

        $sudatumk2dr->{_ds} = $ds;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' ds=' . $sudatumk2dr->{_ds};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' ds=' . $sudatumk2dr->{_ds};

    }
    else {
        print("sudatumk2dr, ds, missing ds,\n");
    }
}

=head2 sub dt 


=cut

sub dt {

    my ( $self, $dt ) = @_;
    if ( $dt ne $empty_string ) {

        $sudatumk2dr->{_dt} = $dt;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' dt=' . $sudatumk2dr->{_dt};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' dt=' . $sudatumk2dr->{_dt};

    }
    else {
        print("sudatumk2dr, dt, missing dt,\n");
    }
}

=head2 sub dvz 


=cut

sub dvz {

    my ( $self, $dvz ) = @_;
    if ( $dvz ne $empty_string ) {

        $sudatumk2dr->{_dvz} = $dvz;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' dvz=' . $sudatumk2dr->{_dvz};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' dvz=' . $sudatumk2dr->{_dvz};

    }
    else {
        print("sudatumk2dr, dvz, missing dvz,\n");
    }
}

=head2 sub dxgo 


=cut

sub dxgo {

    my ( $self, $dxgo ) = @_;
    if ( $dxgo ne $empty_string ) {

        $sudatumk2dr->{_dxgo} = $dxgo;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' dxgo=' . $sudatumk2dr->{_dxgo};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' dxgo=' . $sudatumk2dr->{_dxgo};

    }
    else {
        print("sudatumk2dr, dxgo, missing dxgo,\n");
    }
}

=head2 sub dxi 


=cut

sub dxi {

    my ( $self, $dxi ) = @_;
    if ( $dxi ne $empty_string ) {

        $sudatumk2dr->{_dxi} = $dxi;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' dxi=' . $sudatumk2dr->{_dxi};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' dxi=' . $sudatumk2dr->{_dxi};

    }
    else {
        print("sudatumk2dr, dxi, missing dxi,\n");
    }
}

=head2 sub dxso 


=cut

sub dxso {

    my ( $self, $dxso ) = @_;
    if ( $dxso ne $empty_string ) {

        $sudatumk2dr->{_dxso} = $dxso;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' dxso=' . $sudatumk2dr->{_dxso};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' dxso=' . $sudatumk2dr->{_dxso};

    }
    else {
        print("sudatumk2dr, dxso, missing dxso,\n");
    }
}

=head2 sub dxt 


=cut

sub dxt {

    my ( $self, $dxt ) = @_;
    if ( $dxt ne $empty_string ) {

        $sudatumk2dr->{_dxt} = $dxt;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' dxt=' . $sudatumk2dr->{_dxt};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' dxt=' . $sudatumk2dr->{_dxt};

    }
    else {
        print("sudatumk2dr, dxt, missing dxt,\n");
    }
}

=head2 sub dzo 


=cut

sub dzo {

    my ( $self, $dzo ) = @_;
    if ( $dzo ne $empty_string ) {

        $sudatumk2dr->{_dzo} = $dzo;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' dzo=' . $sudatumk2dr->{_dzo};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' dzo=' . $sudatumk2dr->{_dzo};

    }
    else {
        print("sudatumk2dr, dzo, missing dzo,\n");
    }
}

=head2 sub dzt 


=cut

sub dzt {

    my ( $self, $dzt ) = @_;
    if ( $dzt ne $empty_string ) {

        $sudatumk2dr->{_dzt} = $dzt;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' dzt=' . $sudatumk2dr->{_dzt};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' dzt=' . $sudatumk2dr->{_dzt};

    }
    else {
        print("sudatumk2dr, dzt, missing dzt,\n");
    }
}

=head2 sub fmax 


=cut

sub fmax {

    my ( $self, $fmax ) = @_;
    if ( $fmax ne $empty_string ) {

        $sudatumk2dr->{_fmax} = $fmax;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' fmax=' . $sudatumk2dr->{_fmax};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' fmax=' . $sudatumk2dr->{_fmax};

    }
    else {
        print("sudatumk2dr, fmax, missing fmax,\n");
    }
}

=head2 sub fs 


=cut

sub fs {

    my ( $self, $fs ) = @_;
    if ( $fs ne $empty_string ) {

        $sudatumk2dr->{_fs} = $fs;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' fs=' . $sudatumk2dr->{_fs};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' fs=' . $sudatumk2dr->{_fs};

    }
    else {
        print("sudatumk2dr, fs, missing fs,\n");
    }
}

=head2 sub ft 


=cut

sub ft {

    my ( $self, $ft ) = @_;
    if ( $ft ne $empty_string ) {

        $sudatumk2dr->{_ft} = $ft;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' ft=' . $sudatumk2dr->{_ft};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' ft=' . $sudatumk2dr->{_ft};

    }
    else {
        print("sudatumk2dr, ft, missing ft,\n");
    }
}

=head2 sub fxgo 


=cut

sub fxgo {

    my ( $self, $fxgo ) = @_;
    if ( $fxgo ne $empty_string ) {

        $sudatumk2dr->{_fxgo} = $fxgo;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' fxgo=' . $sudatumk2dr->{_fxgo};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' fxgo=' . $sudatumk2dr->{_fxgo};

    }
    else {
        print("sudatumk2dr, fxgo, missing fxgo,\n");
    }
}

=head2 sub fxi 


=cut

sub fxi {

    my ( $self, $fxi ) = @_;
    if ( $fxi ne $empty_string ) {

        $sudatumk2dr->{_fxi} = $fxi;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' fxi=' . $sudatumk2dr->{_fxi};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' fxi=' . $sudatumk2dr->{_fxi};

    }
    else {
        print("sudatumk2dr, fxi, missing fxi,\n");
    }
}

=head2 sub fxso 


=cut

sub fxso {

    my ( $self, $fxso ) = @_;
    if ( $fxso ne $empty_string ) {

        $sudatumk2dr->{_fxso} = $fxso;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' fxso=' . $sudatumk2dr->{_fxso};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' fxso=' . $sudatumk2dr->{_fxso};

    }
    else {
        print("sudatumk2dr, fxso, missing fxso,\n");
    }
}

=head2 sub fxt 


=cut

sub fxt {

    my ( $self, $fxt ) = @_;
    if ( $fxt ne $empty_string ) {

        $sudatumk2dr->{_fxt} = $fxt;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' fxt=' . $sudatumk2dr->{_fxt};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' fxt=' . $sudatumk2dr->{_fxt};

    }
    else {
        print("sudatumk2dr, fxt, missing fxt,\n");
    }
}

=head2 sub fzo 


=cut

sub fzo {

    my ( $self, $fzo ) = @_;
    if ( $fzo ne $empty_string ) {

        $sudatumk2dr->{_fzo} = $fzo;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' fzo=' . $sudatumk2dr->{_fzo};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' fzo=' . $sudatumk2dr->{_fzo};

    }
    else {
        print("sudatumk2dr, fzo, missing fzo,\n");
    }
}

=head2 sub fzt 


=cut

sub fzt {

    my ( $self, $fzt ) = @_;
    if ( $fzt ne $empty_string ) {

        $sudatumk2dr->{_fzt} = $fzt;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' fzt=' . $sudatumk2dr->{_fzt};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' fzt=' . $sudatumk2dr->{_fzt};

    }
    else {
        print("sudatumk2dr, fzt, missing fzt,\n");
    }
}

=head2 sub jpfile 


=cut

sub jpfile {

    my ( $self, $jpfile ) = @_;
    if ( $jpfile ne $empty_string ) {

        $sudatumk2dr->{_jpfile} = $jpfile;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' jpfile=' . $sudatumk2dr->{_jpfile};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' jpfile=' . $sudatumk2dr->{_jpfile};

    }
    else {
        print("sudatumk2dr, jpfile, missing jpfile,\n");
    }
}

=head2 sub mtr 


=cut

sub mtr {

    my ( $self, $mtr ) = @_;
    if ( $mtr ne $empty_string ) {

        $sudatumk2dr->{_mtr} = $mtr;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' mtr=' . $sudatumk2dr->{_mtr};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' mtr=' . $sudatumk2dr->{_mtr};

    }
    else {
        print("sudatumk2dr, mtr, missing mtr,\n");
    }
}

=head2 sub ns 


=cut

sub ns {

    my ( $self, $ns ) = @_;
    if ( $ns ne $empty_string ) {

        $sudatumk2dr->{_ns} = $ns;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' ns=' . $sudatumk2dr->{_ns};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' ns=' . $sudatumk2dr->{_ns};

    }
    else {
        print("sudatumk2dr, ns, missing ns,\n");
    }
}

=head2 sub ntr 


=cut

sub ntr {

    my ( $self, $ntr ) = @_;
    if ( $ntr ne $empty_string ) {

        $sudatumk2dr->{_ntr} = $ntr;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' ntr=' . $sudatumk2dr->{_ntr};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' ntr=' . $sudatumk2dr->{_ntr};

    }
    else {
        print("sudatumk2dr, ntr, missing ntr,\n");
    }
}

=head2 sub nxgo 


=cut

sub nxgo {

    my ( $self, $nxgo ) = @_;
    if ( $nxgo ne $empty_string ) {

        $sudatumk2dr->{_nxgo} = $nxgo;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' nxgo=' . $sudatumk2dr->{_nxgo};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' nxgo=' . $sudatumk2dr->{_nxgo};

    }
    else {
        print("sudatumk2dr, nxgo, missing nxgo,\n");
    }
}

=head2 sub nxi 


=cut

sub nxi {

    my ( $self, $nxi ) = @_;
    if ( $nxi ne $empty_string ) {

        $sudatumk2dr->{_nxi} = $nxi;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' nxi=' . $sudatumk2dr->{_nxi};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' nxi=' . $sudatumk2dr->{_nxi};

    }
    else {
        print("sudatumk2dr, nxi, missing nxi,\n");
    }
}

=head2 sub nxso 


=cut

sub nxso {

    my ( $self, $nxso ) = @_;
    if ( $nxso ne $empty_string ) {

        $sudatumk2dr->{_nxso} = $nxso;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' nxso=' . $sudatumk2dr->{_nxso};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' nxso=' . $sudatumk2dr->{_nxso};

    }
    else {
        print("sudatumk2dr, nxso, missing nxso,\n");
    }
}

=head2 sub nxt 


=cut

sub nxt {

    my ( $self, $nxt ) = @_;
    if ( $nxt ne $empty_string ) {

        $sudatumk2dr->{_nxt} = $nxt;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' nxt=' . $sudatumk2dr->{_nxt};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' nxt=' . $sudatumk2dr->{_nxt};

    }
    else {
        print("sudatumk2dr, nxt, missing nxt,\n");
    }
}

=head2 sub nzo 


=cut

sub nzo {

    my ( $self, $nzo ) = @_;
    if ( $nzo ne $empty_string ) {

        $sudatumk2dr->{_nzo} = $nzo;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' nzo=' . $sudatumk2dr->{_nzo};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' nzo=' . $sudatumk2dr->{_nzo};

    }
    else {
        print("sudatumk2dr, nzo, missing nzo,\n");
    }
}

=head2 sub nzt 


=cut

sub nzt {

    my ( $self, $nzt ) = @_;
    if ( $nzt ne $empty_string ) {

        $sudatumk2dr->{_nzt} = $nzt;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' nzt=' . $sudatumk2dr->{_nzt};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' nzt=' . $sudatumk2dr->{_nzt};

    }
    else {
        print("sudatumk2dr, nzt, missing nzt,\n");
    }
}

=head2 sub offmax 


=cut

sub offmax {

    my ( $self, $offmax ) = @_;
    if ( $offmax ne $empty_string ) {

        $sudatumk2dr->{_offmax} = $offmax;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' offmax=' . $sudatumk2dr->{_offmax};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' offmax=' . $sudatumk2dr->{_offmax};

    }
    else {
        print("sudatumk2dr, offmax, missing offmax,\n");
    }
}

=head2 sub par_file 


=cut

sub par_file {

    my ( $self, $par_file ) = @_;
    if ( $par_file ne $empty_string ) {

        $sudatumk2dr->{_par_file} = $par_file;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' par=' . $sudatumk2dr->{_par_file};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' par=' . $sudatumk2dr->{_par_file};

    }
    else {
        print("sudatumk2dr, par_file, missing offmax,\n");
    }
}

=head2 sub sgn 


=cut

sub sgn {

    my ( $self, $sgn ) = @_;
    if ( $sgn ne $empty_string ) {

        $sudatumk2dr->{_sgn} = $sgn;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' sgn=' . $sudatumk2dr->{_sgn};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' sgn=' . $sudatumk2dr->{_sgn};

    }
    else {
        print("sudatumk2dr, sgn, missing sgn,\n");
    }
}

=head2 sub surf 


=cut

sub surf {

    my ( $self, $surf ) = @_;
    if ( $surf ne $empty_string ) {

        $sudatumk2dr->{_surf} = $surf;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' surf=' . $sudatumk2dr->{_surf};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' surf=' . $sudatumk2dr->{_surf};

    }
    else {
        print("sudatumk2dr, surf, missing surf,\n");
    }
}

=head2 sub ttfile 


=cut

sub ttfile {

    my ( $self, $ttfile ) = @_;
    if ( $ttfile ne $empty_string ) {

        $sudatumk2dr->{_ttfile} = $ttfile;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' ttfile=' . $sudatumk2dr->{_ttfile};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' ttfile=' . $sudatumk2dr->{_ttfile};

    }
    else {
        print("sudatumk2dr, ttfile, missing ttfile,\n");
    }
}

=head2 sub v0 


=cut

sub v0 {

    my ( $self, $v0 ) = @_;
    if ( $v0 ne $empty_string ) {

        $sudatumk2dr->{_v0} = $v0;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' v0=' . $sudatumk2dr->{_v0};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' v0=' . $sudatumk2dr->{_v0};

    }
    else {
        print("sudatumk2dr, v0, missing v0,\n");
    }
}

=head2 sub verbose 


=cut

sub verbose {

    my ( $self, $verbose ) = @_;
    if ( $verbose ne $empty_string ) {

        $sudatumk2dr->{_verbose} = $verbose;
        $sudatumk2dr->{_note} =
          $sudatumk2dr->{_note} . ' verbose=' . $sudatumk2dr->{_verbose};
        $sudatumk2dr->{_Step} =
          $sudatumk2dr->{_Step} . ' verbose=' . $sudatumk2dr->{_verbose};

    }
    else {
        print("sudatumk2dr, verbose, missing verbose,\n");
    }
}

=head2 sub get_max_index
 
max index = number of input variables -1
 
=cut

sub get_max_index {
    my ($self) = @_;
    my $max_index = 37;

    return ($max_index);
}

1;
