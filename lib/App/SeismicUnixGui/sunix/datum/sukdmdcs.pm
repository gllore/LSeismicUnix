package App::SeismicUnixGui::sunix::datum::sukdmdcs;

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
  SUKDMDCS - 2.5D datuming of sources for prestack common receiver 	

 	     data, using constant-background data-mapping formula.      

            (See selfdoc for specific survey geometry requirements.)   



    sukdmdcs  infile=  outfile=  [parameters] 		         	



 Required parameters:							

 infile=stdin		file for input seismic traces			

 outfile=stdout	file for output  	                        

 ttfile=file for input traveltime tables		



 Required parameters describing the traveltime tables:	         	

 fzt= 			first depth sample in traveltime table		

 nzt= 			number of depth samples in traveltime table	

 dzt			depth interval in traveltime table		

 fxt=			first lateral sample in traveltime table	

 nxt=			number of lateral samples in traveltime table	

 dxt=			lateral interval in traveltime table		

 fs= 			x-coordinate of first source in table		

 ns =			number of sources in table			

 ds= 			x-coordinate increment of sources in table	



 Parameters describing the input data:                                 

 nxso=                  number of shots                                 

 dxso=                  shot interval                                   

 fxso=0                x-coordinate of first shot                      

 nxgo=                  number of receiver offsets per shot             

 dxgo=                  receiver offset interval                        

 fxgo=0                first receiver offset                           

 dt= or from header (dt)       time sampling interval of input data    

 ft= or from header (ft)       first time sample of input data         

 dc=0                  flag for previously datumed receivers:          

                          dc=0 receivers on recording surface          

                          dc=1 receivers on datum                      ", 



 Parameters descrbing the domain of the problem:	                

 dzo=0.2*dzt		vertical spacing in surface determination	

 offmax=99999		maximum absolute offset allowed             	



 Parameters describing the recording and datuming surfaces:            

 recsurf=0             recording surface (horizontal=0, topographic=1) 

 zrec=                  defines recording surface when recsurf=0        

 recfile=              defines recording surface when recsurf=1        

 datsurf=0             datuming surface (horizontal=0, irregular=1)    

 zdat=                  defines datuming surface when datsurf=0         

 datfile=              defines datuming surface when datsurf=1         



 Parameters describing the extrapolation:                              

 aperx=nxt*dxt/2  	lateral aperture         			

 v0=1500(m/s)		reference wavespeed             		

 freq=50               dominant frequency in data, used to determine   

                       the minimum distance below the datum that       

                       the stationary phase calculation is valid.      

 scale=1.0             user defined scale factor for output            

 jpfile=stderr		job print file name 				

 mtr=100  		print verbal information at every mtr traces	

 ntr=100000		maximum number of input traces to be datumed	







 Computational Notes:                                                

   

 1. Input traces must be SU format and organized in common receiver gathers.

    

 2. Traveltime tables were generated by program rayt2d (or equivalent)     

    on any grid, with dimension ns*nxt*nzt. In the extrapolation process,       

    traveltimes are interpolated into shot/geophone locations and     

    output grids.                                          



 3. If the offset value of an input trace is not in the offset array     

    of output, the nearest one in the array is chosen.                   



 4. Amplitudes are computed using the constant reference wavespeed v0.  

                                

 5. Input traces must specify source and receiver positions via the header  

    fields tr.sx and tr.gx.             



 6. Recording and datuming surfaces are defined as follows:  If recording

    surface is horizontal, set recsurf=0 (default).  Then, zrec will be a

    required parameter, set to the depth of surface.  If the recording  

    surface is topographic, then set recsurf=1.  Then, recfile is a required

    input file.  The input file recfile should be a single column ascii file

    with the depth of the recording surface at every surface location (first 

    source to last offset), with spacing equal to dxgo. 

 

    The same holds for the datuming surface, using datsurf, zdat, and datfile.





 Assumptions and limitations:



 1. This code implements a 2.5D extraplolation operator that allows to

    transfer data from one reference surface to another.  The formula used in

    this application is an adaptation of Bleistein & Jaramillo's 2.5D data

    mapping formula for receiver extrapolation.  This is the result of a

    stationary phase analysis of the data mapping equation in the case of

    a constant input receiver location (receiver gather). 

 



 Credits:

 

 Authors:  Steven D. Sheaffer (CWP), 11/97 





 References:  Sheaffer, S., 1999, "2.5D Downward Continuation of the Seismic

              Wavefield Using Kirchhoff Data Mapping."  M.Sc. Thesis, 

              Dept. of Mathematical & Computer Sciences, 

              Colorado School of Mines.







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

