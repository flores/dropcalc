#!/usr/bin/perl



use CGI::Form;

$q = new CGI::Form;

print $q->header();
        print '<html><head>
<link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="http://cdn.petalphile.com/javascript/jquery-1.4.4.min.js"></script>
<script type="text/javascript" src="http://cdn.petalphile.com/javascript/jquery-ui.min.js"></script>';

print '<script>
	$(document).ready(function() {
		
		$("#accordion").accordion({ 
			active: 1, 
			fillSpace: false, 
			autoHeight: false,
			collapsible: true
		 });
	});
</script>';

print '<title>Engineer a DIY Drop Checker solution for any target CO2</title>';

print "</head>";

print "<H2>Reference KH for target CO2 calculator</H2><H3>(for one or two drop checkers, the colors green or yellow, or any margin of error.)</H3>\n";

print "<div id='accordion'>";

print "<h4><a href='#'>How it works</a></h4>
<div>
This calculator allows you to make a reference KH solution for a CO2 drop checker using some container, NaHCO3 (baking soda), Bromothymol blue (such as from a low-range AP pH test kit), and any target CO2 ppm.  Keep in mind that this target should be the perfect green on your drop checker (6.6 pH).  This calculator assumes humans can see \"green\" at +/- 0.2pH.<br />\n
<img src=\"/public/d1_small.jpg\"><br />\n<br />\n
So, if we use that assumption with two drop checkers, we can calculate CO2 anywhere from +/- 2.5ppm to 30ppm.<br />\n
<img src=\"/public/d2_small.jpg\"><br />\n<br />\n
pat_w provides another example.<br />\n
<img src=\"/public/patw_example.jpg\"<br />\n
<h6>image courtesy of pat_w</h6><br />\n
Another way to do this is Hoppy\'s method of targeting the color yellow, which is much easier for some to read.<br />
<img src=\"/public/yellow.jpg\"><br />
<h6>image courtesy of hoppycalif</h6><br />
</div>";

print "<h4><a href='#'>Calculator</a></h4>";
print "<div>";

if ($q->cgi->var('REQUEST_METHOD') eq 'GET') {

	$co2=0;
	$mix=0;



	

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

	if ($color = 'green')
	{
		$ph_high = 6.8;
		$ph_low = 6.4;
		$ph_perfect = 6.6;
	}
	else
	{
		$ph_high = 6.0;
		$ph_low = $ph_high;
		$ph_perfect = $ph_low;
	}

	if ($checkers=~/two/)
	{
		$co2_min = $co2 + $margin;
		$co2_max = $co2 - $margin;
#the high range
		$dkh_max = $co2_max / ( 3 * ( 10 ** ( 7 - $ph_high ) ));
		$co2_max_max = 3 * $dkh_max * ( 10 ** ( 7 - $ph_low ));
		$co2_max_perfect = 3 * $dkh_max * ( 10 ** ( 7 - $ph_perfect ));
#the low range
		$dkh_min = $co2_min / ( 3 * ( 10 ** ( 7 - $ph_low ) ));
		$co2_min_min= 3 * $dkh_min * ( 10 ** (7 - $ph_high));
		$co2_min_perfect = 3 * $dkh_min* ( 10 ** (7 - $ph_perfect));
# and if we have two drop checkers, we're going to make a new chart for known values of pH
# so ugly....
		$co2_max_60 = sprintf("%.1f", 3 * $dkh_max * ( 10 ** ( 7 - 6.0 )));
		$co2_max_64 = sprintf("%.1f", 3 * $dkh_max * ( 10 ** ( 7 - 6.4 )));
		$co2_max_66 = sprintf("%.1f", 3 * $dkh_max * ( 10 ** ( 7 - 6.6 )));
		$co2_max_68 = sprintf("%.1f", 3 * $dkh_max * ( 10 ** ( 7 - 6.8 )));
		$co2_max_70 = sprintf("%.1f", 3 * $dkh_max * ( 10 ** ( 7 - 7.0 )));

		$co2_min_60 = sprintf("%.1f", 3 * $dkh_min * ( 10 ** ( 7 - 6.0 )));
		$co2_min_64 = sprintf("%.1f", 3 * $dkh_min * ( 10 ** ( 7 - 6.4 )));
		$co2_min_66 = sprintf("%.1f", 3 * $dkh_min * ( 10 ** ( 7 - 6.6 )));
		$co2_min_68 = sprintf("%.1f", 3 * $dkh_min * ( 10 ** ( 7 - 6.8 )));
		$co2_min_70 = sprintf("%.1f", 3 * $dkh_min * ( 10 ** ( 7 - 7.0 )));
	}
	else
	{
		$co2_min_min= 3 * $dkh * ( 10 ** ( 7 - $ph_high ));
		$co2_min= 3 * $dkh * ( 10 ** ( 7 - $ph_low ));
		$dkh_min=$dkh;
		$co2_min_perfect=$co2;
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

# now convert it into grams for the majority of scales
	$grams_max = $mgrams_max * 1000;
	$grams_min = $mgrams_min * 1000;

	      	print "1) Add $grams_min grams of baking soda to $mix $unit of RO/DI water for $dkh_min dKH. Fully dilute.<br />\n
	        2) Add the contents of this mixture to the drop checker, then add a couple drops of Bromothymol blue to the drop checker.<br />\n";
	if ($color = 'green')
	{
		print "The range for \"$color\" in this drop checker is $co2_min_min - $co2_min ppm CO2.";
	}
	print "The perfect $color (shade, reaction between Br. Blue and CO3) is $co2_min_perfect ppm CO2.<br />\n
<br />\n";
	if ($checkers=~/two/)
	{
		print "3) Add $grams_max grams of baking soda to $mix $unit of RO/DI water for $dkh_max dKH. Fully dilute.<br />\n
	                    4) Add the contents of this mixture to the second drop checker, then add a couple drops of Bromothymol blue to that drop checker.<br />\n";
		if ($color = 'green')
		{
	print "The range for \"$color\" in the second drop checker is $co2_max - $co2_max_max ppm CO2.";
		}  
		print "The perfect $color (shade, reaction between Br. Blue and CO3) is $co2_max_perfect ppm CO2.<br />\n";
		
		print "<br />\n	If both drop checkers are $color, you have $co2_max - $co2_min ppm CO2.<br />\n<br />\n";
	
		print "Here's a chart:<br />\n<br />\n";

		print "
<table>
<tbody align='center'>
<th>CO2 at<br />$dkh_min dKH</th>
<th>expected drop<br />checker color</th>
<th>CO2 at<br />$dkh_max dKH</th>
<tr height='90'>
	<td>$co2_min_60</td>
	<td rowspan=5><img src='public/pHrange_scale.png'></td>
	<td>$co2_max_60</td>
</tr>
<tr height='90'>
	<td>$co2_min_64</td>
	<td>$co2_max_64</td>
</tr>
<tr height='90'>
	<td>$co2_min_66</td>
	<td>$co2_max_66</td>
</tr>
<tr height='90'>
	<td>$co2_min_68</td>
	<td>$co2_max_68</td>
</tr>
<tr height='90'>
	<td>$co2_min_70</td>
	<td>$co2_max_70</td>
</tr>
</tbody>
</table>
<br />
<br />";
	}
	   	
	   }

	} else {

	   print "<p><STRONG>Enter only numbers!</STRONG></p>\n";

	}

}

