{smcl}
{* *! version 1.0.0  21jan2026}{...}
{vieweralsosee "[PSS] power" "help power"}{...}
{vieweralsosee "[R] loneway" "help loneway"}{...}
{viewerjumpto "Syntax" "icc_sampsi##syntax"}{...}
{viewerjumpto "Description" "icc_sampsi##description"}{...}
{viewerjumpto "Options" "icc_sampsi##options"}{...}
{viewerjumpto "Remarks" "icc_sampsi##remarks"}{...}
{viewerjumpto "Examples" "icc_sampsi##examples"}{...}
{viewerjumpto "Stored results" "icc_sampsi##results"}{...}
{viewerjumpto "References" "icc_sampsi##references"}{...}
{title:Title}

{p2colset 5 22 24 2}{...}
{p2col :{cmd:icc_sampsi} {hline 2}}Sample size calculation for ICC estimation{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:icc_sampsi}
{cmd:,}
{opt rho(#)}
{opt precision(#)}
[{opt level(#)}
{opt k(#)}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt rho(#)}}planning value of the intraclass correlation coefficient; must be between 0 and 1{p_end}
{synopt:{opt precision(#)}}desired precision (half-width of confidence interval); must be between 0 and 1{p_end}

{syntab:Optional}
{synopt:{opt level(#)}}confidence level, as a percentage; default is {cmd:level(95)}{p_end}
{synopt:{opt k(#)}}number of repetitions (measurements) per subject; default is {cmd:k(2)}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:icc_sampsi} calculates the approximate sample size required to estimate an 
intraclass correlation coefficient (ICC) with a specified precision at a given 
confidence level. The command uses an approximate formula based on the asymptotic 
variance of the ICC estimator.

{pstd}
The calculation is based on the approximate formula:

{pmore}
n = {8*z²(α/2) * (1-ρ)² * [1+(k-1)ρ]²} / {k(k-1)w²} + 1

{pstd}
where:

{phang2}ρ = planning value of the ICC{p_end}
{phang2}w = width of the confidence interval (2 x desired precision){p_end}
{phang2}k = number of repetitions per subject{p_end}
{phang2}z(α/2) = critical value from the standard normal distribution{p_end}

{pstd}
This approximation is accurate when n > 30. For smaller sample sizes, the 
approximation may be less reliable.


{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt rho(#)} specifies the planning value (anticipated value) of the intraclass 
correlation coefficient. This should be based on prior research, pilot studies, 
or expert opinion. The value must be between 0 and 1 (exclusive).

{phang}
{opt precision(#)} specifies the desired precision of the estimate, defined as 
the half-width of the confidence interval. For example, {cmd:precision(0.1)} 
requests a confidence interval of width ±0.1 around the ICC estimate. The value 
must be between 0 and 1 (exclusive).

{dlgtab:Optional}

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for the 
confidence interval. The default is {cmd:level(95)}, meaning a 95% confidence 
interval. The value must be between 10 and 99.

{phang}
{opt k(#)} specifies the number of repetitions (measurements or observations) 
per subject. The default is {cmd:k(2)}. The value must be at least 2.


{marker remarks}{...}
{title:Remarks}

{pstd}
The intraclass correlation coefficient (ICC) is commonly used to assess 
reliability and concordance in studies where measurements are nested within 
subjects (e.g., repeated measurements, raters, or observers).

{pstd}
When planning a reliability study, researchers need to determine how many 
subjects are required to estimate the ICC with adequate precision. This command 
implements the approximate sample size formula described in Bonett (2002).

{pstd}
The approximate variance of the ICC estimator is:

{pmore}
var(ρ̂) = 2(1-ρ)²[1+(k-1)ρ]² / [k(k-1)(n-1)]

{pstd}
This variance approximation is known to be accurate when n > 30. For smaller 
sample sizes, exact methods based on the F-distribution should be considered, 
though they require iterative search procedures.

{pstd}
The precision parameter represents the half-width of the confidence interval. 
For instance, if the true ICC is 0.80 and you specify {cmd:precision(0.10)}, 
the resulting confidence interval would be approximately [0.70, 0.90].

{pstd}
Choice of planning value: The sample size depends heavily on the planning value 
of ρ. ICCs closer to 0 or 1 generally require smaller sample sizes for the same 
precision, while ICCs around 0.5 require larger samples.


{marker examples}{...}
{title:Examples}

{pstd}Setup: Calculate sample size for ICC of 0.8 with precision ±0.1{p_end}
{phang2}{cmd:. icc_sampsi, rho(0.8) precision(0.1)}{p_end}

{pstd}Specify 99% confidence level{p_end}
{phang2}{cmd:. icc_sampsi, rho(0.8) precision(0.1) level(99)}{p_end}

{pstd}Three repetitions per subject{p_end}
{phang2}{cmd:. icc_sampsi, rho(0.8) precision(0.1) k(3)}{p_end}

{pstd}Higher ICC with tighter precision{p_end}
{phang2}{cmd:. icc_sampsi, rho(0.9) precision(0.05)}{p_end}

{pstd}Moderate ICC with four repetitions{p_end}
{phang2}{cmd:. icc_sampsi, rho(0.5) precision(0.1) k(4)}{p_end}

{pstd}Store and display results{p_end}
{phang2}{cmd:. icc_sampsi, rho(0.8) precision(0.1)}{p_end}
{phang2}{cmd:. display "Required sample size: " r(N)}{p_end}
{phang2}{cmd:. display "Critical z-value: " r(z_alpha2)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:icc_sampsi} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}required sample size (rounded up to nearest integer){p_end}
{synopt:{cmd:r(n_raw)}}raw calculated sample size (before rounding){p_end}
{synopt:{cmd:r(rho)}}planning value of ICC{p_end}
{synopt:{cmd:r(precision)}}desired precision{p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}
{synopt:{cmd:r(k)}}number of repetitions per subject{p_end}
{synopt:{cmd:r(z_alpha2)}}critical value from standard normal distribution{p_end}
{p2colreset}{...}


{marker references}{...}
{title:References}

{phang}
Bonett, D. G. 2002. Sample size requirements for estimating intraclass 
correlations with desired precision. {it:Statistics in Medicine} 21: 1331-1335.

{phang}
Shoukri, M. M., Asyali, M. H., and Donner, A. 2004. Sample size requirements 
for the design of reliability study: review and new results. 
{it:Statistical Methods in Medical Research} 13: 251-271.

{phang}
Shrout, P. E. and Fleiss, J. L. 1979. Intraclass correlations: uses in 
assessing rater reliability. {it:Psychological Bulletin} 86: 420-428.


{title:Author}

{pstd}
Alun Hughes{break}
UCL, London, UK{break}
alun.hughes@ucl.ac.uk


{title:Also see}

{psee}
Online:  {helpb loneway}, {helpb anova}, {helpb power}
{p_end}