use App::SeismicUnixGui::misc::SeismicUnix
  qw($in $out $on $go $to $suffix_ascii $off $suffix_su $suffix_bin);
use aliased 'App::SeismicUnixGui::configs::big_streams::Project_config';

=head2 instantiation of packages

=cut

my $get              = L_SU_global_constants->new();
my $Project          = Project_config->new();
my $DATA_SEISMIC_SU  = $Project->DATA_SEISMIC_SU();
my $DATA_SEISMIC_BIN = $Project->DATA_SEISMIC_BIN();
my $DATA_SEISMIC_TXT = $Project->DATA_SEISMIC_TXT();

my $var          = $get->var();
my $on           = $var->{_on};
my $off          = $var->{_off};
my $true         = $var->{_true};
my $false        = $var->{_false};
my $empty_string = $var->{_empty_string};

=head2 Encapsulated
hash of private variables

=cut

my $sukdmdcs = {
	_aperx   => '',
	_datfile => '',
	_datsurf => '',
	_dc      => '',
	_ds      => '',
	_dt      => '',
	_dxgo    => '',
	_dxso    => '',
	_dxt     => '',
	_dzo     => '',
	_freq    => '',
	_fs      => '',
	_ft      => '',
	_fxgo    => '',
	_fxso    => '',
	_fxt     => '',
	_fzt     => '',
	_infile  => '',
	_jpfile  => '',
	_mtr     => '',
	_ns      => '',
	_ntr     => '',
	_nxgo    => '',
	_nxso    => '',
	_nxt     => '',
	_nzt     => '',
	_offmax  => '',
	_outfile => '',
	_recfile => '',
	_recsurf => '',
	_scale   => '',
	_ttfile  => '',
	_v0      => '',
	_zdat    => '',
	_zrec    => '',
	_Step    => '',
	_note    => '',

};

=head2 sub Step

collects switches and assembles bash instructions
by adding the program name

=cut

sub Step {

	$sukdmdcs->{_Step} = 'sukdmdcs' . $sukdmdcs->{_Step};
	return ( $sukdmdcs->{_Step} );

}

=head2 sub note

collects switches and assembles bash instructions
by adding the program name

=cut

sub note {

	$sukdmdcs->{_note} = 'sukdmdcs' . $sukdmdcs->{_note};
	return ( $sukdmdcs->{_note} );

}

=head2 sub clear

=cut

sub clear {

	$sukdmdcs->{_aperx}   = '';
	$sukdmdcs->{_datfile} = '';
	$sukdmdcs->{_datsurf} = '';
	$sukdmdcs->{_dc}      = '';
	$sukdmdcs->{_ds}      = '';
	$sukdmdcs->{_dt}      = '';
	$sukdmdcs->{_dxgo}    = '';
	$sukdmdcs->{_dxso}    = '';
	$sukdmdcs->{_dxt}     = '';
	$sukdmdcs->{_dzo}     = '';
	$sukdmdcs->{_freq}    = '';
	$sukdmdcs->{_fs}      = '';
	$sukdmdcs->{_ft}      = '';
	$sukdmdcs->{_fxgo}    = '';
	$sukdmdcs->{_fxso}    = '';
	$sukdmdcs->{_fxt}     = '';
	$sukdmdcs->{_fzt}     = '';
	$sukdmdcs->{_infile}  = '';
	$sukdmdcs->{_jpfile}  = '';
	$sukdmdcs->{_mtr}     = '';
	$sukdmdcs->{_ns}      = '';
	$sukdmdcs->{_ntr}     = '';
	$sukdmdcs->{_nxgo}    = '';
	$sukdmdcs->{_nxso}    = '';
	$sukdmdcs->{_nxt}     = '';
	$sukdmdcs->{_nzt}     = '';
	$sukdmdcs->{_offmax}  = '';
	$sukdmdcs->{_outfile} = '';
	$sukdmdcs->{_recfile} = '';
	$sukdmdcs->{_recsurf} = '';
	$sukdmdcs->{_scale}   = '';
	$sukdmdcs->{_ttfile}  = '';
	$sukdmdcs->{_v0}      = '';
	$sukdmdcs->{_zdat}    = '';
	$sukdmdcs->{_zrec}    = '';
	$sukdmdcs->{_Step}    = '';
	$sukdmdcs->{_note}    = '';
}

