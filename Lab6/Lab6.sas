/* Import the dataset */
proc import datafile='/home/u64002069/Lab6/healthcare_dataset.csv'
    out=health_data
    dbms=csv
    replace;
    getnames=yes;
run;

/* Check column names to confirm import */
proc contents data=health_data;
run;
/*************************************************************/
/* Calculate the mean and standard deviation by Medical Condition */
proc means data=health_data mean std;
    class 'Medical Condition'n;
    var 'Billing Amount'n;
run;

/* Count the number of observations per medical condition */
proc freq data=health_data noprint;
    tables 'Medical Condition'n / out=condition_counts(drop=percent);
run;

/* Bar chart of the number of observations */
proc sgplot data=condition_counts;
    vbar 'Medical Condition'n / response=Count datalabel;
    xaxis label='Medical Condition' fitpolicy=split;
    yaxis label='Number of Observations';
    title 'Number of Observations per Medical Condition';
run;

/* there is another way to show this figure*/

/* Sort the condition counts in descending order */
proc sort data=condition_counts;
    by descending Count;
run;

/* Horizontal bar chart for better readability */
proc sgplot data=condition_counts;
    hbar 'Medical Condition'n / response=Count 
                              datalabel 
                              fillattrs=(color=lightblue)
                              barwidth=0.7;
    xaxis label='Number of Observations';
    yaxis label='Medical Condition' fitpolicy=split;
    title 'Number of Observations per Medical Condition';
run;


/* Box plot of billing amount by medical condition */
proc sgplot data=health_data;
    vbox 'Billing Amount'n / category='Medical Condition'n;
    xaxis label='Medical Condition' fitpolicy=split;
    yaxis label='Billing Amount';
    title 'Box Plot of Billing Amount by Medical Condition';
run;
/************************************************************/
/* Create a contingency table of Medical Condition and Blood Type */
proc freq data=health_data;
    tables 'Medical Condition'n * 'Blood Type'n / norow nocol nopercent;
    title 'Contingency Table of Medical Condition and Blood Type';
run;

/* Grouped bar chart to visualize the relationship between Medical Condition and Blood Type */
proc sgplot data=health_data;
    vbar 'Medical Condition'n / group='Blood Type'n groupdisplay=cluster datalabel;
    xaxis label='Medical Condition' fitpolicy=split;
    yaxis label='Count';
    title 'Grouped Bar Chart of Medical Condition and Blood Type';
run;

/************************************************************/
/* Calculate the average billing amount for each hospital */
proc means data=health_data noprint;
    class Hospital;
    var 'Billing Amount'n;
    output out=avg_billing_hospital mean=Avg_Billing_Amount;
run;

/* Sort the results to get the top 10 most expensive hospitals */
proc sort data=avg_billing_hospital out=top10_hospitals;
    by descending Avg_Billing_Amount;
run;

data top10_hospitals;
    set top10_hospitals;
    if _n_ <= 10;  /* Keep only the top 10 entries */
run;

/* Print the top 10 most expensive hospitals */
proc print data=top10_hospitals;
    title 'Top 10 Most Expensive Hospitals by Average Billing Amount';
run;

/* Create a bar chart for the top 10 hospitals */
proc sgplot data=top10_hospitals;
    vbar Hospital / response=Avg_Billing_Amount stat=mean 
                    datalabel
                    categoryorder=respdesc;
    title 'Top 10 Hospitals by Average Billing Amount';
    yaxis label='Average Billing Amount';
    xaxis label='Hospital';
run;

/* Check unique values in 'Admission Type' */
proc freq data=health_data;
    tables 'Admission Type'n;
run;

/* Filter Urgent and Elective admissions, ensuring spaces are handled */
data urgent_elective;
    set health_data;
    if strip('Admission Type'n) in ('Urgent', 'Elective');
run;

/* Verify the filtered dataset */
proc print data=urgent_elective (obs=10);
    title 'Sample of Urgent and Elective Admissions';
run;

/* Calculate the average billing amount by admission type */
proc means data=urgent_elective noprint;
    class 'Admission Type'n;
    var 'Billing Amount'n;
    output out=avg_billing_admission mean=Avg_Billing_Amount;
run;

/* Print the results */
proc print data=avg_billing_admission;
    title 'Comparison of Average Billing: Urgent vs. Elective Admissions';
run;

/* Create a bar chart comparing urgent vs. elective admissions */
proc sgplot data=avg_billing_admission;
    vbar 'Admission Type'n / response=Avg_Billing_Amount stat=mean 
                              datalabel
                              categoryorder=respdesc;
    title 'Comparison of Average Billing Amount: Urgent vs. Elective Admissions';
    yaxis label='Average Billing Amount';
    xaxis label='Admission Type';
