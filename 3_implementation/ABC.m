function [X, FVAL, Foods,ObjVal,BestFVALCycle] = ABC(FITNESSFCN,lb,ub,MaxFe,NumberFoods,limit)
% Artificial Bee Colony(ABC)
% ABC attempts to solve problems of the following forms:
%         min F(X)  subject to: lb <= X <= ub
%          X
%
%  [BestSolObj, BestSol,Foods,ObjVal] = ABC(FITNESSFCN,lb,ub,MaxFe,NumberFoods,limit)
%  FITNESSFCN    - function handle of the fitness function
%  lb            - lower bounds on X
%  ub            - upper bounds on X
%  MaxFe         - maximum number of functional evaluations
%  NumberFoods   - number of food sources
%  limit         - maximum number of failures which lead to the elimination
%                  of a food source
%  X             - minimum of the fitness function determined by ABC
%  FVAL          - value of the fitness function at the minima (X)
%  Foods         - the latest solution pool
%  ObjVal        - the value of the objective function of Foods
%  BestFVALCycle - provides the best objective function value discovered till the particular cycle
% ================================================================================================== %


% Determining the dimension of the problem
D = length(lb);

if nargin == 5
    % Setting the maximum number of trial for abandoning a source
    limit = NumberFoods * D;
end

% Producing initial food source sites (Equation 1 of [1])
Foods = repmat(lb, NumberFoods,1) + rand(NumberFoods,D) .* repmat((ub-lb),NumberFoods,1);

% Assumption: Maximum number of functional evaluations is greater than the number of foods
% Determining the objective function of the solutions
% Can be vectorized if the objective function is compatible
ObjVal = NaN(NumberFoods,1);
for i = 1: NumberFoods
    ObjVal(i) = FITNESSFCN(Foods(i,:));
end

% Determining the fitness function of the solutions
Fitness = CalculateFitness(ObjVal);

% This is a counter that will keep track of the number of functional evluations
NumEval = NumberFoods;


% Initialization of the trial vector
trial = zeros(1,NumberFoods);

% The best food source is memorized
[FVAL, Ind] = min(ObjVal);
X = Foods(Ind,:);


% ------------The following lines are required to store the best solution in a cycle. ------------
% The number of cycles cannot be uniquely determined given the number
% of maximum functional evaluations and the number of food sources.
% In a cycle, a minimum of 2 x NumberFoods evaluations of the objective function are
% utilized. Hence the variable BestFVALIter is initialized to
% the maximum possible cycles and is not the number of actual cycles.
cycle = 0;
BestFVALCycle = NaN(round((MaxFe -  NumberFoods)/(2*NumberFoods)),1);
% --------------------------------------------------------------------------------------

while ((NumEval < MaxFe))
    
    cycle = cycle + 1;
    
    % Employed Bees Phase
    for i = 1:NumberFoods
        % Only one functional evaluation will be done in GenerateNewsol
        [NumEval,trial,Foods,Fitness,ObjVal] = GenerateNewSol(FITNESSFCN, lb, ub, NumEval, NumberFoods, i, Foods, Fitness, trial, ObjVal, D);
        if NumEval == MaxFe
            break % Terminate the algorithm
        end
    end
    
    % Onlooker Bee Phase
    % Equation 4 of Reference [1]
    prob = Fitness./sum(Fitness);
    
    i=1; t=1;
    
    % The second condition is needed so that when NumEval = MaxFe,
    % time is not spent in this while loop
    while(t <= NumberFoods && NumEval < MaxFe)
        
        if(rand < prob(i))
            
            t = t + 1;
            
            % Only one functional evaluation will be done in GenerateNewsol
            [NumEval,trial,Foods,Fitness,ObjVal] = GenerateNewSol(FITNESSFCN, lb, ub, NumEval, NumberFoods, i, Foods, Fitness, trial, ObjVal, D);
            
            if NumEval == MaxFe
                break % Terminate the algorithm
            end
            
        end
        
        % The counter i keeps increasing irrespective of the generation of
        % the new solution. Hence it may attain a value which is greater
        % than NumberFoods whereas prob is available only for NumberFoods.
        % The mod operator is used to ensure that i does not
        % exceed NumberFoods.
        % Implementation is as suggested in Reference [2] page 123
        i = mod(i,NumberFoods) + 1;
        
    end
    
    % Scout Bee Phase
    if NumEval < MaxFe
        
        % Determine the Food that has failed the maximum times
        % Assumption: elimination only one food source even if more than
        % one might have failed the maximum times.
        [val,ind] = max(trial);
        
        if (val > limit)
            % reset the trial value to zero
            trial(ind) = 0;
            % Generate a random solution as per Equation 1 of Reference [1]
            Foods(ind,:) = (ub-lb).*rand(1,D)+lb;
            
            % Determine the objective function and the fitness function
            % value of the newly generated solution
            ObjVal(ind) = FITNESSFCN(Foods(ind,:));
            Fitness(ind) = CalculateFitness(ObjVal(ind));
            NumEval = NumEval + 1;
        end
    end
    
    % Keeping track of the best solution 
    [BestFVALCycle(cycle),ind] = min([ObjVal;FVAL]);
    FVAL = BestFVALCycle(cycle);
    CombinedSol = [Foods;X];
    X = CombinedSol(ind,:);
end

% Removing the NaN entries in the vector
BestFVALCycle = BestFVALCycle(~isnan(BestFVALCycle));
end