if ispc

	q = what('l:\courses\COMP61011\MLOtools\61011\data');
    disp(q.mat)
    clear q;
    
elseif isunix

    [folder, name, ext] = fileparts(which(mfilename));
    q = what(folder);
	%q = what('/opt/info/courses/COMP61011/MLOtools/61011/data');
    disp(q.mat)
    clear q folder name ext;
    
    
end
