/****************************************/
/* Date created: 12 Oct 2020            */
/* Last Update: 12 Oct 2020             */
/* Modded: 1 February 2022				*/
/* Last Mod: 3 Oct 2024            */
/****************************************/
/* Created by:			                */
/* Emanuel Krebs			            */
/* Modded by:							*/
/* Mina Moeini						*/
/****************************************/
/* For:									*/
/* HSCI 416 - Lab 4				        */
/* Summary statistics & plots - 2		*/
/****************************************/

/* Set library */
*libname lab4 "H:\HSCI416\Lab 4\";
*libname lab4 "/home/u59485253/Lab4";

libname lab4 "/home/u64002069/Lab4";

/* Get data */
data samhsa_obs; set lab4.samhsa_obs;
run;

/*****************************************/
/* LINGERING VARIABLE CREATION QUESTIONS */
/*****************************************/

* in IF THEN ELSE statements, variables created can have a numerical or character value

In Creating a variable with a character value: 

  1. make sure the 1st value (ex. age <10) has the maximium length of digits you'll give the values
     for that variable
     ex. if age <10 then agecategory = "Under 10" (insert semicolon here)
		 	else if age >=11 and age <=20 then agecategory = "10-20" (insert semicolon here)

  2. If you created character values for a variable, make sure that proc means proc freq,
 	and proc univariate run
 	
  3. To keep your categories in order, especially when naming them in character values,
  	make sure the order is kept while naming the variables (the longest variable name
  	needs to come first). Say if your categories are <10, 10-20, >20, your categories
  	should be named to keep the order (under 10, 10-20, over 20). Count the phsycial
  	spaces each character takes up.
 	
 OR Create a variable with numerical value 
 	(see image in lab 4 folder)
 	
  3. You can assign the new variable a numerical value
  		ex. if age <10 then agecategory = 1(insert semicolon here)
		 	else if age >=11 and age <=20 then agecategory = 2(insert semicolon here)
		 	
	 Save somewhere easy to find, your own codebook of what the numerical values mean to 
	 later change the names when producing the nice, formatted table on excel 
	 (if agecategory is 1, then it means age is <10);
 	

/******************************************************************/
/* EXAMPLES OF STATEMENTS, OPTIONS & MEANINGS FOR CREATING TABLES */
/******************************************************************/

proc freq data = samhsa_obs;
/* Type after 'table' the variable you would like to get frequency for */
table age;  
run;

***********************************
  CROSS-TABULATIONS and PROC FREQ 
***********************************;

/*One way frequency tables*/
proc freq data = samhsa_obs;
table gender;
run;


/* Cross-tabulation for two variables	*/
/* You can create a table summarizing two variables */

proc freq data = samhsa_obs;
  table EDUC*age / nocol norow nocum nofreq nopercent; 
  
/************************************************************************/
/* the forward slash '/' tells SAS that you'll be coding some options: 	*/
/* nocol - no column percent displayed									*/
/* norow - no row percent displayed 									*/
/* nocum - no cumulative frequency and percent displayed				*/
/* nofreq - no frequency displayed										*/
/* nopercent - no percent displayed										*/
/* if you write down all the options, nothing will appear on the table	*/
/************************************************************************/

title 'educ by age';
title2 'e by a';
/* title statement gives the "Main title", can be written during a step	*/
/* you can add more subtitles by stating title2, title3, title4, etc.	*/
run;



/* to remove titles*/
title;



/* another way to display results*/
proc freq data = samhsa_obs;
  table EDUC*age / list;
run;



/* You can create multiple cross-tabulations sumarizing variables by a specific one*/
proc freq data = samhsa_obs;
  table (Gender Age Employ)*EDUC;
  run;


/* You can create separate tables summarizing a variable stratified by another variable */
/* Sort first! */
proc sort data = samhsa_obs out = samhsa_sort;
by EDUC;
run;


proc freq data = samhsa_sort;
by EDUC;
table gender age employ;           
run;


proc freq data=samhsa_sort order=freq noprint;  /* ORDER= sorts by counts within X */
by Educ;                               /* X var */
tables AGE / out=samhsaSorted;         /* Y var */
run;
 
proc print data=samhsaSorted (obs=30);
run;



proc sort data = samhsa_obs out = samhsa_sort;
by educ;
run;

proc freq data=samhsa_sort order=formatted;  
						 /* order = formatted means that data is sorted in ascending order*/
						 /*order=data means that the sorted order of the variable will be used*/
						 /*order=freq; is another way to present the data based on the frequency of the variable. 
						 Which way makes more sense?*/
