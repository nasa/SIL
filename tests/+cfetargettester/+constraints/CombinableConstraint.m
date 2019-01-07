classdef(Hidden) CombinableConstraint < matlab.unittest.constraints.Constraint
    
    % CombinableConstraint - Interface for Constraints that can be combined
    %
    %   The CombinableConstraint interface is a sub-interface of Constraint
    %   which allows constraints to be combined. In particular, any
    %   constraint which derives from CombinableConstraint is able to be
    %   combined  using the AND (&) and OR (|) operators of the MATLAB
    %   language.
    %
    %   Classes which derive from the CombinableConstraint interface must
    %   implement everything required by the standard Constraint interface.
    %   In exchange for meeting these requirements, all CombinableConstraint
    %   implementations inherit the appropriate MATLAB overloads for AND
    %   and OR so that they can be combined with other CombinableConstraints.
    %
    %   CombinableConstraint methods:
    %       and - the logical conjunction of a combinable constraint
    %       or - the logical disjunction of a combinable constraint
    %
    %   See also
    %       matlab.unittest.constraints.BooleanConstraint
    %       matlab.unittest.diagnostics.Diagnostic
       
    methods (Sealed)
        function constraint = and(constraint1,constraint2)
            % and - the logical conjunction of a combinable constraint
            %
            %   and(CONSTRAINT1, CONSTRAINT2) returns a constraint which is the boolean
            %   conjunction of CONSTRAINT1 and CONSTRAINT2. This is a means to specify
            %   that both CONSTRAINT1 and CONSTRAINT2 should be satisfied by the
            %   actual value provided, and that a qualification failure should be
            %   produced when either CONSTRAINT1 or CONSTRAINT2 is not satisfied.
            %
            %   Typically, the AND method is not called directly, but the MATLAB "&"
            %   operator is used to denote the conjunction of any two
            %   CombinableConstraints.
            %
            %   Examples:
            %
            %       import matlab.unittest.constraints.ContainsSubstring;
            %       import matlab.unittest.constraints.HasElementCount;
            %       import matlab.unittest.constraints.HasSize;
            %       import matlab.unittest.constraints.IsEmpty;
            %       import matlab.unittest.constraints.IsInstanceOf;
            %       import matlab.unittest.constraints.IsGreaterThan;
            %       import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
            %       import matlab.unittest.constraints.IsOfClass;
            %       import matlab.unittest.constraints.IsReal;
            %       import matlab.unittest.TestCase;
            %
            %       % Create a TestCase for interactive use
            %       testCase = TestCase.forInteractiveUse;
            %
            %       % Passing qualifications
            %       testCase.verifyThat(3, IsReal & IsGreaterThanOrEqualTo(3));
            %       testCase.assertThat('Some char', IsOfClass(?char) & ~IsEmpty);
            %       testCase.assumeThat([1 2 3; 4 5 6], HasLength(3) & HasElementCount(6));
            %
            %       % Failing qualifications
            %       testCase.verifyThat(3+i, IsGreaterThan(4), & IsReal);
            %       testCase.assertThat({1, 2}, IsInstanceOf(?cell) & HasSize([1 2]));
            %       testCase.fatalAssertThat('', ContainsSubstring('string') & IsEmpty);
            %
            
            import matlab.unittest.constraints.AndConstraint;
            
            validateConstraint(constraint1);
            validateConstraint(constraint2);
            constraint = AndConstraint(constraint1, constraint2);
        end
        
        function constraint = or(constraint1,constraint2)
            % or - the logical disjunction of a combinable constraint
            %
            %   or(CONSTRAINT1, CONSTRAINT2) returns a constraint which is the boolean
            %   disjunction of CONSTRAINT1 and CONSTRAINT2. This is a means to specify
            %   that either CONSTRAINT1 or CONSTRAINT2 should be satisfied by the
            %   actual value provided, and that a qualification failure should only be
            %   produced when both CONSTRAINT1 and CONSTRAINT2 are not satisfied.
            %
            %   Typically, the OR method is not called directly, but the MATLAB "|"
            %   operator is used to denote the disjunction of any two
            %   CombinableConstraints.
            %
            %   Examples:
            %
            %       import matlab.unittest.constraints.HasInf;
            %       import matlab.unittest.constraints.HasNaN;
            %       import matlab.unittest.constraints.EndsWithSubstring;
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.IsGreaterThan;
            %       import matlab.unittest.constraints.IsLessThan;
            %       import matlab.unittest.constraints.IsOfClass;
            %       import matlab.unittest.constraints.IsReal;
            %       import matlab.unittest.constraints.StartsWithSubstring;
            %       import matlab.unittest.TestCase;
            %
            %       % Create a TestCase for interactive use
            %       testCase = TestCase.forInteractiveUse;
            %
            %       % Passing qualifications
            %       testCase.verifyThat([3 NaN 5], HasNaN | HasInf);
            %       testCase.assertThat(5, IsEqualTo(5) | IsLessThan(0));
            %       testCase.fatalAssertThat(-3, IsEqualTo(5) | IsLessThan(0));
            %
            %       % Failing qualifications
            %       testCase.verifyThat(3+i, IsGreaterThan(4), | IsReal);
            %       testCase.assertThat(true, IsOfClass(?char) | IsOfClass(?cell));
            %       testCase.fatalAssertThat('Some long string', StartsWithSubstring('long') | EndsWithSubstring('long'));
            %
            %   See also
            %       and
            
            import matlab.unittest.constraints.OrConstraint;
            
            validateConstraint(constraint1);
            validateConstraint(constraint2);
            constraint = OrConstraint(constraint1, constraint2);
        end
    end
end

function validateConstraint(constraint)
% It is valid to combine a NotConstraint with another constraint provided
% the NotConstraint contains a CombinableConstraint.

if isa(constraint, 'matlab.unittest.constraints.NotConstraint')
    subConstraint = constraint.Constraint;
    
    % The NotConstraint may itself contain another NotConstraint.
    while isa(subConstraint, 'matlab.unittest.constraints.NotConstraint')
        subConstraint = subConstraint.Constraint;
    end
    
    validateattributes(subConstraint, ...
        {'cfetargettester.constraints.CombinableConstraint'}, ...
        {'scalar'}, '', 'Constraint');
end
end

