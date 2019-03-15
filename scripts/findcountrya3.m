function [ a3codes, fullnames ] = findcountrya3( variousnames, lkup_fn )
% [A3CODES, FULLNAMES] = FINDCOUNTRYA3 (VARIOUSNAMES, [lkup_fn]) Reads "country_lookup.csv" to translate country long names
%(e.g. 'Plurinational States of Bolivia', from a CDIAC CSV file) into a3
%codes
% In:
% VARIOUSNAMES is a string or cell array of strings containing country names or A3 codes
% [lkup_fn] (optional) is the location of "country_lookup.csv" file. Download it from
% Out:
% A3CODES a string or cell array of strings containing the a3 code(s), or '' if no match found
% FULLANMES is a string or cell array of strings containing the full name(s), or '' if no match found
%
% Secret usage:
% [a3codes,AllKnownCountries] = findcountrya3('all');
%

persistent lk; % Used to cache the country_lookup.csv file, for speed.
persistent lkup_date; % Cached timestamp. If it changes, we'll reload the file

if ~exist('lkup_fn','var'), lkup_fn ='country_lookup.txt'; end;
if ~exist(lkup_fn,'file'), error(['findcountrya3 cannot find required lookup file ' lkup_fn '. Download it from http://worldmrio.com/Classifications?country=2']); lk=[]; end;

tmpd = dir(which(lkup_fn)); 
if isempty(lk) || ~strcmp(tmpd.date, lkup_date), lk=cellread(lkup_fn,'\t',3); tmpd = dir(which(lkup_fn)); lkup_date = tmpd.date; end;

notfound={};

% Cached copy of prevous Not Found list. If our list today is the same we will not bother displaying it.
persistent prev_notfound; if isempty(prev_notfound), prev_notfound=''; end;

% Trim whitespace
variousnames = strtrim(variousnames);

if iscell(variousnames)
	n=length(variousnames);
	a3codes=cell(n,1);
	fullnames=cell(n,1);
	for i=1:n, 
        % Special case for Cote ivoire (since it often is corrutped by
        % unicode)
        tmp = variousnames{i}; if length(tmp)>5 && strcmpi(tmp(1),'c') && strcmpi(tmp(end-5:end),'ivoire'), variousnames{i}='Cote Divoire'; end;
        
		idx = strcmpi(lk(:,2),variousnames{i});
		if sum(idx)==0, idx = strcmpi(lk(:,3), variousnames{i}); end; % Check A3s codes as alternative.
		if isempty(variousnames{i}),idx=0; end; %Handle case that the input name is ''
		if sum(idx)==0,
			a3codes{i} = '';
			fullnames{i}='';
            notfound{end+1} = variousnames{i};
		elseif sum(idx)>1, % Multiple matches can happen because country_lookup.csv has Japan and JAPAN
			% So long as all a3 codes are JPN, no worries
			if length( unique(lk(idx,3)))>1, 

                if strcmpi(variousnames{i},'sudan')
                    a3codes{i} = 'SUD'; % We manually assign sudan the NEW sudan country code SUD. Old code is SDN (for both countries together)
                    fullnames{i} ='Sudan';
                else
                    disp(['SERIOUS ERROR in findcountrya3: found multiple different country codes for ' variousnames{i}]);
                end
            else
                idx = find(idx);
                a3codes{i} = lk{ idx(1), 3};
                fullnames{i} = lk{idx(1),1};
            end
		else
			a3codes{i} = lk{idx, 3};
			fullnames{i} = lk{idx,1};
		end;
	end;
    notfound = notfound(cellfun('length',notfound)>0); % Ignore empty countries
    notfound=unique(notfound);
    if ~isempty(notfound),
	    s = join(', ',notfound);
	    % If we have a new Not Found list, display it (and update our cache)
	    if ~strcmp(s, prev_notfound),
% 		    disp(['findcountrya3() did not find a matching Eora country for: ' s]);
		    prev_notfound=s;
	    end;
	end;


else % string case
    if strcmpi(variousnames,'all')
        a3codes = unique(lk(2:end,3));
        [~,fullnames] = findcountrya3(a3codes);
        return;
    end
    
    % Special case for Cote Ivoire
    if length(variousnames)>5  && strcmpi(variousnames(1),'c') && strcmpi(variousnames(end-5:end),'ivoire'), variousnames='Cote Divoire'; end

	idx = strcmpi(lk(:,2),variousnames);
	if sum(idx)==0, idx = strcmpi(lk(:,3),variousnames); end;
	
	if sum(idx)==0, 
		a3codes='';
		fullnames='';
	else
		a3codes = lk{idx,3};
		fullnames = lk{idx,1};
	end;
end

	

end

