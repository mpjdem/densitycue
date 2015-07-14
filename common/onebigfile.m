function onebigfile(datdir, prefix, vec_length)
    
    % Change directory
    olddir = cd();
    chdir(datdir)
    big_file = struct;
    dirlist = dir();
    
    if exist('all.mat','file')
        disp('Combined file exists')
        chdir(olddir);
        return 
    end

    for fn = 1:length(dirlist)
        
        % Check whether this is a valid file
        loc1 = findstr(prefix,dirlist(fn).name);
        loc2 = findstr('.mat',dirlist(fn).name);
        if isempty(loc1) || loc1~=1
            continue
        end
        this_file = load(dirlist(fn).name);
        or_fieldnames = fields(this_file);
        if length(or_fieldnames) ~= 1
			continue
        end
        
        % Retrieve subject number
        this_file = this_file.(or_fieldnames{1});
        fieldnames = fields(this_file);
        if loc1+length(prefix) ~= loc2-1
            subj = str2num(dirlist(fn).name(loc1+length(prefix):loc2-1));
        else
            subj = str2num(dirlist(fn).name(loc1+length(prefix)));
        end
        if isempty(subj)
            continue
        end
        
        % If this is the first file, create the structure
        if isempty(fields(big_file))
            for fldn = 1:length(fieldnames)
                fld = fieldnames{fldn};
                if ~iscell(this_file.(fld))
                    big_file.(fld) = [];
                else
                    big_file.(fld) = {};
                end
            end
            big_file.subj = [];
            big_file.setn = [];
        end
        
        % Append the vectors of this file
        for fldn = 1:length(fieldnames)
            fld = fieldnames{fldn}; 
            if length(this_file.(fld)) < vec_length
                continue
            elseif length(this_file.(fld)) > vec_length
                this_file.(fld) = this_file.(fld)(1:vec_length);
            end
            big_file.(fld) = cat(2,big_file.(fld),this_file.(fld)); 
        end
        
        % Retrieve the stimulus set number
        setn = [];
        for i = 1:length(this_file.stimseq)
        	setn = cat(2,setn,this_file.stimseq{i}(this_file.target(i)*2));
        end
        
        % And append to the new subj and setn fields
        big_file.subj = cat(2,big_file.subj,ones(1,vec_length)*subj);
        big_file.setn = cat(2,big_file.setn,setn);

    end
	
    % Save the file
    if exist('or_fieldnames', 'var')
        eval([or_fieldnames{1} '= big_file;']);
        save('all.mat', or_fieldnames{1});
    end
    
    % Back to the old directory
    chdir(olddir);
    
end
