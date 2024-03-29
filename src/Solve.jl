function solve(lp::LinearProgram; iB::Vector{Int}=Int[], type::Symbol=:min, anticycling::Bool=true, maxiter::Int=100)
    @match type begin
        :firstPhase => begin
            return simplex(lp, lp.iB, :firstPhase, anticycling, maxiter)
        end
        :min || :max => begin
            if isempty(iB)
                phaseOne = simplex(lp, lp.iB, :firstPhase, anticycling, maxiter)
                phaseOne.conclusion == :unfeasible && return phaseOne
                phaseOne.conclusion == :tired && return phaseOne
                solution = simplex(lp, phaseOne.iB, type, anticycling, maxiter, validRows=phaseOne.validRows)
                solution.iter += phaseOne.iter - 1
                return solution
            end
            return simplex(lp, iB, type, anticycling, maxiter)
        end 
    end
end
