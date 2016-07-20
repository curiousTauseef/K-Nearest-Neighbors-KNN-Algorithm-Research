clear;
load breast;
mysampler=sampler(data,labels);
[tr te]=mysampler.split(1,5);
for i=1:150
    tstart1=tic;
    labels_predict1=myknn_Ed(te.data,tr.data,tr.labels,i);
    e1(i)=myerr(labels_predict1,te.labels);
    telapsed1(i)=toc(tstart1);
end
errorbar(1:150,e1(:,1:150),std(e1(:,1:150))*ones(size(1:150)),'b');
title('error rate for different K value selection in KNN classifier');
xlabel('k');
ylabel('error');
grid on;
figure();
plot(1:150,telapsed1(:,1:150),'b');
title('training time for different K value selection in KNN classifier');
xlabel('k');
ylabel('training time');
grid on;