$q->param('hiddenValue',$val);
&printForm($q,$val);

print "</div>";

print "<h4><a href='#'>Credits</a></h4>
<div>
This project is heavily influenced by fellow aquarists and particularly Hoppy, who you'll find posting on <a href='http://plantedtank.net'>plantedtank.net</a> and <a href='http://barrreport.com'>barrreport.com</a><br /><br />
Drop checker example images, in order, were taken by wet, patw, and Hoppy, who are active on the above forums as well as <a href='http://aquaticplantcentral.com'>APC</a><br /><br />
The pH chart is courtesy of <a href='http://aquariumpharm.com'>Aquarium Pharmaceuticals</a> and is available at most any local pet store.<br /><br />
This calculator and page was built and is supported by <a href='mailto:dropcheck@petalphile.com'>wet</a> and is released under The Whiskey License.  (You can do whatever you want with it, but there is no warranty.  If you like it and want to say 'thanks', be aware I like tasty whiskey.  If you find bugs, please let me know!)<br /><br />
You can find the source code on <a href='https://github.com/flores/dropcalc'>GitHub</a>.
</div>";

print "</div>";
print "<p>back to <a href='http://petalphile.com' target='_blank'>petalphile.com</a>";

print $q->end_html();



sub printForm {

	my($q,$val)=@_;


	print $q->start_multipart_form();
        
	print "<table>";
	print "<tr>";
	print "<td align='right'>";
	print "My target CO2 is";
	print "</td>";
	print "<td>";
	print $q->textfield(-name=>'co2',-size=>1,-maxlength=>5);
	print "ppm";
	print "</td></tr>";
	print "<tr><td align='right'>";
	print "margin of error +/-";
	print "</td><td>";
        print $q->popup_menu( -name=>'range', -values=>['2.5','5','10','15','20','25','30'], -default=>'5' );
	print " ppm CO2";
	print "</td></tr>";
	print "<tr><td colspan=2> </td></tr>";
	print "<tr><td align='right'>";
	print "I'm mixing the solution in";
	print "</td><td>";
	print $q->textfield(-name=>'mix',-size=>1,-maxlength=>5);
	print $q->radio_group( -name=>'unit', values=>['L', 'gal'], -default=>'Liter');
	print "of water";
	print "</td></tr>";

	print "<tr><td colspan=2> </td></tr>";
	print "<tr><td align='right'>";
	print "it's easiest to see";
	print "</td><td>";
	print $q->radio_group( -name=>'color', values=>['green', 'yellow'], -default=>'green');
	print "</td></tr>";
	print "<tr><td colspan=2> </td></tr>";
	print "<tr><td align='right'>";
	print "and I'm using";
	print "</td><td>";
	print $q->radio_group( -name=>'checkers', values=>['one', 'two'], -default=>'two');
	print "dropcheckers";
	print "</td></tr>";

	print "<tr><td colspan=2, align='center'>";
	print $q->submit(-name=>'Action',-value=>'Gimmie!');
	print "</tr></td>";
	print "</table>";

}


