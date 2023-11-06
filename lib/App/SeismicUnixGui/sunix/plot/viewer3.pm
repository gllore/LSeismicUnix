 package viewer3;


=head1 DOCUMENTATION

=head2 SYNOPSIS

PERL PROGRAM NAME:  VIEWER3 - VIEWER for 3-dimensional model				", 
AUTHOR: Juan Lorenzo (Perl module only)
DATE:   
DESCRIPTION:
Version: 

=head2 USE

=head3 NOTES

=head4 Examples

=head3 SEISMIC UNIX NOTES

 VIEWER3 - VIEWER for 3-dimensional model				", 

 viewer3 [parameters] < hzfile		 				

 Optional Parameters:							",	

 hue=1		=1 for hue =0 for black/white				
 q=-0.6,0.06,-0.06,0.8 define the quaternion			   	
 tbs=0.8 	the lager the trackball size is, the slower it rotates  
 verbose=0     =1 print some useful information			
 rayfile=NULL	ray path file to read in 				
 wffile=NULL	wavefront file to read in				
 sttfile=NULL  surface traveltime file to read in                      

 Menu: The rightmost mouse button, with cursor placed on the graphics  
       window activates the following menu:				
 Quit:			quits the application				
 Full Screen:		expands graphics window to full screen		
 White/Color Rays:		selects colored (default) or white rays	", 
 Plot Rays:			show the rays (default: off)		
 Surface Traveltimes:	show surface traveltimes (default: off)		
 Wired or Solid WFs:	style of wavefront display wireframe (default)	
			or solid					",	
 Plot Wavefronts:	turn on wavefronts default: off			
 TRI or TETRA or LAYER or HORZ:	toggles display from wireframe	
 			triangulated horizons, to wireframe tetrahedra, 
			to solid layers, to solid horizons		
 Layer1:		toggle layer on or off (default is on)		
 ....									

 Notes:								
 In general, the tetrahedra model should be generated by tetramod	
 (tetrahedra modle builder) which outputs a file called hzfile, so	
 that viewer3 can read input from stdin.				

 If, in addition, you have 3D raypath information (rayfile), wavefronts
 (wffile) and surface traveltimes (sttfile), typically generated by    
 sutetraray (tetrahedral wavefront construction ray tracing),	  	
 then rays, wavefronts and surface traveltimes can be displayed as well
 as the model.							 	

 The plot may be rotated by depressing the leftmost mouse button	
 and dragging the cursor in the desired direction of rotation. The speed
 of rotation is controlled by the speed of the cursor.			

 The plot may be rescaled by depressing the shift key, while also	
 depressing and dragging the cursor up or down on the display window.	



 Credits:
  	CWP: Zhaobo Meng, 1996

=head2 CHANGES and their DATES

=cut
 use Moose;
our $VERSION = '0.0.1';
use aliased 'App::SeismicUnixGui::misc::L_SU_global_constants';

	my $get					= L_SU_global_constants->new();

	my $var				= $get->var();
	my $empty_string    	= $var->{_empty_string};


	my $viewer3		= {
		_hue					=> '',
		_q					=> '',
		_rayfile					=> '',
		_sttfile					=> '',
		_tbs					=> '',
		_verbose					=> '',
		_wffile					=> '',
		_Step					=> '',
		_note					=> '',
    };


=head2 sub Step

collects switches and assembles bash instructions
by adding the program name

=cut

 sub  Step {

	$viewer3->{_Step}     = 'viewer3'.$viewer3->{_Step};
	return ( $viewer3->{_Step} );

 }


=head2 sub note

collects switches and assembles bash instructions
by adding the program name

=cut

 sub  note {

	$viewer3->{_note}     = 'viewer3'.$viewer3->{_note};
	return ( $viewer3->{_note} );

 }


=head2 sub clear

