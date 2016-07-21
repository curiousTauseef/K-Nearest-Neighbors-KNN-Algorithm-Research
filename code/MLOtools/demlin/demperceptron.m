%
% DEMPERCEPTRON
%
% Demo to show how linear models work and learn
% Run just 'demperceptron' to get an example dataset.
%
% Try also:
%   load muddleddata
%   demperceptron(data,labels)
function demperceptron(varargin)

if nargin>0
    data = varargin{1};
    labels = varargin{2};
else
    %GENERATE SOME DEFAULT DATA
    data = 4*[-0.5000   -0.5000;
           -0.5000    0.5000;
           0.3000   -0.5000;
           -0.1000    1.0000;
           -0.8000         0];
    labels = [1 0 0 0 1]';
end

functionality(1) = 0; %LOGREG_ENABLE;
functionality(2) = 1; %PERCEPTRON_ENABLE;
functionality(3) = 0; %SVM_ENABLE;
functionality(4) = 0; %MYCODE_ENABLE;

demlinear(data,labels,functionality);

end

