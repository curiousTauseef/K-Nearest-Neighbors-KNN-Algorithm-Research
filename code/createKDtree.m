function KDtree = createKDtree( data,parent )


% INPUTS
% X                --- contains the data (nxd) matrix , where n is the
%                      number of feature vectors and d is the dimensionality 
%                      of each feature vector 
% parent_number    --- Internal variable .... Donot Assign 
% split_dimension  --- Internal variable .... Donot Assign 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUTS
% tree_output --- contains the a array of structs, each struct is a node 
%                 node in the tree. The size of the array is equal to the 
%                 the number of feature vectors in the data matrix X 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% each struct in the output cell array contains the following information 
% left        -  (tree) left tree node location in the array 
% right       -  (tree) right tree node location in the array 
% numpoints   -  number of points in this node 
% nodevector  -  the median of the data along dimension that it is split 
% hyperrect   -  (2xd) hyperrectangle bounding the points 
% type        -  'leaf' = node is leaf
%                'node' = node has 2 children
% parent      -  the location of the parent of the current node in the
%                struct array 
% index       -  the index of the feature vector in the original matrix 
%                that was used to build the tree
% splitdim    -  the dimension along which the split is made 
% splitval    -  the value along that dimension in which the split is made 

    global tree;
    global nodenum;

    % add the index values to the last column
    % easy way to keep track of them
    [n,d] = size(data);
    data(:,d+1) = 1:n';
    parent=0;
    split=0;
    nodenum=1;
    
    % intialize the node
    Node.type='node';
    Node.node_data = zeros(1,d);
    Node.range = [zeros(1,d);zeros(1,d)];
    Node.split = 0;
    Node.left = 0;
    Node.right = 0;
    Node.parent = 0;
    Node.pointnum = 0;
    
    
    % initilaze the tree
    tree1(1:n) = Node;
    tree = tree1;
    
    % assigned node number for this particular iteration 
    current_node = nodenum;
    
    
    % set assignments to current node
    tree(current_node).type = 'node';
    tree(current_node).parent = parent;
    
    
    % if there is 1 datapoint left, make a leaf out of it
    if n==1
        tree(current_node).left=[];
        tree(current_node).right=[];
        tree(current_node).node_data=data(:,1:end-1);
        tree(current_node).range=[data(:,1:end-1);data(:,1:end-1)];
        tree(current_node).type='leaf';
        tree(current_node).pointnum=1;
    end

    % if there are more than 1 data points left calculate some of the node
    % values
    tree(current_node).pointnum = n;
    a = min(data(:,1:end-1)); b = max(data(:,1:end-1));
    tree(current_node).range = [a; b];
    
    % if the feature vectors happen to be the same then leaf again
    if a==b tree(current_node).type='leaf'; end
% recursively build rest of tree
% if the node is a leaf then assign the index and node vector
if (strcmp(tree(current_node).type,'leaf'))

    tree(current_node).node_data = mean(X(:,1:end-1));
    % if it is not a leaf
    
    % figure out which dimension to split (going in order)
    variance=var(data(:,1:d));
    tree(current_node).splitdim=find(variance==max(variance));
    % figure out the median value to cut this dimension 
    mean_value=mean(data(:,tree(current_node).splitdim));
    % find out all the values that are lower than or equal to this median 
    i=find(data(:, tree(current_node).splitdim)<=mean_value);
    
     % if there are more than 2 points 
    if (tree(current_node).pointnum>2)
        % as there more than two points 
        [max_val,max_pos]=max(data(i, tree(current_node).splitdim));
        % recurse for everything to the left of the median 
        tree(current_node).left = kd_buildtree(data([i(1:max_pos-1);i(max_pos+1:end)], :), current_node);
        % recurse for everything to the right of the median
        if(size(data,1)>size(i,1))
            tree(current_node).right = kd_buildtree(data(find(~(data(:, tree(current_node).splitdim)<=mean_value)), :),current_node);
        else
            tree(current_node).right =[];
        end
    else
        % if there are only two data points left 
        % choose the left value as the median 
        % make the right value as a leaf 
        % leave the left leaf blank 
        [max_val,max_pos]=max(data(i, tree(current_node).splitdim));
        if (i(max_pos)==1); min_pos=2; else min_pos=1; end 
        tree(current_node).left = [];
        tree(current_node).right = kd_buildtree(data(min_pos,:),current_node);
    end
    
    % assign the median vector to this node
    tree(current_node).node_data = data(i(max_pos),1:end-1);
    tree(current_node).splitval=data(i(max_pos), tree(current_node).splitdim);
end
KDtree=tree;
end

