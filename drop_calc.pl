#!/usr/bin/perl



 use CGI::Form;

 $q = new CGI::Form;

 print $q->header();

 print $q->start_html(-title=>'Engineer a DIY Drop Checker solution for any target CO2');

 print "<H2>Reference KH for target CO2 calculator</H2><H3>(for one or two drop checkers, the colors green or yellow, or any margin of error.)</H3>\n";

 if ($q->cgi->var('REQUEST_METHOD') eq 'GET') {

    $co2=0;
    $mix=0;

 print "<strong>This calculator is currently in Beta!  See <a href='http://www.plantedtank.net/forums/fertilizers-water-parameters/129720-drop-checker-new-way-use-one.html'>here</a></strong><br /><br />\n";
 print "This calculator allows you to make a reference KH solution for a CO2 drop checker using some container, NaHCO3 (baking soda), Bromothymol blue (such as from a low-range AP pH test kit), and any target CO2 ppm.  Keep in mind that this target should be the perfect green on your drop checker (6.6 pH).  This calculator assumes humans can see \"green\" at +/- 0.2pH.<br />\n
<img src=\"/d1_small.jpg\"><br />\n<br />\n
So, if we use that assumption with two drop checkers, we can calculate CO2 anywhere from +/- 2.5ppm to 20ppm.<br />\n
<img src=\"/d2_small.jpg\"><br />\n<br />\n
Another way to do this is Hoppy\'s method of targeting the color yellow, which is much easier for some to read.<br />\n
<img src=\"/yellow.jpg\"><br />\n<br />\n";
    &printForm($q,$val);

 } else {

    $co2=$q->param('co2');

    $mix=$q->param('mix');

    $unit=$q->param('unit');
    
    $range=$q->param('range');

    $color=$q->param('color');

    my $checkers=$q->param('checkers');

    if ( $co2  <= $range )
    {
		print "<P><STRONG>The CO2 target must be more than the margin of error!</STRONG><br /><br />\n";
    }

    elsif ( ($co2=~/^[\d]+$/) && ($mix=~/^\.?[\d]+\.?\d*$/) && ($mix!~/.*\..*\./) ) {

       $op=$q->param('Action');

       if ($op eq "Gimmie!") {

# CO2 (in PPM) = 3 * KH * 10^( 7-pH )

		$dkh=(($co2)/(3*2.5119));

		$margin = $range;


# pH color chart: http://www.americanaquariumproducts.com/images/graphics/phlowhighrange2.jpg

		if ($color=~/green/)
		{
			$ph_high = 6.8;
			$ph_low = 6.4;
			$ph_perfect = 6.6;
		}
		else
		{
			$ph_high = 6.0;
			$ph_low = 6.0;
			$ph_perfect = 6.0;
		}

		if ($checkers=~/two/)
		{
			$co2_min = $co2 + $margin;
			$co2_max = $co2 - $margin;
		}
		else
		{
			$co2_min_min= 3 * $dkh * ( 10 ** ( 7 - $ph_high ));
			$co2_min= 3 * $dkh * ( 10 ** ( 7 - $ph_low ));
			$dkh_min=$dkh;
			$co2_min_perfect=$co2;
		}
		
		if ($checkers=~/two/)
		{
#the high range
			$dkh_max = $co2_max / ( 3 * ( 10 ** ( 7 - $ph_high ) ));
			$co2_max_max = 3 * $dkh_max * ( 10 ** ( 7 - $ph_low ));
			$co2_max_perfect = 3 * $dkh_max * ( 10 ** ( 7 - $ph_perfect ));
#the low range
			$dkh_min = $co2_min / ( 3 * ( 10 ** ( 7 - $ph_low ) ));
			$co2_min_min= 3 * $dkh_min * ( 10 ** (7 - $ph_high));
			$co2_min_perfect = 3 * $dkh_min* ( 10 ** (7 - $ph_perfect));
		}

# dKH less than 1dKH is inaccurate.

		if ( ($dkh_min <=1) || ($dkh_max <= 1) )
		{
			if ( $dkh_max <= 1 )
			{
				$alert = "low range and high range";
			}
			else 
			{
				$alert = "low range";
			}
			print "<br /><font color='red'><strong>Your values are such that we cannot accurately measure CO2, since the resulting $alert would be less than 1dKH.</strong></font><br />
<p>
'[I]t appears that a KH below 1 dKH does not buffer against CO2 additions, which means the relationship between pH/KH/ppm of CO2 doesn't hold true, and the pH can have many values for a given amount of CO2 in the water. But, that 1 dKH is only a rough estimate given as such on the forum a few months ago. What if the real limit is 1.6 or 1.1 or .9 dKH? That prevents a drop checker from working with a KH below that limit, and makes it hard to use the yellow color as the indication color.' - Hoppy
</p><p>
'For the purposes of moving forward with this calculator, I\'m moving forward with 1dKH.  Any less and the calculator breaks.  This number is not set in stone and we can change it if this estimate is unfair.' - wet
</p>
<font color='red'>Things to try: use a higher CO2 target ";
			if ($color = 'yellow')
			{
				print ", calibrate a green instead of yellow drop checker, ";
			}
			print "or use a smaller margin of error.</strong></font><br /><br /><br />";
			break;
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
		$dkh_min = sprintf("%.2f", $dkh_min);
		$dkh_max = sprintf("%.2f", $dkh_max);
		$co2_min = sprintf("%.1f", $co2_min);
		$co2_min_perfect = sprintf("%.1f", $co2_min_perfect);
		$co2_max_perfect = sprintf("%.1f", $co2_max_perfect);
		$co2_max_max = sprintf("%.1f", $co2_max_max);
		$co2_min_min = sprintf("%.1f", $co2_min_min);

          	print "1) Add $mgrams_min mg of baking soda to $mix $unit of DI water for $dkh_min dKH. Fully dilute.<br />\n
	  	        2) Add the contents of this mixture to the drop checker, then add a couple drops of Bromothymol blue to the drop checker.<br />\n";
		if ($color =~ /green/)
		{
			print "The range for \"$color\" in this drop checker is $co2_min_min - $co2_min ppm CO2.";
		}
		print "The perfect $color (shade, reaction between Br. Blue and CO3) is $co2_min_perfect ppm CO2.<br />\n
<br />\n";
		if ($checkers=~/two/)
		{
			print "3) Add $mgrams_max mg of baking soda to $mix $unit of DI water for $dkh_max dKH. Fully dilute.<br />\n
                        4) Add the contents of this mixture to the second drop checker, then add a couple drops of Bromothymol blue to that drop checker.<br />\n";
			if ($color =~ /green/)
			{
				print "The range for \"$color\" in the second drop checker is $co2_max - $co2_max_max ppm CO2.";
			}  
			print "The perfect $color (shade, reaction between Br. Blue and CO3) is $co2_max_perfect ppm CO2.<br />\n";
			
			print "<br />\n	If both drop checkers are $color, you have $co2_max - $co2_min ppm CO2.<br />\n<br />\n<br />\n";
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
    
    print "with a margin of error of +/- ";
    print $q->radio_group( -name=>'range', values=>['2.5', '5', '10', '15', '20', '25', '30'], -default=>'5');
    print " ppm.<br />\n";

    print "I have a ";
    print $q->textfield(-name=>'mix',-size=>5,-maxlength=>5);
    print $q->radio_group( -name=>'unit', values=>['Liter', 'Gallon'], -default=>'Liter');
    print " container to mix with (recommend at least 2L)<br />\n";

    print "I find it easiest to see ";
    print $q->radio_group( -name=>'color', values=>['green', 'yellow'], -default=>'green');
    print ".<br />\n";

    print "I have "; 
    print $q->radio_group( -name=>'checkers', values=>['one', 'two'], -default=>'two');

    print " drop checkers.<br />\n";

    print $q->submit(-name=>'Action',-value=>'Gimmie!');

    print "<br /><br /><p>back to <a href='http://petalphile.com' target='_blank'>petalphile.com</a>";


 }


