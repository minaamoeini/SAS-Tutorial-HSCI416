/****************************************/
/* Date created: 27 Sep 2020            */
/* Last Update: 13 Sep 2024             */
/****************************************/
/* Created by:			                */
/* Mina Moeini			            */
/****************************************/
/* For:									*/
/* HSCI 416 - Lab 2				        */
/* Manipulating data					*/
/* Objective: define weekly income		*/
/* as a function of education			*/
/* and number of hours worked			*/
/****************************************/
/* Set library */
/* Recall: libname allows you to create an indicator for a folder */
libname lab2 "/home/u64002069/lab2";

/****************************************/
/* Section 1:			                */
/* Subsetting data				        */
/****************************************/
/* Recall: Reading datasets */
data full; set lab2.samhsa_obs;
run; * How many observations? Hint: Check the log;

/* Subsetting using variable values */
/* where statement */
data samhsa_sub1; set lab2.samhsa_obs;
/* See slides for info on the dataset */
Where EDUC = 5; /* Subset those with educ = 5, i.e., 16 or more */
run; * How many observations?;

/* If statement */
data samhsa_sub2; set lab2.samhsa_obs;    
If EDUC = 5; /* Subset those with educ = 5, i.e., 16 or more */
run; * How many observations?;

/* same as with where statement? */


/****************************************/
/* Section 2:			                */
/* Cleaning data						*/
/****************************************/
/* Missing data */
/* Data entry is not always perfect for all variables */
/* We are interested in education level and employment status */
/* Missing data will not help, so we need to clean our data */
/* If / then statement */
data samhsa_clean; set lab2.samhsa_obs;  
/* missing data is coded as -9 */  
If EDUC = -9 OR EMPLOY = -9 THEN DELETE; /* delete missing data for EDUC, EMPLOY */        
run; * How many observations compared to temporary dataset full?;


/****************************************/
/* Section 3:			                */
/* Creating new variables				*/
/****************************************/
/* 3.1 Transforming categorical variable(s) into a new categorical variable */
/* Education level */
data samhsa_edu; set samhsa_clean;
IF EDUC = 4 OR EDUC = 5 THEN EDU = 'High';
	ELSE IF EDUC = 3 THEN EDU = 'Mid';
	ELSE IF EDUC = 2 OR EDUC = 1 THEN EDU = 'Low';
run;

/* Let's check the dataset for our new variable */
proc print data = samhsa_edu (obs = 30);
run;


/****************************************/
/* 3.2 Transforming categorical variable(s) into a new numeric variable */
/* Using employment status to define weekly hours worked */
/* Recall: See slides for info on the dataset */
data samhsa_wh; set samhsa_edu;
IF EMPLOY = 1 THEN W_H = 40;
	ELSE IF EMPLOY = 2 THEN W_H = 25;
	ELSE W_H = 0;
run;

/* Let's check the dataset for our new variable */
proc print data = samhsa_wh (obs = 30);
run;

/****************************************/
/* 3.3 Transforming numeric variable(s) into numeric variable */
/* Using employment status and education level to define hourly wage */
/* Calculating weekly income as the product of weekly hours X hourly wage */
data samhsa_wage; set samhsa_wh;
IF EMPLOY = 1 THEN DO;
		if EDU = 'High' THEN H_SA = 40;	  /* create hourly wage variable according to employment and education*/
		else if EDU = 'Mid' THEN H_SA = 30;
		else if EDU = 'Low' THEN H_SA = 20;
		WI = H_SA * W_H;            /* weekly income(WI) = hourly salary(H_SA) * working hours(W_H) */
		END;
ELSE IF EMPLOY = 2 THEN DO;
		if EDU = 'High' THEN H_SA = 35;
		else if EDU = 'Mid' THEN H_SA = 25;
		else if EDU = 'Low' THEN H_SA = 15;
		WI = H_SA * W_H;
		END;
ELSE DO; H_SA = 0; WI = 0; END;
run;

/* Let's check the dataset for our new variable */
proc print data=samhsa_wage (obs = 30);
run;

/****************************************/
/* 3.4 Transforming numeric variable(s) into categorical variable */
/* Classifying weekly income into levels */
data samhsa_inc; set samhsa_wage;
IF WI > 1000 THEN INC_L = 'H';
ELSE if WI >= 500 AND WI <= 1000 THEN INC_L = 'M';
ELSE if WI < 500 THEN INC_L = 'L';
run;

/* Let's check our new variables */
proc print data=samhsa_inc (obs = 15);
	VAR CASEID EDU W_H H_SA WI INC_L;
	title "Result from my data manipulation";
run;
/* Let's checl the data set with our new variables */
proc print data=samhsa_inc (obs = 30);
run;

/* Saving our dataset */
/* You could save it in the "Lab 3" folder */
data lab2.samhsa_inc; set samhsa_inc;
run;

/* Or in the "MySASdata" folder we created last week */
/* Note: This will only work if you created the folder in "MY SFU Files" */
libname mydata "H:\HSCI416\MySASdata\";
data mydata.samhsa_inc; set samhsa_inc;
run;
