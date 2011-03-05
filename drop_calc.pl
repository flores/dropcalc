#!/usr/bin/perl



 use CGI::Form;

 $q = new CGI::Form;

 print $q->header();

 print $q->start_html(-title=>'The new and improved drop checker for target CO2 calculator');

 print "<H2>Reference KH for target CO2 calculator</H2>\n";



 if ($q->cgi->var('REQUEST_METHOD') eq 'GET') {

    $co2=0;
    $mix=0;

 print "This calculator allows you to make a reference KH solution for a CO2 drop checker using some container, NaHCO3 (baking soda), Bromothymol blue (such as from a low-range AP pH test kit), and any target CO2 ppm.  Keep in mind that this target should be the perfect green on your drop checker (6.6 pH).  This calculator assumes humans can see \"green\" at +/- 0.2pH.<br />\n
<img src=\"/logs/images/stuff/d1_small.jpg\"><br />\n<br />\n
So, if we use that assumption with two drop checkers, we can calculate CO2 to +/- 2.5ppm.<br />\n
<img src=\"/logs/images/stuff/d2_small.jpg\"><br />\n<br />\n";
    &printForm($q,$val);

 } else {

    $co2=$q->param('co2');

    $mix=$q->param('mix');

    $unit=$q->param('unit');

    my $checkers=$q->param('checkers');

    if ( ($co2=~/^[\d]+$/) && ($mix=~/^\.?[\d]+\.?\d*$/) && ($mix!~/.*\..*\./) ) {

       $op=$q->param('Action');

       if ($op eq "Gimmie!") {

# CO2 (in PPM) = 3 * KH * 10^( 7-pH )

		$dkh=(($co2)/(3*2.5119));

		if ($checkers=~/two/)
		{
			$co2_min = $co2 + 2.5;
			$co2_max = $co2 - 2.5;
		}
		else
		{
			$co2_min_min= 3 * $dkh * ( 10 ** ( 7 - 6.8 ));
			$co2_min= 3 * $dkh * ( 10 ** ( 7 - 6.4 ));
			$dkh_min=$dkh;
			$co2_min_perfect=$co2;
		}
		
		if ($checkers=~/two/)
		{
#the high range
			$dkh_max = $co2_max / ( 3 * ( 10 ** ( 7 - 6.8 ) ));
			$co2_max_max = 3 * $dkh_max * ( 10 ** ( 7 - 6.4 ));
			$co2_max_perfect = 3 * $dkh_max * ( 10 ** ( 7 - 6.6 ));
#the low range
			$dkh_min = $co2_min / ( 3 * ( 10 ** ( 7 - 6.4 ) ));
			$co2_min_min= 3 * $dkh_min * ( 10 ** (7 - 6.8));
			$co2_min_perfect = 3 * $dkh_min* ( 10 ** (7 - 6.6));
		}
#1 liter of distilled water with a 5 dKH .15 grams (actually .14994)

	  	if ($unit=~/gallon/i)
	  	{
	  		$dil=$mix*3.78541178;
	  	}
	  	else
	  	{
	  		$dil=$mix;
	  	}
		
	  	$mgrams_max=(($dkh_max*$dil)/33.346672)*1000;
	  	$mgrams_min=(($dkh_min*$dil)/33.346672)*1000;
#	  $grams=(($dkh*$dil)/30.02);
	  
	  	$dkh = sprintf("%.3f", $dkh);
	  	$mgrams_max = sprintf("%.1f", $mgrams_max);
	  	$mgrams_min = sprintf("%.1f", $mgrams_min);
		$dkh_min = sprintf("%.1f", $dkh_min);
		$dkh_max = sprintf("%.1f", $dkh_max);
		$co2_min = sprintf("%.1f", $co2_min);
		$co2_min_perfect = sprintf("%.1f", $co2_min_perfect);
		$co2_max_perfect = sprintf("%.1f", $co2_max_perfect);
		$co2_max_max = sprintf("%.1f", $co2_max_max);
		$co2_min_min = sprintf("%.1f", $co2_min_min);

          	print "1) Add $mgrams_min mg of baking soda to $mix $unit of DI water for $dkh_min dKH. Fully dilute.<br />\n
	  	        2) Add the contents of this mixture to the drop checker, then add a couple drops of Bromothymol blue to the drop checker.<br />\n
			The range for \"green\" in this drop checker is $co2_min_min - $co2_min ppm CO2.  The perfect green (shade, reaction between Br. Blue and CO3) is $co2_min_perfect ppm CO2.<br />\n
<br />\n";
		if ($checkers=~/two/)
		{
			print "3) Add $mgrams_max mg of baking soda to $mix $unit of DI water for $dkh_max dKH. Fully dilute.<br />\n
                        4) Add the contents of this mixture to the second drop checker, then add a couple drops of Bromothymol blue to that drop checker.<br />\n
			The range for \"green\" in the second drop checker is $co2_max - $co2_max_max ppm CO2.  The perfect green (shade, reaction between Br. Blue and CO3) is $co2_max_perfect ppm CO2.<br />\n
		<br />\n
		If both drop checkers are green, you have $co2_max - $co2_min ppm CO2.<br />\n<br />\n<br />\n";
		}
       	
       }

    } else {

       print "<P><STRONG>Enter only numbers!</STRONG><BR><BR>\n";

    }

    $q->param('hiddenValue',$val);

    &printForm($q);

 }

 print $q->end_html();



 sub printForm {

    my($q,$val)=@_;

    print $q->start_multipart_form();

    print "My target CO2 is ";

    print $q->textfield(-name=>'co2',-size=>5,-maxlength=>3);

    print " ppm<br />\n";#</TD></TR>\n<TR><TD COLSPAN=2>\n";

    print "I have a ";

    print $q->textfield(-name=>'mix',-size=>5,-maxlength=>5);

    print $q->radio_group( -name=>'unit', values=>['Liter', 'Gallon'], -default=>'Liter');

    print " container to mix with (recommend at least 2L)<br />\n";

    print "I have "; 
    print $q->radio_group( -name=>'checkers', values=>['one', 'two'], -default=>'two');

    print " drop checkers.<br />\n";

    print $q->submit(-name=>'Action',-value=>'Gimmie!');


 }


