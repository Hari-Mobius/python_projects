
#######################################################################################################

# Developer Name	: Devid Mazeeta G F
# Development Date	: 11-Oct-2016
# Project Name		: Description Viewer
# Updated By            : Ponmozhi selvan

############################################### Used Modules ##########################################

use strict;
use warnings;

######################################## Counting no. of XML files ####################################

print "\n\nEnter Output File Name (without extension) :: ";
chop(my $file_name = <stdin>);

open (FH ,"<".$file_name.".txt");
my @output_content=<FH>;
my $output_content=join('',@output_content);
close FH;

my (@products,@product_category,@product_url,@product_title,@product_overview_name);

while($output_content=~m/([\d]+)\t([^\t]*?)\t([^\t]*?)\t([^\t]*?)\t([^\t]*?)\t[^\n]*?\n/igs)
{
	push(@products,$1);
	push(@product_category,$2);
	push(@product_url,$3);
	push(@product_title,$4);
	push(@product_overview_name,$5);
}

my $count = scalar(@products);
print "\n\nTotal no. of XML files :: $count\n";

########################################### Preparing HTML file #######################################

open (FH ,">view.html");
print FH "<br /><hr>";
close FH;

open (FH ,">desc_missing_log.txt");
print FH "Overview_Name\n";
close FH;

for(my $num=0; $num<$count; $num++)
{	
	my $category = $product_category[$num];
	$category=~s/<tag>/ &gt;&gt; /igs;
	
	my $heading_desc = "<h3>Product ID ::	$products[$num]<br />Product Category :: $category<br />Product Url :: <a href='$product_url[$num]' target='_blank' >$product_url[$num]</a><br />Product Title :: $product_title[$num]<br />Overview Name :: $product_overview_name[$num]</h3><hr>";
	
	open (FH ,"<Content/".$product_overview_name[$num]) or die "\n$product_overview_name[$num] missing in \( Content \) folder missing ====> $!\n";
	my $xml_content=join('',<FH>);
	close FH;
	
	my $shortdesc;
	if($xml_content=~m/<short-description>\s*([\w\W]*?)\s*<\/short-description>/is)
	{
		my $temp_1 = $1;
		my $flag = "1";
		
		if($temp_1=~m/<\!\[CDATA\[\s*([\w\W]*?)\s*\]\]>/is)
		{
			my $data = $1;
			my $temp_data = $data;
			$temp_data=~s/\s*<[^>]*?>\s*//igs;
			
			$shortdesc=$temp_data;

			if($temp_data=~m/[^>]+/is)
			{
				$flag="1";
			}
			else
			{
				$flag="0";
			}
			
		}
		else
		{
			$flag="0";
		}
		
		if($flag eq "0")
		{
			open (FH ,">>desc_missing_log.txt");
			print FH "$product_overview_name[$num]\n";
			close FH;
		}
	}
	
	
	if($xml_content=~m/<description>\s*([\w\W]*?)\s*<\/description>/is)
	{
		my $temp_1 = $1;
		my $flag = "1";
		
		if($temp_1=~m/<\!\[CDATA\[\s*([\w\W]*?)\s*\]\]>/is)
		{
			my $data = $1;
			my $temp_data = $data;
			$temp_data=~s/\s*<[^>]*?>\s*//igs;
			
			open (FH ,">>view.html");
			print FH $heading_desc."<strong>Short Description:</strong><br /><br />".$shortdesc."<br /><br /><strong>Long Description:</strong><br /><br />".$data."<\/p>"."\n\n<br /><br /><hr>\n\n";
			close FH;

			if($temp_data=~m/[^>]+/is)
			{
				$flag="1";
			}
			else
			{
				$flag="0";
			}
			
		}
		else
		{
			$flag="0";
		}
		
		if($flag eq "0")
		{
			open (FH ,">>desc_missing_log.txt");
			print FH "$product_overview_name[$num]\n";
			close FH;
		}
	}
	my $attributeTable;
	while($xml_content=~m/<metadata-group\s*type="ATTRIBUTE"\s*title="([^"]*?)">([\w\W]+?)<\/metadata-group>/igs)
	{
		my $tableName=$1;
		my $tableBlock=$2;
		my @table;
		$attributeTable.="\n<h2>$tableName</h2>\n";
		$attributeTable.="<table border='1'>";
		my $header="<tr>\n";
		my $flag=0;
		while($tableBlock=~m/<metadata-item-list\s*type="TABLE"\s*title="([^"]*?)">([\w\W]+?)<\/metadata-item-list>/igs)
		{
			my $columnHeader=$1;
			my $columnBlock=$2;
			my $row=0;
			$flag=1 if($columnHeader ne "");
			$header.="<th>$columnHeader<\/th>\n";
			while($columnBlock=~m/(?:<metadata[^\/]*?>(?:<\!\[CDATA\[)?([\w\W]+?)(?:\]\]>)?<\/metadata>|<metadata[^>]*?src="([^>]*?)"[^>]*?\/>)/igs)
			{
				my $data=$1;
				my $src=$2;
				if($src ne '')
				{
					push(@{$table[$row]},"src=>".$src);
				}
				else
				{
					push(@{$table[$row]},$data);
				}
				$row++;
			}
		}
		$header.="<\/tr>\n";
		if($flag)
		{
			$attributeTable.=$header;
		}
		# print "Row Length  ::  ".scalar(@table)."\n";
		for(my $row=0;$row<scalar(@table);$row++)
		{
			$attributeTable.="<tr>\n";
			for(my $col=0;$col<scalar(@{$table[$row]});$col++)
			{
				if($table[$row][$col]=~m/src=>([^>]+?)$/is)
				{
					$attributeTable.="<td><img src=\"$1\" /><\/td>\n";
				}
				else
				{
					$attributeTable.="<td>$table[$row][$col]<\/td>\n";
				}
			}
			$attributeTable.="<\/tr>\n";
		}
		$attributeTable.="<\/table>\n";
		
		open (FH ,">>view.html");
		print FH $attributeTable;
		close FH;
	}
	

}

################################################## Completed ##########################################

print "\nProcess Completed :: HTML file generated (view.html)\n\n";

#######################################################################################################

