/****************************************/
/* Date created: 4 Sep 2020            */
/* Last Update: 4 Sep 2024             */

/****************************************/
/* Created by:			                */
/* Emanuel Krebs
	Updated by: Mina Moeini				*/
/****************************************/
/* For:									*/
/* HSCI 416 - Lab 1				        */
/****************************************/
/* Section 1:			                */
/* Read / import data			        */
/****************************************/

/* Read raw data */
/* reads data created after datalines */
/* variables (columns) divided by spaces and observations (rows) by lines */
/****************************************/
/* 1. Using Datalines */
data grades1;    /* save data into the temporary dataset grades */
input ID Sex $ Age Grade;  /* create four variables for the dataset */
/* Note: $ indicates that sex is a character variable */
datalines;
1 F 19 20
2 M 20 25
3 F 19 27
4 F 20 28
5 M 18 19
;                    

/* Read data from Excel */
/* out = the name you would like to save the dataset as */
/* datafile = the path of the file */
/****************************************/
/*2. Using Proc Import with CSV File:*/
proc import out = grades2 datafile = "/home/u64002069/Lab1/grades.csv" dbms = csv replace;   
	sheet = "Sheet1";      /* only read sheet1 */
	getnames = yes;        /* including the variable names in the excel file */
run;


/* Read data from .csv file */
/* Option 1: variables don't have names defined */
data grades3;
infile "/home/u64002069/Lab1/grades.csv" dlm = ',';     
/* dlm=',' indicates that the variables are seperated by a comma */
input ID Sex $ Age Grade;      /* type in the variable names by yourself */
run;

/* Option 2: variables have names defined */
proc import out = grades4 datafile = "/home/u64002069/Lab1/grades_na.csv" dbms=csv replace;
/* same as reading excel file */
/* dbms=(file type) and replace (overwrite an existing file) are optional */
/* The replace; option in SAS is used to overwrite an existing dataset with the same name */
/* The getnames=yes; option tells SAS to use the first row of the external file as variable names */
getnames = yes; 
run;


/* Describing data */
/* PROC PRINT */
/* describe data: print */
Proc print data = grades2; * this is another way to comment your code;  
run;

/* Best practices: always specific number of observations */
/* This is particularly important when working with large datasets */
Proc print data = grades2 (obs = 2);   
run;


/* PROC CONTENTS */
/*proc contents, it outputs various details about the specified dataset*/
proc contents data = grades2;
run;

/* You can also give the output a title */
proc contents data = grades2;
	title "Content of the grades data set";
run;


/****************************************/
/* Section 2:			                */
/* Libraries / Saving datasets			*/
/****************************************/
/* Libraries */
/* libname allows you to create an indicator for a folder */
libname saslab1 "/home/u64002069/Lab1";

/* Saving permanent datasets */
/* save the temporary dataset 'grades4' permanently in your folder */
data saslab1.grades; set grades4; 
run;

/* Saving temporary datasets */
data grades5; set saslab1.grades;
run;


/* Verify file was saved correctly */
/* note use of library to define data to be used */
/* describe data: print */
proc print data = saslab1.grades (obs = 3);   
run;
/* describe data: proc contents */
proc contents data = saslab1.grades;
	title "My first permanent dataset";
run;


/****************************************/
/* Section 3:			                */
/* Subset data					        */
/****************************************/

/* Subsetting */

/* First few observations */
data grades_sub1; set grades3 (obs=3);    
/* the obs=3 in the round bracket indicates to extract the first 3 observations */
run;

proc print data=grades_sub1;
run;


/* By random sampling*/
proc surveyselect data=grades3 method=srs n=3 out=grades_sub2;
/* Randomply sampling a subset of the dataset, data = (source dataset), */
/* 'srs' indicates simple random sampling, n = (number of observations you want to sample), */
/* out = (the name you want to save it as) */
run;

proc print data=grades_sub2;
run;


/* By variable values */
data grades_sub3; set grades3;
where Grade>20;    /*extract data where grade>20*/
run;

proc print data=grades_sub3;
run;


data grades_sub4; set grades3;
where Grade>20 and Sex = 'F';   /* extract data where grade>20 and sex equals female */
run;

proc print data=grades_sub4;
run;


/* Including or exluding a subset of variables */
/*by drop*/
data grade_sub5; set grades3;
Drop Sex Age;
run;

proc print data=grade_sub5;
run;


/*by Keep*/
data grade_sub6; set grades3;
Keep ID Grade;
run;

proc print data=grade_sub6;
run;
