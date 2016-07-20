function [psearch1  stack  currentnode]= kdtreesearch( point,kdtree,current_node )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    N=size(kdtree,2);
    stack=zeros(1,N);
    for i=1:N
        
        if (strcmp(current_node, [])) break
        else
            stack(i)=current_node;
            split=kdtree(current_node).splitdim;
            if strcmp(kdtree(current_node).type,'node')
                if point(split)<kdtree(current_node).nodedata(split)
                    currentnode=kdtree(current_node).left;
                else
                    currentnode=kdtree(current_node).right;
                end
            end
        end
    end
    psearch1 = kdtree(current_node).nodedata;

end

