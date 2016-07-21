

function [w theta] = fisher( data, labels, w, theta )

p = mean(data(labels==1,:));
n = mean(data(labels==0,:));

%within class scatter
sw = cov(data(labels==1,:))+cov(data(labels==0,:));

%FISHER
w = ((p-n) / sw)';
%FLACH
%w = (p-n)';

%BOTH USE THE SAME THRESHOLD FORMULA
theta = (p+n)*w*0.5;



end
