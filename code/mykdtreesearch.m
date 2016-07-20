function labels_predict = mykdtreesearch( data_test,data_train,labels_train,kdtree )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    [N_test,~]=size(data_test);
    labels=zeros(N_test,1);
    for i=1:N_test
        kdtree_test=kdtree;
        [psearch1 stack currentnode]=kdtreesearch(data_test(i,:),kdtree_test,1);
        [psearch2 node]=stacksearch(data_test(i,:),psearch1,kdtree_test,stack,currentnode);
        labels(i,:)=labels_train(kdtree(node).index);
    end
    labels_predict=labels;    

end