=head2 sub aperx 


=cut

sub aperx {

	my ( $self, $aperx ) = @_;
	if ( $aperx ne $empty_string ) {

		$sukdmdcs->{_aperx} = $aperx;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' aperx=' . $sukdmdcs->{_aperx};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' aperx=' . $sukdmdcs->{_aperx};

	}
	else {
		print("sukdmdcs, aperx, missing aperx,\n");
	}
}

=head2 sub datfile 


=cut

sub datfile {

	my ( $self, $datfile ) = @_;
	if ( $datfile ne $empty_string ) {

		$sukdmdcs->{_datfile} = $datfile;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' datfile=' . $sukdmdcs->{_datfile};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' datfile=' . $sukdmdcs->{_datfile};

	}
	else {
		print("sukdmdcs, datfile, missing datfile,\n");
	}
}

=head2 sub datsurf 


=cut

sub datsurf {

	my ( $self, $datsurf ) = @_;
	if ( $datsurf ne $empty_string ) {

		$sukdmdcs->{_datsurf} = $datsurf;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' datsurf=' . $sukdmdcs->{_datsurf};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' datsurf=' . $sukdmdcs->{_datsurf};

	}
	else {
		print("sukdmdcs, datsurf, missing datsurf,\n");
	}
}

=head2 sub dc 


=cut

sub dc {

	my ( $self, $dc ) = @_;
	if ( $dc ne $empty_string ) {

		$sukdmdcs->{_dc}   = $dc;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' dc=' . $sukdmdcs->{_dc};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' dc=' . $sukdmdcs->{_dc};

	}
	else {
		print("sukdmdcs, dc, missing dc,\n");
	}
}

=head2 sub ds 


=cut

sub ds {

	my ( $self, $ds ) = @_;
	if ( $ds ne $empty_string ) {

		$sukdmdcs->{_ds}   = $ds;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' ds=' . $sukdmdcs->{_ds};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' ds=' . $sukdmdcs->{_ds};

	}
	else {
		print("sukdmdcs, ds, missing ds,\n");
	}
}

=head2 sub dt 


=cut

sub dt {

	my ( $self, $dt ) = @_;
	if ( $dt ne $empty_string ) {

		$sukdmdcs->{_dt}   = $dt;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' dt=' . $sukdmdcs->{_dt};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' dt=' . $sukdmdcs->{_dt};

	}
	else {
		print("sukdmdcs, dt, missing dt,\n");
	}
}

=head2 sub dxgo 


=cut

sub dxgo {

	my ( $self, $dxgo ) = @_;
	if ( $dxgo ne $empty_string ) {

		$sukdmdcs->{_dxgo} = $dxgo;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' dxgo=' . $sukdmdcs->{_dxgo};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' dxgo=' . $sukdmdcs->{_dxgo};

	}
	else {
		print("sukdmdcs, dxgo, missing dxgo,\n");
	}
}

=head2 sub dxso 


=cut

