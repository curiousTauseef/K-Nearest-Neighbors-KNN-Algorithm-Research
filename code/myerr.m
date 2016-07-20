function error = myerr( labels_predict,labels )
N=size(labels,1);
res=abs(labels-labels_predict);
num=size(find(res),1);
error=num/N;
end

