function [psearch2 node]  = stacksearch( point,psearch1,kdtree,stack,current_node )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    N=size(stack,2);
    node=current_node;
    for i=0:N-1
        current_node2=stack(end-i);
        point_test=kdtree(current_node2).nodedata;
        dist_test=sum((point_test-point).^2);
        dist=sum((psearch1-point).^2);
        if dist_test<dist
            psearch1=point_test;
            node=current_node2;
        end
    end
    psearch2=psearch1;
end