sub dxso {

	my ( $self, $dxso ) = @_;
	if ( $dxso ne $empty_string ) {

		$sukdmdcs->{_dxso} = $dxso;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' dxso=' . $sukdmdcs->{_dxso};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' dxso=' . $sukdmdcs->{_dxso};

	}
	else {
		print("sukdmdcs, dxso, missing dxso,\n");
	}
}

=head2 sub dxt 


=cut

sub dxt {

	my ( $self, $dxt ) = @_;
	if ( $dxt ne $empty_string ) {

		$sukdmdcs->{_dxt}  = $dxt;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' dxt=' . $sukdmdcs->{_dxt};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' dxt=' . $sukdmdcs->{_dxt};

	}
	else {
		print("sukdmdcs, dxt, missing dxt,\n");
	}
}

=head2 sub dzo 


=cut

sub dzo {

	my ( $self, $dzo ) = @_;
	if ( $dzo ne $empty_string ) {

		$sukdmdcs->{_dzo}  = $dzo;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' dzo=' . $sukdmdcs->{_dzo};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' dzo=' . $sukdmdcs->{_dzo};

	}
	else {
		print("sukdmdcs, dzo, missing dzo,\n");
	}
}

=head2 sub freq 


=cut

sub freq {

	my ( $self, $freq ) = @_;
	if ( $freq ne $empty_string ) {

		$sukdmdcs->{_freq} = $freq;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' freq=' . $sukdmdcs->{_freq};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' freq=' . $sukdmdcs->{_freq};

	}
	else {
		print("sukdmdcs, freq, missing freq,\n");
	}
}

=head2 sub fs 


=cut

sub fs {

	my ( $self, $fs ) = @_;
	if ( $fs ne $empty_string ) {

		$sukdmdcs->{_fs}   = $fs;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' fs=' . $sukdmdcs->{_fs};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' fs=' . $sukdmdcs->{_fs};

	}
	else {
		print("sukdmdcs, fs, missing fs,\n");
	}
}

=head2 sub ft 


=cut

sub ft {

	my ( $self, $ft ) = @_;
	if ( $ft ne $empty_string ) {

		$sukdmdcs->{_ft}   = $ft;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' ft=' . $sukdmdcs->{_ft};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' ft=' . $sukdmdcs->{_ft};

	}
	else {
		print("sukdmdcs, ft, missing ft,\n");
	}
}

=head2 sub fxgo 


=cut

sub fxgo {

	my ( $self, $fxgo ) = @_;
	if ( $fxgo ne $empty_string ) {

		$sukdmdcs->{_fxgo} = $fxgo;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' fxgo=' . $sukdmdcs->{_fxgo};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' fxgo=' . $sukdmdcs->{_fxgo};

	}
	else {
		print("sukdmdcs, fxgo, missing fxgo,\n");
	}
}

=head2 sub fxso 


=cut

sub fxso {

	my ( $self, $fxso ) = @_;
	if ( $fxso ne $empty_string ) {

		$sukdmdcs->{_fxso} = $fxso;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' fxso=' . $sukdmdcs->{_fxso};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' fxso=' . $sukdmdcs->{_fxso};

	}
	else {
		print("sukdmdcs, fxso, missing fxso,\n");
	}
}

=head2 sub fxt 


=cut

sub fxt {

	my ( $self, $fxt ) = @_;
	if ( $fxt ne $empty_string ) {

		$sukdmdcs->{_fxt}  = $fxt;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' fxt=' . $sukdmdcs->{_fxt};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' fxt=' . $sukdmdcs->{_fxt};

	}
	else {
		print("sukdmdcs, fxt, missing fxt,\n");
	}
}

=head2 sub fzt 


=cut

sub fzt {

	my ( $self, $fzt ) = @_;
	if ( $fzt ne $empty_string ) {

		$sukdmdcs->{_fzt}  = $fzt;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' fzt=' . $sukdmdcs->{_fzt};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' fzt=' . $sukdmdcs->{_fzt};

	}
	else {
		print("sukdmdcs, fzt, missing fzt,\n");
	}
}

=head2 sub infile 


