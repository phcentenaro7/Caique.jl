This file contains descriptions for all the main algorithms and methods contained in this project. Its main purpose
is to serve as a guide on how to write the report on the simplex method.

# LinearProgram.jl
Contains the struct LinearProgram and relevant functions. The LinearProgram struct is constructed in canonical
form from the cost vector c, the constraint matrix A, the constraint sign vector s and the right-hand-side value
vector b. Though the program is converted to canonical form, these arguments are all preserved in case the user
expects to use them to formulate other programming problems.
## createSlackSubmatrix
    MAIN STEP

        1.  If i > m, stop. Return the current slack matrix.
        2.  Verify the value of bᵢ. If it is negative, multiply bᵢ and Aᵢ by -1. If it's an equality constraint,
            keep it as such. Otherwise, if it's a ≥ constraint, make it ≤ and vice versa.
        3.  Verify the constraint sign. If it's ≤, add an eᵢ (ith unit) vector to the slack matrix. If it's ≥,
            add an -eᵢ vector to the slack matrix. In either case, append a 0 to the cost vector.
        4. Increment i by one and repeat step 1.
    
## createArtificialSubmatrix
    INITIAL STEP
    
        1.  If there aren't any slack variables, set the artificial matrix to I and put all the artificial
            variables in the basis, in ascending order of indices. Return the artificial matrix.
        2.  Add as many zeros to the cost coefficient vector as there are slack variables.
        3.  Select the first slack variable column in the constraint matrix.
        4.  Select the first row of this column.
        We will henceforth name the current row and column i and j, respectively.
        Moreover, let A be an mxn constraint matrix after the inclusion of the slack variables.
    
    MAIN STEP

        1.  If i > m, stop. Return the current artificial matrix.
        2.  If Aᵢⱼ = 1 and j ≠ n, increment j by one, put the slack variable in the basis and go to step 5.
        3.  Add an eᵢ (ith unit) vector to the artificial matrix, put the artificial variable in the basis
            and add a zero to the cost vector.
        4.  If Aᵢⱼ = -1 and j ≠ n, increment j by one.
        5.  Increment i by one and repeat step 1.

# Simplex.jl
Contains the simplex method and all of its step functions.
## initialStep!
    MAIN STEP
    
        1.  Generate the basis matrix from the constraint matrix. Suppose that the basic variables are ordered
            from indices 1 to m and let A be the constraint matrix. Then we can define the basis B as
            B = [a₁, ..., aₘ].
        2.  Perform LU factorization on the B matrix. This is important to speed up resolution of subsequent
            steps, since they rely on multiple operations upon the basis matrix.
        3.  Generate the values of the variables in the current basis. Denoting the basis variable vector as
            xB, the LU-factorized basis matrix as B̄ and the right-hand-side vector as b, the basis variable
            vector is xB = B̄⁻¹b.
        4.  Generate the current objective value z. Since the nonbasic variables are all equal to zero, to
            calculate z we need only consider basic variables and their costs. Mathematically, Denoting
            the cost vector for the basic variables as cB and the basic variable vector as xB, we have
            z = cBᵀxB.
        5.  Generate the current basis vector b̄. This is the same as the basis variable vector xB. Though they
            are equal, they are symbolically different. We use b̄ as a fixed vector for the current basic variable
            values, subject to changes through Dantzig's rule. The vector xB, on the other hand, is used to
            represent the basic variables as they suffer updates.
            6. Return the basis matrix, the LU-factorized basis matrix and the current basis vector.
## pricing!
        MAIN STEP
        
            1.  Calculate the simplex multiplier vector w. Denoting the basic cost vector by cB and the basis matrix
                by B, the simplex multiplier vector is given by w = cBᵀB⁻¹.
            2.  Calculate the cost reduction vector z̄. Let N be the nonbasic matrix and cN be the nonbasic cost vector.
                Then z̄ can be calculated as z̄ = Nᵀw - cN.
            3.  Obtain z̄ₖ such that z̄ₖ = max{z̄ⱼ, j ∈ J}.
            4.  If z̄ₖ ≤ 0, stop. We have reached an optimal basic feasible solution and the problem is bounded.
                Specifically, if z̄ₖ < 0, the solution found is the only optimal solution. However, if z̄ₖ = 0, then the
                problem has infinitely many solutions along the hyperplane over which xₖ can be increased, so long as
                all the other variables' nonnegativity constraints are respected.
            5.  Return z̄ₖ and k.
## unboundednessTest!
        MAIN STEP

            1.  Generate the coefficient vector yₖ for the entering variable. This vector contains all the coefficients
                for the entering variable xₖ, for each of its constraints, when the problem is represented in terms of the
                nonbasic variables. Vector yₖ can be calculated as yₖ = B⁻¹aₖ.
            2.  If max{yₖ} ≤ 0, stop. This is justified by the fact that we can isolate the basic variable vector in the
                nonbasic representation of the linear programming problem, resulting in the expression xB = b̄ - yₖxₖ.
                Observe that if all the elements of yₖ are ≤ 0, none of the variables in the base will ever decrease.
                Therefore, by increasing xₖ indefinitely, we decrease the objective function value (when minimizing)
                indefinitely, and the base remains compliant with the nonnegativity constraints forever.
            3.  Return yₖ.
## minRatioTest
        MAIN STEP
            1.  Calculate the vector q = b̄ᵢ/yᵢₖ.
            2.  Return the index r of the blocking variable, such that b̄ᵣ/yᵣₖ = min{q}.
## lexicographicRule
        INITIAL STEP
            1.  Let j = 1. This variable will indicate the current basic variable row in the main step.
        MAIN STEP
            1.  Calculate the vector q₀ = b̄ₙ/yₙₖ.
            2.  Let I₀ be the set of indices i such that b̄ᵢ/yᵢₖ = min{q}. If |I₀| = 1, then return r such that I₀ = {r}.
            3.  Calculate the vector qⱼ = yᵢⱼ/yᵢₖ, with yᵢₖ > 0 and i ∈ Iⱼ₋₁.
            4.  Let Iⱼ be the set of indices i such that yᵢⱼ/yᵢₖ = min{qⱼ}. If |Iⱼ| = 1, then return r such that Iⱼ = {r}.
            5.  Increment j by one and repeat step 3.