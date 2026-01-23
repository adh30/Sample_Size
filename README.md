# Sample_Size
Stata code for sample size estimates

## icc_sampsi.ado
Calculates required sample size to estimate an intraclass correlation coefficient (ICC) with desired precision using an approximate formula. Options for repetitions and confidence interval coverage. Similar to https://wnarifin.github.io/ssc/ssicc.html but runs in Stata.  Based on Bonett, D. G. 2002. Sample size requirements for estimating intraclass correlations with desired precision. *Statistics in Medicine* 21: 1331-1335.

## icc_sampsi.sthlp
Help file for icc_sampsi.

## icc_exact.ado
Calculates required sample size to estimate an intraclass correlation coefficient (ICC) with desired precision using an exact method (more appropriate than the approximation for small sample sizes). 

## icc_exact.sthlp
Help file for icc_exact.

## icc_exact_sim.ado
Performs Monte Carlo simulation to check sample size performance for ICC. Applicable to different ICC types (ICC(1,1), ICC(2,1) and ICC(3,1). 

## icc_exact_sim.ado
Help file for for icc_exact_sim.

## Comments
**NB: All code in beta state - requires more testing to check all calculations are valid**

*Last updated: 23/01/26*
