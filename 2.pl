$,= " ";
$\="\n";
$/=" ";
$sum_file=0;
@array;
for $i (@ARGV){
	(open(FILE, '<', "$i") and $b=1) or ( print "Warning: can't open file $i" and $b=0);
	if($b){
		$sum_file+= -s("$i");
		if($sum_file>300000000){print "Error: too large size of files";exit;}
		if(-s("$i")>20000000){print "Warning: file $i is too big, processing file may take some minutes";}
		while(!eof(FILE)){
			$z=<FILE>;
			if($z=~/[0-9]+/){push @array, $z;}
			else{print "Warning: some not number found in $i";last;}
			
		}
		while(!eof(FILE)){
			$z=<FILE>;
			if($z=~/[0-9]+/){push @array, $z;}
		}
	}
}
@array= sort {$a <=> $b} @array;
open (qwe , '>', "out.txt") or die "can't create file $i";
print qwe @array;  