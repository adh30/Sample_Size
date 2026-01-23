*! version 1.0.0  23jan2026
*! Exact sample size calculation for ICC estimation using F-distribution

program define icc_exact, rclass
    version 14.0
    syntax , Rho(real) Precision(real) [Level(real 95) K(integer 2) SIMulate(integer 0)]
    
    * Validate inputs
    if `rho' <= 0 | `rho' >= 1 {
        display as error "rho must be between 0 and 1"
        exit 198
    }
    
    if `precision' <= 0 | `precision' >= 1 {
        display as error "precision must be between 0 and 1"
        exit 198
    }
    
    if `level' < 10 | `level' > 99.99 {
        display as error "level must be between 10 and 99.99"
        exit 198
    }
    
    if `k' < 2 {
        display as error "k (repetitions per subject) must be at least 2"
        exit 198
    }
    
    if `simulate' < 0 {
        display as error "simulate must be non-negative"
        exit 198
    }
    
    * Calculate alpha from confidence level
    local alpha = (100 - `level') / 100
    local ci_width_target = 2 * `precision'
    
    *==========================================================================
    * PART 1: FIND REQUIRED SAMPLE SIZE USING EXACT METHOD
    *==========================================================================
    
    display as text _newline "{hline 70}"
    display as text "Exact ICC Sample Size Calculation (F-Distribution Method)"
    display as text "{hline 70}"
    display as result "  Planning ICC (rho):             " %7.4f `rho'
    display as result "  Desired half-width (±):         " %7.4f `precision'
    display as result "  Desired total CI width:         " %7.4f `ci_width_target'
    display as result "  Confidence level:               " %7.2f `level' "%"
    display as result "  Repetitions per subject (k):    " %7.0f `k'
    display as text "{hline 70}"
    
    * Binary search for required sample size
    display as text _newline "Searching for minimum required sample size..."
    
    local n_low = 10
    local n_high = 1000
    
    while `n_high' - `n_low' > 1 {
        local n_mid = floor((`n_low' + `n_high') / 2)
        
        * Calculate expected F statistic from ICC
        local F_obs = (1 + (`k' - 1) * `rho') / (1 - `rho')
        
        * Degrees of freedom
        local v1 = `n_mid' - 1
        local v2 = `n_mid' * (`k' - 1)
        
        * Calculate F critical values
        local F_lower = invF(`v2', `v1', `alpha'/2)
        local F_upper = invF(`v2', `v1', 1 - `alpha'/2)
        
        * Calculate confidence limits for ICC
        local FL = `F_obs' / `F_upper'
        local rho_lower = (`FL' - 1) / (`FL' + `k' - 1)
        
        local FU = `F_obs' / `F_lower'
        local rho_upper = (`FU' - 1) / (`FU' + `k' - 1)
        
        * Calculate max half-width
        local half_width_lower = `rho' - `rho_lower'
        local half_width_upper = `rho_upper' - `rho'
        local max_half_width = max(`half_width_lower', `half_width_upper')
        
        if `max_half_width' > `precision' {
            local n_low = `n_mid'
        }
        else {
            local n_high = `n_mid'
        }
    }
    
    * Verify the exact solution
    local n_exact = `n_high'
    
    * Calculate expected CI for the exact n
    local F_obs = (1 + (`k' - 1) * `rho') / (1 - `rho')
    local v1 = `n_exact' - 1
    local v2 = `n_exact' * (`k' - 1)
    local F_lower = invF(`v2', `v1', `alpha'/2)
    local F_upper = invF(`v2', `v1', 1 - `alpha'/2)
    
    local FL = `F_obs' / `F_upper'
    local expected_lower = (`FL' - 1) / (`FL' + `k' - 1)
    
    local FU = `F_obs' / `F_lower'
    local expected_upper = (`FU' - 1) / (`FU' + `k' - 1)
    
    local expected_total_width = `expected_upper' - `expected_lower'
    local half_width_lower = `rho' - `expected_lower'
    local half_width_upper = `expected_upper' - `rho'
    local expected_max_hw = max(`half_width_lower', `half_width_upper')
    local df1 = `v1'
    local df2 = `v2'
    
    display as text _newline "RESULT:"
    display as result "  Required sample size (N):       " `n_exact' " subjects"
    display as text "{hline 70}"
    display as result "  Expected " %4.1f `level' "% CI:             [" %5.3f `expected_lower' ", " %5.3f `expected_upper' "]"
    display as result "  Expected total width:           " %6.4f `expected_total_width' " (target: " %6.4f `ci_width_target' ")"
    display as result "  Expected max half-width:        " %6.4f `expected_max_hw' " (target: " %6.4f `precision' ")"
    display as result "  Degrees of freedom:             v1 = " `df1' ", v2 = " `df2'
    display as text "{hline 70}"
    
    if `n_exact' <= 30 {
        display as text "Note: n <= 30; consider verifying with simulation."
    }
    
    *==========================================================================
    * PART 2: OPTIONAL SIMULATION VERIFICATION
    *==========================================================================
    
    if `simulate' > 0 {
        display as text _newline "SIMULATING DATA TO VERIFY COVERAGE..."
        display as text "{hline 70}"
        display as text "Running " `simulate' " simulations with n = " `n_exact' " subjects"
        display as text "{hline 70}"
        
        * Save current data
        tempfile original_data
        local has_data = 0
        quietly capture describe
        if _rc == 0 {
            if c(N) > 0 | c(k) > 0 {
                quietly save `original_data'
                local has_data = 1
            }
        }
        
        quietly {
            clear
            set obs `simulate'
            
            gen sim_id = _n
            gen icc_estimate = .
            gen ci_lower = .
            gen ci_upper = .
            gen covers = .
            gen total_width = .
            gen max_half_width = .
            
            * Set variance components to achieve target ICC
            local sigma_b = sqrt(`rho')
            local sigma_w = sqrt(1 - `rho')
            
            * Run simulations
            forvalues sim = 1/`simulate' {
                
                preserve
                
                * Generate nested data structure
                clear
                set obs `n_exact'
                gen subject = _n
                gen u_i = rnormal(0, `sigma_b')
                
                expand `k'
                bysort subject: gen rep = _n
                gen e_ij = rnormal(0, `sigma_w')
                gen y = u_i + e_ij
                
                * Calculate ANOVA components
                capture anova y subject
                
                if _rc == 0 {
                    * Extract mean squares
                    local MSB = e(mss) / e(df_m)
                    local MSW = e(rss) / e(df_r)
                    local F_stat = `MSB' / `MSW'
                    
                    * Calculate ICC estimate
                    local icc_hat = (`F_stat' - 1) / (`F_stat' + `k' - 1)
                    
                    * Degrees of freedom
                    local v1_sim = `n_exact' - 1
                    local v2_sim = `n_exact' * (`k' - 1)
                    
                    * Calculate exact confidence interval
                    local F_lower_sim = invF(`v2_sim', `v1_sim', `alpha'/2)
                    local F_upper_sim = invF(`v2_sim', `v1_sim', 1 - `alpha'/2)
                    
                    local FL_sim = `F_stat' / `F_upper_sim'
                    local rho_L = (`FL_sim' - 1) / (`FL_sim' + `k' - 1)
                    
                    local FU_sim = `F_stat' / `F_lower_sim'
                    local rho_U = (`FU_sim' - 1) / (`FU_sim' + `k' - 1)
                    
                    * Check if CI covers true ICC
                    local covers = (`rho_L' <= `rho') & (`rho_U' >= `rho')
                    
                    * Calculate CI widths
                    local tot_width = `rho_U' - `rho_L'
                    local hw_lower = `icc_hat' - `rho_L'
                    local hw_upper = `rho_U' - `icc_hat'
                    local max_hw = max(`hw_lower', `hw_upper')
                }
                else {
                    local icc_hat = .
                    local rho_L = .
                    local rho_U = .
                    local covers = .
                    local tot_width = .
                    local max_hw = .
                }
                
                restore
                
                * Store results
                replace icc_estimate = `icc_hat' in `sim'
                replace ci_lower = `rho_L' in `sim'
                replace ci_upper = `rho_U' in `sim'
                replace covers = `covers' in `sim'
                replace total_width = `tot_width' in `sim'
                replace max_half_width = `max_hw' in `sim'
                
                * Progress indicator
                if mod(`sim', 1000) == 0 {
                    noisily display as text "  Completed " `sim' " simulations..."
                }
            }
        }
        
        * Calculate simulation statistics
        quietly summarize covers
        local coverage_prob = r(mean) * 100
        
        quietly summarize total_width, detail
        local mean_total_width = r(mean)
        local median_total_width = r(p50)
        
        quietly summarize max_half_width, detail
        local mean_max_hw = r(mean)
        if missing(r(p50)) {
            display as error "Median max half-width could not be computed"
            exit 459
        }
        local median_max_hw = r(p50)
        
        quietly gen meets_half_width = (max_half_width <= `precision')
        quietly summarize meets_half_width
        local prop_meets_hw = r(mean) * 100
        
        quietly gen meets_total_width = (total_width <= `ci_width_target')
        quietly summarize meets_total_width
        local prop_meets_tw = r(mean) * 100
        
        quietly summarize icc_estimate
        local mean_icc = r(mean)
        local bias = r(mean) - `rho'
        local sd_icc = r(sd)
        
        * Display simulation results
        display as text _newline "SIMULATION RESULTS"
        display as text "{hline 70}"
        display as result "  Number of simulations:          " `simulate'
        display as result "  Mean ICC estimate:              " %10.4f `mean_icc'
        display as result "  Bias:                           " %10.4f `bias'
        display as result "  SD of ICC estimates:            " %10.4f `sd_icc'
        display as text "{hline 70}"
        display as result "  Coverage probability:           " %10.2f `coverage_prob' "%"
        display as result "  Target coverage:                " %10.2f `level' "%"
        display as text "{hline 70}"
        display as result "  Mean total CI width:            " %10.4f `mean_total_width'
        display as result "  Median total CI width:          " %10.4f `median_total_width'
        display as result "  Target total width:             " %10.4f `ci_width_target'
        display as result "  % meeting total width target:   " %10.2f `prop_meets_tw' "%"
        display as text "{hline 70}"
        display as result "  Mean max half-width:            " %10.4f `mean_max_hw'
        display as result "  Median max half-width:          " %10.4f `median_max_hw'
        display as result "  Target half-width:              " %10.4f `precision'
        display as result "  % meeting half-width target:    " %10.2f `prop_meets_hw' "%"
        display as text "{hline 70}"
        
        * Store simulation results for return
        local sim_coverage = `coverage_prob'
        local sim_mean_width = `mean_total_width'
        local sim_prop_meets = `prop_meets_hw'
        
        * Restore original data
        if `has_data' == 1 {
            quietly use `original_data', clear
        }
        else {
            clear
        }
    }
    else {
        local sim_coverage = .
        local sim_mean_width = .
        local sim_prop_meets = .
    }
    
    *==========================================================================
    * RETURN RESULTS
    *==========================================================================
    
    return scalar N = `n_exact'
    return scalar rho = `rho'
    return scalar precision = `precision'
    return scalar level = `level'
    return scalar k = `k'
    return scalar alpha = `alpha'
    return scalar ci_width_target = `ci_width_target'
    return scalar expected_lower = `expected_lower'
    return scalar expected_upper = `expected_upper'
    return scalar expected_total_width = `expected_total_width'
    return scalar expected_max_hw = `expected_max_hw'
    return scalar df1 = `df1'
    return scalar df2 = `df2'
    
    if `simulate' > 0 {
        return scalar n_sims = `simulate'
        return scalar sim_coverage = `sim_coverage'
        return scalar sim_mean_width = `sim_mean_width'
        return scalar sim_prop_meets = `sim_prop_meets'
    }
    
    display as text _newline "Results stored in r()"
    
end