=cut

 sub clear {

		$viewer3->{_hue}			= '';
		$viewer3->{_q}			= '';
		$viewer3->{_rayfile}			= '';
		$viewer3->{_sttfile}			= '';
		$viewer3->{_tbs}			= '';
		$viewer3->{_verbose}			= '';
		$viewer3->{_wffile}			= '';
		$viewer3->{_Step}			= '';
		$viewer3->{_note}			= '';
 }


=head2 sub hue 


=cut

 sub hue {

	my ( $self,$hue )		= @_;
	if ( $hue ne $empty_string ) {

		$viewer3->{_hue}		= $hue;
		$viewer3->{_note}		= $viewer3->{_note}.' hue='.$viewer3->{_hue};
		$viewer3->{_Step}		= $viewer3->{_Step}.' hue='.$viewer3->{_hue};

	} else { 
		print("viewer3, hue, missing hue,\n");
	 }
 }


=head2 sub q 


=cut

 sub q {

	my ( $self,$q )		= @_;
	if ( $q ne $empty_string ) {

		$viewer3->{_q}		= $q;
		$viewer3->{_note}		= $viewer3->{_note}.' q='.$viewer3->{_q};
		$viewer3->{_Step}		= $viewer3->{_Step}.' q='.$viewer3->{_q};

	} else { 
		print("viewer3, q, missing q,\n");
	 }
 }


=head2 sub rayfile 


=cut

 sub rayfile {

	my ( $self,$rayfile )		= @_;
	if ( $rayfile ne $empty_string ) {

		$viewer3->{_rayfile}		= $rayfile;
		$viewer3->{_note}		= $viewer3->{_note}.' rayfile='.$viewer3->{_rayfile};
		$viewer3->{_Step}		= $viewer3->{_Step}.' rayfile='.$viewer3->{_rayfile};

	} else { 
		print("viewer3, rayfile, missing rayfile,\n");
	 }
 }


=head2 sub sttfile 


=cut

 sub sttfile {

	my ( $self,$sttfile )		= @_;
	if ( $sttfile ne $empty_string ) {

		$viewer3->{_sttfile}		= $sttfile;
		$viewer3->{_note}		= $viewer3->{_note}.' sttfile='.$viewer3->{_sttfile};
		$viewer3->{_Step}		= $viewer3->{_Step}.' sttfile='.$viewer3->{_sttfile};

	} else { 
		print("viewer3, sttfile, missing sttfile,\n");
	 }
 }


=head2 sub tbs 


=cut

 sub tbs {

	my ( $self,$tbs )		= @_;
	if ( $tbs ne $empty_string ) {

		$viewer3->{_tbs}		= $tbs;
		$viewer3->{_note}		= $viewer3->{_note}.' tbs='.$viewer3->{_tbs};
		$viewer3->{_Step}		= $viewer3->{_Step}.' tbs='.$viewer3->{_tbs};

	} else { 
		print("viewer3, tbs, missing tbs,\n");
	 }
 }


=head2 sub verbose 


=cut

 sub verbose {

	my ( $self,$verbose )		= @_;
	if ( $verbose ne $empty_string ) {

		$viewer3->{_verbose}		= $verbose;
		$viewer3->{_note}		= $viewer3->{_note}.' verbose='.$viewer3->{_verbose};
		$viewer3->{_Step}		= $viewer3->{_Step}.' verbose='.$viewer3->{_verbose};

	} else { 
		print("viewer3, verbose, missing verbose,\n");
	 }
 }


=head2 sub wffile 


=cut

 sub wffile {

	my ( $self,$wffile )		= @_;
	if ( $wffile ne $empty_string ) {

		$viewer3->{_wffile}		= $wffile;
		$viewer3->{_note}		= $viewer3->{_note}.' wffile='.$viewer3->{_wffile};
		$viewer3->{_Step}		= $viewer3->{_Step}.' wffile='.$viewer3->{_wffile};

	} else { 
		print("viewer3, wffile, missing wffile,\n");
	 }
 }


=head2 sub get_max_index

max index = number of input variables -1
 
=cut
 
sub get_max_index {
 	  my ($self) = @_;
    my $max_index = 36;

    return($max_index);
}
 
 
1; 
