function labels_predict = myknn_Wd( data_test, data_train, labels_train, k )
[N_test,~]=size(data_test);
labels=zeros(N_test,1);
for i=1:N_test  
    [dists, neighbors] = kneighbors(data_train,labels_train,data_test(i,:),k);   
    % calculate the K nearest neighbors and the distances.  
    labels(i,:) = res(labels_train(neighbors),dists,k);  
    % recognize the label of the test vector.  
end  
labels_predict=labels;
end
function [dists, neighbors]=kneighbors(data_train,labels_train,data_test,k)
[N_train, ~] = size(data_train);  
test_mat = repmat(data_test,N_train,1);  
dist_mat = (data_train-double(test_mat)) .^2;
[dist_array,neighbors_array]=sort(sqrt(sum(dist_mat,2)));
dists=dist_array(1:k);
neighbors=neighbors_array(1:k);
end
function predict = res(k_labels,dists,k)
for i=1:k
    weighted_dist(i,:)=(sum(dists)-dists(i,:))/sum(dists);
end
result=sum(weighted_dist.*k_labels)/k;
predict=round(result);
% location=find(k_labels);
%     if size(location,1)>(k-1)/2;
%         predict=1;
%     else predict=0;
%     end       
end
