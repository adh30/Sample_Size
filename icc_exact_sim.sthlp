{smcl}
{cmd:help icc_exact_sim}
{hline}
{title:Title}

{phang}
{bf:icc_exact_sim} — Monte Carlo simulation of ICC confidence interval performance
for ICC(1,1), ICC(2,1), and ICC(3,1)

{hline}
{title:Syntax}

{p 8 15 2}
{cmd:icc_exact_sim} , 
{opt n(#)} 
{opt k(#)} 
{opt rho(real)} 
[{opt method(#)} 
{opt alpha(real)} 
{opt sims(#)} 
{opt seed(#)}]

{hline}
{title:Description}

{pstd}
{cmd:icc_exact_sim} performs Monte Carlo simulations to evaluate the performance of 
confidence intervals for intraclass correlation coefficients (ICC). The command 
supports three ICC types:

{p 8 12 2}
{bf:ICC(1,1)} — one–way random effects; 
{bf:ICC(2,1)} — two–way random effects (subjects and raters random);  
{bf:ICC(3,1)} — two–way mixed effects (subjects random, raters fixed)

{pstd}
For each replication, the program generates data under the specified ICC model, 
fits the appropriate mixed-effects model using {cmd:mixed}, extracts the REML ICC 
estimate and confidence interval using {cmd:estat icc}, and computes coverage and 
interval width. For ICC(1,1), the exact F–based confidence interval is also computed. 
In many clinical situations ICC(2,1) is relevant as it assumes a two-way random effects 
model where raters are chosen from a larger population of raters with similar characteristics
and we wand to generalize results to similar raters (i.e. subjects and raters are random). 
For method (device) comparisons if we assume that the methods are fixed and subjects are 
random then ICC(1,1) seems appropriate. The Exact method is only valid for ICC(1,1).

{hline}
{title:Options}

{dlgtab:Required}

{phang}
{opt n(#)}  
Number of subjects.

{phang}
{opt k(#)}  
Number of repeated measurements (or raters) per subject.

{phang}
{opt rho(real)}  
True ICC used to generate the data.

{dlgtab:Optional}

{phang}
{opt method(#)}  
Specifies the ICC type to simulate.  
Choices are:

{p 12 16 2}
{cmd:method(1)} — ICC(1,1), one–way random effects (default)  
{cmd:method(2)} — ICC(2,1), two–way random effects 
{cmd:method(3)} — ICC(3,1), two–way mixed effects  

{phang}
{opt alpha(real)}  
Significance level for confidence intervals.  
Default is {cmd:alpha(0.05)}.

{phang}
{opt sims(#)}  
Number of Monte Carlo replications.  
Default is {cmd:sims(1000)}.

{phang}
{opt seed(#)}  
Random-number seed for reproducibility.  
Default is {cmd:seed(12345)}.

{hline}
{title:Details}

{pstd}
The data-generating model depends on the ICC type:

{p 8 12 2}
{bf:ICC(1,1)}  
One–way random effects:  
{it:y_ij = u_i + e_ij}

{p 8 12 2}
{bf:ICC(2,1)}  
Two–way random effects:  
{it:y_ij = u_i + v_j + e_ij}

{p 8 12 2}
{bf:ICC(3,1)}  
Two–way mixed effects (raters fixed):  
{it:y_ij = u_i + β_j + e_ij}

{pstd}
For ICC(1,1), the exact confidence interval is computed using the F distribution 
with df1 = n − 1 and df2 = n(k − 1). For all ICC types, the REML ICC and its 
confidence interval are obtained from:

{p 12 12 2}
{cmd:mixed}  
{cmd:estat icc, level(#)}

{pstd}
In Stata 18, the subject-level ICC is returned in {cmd:r(icc2)} and its confidence 
interval in {cmd:r(ci2)}.

{hline}
{title:Example}

{pstd}
Simulate ICC(1,1):

{cmd}
. icc_exact_sim, n(30) k(3) rho(0.5) method(1) sims(2000)
{txt}

{pstd}
Simulate ICC(2,1):

{cmd}
. icc_exact_sim, n(40) k(4) rho(0.7) method(2) sims(3000)
{txt}

{pstd}
Simulate ICC(3,1):

{cmd}
. icc_exact_sim, n(50) k(5) rho(0.6) method(3) sims(5000)
{txt}

{hline}
{title:Stored results}

{pstd}
{cmd:icc_exact_sim} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{synopt:{cmd:r(cov_e)}}Coverage (%) of exact CI (method 1 only){p_end}
{synopt:{cmd:r(w_e)}}Mean width of exact CI (method 1 only){p_end}
{synopt:{cmd:r(cov_r)}}Coverage (%) of REML CI{p_end}
{synopt:{cmd:r(w_r)}}Mean width of REML CI{p_end}

{hline}
{title:Author}

{pstd}
Alun Hughes, UCL, London, UK
alun.hughes@ucl.ac.uk

{hline}
{title:Also see}

{pstd}
{help anova}, {help mixed}, {help estat icc}
