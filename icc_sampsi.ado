*! version 1.0.0  21jan2026
*! Sample size calculation for ICC estimation using approximate formula

program define icc_sampsi, rclass
    version 14.0
    syntax , Rho(real) Precision(real) [Level(real 95) K(integer 2)]
    
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
    
    * Calculate alpha from confidence level
    local alpha = (100 - `level') / 100
    
    * Calculate z-critical value (z_alpha/2)
    local z_alpha2 = invnormal(1 - `alpha'/2)
    
    * Calculate approximate sample size using equation (3):
    * n = {8*(z_alpha/2)^2 * (1-rho)^2 * (1+(k-1)*rho)^2} / {k*(k-1)*w^2} + 1
    
    local numerator = 8 * `z_alpha2'^2 * (1 - `rho')^2 * (1 + (`k' - 1) * `rho')^2
    local denominator = `k' * (`k' - 1) * (`precision'*2)^2
    
    local n_raw = (`numerator' / `denominator') + 1
    local n_required = ceil(`n_raw')
    
    * Display results
    display as text _newline "{hline 60}"
    display as text "ICC Sample Size Calculation (Approximate Method)"
    display as text "{hline 60}"
    display as result "  Planning ICC (rho):             " %7.4f `rho'
    display as result "  Desired precision (±):          " %7.4f `precision'
    display as result "  Confidence level:               " %7.2f `level' "%"
    display as result "  Repetitions per subject (k):    " %7.0f `k'
    display as text "{hline 60}"
    display as result "  Required sample size (N):       " %7.0f `n_required' " subjects"
    display as text "{hline 60}"
    
    if `n_required' <= 30 {
        display as text "Note: n <= 30; approximation may be less accurate."
    }
    else {
        display as text "Note: n > 30; approximation is reliable."
    }
    display as text "{hline 60}"
    
    * Return results
    return scalar N = `n_required'
    return scalar rho = `rho'
    return scalar precision = `precision'
    return scalar level = `level'
    return scalar k = `k'
    return scalar z_alpha2 = `z_alpha2'
    return scalar n_raw = `n_raw'
    
end