=cut

sub infile {

	my ( $self, $infile ) = @_;
	if ( $infile ne $empty_string ) {

		$sukdmdcs->{_infile} = $infile;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' infile=' . $sukdmdcs->{_infile};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' infile=' . $sukdmdcs->{_infile};

	}
	else {
		print("sukdmdcs, infile, missing infile,\n");
	}
}

=head2 sub jpfile 


=cut

sub jpfile {

	my ( $self, $jpfile ) = @_;
	if ( $jpfile ne $empty_string ) {

		$sukdmdcs->{_jpfile} = $jpfile;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' jpfile=' . $sukdmdcs->{_jpfile};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' jpfile=' . $sukdmdcs->{_jpfile};

	}
	else {
		print("sukdmdcs, jpfile, missing jpfile,\n");
	}
}

=head2 sub mtr 


=cut

sub mtr {

	my ( $self, $mtr ) = @_;
	if ( $mtr ne $empty_string ) {

		$sukdmdcs->{_mtr}  = $mtr;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' mtr=' . $sukdmdcs->{_mtr};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' mtr=' . $sukdmdcs->{_mtr};

	}
	else {
		print("sukdmdcs, mtr, missing mtr,\n");
	}
}

=head2 sub ns 


=cut

sub ns {

	my ( $self, $ns ) = @_;
	if ( $ns ne $empty_string ) {

		$sukdmdcs->{_ns}   = $ns;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' ns=' . $sukdmdcs->{_ns};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' ns=' . $sukdmdcs->{_ns};

	}
	else {
		print("sukdmdcs, ns, missing ns,\n");
	}
}

=head2 sub ntr 


=cut

sub ntr {

	my ( $self, $ntr ) = @_;
	if ( $ntr ne $empty_string ) {

		$sukdmdcs->{_ntr}  = $ntr;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' ntr=' . $sukdmdcs->{_ntr};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' ntr=' . $sukdmdcs->{_ntr};

	}
	else {
		print("sukdmdcs, ntr, missing ntr,\n");
	}
}

=head2 sub nxgo 


=cut

sub nxgo {

	my ( $self, $nxgo ) = @_;
	if ( $nxgo ne $empty_string ) {

		$sukdmdcs->{_nxgo} = $nxgo;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' nxgo=' . $sukdmdcs->{_nxgo};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' nxgo=' . $sukdmdcs->{_nxgo};

	}
	else {
		print("sukdmdcs, nxgo, missing nxgo,\n");
	}
}

=head2 sub nxso 


=cut

sub nxso {

	my ( $self, $nxso ) = @_;
	if ( $nxso ne $empty_string ) {

		$sukdmdcs->{_nxso} = $nxso;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' nxso=' . $sukdmdcs->{_nxso};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' nxso=' . $sukdmdcs->{_nxso};

	}
	else {
		print("sukdmdcs, nxso, missing nxso,\n");
	}
}

=head2 sub nxt 


=cut

sub nxt {

	my ( $self, $nxt ) = @_;
	if ( $nxt ne $empty_string ) {

		$sukdmdcs->{_nxt}  = $nxt;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' nxt=' . $sukdmdcs->{_nxt};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' nxt=' . $sukdmdcs->{_nxt};

	}
	else {
		print("sukdmdcs, nxt, missing nxt,\n");
	}
}

=head2 sub nzt 


=cut

sub nzt {

	my ( $self, $nzt ) = @_;
	if ( $nzt ne $empty_string ) {

		$sukdmdcs->{_nzt}  = $nzt;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' nzt=' . $sukdmdcs->{_nzt};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' nzt=' . $sukdmdcs->{_nzt};

	}
	else {
		print("sukdmdcs, nzt, missing nzt,\n");
	}
}

=head2 sub offmax 


=cut

sub offmax {

	my ( $self, $offmax ) = @_;
	if ( $offmax ne $empty_string ) {

		$sukdmdcs->{_offmax} = $offmax;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' offmax=' . $sukdmdcs->{_offmax};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' offmax=' . $sukdmdcs->{_offmax};

	}
	else {
		print("sukdmdcs, offmax, missing offmax,\n");
	}
}

