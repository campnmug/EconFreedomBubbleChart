ods graphics on / height=8in;
libname boss 'D:\Index of Economic Freedom';

Data freedom;
set boss.both2;

length Freedom13 $ 19  Freedom17 $ 19;

Freedom13='';  Nfreedom13=.;
If 	y13_2013_score GE 80 	then do; 		 Freedom13='5. Free';				Nfreedom13=5; end;
if 70 le 	y13_2013_score lt 80 	then do; Freedom13='4. Mostly Free';		Nfreedom13=4; end;
if 60 le 	y13_2013_score lt 70 	then do; Freedom13='3. Moderately Free';	Nfreedom13=3; end;
if 50 le 	y13_2013_score lt 60 	then do; Freedom13='2. Mostly Unfree';		Nfreedom13=2; end;
if 0  le	y13_2013_score lt 50 	then do; Freedom13='1. Repressed';			Nfreedom13=1; end;

Freedom17= ''; Nfreedom17=.;
If 	y17_2017_score GE 80 	then do; 		 Freedom17='5. Free';				Nfreedom17=5; end;
if 70 le 	y17_2017_score lt 80 	then do; Freedom17='4. Mostly Free';		Nfreedom17=4; end;
if 60 le 	y17_2017_score lt 70 	then do; Freedom17='3. Moderately Free';	Nfreedom17=3; end;
if 50 le 	y17_2017_score lt 60 	then do; Freedom17='2. Mostly Unfree';		Nfreedom17=2; end;
if 0  le	y17_2017_score lt 50 	then do; Freedom17='1. Repressed';		    Nfreedom17=1; end;

/* note, if you have any missing, you may have a problem if Yxx_20xx_score is not missing. */

y17scoresq=y17_2017_score*y17_2017_score;

run;

proc reg data=freedom; 
	 model y17_GDP_per_Capita_PPP = y17_2017_score y17scoresq; 
	 output out=freedom student=res;
	 run;

data freedom;
	set freedom;
	length y17_labels $20;
	if res <= -1.2 or res>=1.2  then y17_labels=country;
								else Y17_labels=''; 
	if Y17_2017_score <45 		then y17_labels=country;
	if Y17_2017_score >80 		then y17_labels=country;
	if Y17_population>200 		then y17_labels=country;
	run;


proc sort data=freedom; by y17_2017_score; run;
Title1 		'Standards of Living is higher in countries where Economic Freedom is higher';
footnote1 	'Source: Data from the 2017 Index of Economic Freedom, https://www.heritage.org/index/';
Footnote2  	'Graph illustrates a combination of a block chart, a loess trend and a bubble chart';

PROC SGPLOT DATA=freedom noborder uniform=all;
	inset '2017' /position =topleft  textattrs=(size=80pt weight=bold color=grey );
		block 	x=Y17_2017_score block=freedom17 /  filltype=alternate;
	reg	  	x=Y17_2017_Score y=Y17_GDP_per_Capita_PPP / degree=2 NOMARKERS CLM NOLEGCLM curvelabel='quad reg';
	Loess 	x=Y17_2017_Score y=Y17_GDP_per_Capita_PPP / NOMARKERS CLM NOLEGCLM smooth=.8 
														transparency=.6 clmtransparency=.6 curvelabel='nonpar tr.';
	bubble 	y=Y17_GDP_per_Capita_PPP x= Y17_2017_Score size=Y17_population /
			group=region bradiusmin=2pt bradiusmax=15pt  
			datalabel=y17_labels DATALABELPOS=top dataskin=gloss 
			transparency=.3 ;
	xaxis 	values= (20 to 100 by 10)OFFSETMIN=0 OFFSETMAX=0 
			label='Score on the 2017 Index of Economic Freedom';
	yaxis 	min=0 max=100000 Valuesformat=comma14.
			label='GDP per capita in dollars ($,PPP)';
	where region ne '' ;
	run;
