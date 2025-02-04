/* Importing a CSV file into a SAS dataset using PROC IMPORT */
proc import datafile='/home/u64002069/Diabetes/Healthcare-Diabetes.csv' 
    /* Specifying the name of the output dataset to be created */
    out=diabetes_data 
    /* Defining the type of file being imported, in this case, a CSV file */
    dbms=csv 
    /* Replacing the dataset if it already exists */
    replace;
    /* Indicating that the first row of the CSV contains variable names */
    getnames=yes;
run; /* End of the PROC IMPORT step */

/* Using PROC PRINT to display the dataset 'diabetes_data' */
proc print data=diabetes_data;
run;  /* End of PROC PRINT step */


/* Step 1: Assign a permanent library (replace 'mydata' with a meaningful name and 'path-to-directory' with your desired folder path) */
libname diabetes '/home/u64002069';

/* Step 2: Import the CSV file and save it in the permanent library */
proc import datafile='/home/u64002069/Diabetes/Healthcare-Diabetes.csv' 
    out=diabetes_data  /* Save dataset permanently in 'mydata' library */
    dbms=csv  /* File type: CSV */
    replace;  /* Replace dataset if it already exists */
    getnames=yes;  /* Use the first row of the CSV as variable names */
run;

/* Step 3: Print the dataset to confirm it has been imported */
proc print data=diabetes_data;
run;

/* Summary statistics for the dataset */
proc means data=diabetes_data n mean std min max;
    var Pregnancies Glucose BloodPressure SkinThickness Insulin BMI DiabetesPedigreeFunction Age;
run;

/* Frequency distribution for the Outcome variable */
proc freq data=diabetes_data;
    tables Outcome;
run;


/* Correlation analysis for continuous variables */
proc corr data=diabetes_data;
    var Pregnancies Glucose BloodPressure SkinThickness Insulin BMI DiabetesPedigreeFunction Age;
run;
/* Scatter plot to see the relationship between Glucose and BMI */
proc sgplot data=diabetes_data;
    scatter x=Glucose y=BMI / group=Outcome;
run;

/*************************************************/
/* BMI and Insulin Analysis for each outcome gropu */
/* Summary statistics for BMI and Insulin by Outcome */
proc means data=diabetes_data n mean std min max;
    class Outcome;
    var BMI Insulin;
run;
/* Box plot to visualize the distribution of BMI by Outcome */
proc sgplot data=diabetes_data;
    vbox BMI / category=Outcome;
    title "Box Plot of BMI by Outcome";
run;

/* Box plot to visualize the distribution of Insulin by Outcome */
proc sgplot data=diabetes.diabetes_data;
    vbox Insulin / category=Outcome;
    title "Box Plot of Insulin by Outcome";
run;
/******************************************************************/

/* Creating new categorical variables for Age, Glucose, and BMI */
data categorized_data;
    set diabetes_data;

    /* Categorize Age */
    if Age <= 20 then Age_Group = '≤ 20';
    else if 21 <= Age <= 30 then Age_Group = '21-30';
    else if 31 <= Age <= 40 then Age_Group = '31-40';
    else Age_Group = '> 40';

    /* Categorize Glucose levels */
    if Glucose <= 100 then Glucose_Category = 'Normal (≤ 100)';
    else if 101 <= Glucose <= 125 then Glucose_Category = 'Pre-diabetes (101-125)';
    else Glucose_Category = 'Diabetes (≥ 126)';

    /* Classify BMI */
    if BMI < 18.5 then BMI_Category = 'Underweight (< 18.5)';
    else if 18.5 <= BMI < 25 then BMI_Category = 'Normal (18.5-24.9)';
    else if 25 <= BMI < 30 then BMI_Category = 'Overweight (25-29.9)';
    else BMI_Category = 'Obese (≥ 30)';
run;

/* Displaying the new dataset with categorized variables */
proc print data=categorized_data (obs=10); /* Displaying the first 10 observations */
    var Age Age_Group Glucose Glucose_Category BMI BMI_Category;
run;

/* Step 1: Create summary statistics stratified by age categories */
proc means data=categorized_data n mean median std;
    class Age_Group;
    var Glucose Insulin BMI;
    output out=summary_table
        n=Freq_Glucose Freq_Insulin Freq_BMI
        mean=Mean_Glucose Mean_Insulin Mean_BMI
        median=Median_Glucose Median_Insulin Median_BMI
        std=StdDev_Glucose StdDev_Insulin StdDev_BMI;
run;

/* Step 2: Print the summary table */
proc print data=summary_table noobs;
    var Age_Group Freq_Glucose Mean_Glucose Median_Glucose StdDev_Glucose
                 Freq_Insulin Mean_Insulin Median_Insulin StdDev_Insulin
                 Freq_BMI Mean_BMI Median_BMI StdDev_BMI;
run;
/******************************************************************/
/*Visualization*/
/* Step 1: Histograms for Glucose, BMI, and Insulin distribution across different age groups */

proc sgpanel data=categorized_data;
    panelby Age_Group;
    histogram Glucose / scale=percent;
    rowaxis label='Percentage';
    colaxis label='Glucose Level';
    title 'Histogram of Glucose Levels by Age Group';
run;

