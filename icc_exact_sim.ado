*! icc_exact_sim.ado
*! Simulation for ICC(1,1), ICC(2,1), ICC(3,1) — Stata 18 version (v1_beta 22/01/26)

version 18.0
cap program drop icc_exact_sim

program define icc_exact_sim, rclass
    syntax , n(integer) k(integer) rho(real) ///
        [ method(integer 1) alpha(real 0.05) sims(integer 1000) seed(integer 12345) ]

    if `method' < 1 | `method' > 3 {
        di as err "method() must be 1, 2, or 3"
        exit 198
    }

    set seed `seed'

    tempfile res
    tempname results

    postfile `results' ///
        icc_e cover_e width_e icc_r cover_r width_r ///
        using "`res'", replace

    di as txt "Running `sims' simulations using ICC(`method',1)..."
    di as txt _continue

    forvalues i = 1/`sims' {

        quietly clear
        quietly set obs `n'
        quietly gen id = _n

        *--------------------------------------------------------------*
        * Data generation depends on ICC type
        *--------------------------------------------------------------*

        if `method' == 1 {
            * ICC(1,1): one-way random effects
            quietly gen u = rnormal(0, sqrt(`rho'))
            quietly expand `k'
            quietly sort id
            quietly by id: gen e = rnormal(0, sqrt(1-`rho'))
            quietly gen y = u + e
        }

        if `method' == 2 {
            * ICC(2,1): two-way random effects (subjects + raters random)
            quietly gen u = rnormal(0, sqrt(`rho'))
            quietly expand `k'
            quietly sort id
            quietly by id: gen rater = _n
            quietly gen v = rnormal(0, sqrt(0.1))   // rater variance
            quietly gen e = rnormal(0, sqrt(1 - `rho' - 0.1))
            quietly gen y = u + v + e
        }

        if `method' == 3 {
            * ICC(3,1): two-way mixed effects (subjects random, raters fixed)
            quietly gen u = rnormal(0, sqrt(`rho'))
            quietly expand `k'
            quietly sort id
            quietly by id: gen rater = _n
            quietly gen e = rnormal(0, sqrt(1-`rho'))
            quietly gen y = u + e + rater/100   // fixed rater effect
        }

        *--------------------------------------------------------------*
        * Exact ICC(1,1) CI (only valid for method 1)
        *--------------------------------------------------------------*
        if `method' == 1 {
            quietly anova y id
            local MSB = e(mss)/e(df_m)
            local MSW = e(rss)/e(df_r)
            local F   = `MSB'/`MSW'
            local icc_e = (`F' - 1)/(`F' + `k' - 1)

            local v1 = `n' - 1
            local v2 = `n' * (`k' - 1)

            * Correct quantiles
            local Fl = invF(`v1', `v2', `alpha'/2)
            local Fu = invF(`v1', `v2', 1 - `alpha'/2)

            local L_e = (`F'/`Fu' - 1)/(`F'/`Fu' + `k' - 1)
            local U_e = (`F'/`Fl' - 1)/(`F'/`Fl' + `k' - 1)
        }
        else {
            local icc_e = .
            local L_e = .
            local U_e = .
        }

        local cover_e = (`L_e' <= `rho' & `U_e' >= `rho')
        local width_e = `U_e' - `L_e'

        *--------------------------------------------------------------*
        * REML ICC for all methods
        *--------------------------------------------------------------*

        if `method' == 1 {
            quietly mixed y || id:, reml
        }
        if `method' == 2 {
            quietly mixed y rater || id:, reml
        }
        if `method' == 3 {
            quietly mixed y i.rater || id:, reml
        }

        quietly estat icc, level(`=100*(1-`alpha')')

        * Stata 18: subject-level ICC is icc2
        local icc_r = r(icc2)
        matrix CI = r(ci2)
        local L_r = CI[1,1]
        local U_r = CI[1,2]

        local cover_r = (`L_r' <= `rho' & `U_r' >= `rho')
        local width_r = `U_r' - `L_r'

        post `results' (`icc_e') (`cover_e') (`width_e') ///
            (`icc_r') (`cover_r') (`width_r')

        di as txt "." _continue
    }

    di ""
    postclose `results'
    quietly use "`res'", clear

    quietly summarize cover_e
    local cov_e = r(mean)*100
    quietly summarize width_e
    local w_e = r(mean)

    quietly summarize cover_r
    local cov_r = r(mean)*100
    quietly summarize width_r
    local w_r = r(mean)

    di as txt "ICC(`method',1) Simulation Benchmark"
    di as txt "{hline 70}"
    di as res "N = "     %6.0f `n'
    di as res "k = "     %6.0f `k'
    di as res "rho = "   %6.3f `rho'
    di as res "Simulations = "  %6.0f `sims'
    di as res "alpha = " %6.3f `alpha'
    di as txt "{hline 70}"

    di as txt "Exact CI (method 1 only):"
    di as res "  Coverage = " %6.2f `cov_e'
    di as res "  Width    = " %6.4f `w_e'

    di as txt "{hline 70}"
    di as txt "REML CI:"
    di as res "  Coverage = " %6.2f `cov_r'
    di as res "  Width    = " %6.4f `w_r'
end