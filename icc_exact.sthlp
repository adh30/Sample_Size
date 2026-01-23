{smcl}
{* *! version 1.0.0  23jan2026}{...}
{vieweralsosee "[R] loneway" "help loneway"}{...}
{vieweralsosee "[ME] mixed" "help mixed"}{...}
{vieweralsosee "[ME] estat icc" "help estat icc"}{...}
{vieweralsosee "[R] bootstrap" "help bootstrap"}{...}
{viewerjumpto "Syntax" "icc_exact##syntax"}{...}
{viewerjumpto "Description" "icc_exact##description"}{...}
{viewerjumpto "Options" "icc_exact##options"}{...}
{viewerjumpto "Remarks" "icc_exact##remarks"}{...}
{viewerjumpto "Examples" "icc_exact##examples"}{...}
{viewerjumpto "Stored results" "icc_exact##results"}{...}
{viewerjumpto "References" "icc_exact##references"}{...}
{title:Title}

{p2colset 5 22 24 2}{...}
{p2col :{cmd:icc_exact} {hline 2}}Exact sample size calculation for ICC estimation{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:icc_exact}
{cmd:,}
{opt rho(#)}
{opt precision(#)}
[{opt level(#)}
{opt k(#)}
{opt sim:ulate(#)}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt rho(#)}}planning value of the intraclass correlation coefficient (ICC); must be between 0 and 1{p_end}
{synopt:{opt precision(#)}}desired precision (half-width of confidence interval); must be between 0 and 1{p_end}

{syntab:Optional}
{synopt:{opt level(#)}}confidence level, as a percentage; default is {cmd:level(95)}{p_end}
{synopt:{opt k(#)}}number of repetitions (measurements) per subject; default is {cmd:k(2)}{p_end}
{synopt:{opt sim:ulate(#)}}number of Monte Carlo simulations for verification; default is {cmd:simulate(0)} (no simulation){p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:icc_exact} calculates the exact sample size required to estimate an 
intraclass correlation coefficient (ICC) with a specified precision at a given 
confidence level. The command uses the exact F-distribution method based on 
confidence intervals for the ICC derived from the F-statistic.

{pstd}
The exact confidence interval for the ICC is constructed using:

{pmore}
Lower limit: (F_L - 1) / (F_L + k - 1){break}
Upper limit: (F_U - 1) / (F_U + k - 1)

{pstd}
where F_L and F_U are the critical values from the F-distribution with 
appropriate degrees of freedom.

{pstd}
Optionally, {cmd:icc_exact} can conduct Monte Carlo simulations to verify 
that the calculated sample size achieves the desired coverage probability 
and precision.


{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{opt rho(#)} specifies the planning value (anticipated value) of the intraclass 
correlation coefficient. This should be based on prior research, pilot studies, 
or expert opinion. The value must be between 0 and 1 (exclusive). This is the 
ICC(1,1) in the Shrout and Fleiss (1979) taxonomy, representing the correlation 
between two randomly selected measurements on randomly selected subjects.

{phang}
{opt precision(#)} specifies the desired precision of the estimate, defined as 
the half-width of the confidence interval. For example, {cmd:precision(0.1)} 
requests a confidence interval of width ±0.1 around the ICC estimate (total 
width = 0.2). The value must be between 0 and 1 (exclusive).

{dlgtab:Optional}

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for the 
confidence interval. The default is {cmd:level(95)}, meaning a 95% confidence 
interval. The value must be between 10 and 99.99. Non-integer values are 
accepted (e.g., {cmd:level(97.5)}).

{phang}
{opt k(#)} specifies the number of repetitions (measurements or observations) 
per subject in the reliability study. The default is {cmd:k(2)}, representing 
two measurements per subject. The value must be at least 2.

{phang}
{opt simulate(#)} specifies the number of Monte Carlo simulations to conduct 
for verifying the calculated sample size. If {cmd:simulate(0)} (the default), 
no simulation is performed. If {cmd:simulate(#)} where # > 0, the command 
generates # simulated datasets with the specified ICC structure and calculates 
coverage probability and empirical precision. Typical values are 1000-10000 
simulations.


{marker remarks}{...}
{title:Remarks}

{pstd}
The intraclass correlation coefficient (ICC) is commonly used to assess 
reliability and agreement in studies where measurements are nested within 
subjects. Examples include:

{phang2}• Inter-rater reliability studies{p_end}
{phang2}• Test-retest reliability assessments{p_end}
{phang2}• Method comparison studies{p_end}
{phang2}• Cluster randomized trials (to measure within-cluster correlation){p_end}

{pstd}
{cmd:icc_exact} uses the exact F-distribution method to construct confidence 
intervals for the ICC, which is more accurate than large-sample approximations, 
especially for small to moderate sample sizes.

{pstd}
The exact confidence interval is based on the relationship between the ICC and 
the F-statistic from a one-way ANOVA:

{pmore}
ICC = (MS_between - MS_within) / (MS_between + (k-1) × MS_within)

{pmore}
F = MS_between / MS_within

{pstd}
The command uses binary search to find the minimum sample size where the 
maximum half-width of the confidence interval does not exceed the specified 
precision.

{pstd}
{ul:Choice of planning value}: The required sample size depends heavily on the 
planning value of ρ. Generally:

{phang2}• ICCs near 0.5 require the largest samples{p_end}
{phang2}• ICCs near 0 or 1 require smaller samples{p_end}
{phang2}• Use conservative (moderate) values if uncertain{p_end}

{pstd}
{ul:Sample size considerations}: For n ≤ 30, the exact method is particularly 
important as large-sample approximations may be inaccurate. The command will 
note when the calculated sample size is small.

{pstd}
{ul:Simulation verification}: When using {opt simulate(#)}, the command:

{phang2}1. Generates nested data with the specified ICC structure{p_end}
{phang2}2. Calculates ICC estimates and confidence intervals{p_end}
{phang2}3. Reports empirical coverage probability (should match the nominal level){p_end}
{phang2}4. Reports proportion of intervals meeting the precision criterion{p_end}


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. * Calculate sample size for ICC of 0.8 with precision ±0.1}{p_end}

    {hline}
{pstd}Basic usage with default settings (95% CI, k=2){p_end}
{phang2}{cmd:. icc_exact, rho(0.8) precision(0.1)}{p_end}

    {hline}
{pstd}Specify 99% confidence level{p_end}
{phang2}{cmd:. icc_exact, rho(0.8) precision(0.1) level(99)}{p_end}

    {hline}
{pstd}Three repetitions per subject{p_end}
{phang2}{cmd:. icc_exact, rho(0.8) precision(0.1) k(3)}{p_end}

    {hline}
{pstd}Higher ICC with tighter precision{p_end}
{phang2}{cmd:. icc_exact, rho(0.9) precision(0.05)}{p_end}

    {hline}
{pstd}Moderate ICC with four repetitions{p_end}
{phang2}{cmd:. icc_exact, rho(0.5) precision(0.1) k(4)}{p_end}

    {hline}
{pstd}Non-integer confidence level{p_end}
{phang2}{cmd:. icc_exact, rho(0.75) precision(0.08) level(97.5)}{p_end}

    {hline}
{pstd}With simulation verification (1000 simulations){p_end}
{phang2}{cmd:. icc_exact, rho(0.8) precision(0.1) simulate(1000)}{p_end}

    {hline}
{pstd}Extensive simulation verification (10000 simulations){p_end}
{phang2}{cmd:. icc_exact, rho(0.8) precision(0.1) simulate(10000)}{p_end}

    {hline}
{pstd}Store and display results{p_end}
{phang2}{cmd:. icc_exact, rho(0.8) precision(0.1)}{p_end}
{phang2}{cmd:. display "Required sample size: " r(N)}{p_end}
{phang2}{cmd:. display "Expected CI: [" r(expected_lower) ", " r(expected_upper) "]"}{p_end}
{phang2}{cmd:. display "Expected total width: " r(expected_total_width)}{p_end}

    {hline}
{pstd}Access simulation results{p_end}
{phang2}{cmd:. icc_exact, rho(0.8) precision(0.1) simulate(5000)}{p_end}
{phang2}{cmd:. display "Simulated coverage: " r(sim_coverage) "%"}{p_end}
{phang2}{cmd:. display "Mean simulated width: " r(sim_mean_width)}{p_end}
{phang2}{cmd:. display "% meeting precision: " r(sim_prop_meets) "%"}{p_end}

    {hline}
{pstd}Planning for different scenarios{p_end}
{phang2}{cmd:. * Low ICC, moderate precision}{p_end}
{phang2}{cmd:. icc_exact, rho(0.3) precision(0.15) k(2)}{p_end}

{phang2}{cmd:. * High ICC, tight precision, many repetitions}{p_end}
{phang2}{cmd:. icc_exact, rho(0.85) precision(0.05) k(5) level(99)}{p_end}

{phang2}{cmd:. * Moderate ICC with simulation check}{p_end}
{phang2}{cmd:. icc_exact, rho(0.6) precision(0.10) k(3) simulate(2000)}{p_end}

    {hline}
{pstd}Compare different numbers of repetitions{p_end}
{phang2}{cmd:. forvalues k = 2/5 {c -(}}{p_end}
{phang2}{cmd:.     icc_exact, rho(0.7) precision(0.1) k(`k')}{p_end}
{phang2}{cmd:.     display "k = `k': N = " r(N)}{p_end}
{phang2}{cmd:. {c )-}}{p_end}

    {hline}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:icc_exact} stores the following in {cmd:r()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}required sample size (number of subjects){p_end}
{synopt:{cmd:r(rho)}}planning value of ICC{p_end}
{synopt:{cmd:r(precision)}}desired precision (half-width){p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}
{synopt:{cmd:r(k)}}number of repetitions per subject{p_end}
{synopt:{cmd:r(alpha)}}significance level (1 - level/100){p_end}
{synopt:{cmd:r(ci_width_target)}}target total CI width (2 × precision){p_end}
{synopt:{cmd:r(expected_lower)}}expected lower CI limit{p_end}
{synopt:{cmd:r(expected_upper)}}expected upper CI limit{p_end}
{synopt:{cmd:r(expected_total_width)}}expected total CI width{p_end}
{synopt:{cmd:r(expected_max_hw)}}expected maximum half-width{p_end}
{synopt:{cmd:r(df1)}}degrees of freedom (between subjects){p_end}
{synopt:{cmd:r(df2)}}degrees of freedom (within subjects){p_end}

{p2col 5 25 29 2: Simulation results (if {opt simulate(#)} specified)}{p_end}
{synopt:{cmd:r(n_sims)}}number of simulations conducted{p_end}
{synopt:{cmd:r(sim_coverage)}}empirical coverage probability (%){p_end}
{synopt:{cmd:r(sim_mean_width)}}mean simulated total CI width{p_end}
{synopt:{cmd:r(sim_prop_meets)}}proportion meeting precision criterion (%){p_end}
{p2colreset}{...}


{marker references}{...}
{title:References}

{phang}
Bonett, D. G. 2002. Sample size requirements for estimating intraclass 
correlations with desired precision. {it:Statistics in Medicine} 21: 1331-1335.

{phang}
McGraw, K. O., and Wong, S. P. 1996. Forming inferences about some intraclass 
correlation coefficients. {it:Psychological Methods} 1: 30-46.

{phang}
Shrout, P. E., and Fleiss, J. L. 1979. Intraclass correlations: uses in 
assessing rater reliability. {it:Psychological Bulletin} 86: 420-428.

{phang}
Shoukri, M. M., Asyali, M. H., and Donner, A. 2004. Sample size requirements 
for the design of reliability study: review and new results. 
{it:Statistical Methods in Medical Research} 13: 251-271.


{title:Author}

{pstd}
Alun Hughes{break}
UCL, London, UK{break}
alun.hughes@ucl.ac.uk


{title:Also see}

{psee}
Online:  {helpb loneway}, {helpb mixed}, {helpb estat icc}, {helpb bootstrap}, {helpb icc_sampsi}
{p_end}