function kdtree = buildKDtree(data,parent_number,split_dimension)
global node_cell;
global node_number;

if nargin ==1
     
    [n,d] = size(data);
    data(:,d+1)=1:n';
    node_number=1;
    split_dimension=0;
    parent_number=0;
    
    % identify the node 
    Node.type='node'; 
    Node.left=0;
    Node.right=0;
    Node.nodedata=zeros(1,d);
    Node.hyperrect=[zeros(1,d);zeros(1,d)];
    Node.numpoints=0;
    Node.index=0;
    Node.parent=0;
    Node.splitval=0;
    
    % create the tree 
    t(1:n)=Node;
    node_cell=t;
    clear t;
    
else
    
    [n,d] = size(data(:,1:end-1));
    node_number=node_number+1;
    split_dimension=split_dimension+1;
    
end

current_node=node_number; 

node_cell(current_node).type='node'; 
node_cell(current_node).parent=parent_number; 


%  only 1 datapoint left, set it to leaf 
if n==1
    node_cell(current_node).left=[];
    node_cell(current_node).right=[];
    node_cell(current_node).nodedata=data(:,1:end-1);
    node_cell(current_node).hyperrect=[data(:,1:end-1);data(:,1:end-1)];
    node_cell(current_node).type='leaf';
    node_cell(current_node).numpoints=1;
    node_cell(current_node).index=data(:,end);

    
end

% more than 1 data points left 
node_cell(current_node).numpoints = n;
a = min(data(:,1:end-1)); b = max(data(:,1:end-1));
node_cell(current_node).hyperrect = [a; b];
if a==b node_cell(current_node).type='leaf'; end

 
% build rest of tree
% judge the node is not leaf 
if (strcmp(node_cell(current_node).type,'leaf'))

    node_cell(current_node).nodedata = mean(data(:,1:end-1));
    node_cell(current_node).index=data(:,end);
    
else

    %  not a leaf 
    
    % split dimension  
    node_cell(current_node).splitdim=mod(split_dimension,d)+1;
    % median value to cut this dimension 
    median_value=median(data(:,node_cell(current_node).splitdim));
    % all the values that are lower than or equal to this median 
    i=find(data(:, node_cell(current_node).splitdim)<=median_value);

    
    % more than 2 points 
    if (node_cell(current_node).numpoints>2)
        % as there more than two points 
        [max_val,max_pos]=max(data(i, node_cell(current_node).splitdim)); 
        node_cell(current_node).left = buildKDtree(data([i(1:max_pos-1);i(max_pos+1:end)], :), current_node,split_dimension);
        if(size(data,1)>size(i,1))
            node_cell(current_node).right = buildKDtree(data(find(~(data(:, node_cell(current_node).splitdim)<=median_value)), :),current_node,split_dimension);
        else
            node_cell(current_node).right =[];
        end
    else
        % only two data points left  
        [max_val,max_pos]=max(data(i, node_cell(current_node).splitdim));
        if (i(max_pos)==1); min_pos=2; else min_pos=1; end 
        node_cell(current_node).left = [];
        node_cell(current_node).right = buildKDtree(data(min_pos,:),current_node,split_dimension);
    end
    
    node_cell(current_node).nodedata = data(i(max_pos),1:end-1);
    node_cell(current_node).index=data(i(max_pos),end);
    node_cell(current_node).splitval=data(i(max_pos), node_cell(current_node).splitdim);

    

end
 
if nargin ==1 
    kdtree=node_cell;
    clear global node_cell;
else
    % output the current_node 
    kdtree=current_node;
end
