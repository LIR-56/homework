eval{																																											#пытаемся исполнить программу
$,= "\n\t ";
$\="\n";
$/=" ";
#$sum_file=0;
@array;
for $i (@ARGV){																																							#для каждого файла в списке 
	(open(FILE, '<', "$i") and $b=1) or ( print "Warning: can't open file $i" and $b=0);												 #открываем файл
	if($b){
		#$sum_file+= -s("$i");
		#if($sum_file>300000000){print "Error: too large size of files";exit;}
		if(-s("$i")>20000000){print "Warning: file $i is too big, processing file may take some minutes";}					#если большой файл надо предупредить, чтоб люди не нервничали:"а чего оно повисло"						
		while(!eof(FILE)){																																				#бежим по файлу и запихиваем в наш массив все числа(если нашли не число выводим предупреждение и прыгаем на следующий цикл(строка 19))			
			$z=<FILE>;
			if($z=~/^(\d+)(\s|$)/){push @array, $z;}
			else{print "Warning: some not number found in $i";last;}

		}
		while(!eof(FILE)){																																				#в этот цикл попадаем, если нашли в файле строку и выдали предупреждение; продолжаем искать числа в файле и класть их в массив, но в случае нахождения строки в файле уже не выдаем предупреждение(одного на файл вполне хватит)	
			$z=<FILE>;
			if($z=~/^(\d+)(\s|$)/){push @array, $z;}
		}
	}
}
@array= sort {$a <=> $b} @array;																															#сортируем массив
open (qwe , '>', "out.txt") or die "can't create file $i";																								#открываем файл
print qwe @array; 																																						#пишем отсортированный массив в выходной файл
 } or die "$!"