tables age*educ /plots=freqplot(twoway=stacked scale=grouppercent); /*the second variable is the by variable (x axis)*/
run;


*********************
    PROC MEANS
*********************;

proc means data = samhsa_obs;
var LOS; /* var: the variable(s) you want to do the statistics for, only numeric (continuous) variables */
run;


/* Separate analysis by selected variables and save the output */
proc means data = samhsa_obs N Mean Std; /*N Mean Std: tells SAS the statistics you want to see in the ouput*/
var LOS;     
class Gender;  /*CLASSify: Stratified analysis by gender */
output out = means_LOS;       /* Save the output */
run;


*************************************
    PROC UNIVARIATE - HISTOGRAMS
*************************************;


/* You can also draw a histogram with this command */
proc univariate data=samhsa_obs; histogram ;
var LOS;
/* there can also be an "out=dataset" statement in proc univariate to save the output*/
run;
	
	
data samhsa_obs2; set samhsa_obs;
	IF Gender = 1 Then GenC = 'M';
	Else if Gender = 2 then GenC= 'F';
run;

proc print data=samhsa_obs2 (obs=30);
run;
	
proc univariate data=samhsa_obs2; histogram;
	class genc; /* works for categorical values too, gender 'F' or 'M'*/
	var LOS; /* computes descriptive statistics. If no var statement is added, 
				it would compute for every numerical variable.  */
	title 'Histogram with categorical gender';
	label LOS= 'length of stay'; /* label statement is for each variable*/
	label genc = 'gender'; /* how would it look like without this label?*/
run; 

*********************************************************;
/*Histogram (Distribution of Age)*/
proc sgplot data=lab4.samhsa_obs;
   histogram AGE;
   xaxis label="Age";
   yaxis label="Frequency";
   title "Distribution of Age";
run;
/*Box Plot (Age by Gender)*/
/*This will display the distribution of AGE across different GENDER categories.*/
proc sgplot data=lab4.samhsa_obs;
   vbox AGE / category=GENDER;
   xaxis label="Gender";
   yaxis label="Age";
   title "Box Plot of Age by Gender";
run;
/*Bar Chart (Employment Status)*/
/*This will display the distribution of the EMPLOY variable.*/
proc sgplot data=lab4.samhsa_obs;
   vbar EMPLOY;
   xaxis label="Employment Status";
   yaxis label="Frequency";
   title "Distribution of Employment Status";
run;
/*Scatter Plot (Age vs Education)*/
/*This will show the relationship between AGE and EDUC (education level).*/
proc sgplot data=lab4.samhsa_obs;
   scatter x=AGE y=EDUC;
   xaxis label="Age";
   yaxis label="Education Level";
   title "Scatter Plot of Age vs Education";
run;
/*Grouped Bar Chart (Employment Status by Gender)*/
/*This will display the employment status distribution (EMPLOY) grouped by GENDER.*/
proc sgplot data=lab4.samhsa_obs;
   vbar EMPLOY / group=GENDER;
   xaxis label="Employment Status";
   yaxis label="Frequency";
   title "Employment Status by Gender";
run;
/*Scatter Plot with Regression Line (Age vs Education)*/
/*This plot shows the relationship between AGE and EDUC, along with a fitted regression line.*/
proc sgplot data=lab4.samhsa_obs;
   scatter x=AGE y=EDUC;
   reg x=AGE y=EDUC;
   xaxis label="Age";
   yaxis label="Education Level";
   title "Scatter Plot of Age vs Education with Regression Line";
run;
/*Grouped Box Plot with Mean Overlay (Age by Gender and Employment Status)*/
/*This box plot compares AGE across different GENDER categories, grouped by EMPLOY, and overlays the mean for each group.*/
proc sgplot data=lab4.samhsa_obs;
   vbox AGE / category=GENDER group=EMPLOY;
   scatter x=GENDER y=AGE / group=EMPLOY ;
   xaxis label="Gender";
   yaxis label="Age";
   title "Box Plot of Age by Gender and Employment Status with Mean Overlay";
run;
/*Density Plot (Age Distribution with Kernel Density Estimate)*/
/*This density plot shows the distribution of AGE with a kernel density estimation.*/
proc sgplot data=lab4.samhsa_obs;
   histogram AGE / fillattrs=(color=lightblue);
   density AGE / type=kernel lineattrs=(color=red);
   xaxis label="Age";
   yaxis label="Density";
   title "Age Distribution with Kernel Density Estimate";
run;