proc sgpanel data=categorized_data;
    panelby Age_Group;
    histogram BMI / scale=percent;
    rowaxis label='Percentage';
    colaxis label='BMI';
    title 'Histogram of BMI by Age Group';
run;

proc sgpanel data=categorized_data;
    panelby Age_Group;
    histogram Insulin / scale=percent;
    rowaxis label='Percentage';
    colaxis label='Insulin';
    title 'Histogram of Insulin Levels by Age Group';
run;

/* Step 2: Boxplot to visualize the distribution of BMI by different age categories */
proc sgplot data=categorized_data;
    vbox BMI / category=Age_Group;
    xaxis label='Age Group';
    yaxis label='BMI';
    title 'Boxplot of BMI by Age Group';
run;

/* Step 3: Scatterplot to examine the relationship between Glucose and Age with a trend line */
proc sgplot data=categorized_data;
    scatter x=Age y=Glucose / group=Age_Group markerattrs=(symbol=CircleFilled);
    reg x=Age y=Glucose / lineattrs=(color=red);
    xaxis label='Age';
    yaxis label='Glucose Level';
    title 'Scatterplot of Glucose vs. Age with Trend Line';
run;
/******************************************************/

/* Step 1: Produce a summary table for stratified data by BMI categories */
proc means data=categorized_data n mean median std;
    class BMI_Category;
    var Pregnancies Age Glucose BloodPressure;
    output out=summary_bmi_table
        n=Freq_Pregnancies Freq_Age Freq_Glucose Freq_BloodPressure
        mean=Mean_Pregnancies Mean_Age Mean_Glucose Mean_BloodPressure
        median=Median_Pregnancies Median_Age Median_Glucose Median_BloodPressure
        std=StdDev_Pregnancies StdDev_Age StdDev_Glucose StdDev_BloodPressure;
run;

/* Step 2: Visualize data */

/* 2.1: Histograms to compare the distribution of blood pressure across different BMI categories */
proc sgpanel data=categorized_data;
    panelby BMI_Category;
    histogram BloodPressure / scale=percent;
    rowaxis label='Percentage';
    colaxis label='Blood Pressure';
    title 'Histogram of Blood Pressure by BMI Category';
run;

/* 2.2: Scatterplot to investigate the relationship between Insulin and Glucose levels */
proc sgplot data=categorized_data;
    scatter x=Glucose y=Insulin / group=BMI_Category markerattrs=(symbol=CircleFilled);
    reg x=Glucose y=Insulin / lineattrs=(color=red);
    xaxis label='Glucose Level';
    yaxis label='Insulin Level';
    title 'Scatterplot of Insulin vs. Glucose Levels with Trend Line';
run;

/* 2.3: Boxplot to compare Glucose levels between different Outcome groups */
proc sgplot data=categorized_data;
    vbox Glucose / category=Outcome;
    xaxis label='Diabetes Outcome';
    yaxis label='Glucose Level';
    title 'Boxplot of Glucose Levels by Diabetes Outcome';
run;

/* Step 3: Correlation analysis among Age, Glucose, BMI, and Insulin */
proc corr data=categorized_data;
    var Age Glucose BMI Insulin;
run;
/********************************************************/
/* Step 1: Create categories for Pregnancies */
data categorized_data;
    set categorized_data;
    if Pregnancies = 0 then Pregnancy_Category = '0';
    else if 1 <= Pregnancies <= 2 then Pregnancy_Category = '1-2';
    else if 3 <= Pregnancies <= 4 then Pregnancy_Category = '3-4';
    else if Pregnancies >= 5 then Pregnancy_Category = '≥ 5';
run;

/* Step 2: Histogram to analyze Glucose distribution within Pregnancy categories */
proc sgpanel data=categorized_data;
    panelby Pregnancy_Category;
    histogram Glucose / scale=percent;
    rowaxis label='Percentage';
    colaxis label='Glucose Level';
    title 'Histogram of Glucose Levels by Pregnancy Category';
run;

/* Step 3: Summary table for mean and standard deviation of Age, BMI, and Glucose */
proc means data=categorized_data mean std;
    class Pregnancy_Category;
    var Age BMI Glucose;
    output out=summary_pregnancy_table
        mean=Mean_Age Mean_BMI Mean_Glucose
        std=StdDev_Age StdDev_BMI StdDev_Glucose;
run;

/* Step 4: Print the summary table */
proc print data=summary_pregnancy_table noobs;
    var Pregnancy_Category Mean_Age StdDev_Age Mean_BMI StdDev_BMI Mean_Glucose StdDev_Glucose;
    title 'Summary of Mean and Standard Deviation for Age, BMI, and Glucose by Pregnancy Category';
run;

/* Step 5: Scatterplot showing the relationship between Age and BMI across different Pregnancy categories */
proc sgplot data=categorized_data;
    scatter x=Age y=BMI / group=Pregnancy_Category markerattrs=(symbol=CircleFilled);
    xaxis label='Age';
    yaxis label='BMI';
    title 'Scatterplot of Age vs. BMI by Pregnancy Category';
run;

/* Step 6: Correlation matrix to explore relationships between Pregnancies, Glucose, Insulin, and BMI */
proc corr data=categorized_data;
    var Pregnancies Glucose Insulin BMI;
    title 'Correlation Matrix for Pregnancies, Glucose, Insulin, and BMI';
run;
/*********************************************************/