=head2 sub outfile 


=cut

sub outfile {

	my ( $self, $outfile ) = @_;
	if ( $outfile ne $empty_string ) {

		$sukdmdcs->{_outfile} = $outfile;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' outfile=' . $sukdmdcs->{_outfile};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' outfile=' . $sukdmdcs->{_outfile};

	}
	else {
		print("sukdmdcs, outfile, missing outfile,\n");
	}
}

=head2 sub recfile 


=cut

sub recfile {

	my ( $self, $recfile ) = @_;
	if ( $recfile ne $empty_string ) {

		$sukdmdcs->{_recfile} = $recfile;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' recfile=' . $sukdmdcs->{_recfile};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' recfile=' . $sukdmdcs->{_recfile};

	}
	else {
		print("sukdmdcs, recfile, missing recfile,\n");
	}
}

=head2 sub recsurf 


=cut

sub recsurf {

	my ( $self, $recsurf ) = @_;
	if ( $recsurf ne $empty_string ) {

		$sukdmdcs->{_recsurf} = $recsurf;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' recsurf=' . $sukdmdcs->{_recsurf};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' recsurf=' . $sukdmdcs->{_recsurf};

	}
	else {
		print("sukdmdcs, recsurf, missing recsurf,\n");
	}
}

=head2 sub scale 


=cut

sub scale {

	my ( $self, $scale ) = @_;
	if ( $scale ne $empty_string ) {

		$sukdmdcs->{_scale} = $scale;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' scale=' . $sukdmdcs->{_scale};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' scale=' . $sukdmdcs->{_scale};

	}
	else {
		print("sukdmdcs, scale, missing scale,\n");
	}
}

=head2 sub ttfile 


=cut

sub ttfile {

	my ( $self, $ttfile ) = @_;
	if ( $ttfile ne $empty_string ) {

		$sukdmdcs->{_ttfile} = $ttfile;
		$sukdmdcs->{_note} =
		  $sukdmdcs->{_note} . ' ttfile=' . $sukdmdcs->{_ttfile};
		$sukdmdcs->{_Step} =
		  $sukdmdcs->{_Step} . ' ttfile=' . $sukdmdcs->{_ttfile};

	}
	else {
		print("sukdmdcs, ttfile, missing ttfile,\n");
	}
}

=head2 sub v0 


=cut

sub v0 {

	my ( $self, $v0 ) = @_;
	if ( $v0 ne $empty_string ) {

		$sukdmdcs->{_v0}   = $v0;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' v0=' . $sukdmdcs->{_v0};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' v0=' . $sukdmdcs->{_v0};

	}
	else {
		print("sukdmdcs, v0, missing v0,\n");
	}
}

=head2 sub zdat 


=cut

sub zdat {

	my ( $self, $zdat ) = @_;
	if ( $zdat ne $empty_string ) {

		$sukdmdcs->{_zdat} = $zdat;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' zdat=' . $sukdmdcs->{_zdat};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' zdat=' . $sukdmdcs->{_zdat};

	}
	else {
		print("sukdmdcs, zdat, missing zdat,\n");
	}
}

=head2 sub zrec 


=cut

sub zrec {

	my ( $self, $zrec ) = @_;
	if ( $zrec ne $empty_string ) {

		$sukdmdcs->{_zrec} = $zrec;
		$sukdmdcs->{_note} = $sukdmdcs->{_note} . ' zrec=' . $sukdmdcs->{_zrec};
		$sukdmdcs->{_Step} = $sukdmdcs->{_Step} . ' zrec=' . $sukdmdcs->{_zrec};

	}
	else {
		print("sukdmdcs, zrec, missing zrec,\n");
	}
}

=head2 sub get_max_index

max index = number of input variables -1
 
=cut

sub get_max_index {
	my ($self) = @_;
	my $max_index = 34;

	return ($max_index);
}

1;