run;
/*************************************************************************/

/* Verify if the date columns are in valid SAS date format */
proc contents data=health_data;
    title 'Structure of the Healthcare Data';
run;
/* Handle missing or invalid dates and calculate Length of Stay */
data health_data;
    set health_data;
    
    /* Ensure dates are valid and calculate Length of Stay */
    if 'Date of Admission'n > 0 and 'Discharge Date'n > 0 then 
        Length_of_Stay = 'Discharge Date'n - 'Date of Admission'n;
    else 
        Length_of_Stay = .; /* Assign missing if dates are invalid */
run;

/* Check the Length of Stay calculation */
proc print data=health_data(obs=10);
    title 'Sample with Length of Stay Calculation';
run;

/* Filter for valid admissions */
data valid_admissions;
    set health_data;
    if strip('Admission Type'n) in ('Urgent', 'Elective', 'Emergency');
run;

/* Calculate the average length of stay by admission type */
proc means data=valid_admissions noprint;
    class 'Admission Type'n;
    var Length_of_Stay;
    output out=avg_length_of_stay mean=Avg_Length_of_Stay;
run;

/* Print the results */
proc print data=avg_length_of_stay;
    title 'Average Length of Stay by Admission Type';
run;

/* Create a bar chart for the average length of stay */
proc sgplot data=avg_length_of_stay;
    vbar 'Admission Type'n / response=Avg_Length_of_Stay stat=mean 
                              datalabel
                              categoryorder=respdesc;
    title 'Average Length of Stay by Admission Type';
    yaxis label='Average Length of Stay (Days)';
    xaxis label='Admission Type';
run;
/*************************************************/
/* Calculate the average billing amount for each insurance provider */
proc means data=health_data noprint;
    class 'Insurance Provider'n;
    var 'Billing Amount'n;
    output out=avg_billing_insurance mean=Avg_Billing_Amount;
run;

/* Sort the results in descending order to find the highest average */
proc sort data=avg_billing_insurance out=sorted_billing_insurance;
    by descending Avg_Billing_Amount;
run;

/* Print the insurance provider with the highest average billing amount */
proc print data=sorted_billing_insurance(obs=1);
    title 'Insurance Provider with the Highest Average Billing Amount';
run;

/* Create a bar chart for all insurance providers */
proc sgplot data=sorted_billing_insurance;
    vbar 'Insurance Provider'n / response=Avg_Billing_Amount 
                                stat=mean 
                                datalabel 
                                categoryorder=respdesc;
    title 'Average Billing Amount by Insurance Provider';
    yaxis label='Average Billing Amount';
    xaxis label='Insurance Provider';
run;
/*****************************************************/
/* Calculate the average billing amount by gender */
proc means data=health_data noprint;
    class Gender;
    var 'Billing Amount'n;
    output out=avg_billing_gender mean=Avg_Billing_Amount;
run;

/* Print the average billing amount by gender */
proc print data=avg_billing_gender;
    title 'Average Billing Amount by Gender';
run;

/* Create a bar chart to visualize average billing by gender */
proc sgplot data=avg_billing_gender;
    vbar Gender / response=Avg_Billing_Amount stat=mean 
                  datalabel
                  categoryorder=respdesc;
    title 'Average Billing Amount by Gender';
    yaxis label='Average Billing Amount';
    xaxis label='Gender';
run;

/* Perform a t-test to determine if there are significant differences between males and females */
proc ttest data=health_data;
    class Gender;
    var 'Billing Amount'n;
    title 'T-Test for Differences in Billing Amounts by Gender';
run;
/*********************************************************/
/* Create age groups: Young (0–40), Middle-aged (41–65), Senior (66+) */
data health_data;
    set health_data;
    length Age_Group $12; /* Define a character variable for age group */
    
    if Age <= 40 then Age_Group = 'Young';
    else if 41 <= Age <= 65 then Age_Group = 'Middle-aged';
    else if Age >= 66 then Age_Group = 'Senior';
run;

/* Calculate the total billing amount for each age group */
proc means data=health_data noprint;
    class Age_Group;
    var 'Billing Amount'n;
    output out=total_billing_age sum=Total_Billing_Amount;
run;

/* Print the total billing amount by age group */
proc print data=total_billing_age;
    title 'Total Billing Amount by Age Group';
run;

/* Create a bar chart to visualize the total billing by age group */
proc sgplot data=total_billing_age;
    vbar Age_Group / response=Total_Billing_Amount stat=sum 
                    datalabel
                    categoryorder=respdesc;
    title 'Total Billing Amount by Age Group';
    yaxis label='Total Billing Amount';
    xaxis label='Age Group';
run;