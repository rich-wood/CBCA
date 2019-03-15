function rv=cellread(fn,dlm,num,varargin)
% B = CELLREAD(FN) Read data from a text file into a cell array
%
% USAGE:
%  B = cellread(fn, [delim], [num])
%      Dan thinks "num" paramter lets you always read num columns of text
%      even if the first line contains a different number of columns.
%       
%  B = cellread(fn, [delim], Arg1, Val1, Arg2, Val2...);
%      Instead of [num] you can provide Arg/Val pairs that are passed
%      directly to textscan().
%
%  B = cellread(fn, [delim], 'Encoding', [text_encoding'], Arg1, Val1, Arg2, Val2...);
%      Same as above, but specify which text encoding to expect in the file. Default is UTF-8.
%      For some files written on windows the encoding may be 'windows-1252' instead. Use this
%      encoding if you find strange or garbled accent characters.


%% Determine usage signature
% Specific number of columns requested?
if nargin>=3 && ~isnumeric(num), varargin = [num,varargin]; clear num; end;

% Text encoding specified?
text_encoding='UTF-8';
if nargin>=3
    if exist('num','var'), tmp_varargin = [dlm, num, varargin]; else tmp_varargin = [dlm, varargin]; end;
    for aa=1:length(tmp_varargin),
        if strcmpi(tmp_varargin{aa},'encoding'),
            text_encoding=tmp_varargin{aa+1}; % Pick up the text encoding
            break;
        end
    end;
    if strcmpi(dlm,'encoding'), clear dlm; clear num; end;
    % Remove the 'Encoding' paramter from varargin if necessary (to avoid an
    % error by passing this unknown argument to textscan())
    if length(tmp_varargin)==2 && length(varargin)==1, varargin={}; end;
    for aa=1:length(varargin),
        if strcmpi(varargin{aa},'encoding'),
            varargin=[varargin(1:aa-1), varargin(aa+2:end)]; % Remove this paramter pair from varargin() 
            break;
        end
    end;
end


[path,name,ext]=fileparts(fn);
assert(exist(fn,'file')>0, ['cellread() cannot find ' fn] );
% determine delimiter
if ~exist('dlm','var'),
	if strcmp(ext,'.csv')
		dlm=',';
	elseif strcmp(ext,'.txt') || strcmp(ext,'.tab') || strcmp(ext,'.tsv')
		dlm='\t';
	else
		dlm=',';
	end;
end;

fid=fopen(fn,'r','n',text_encoding);
assert(fid > -1, strcat(['Error opening file:' fn]));
if exist('OCTAVE_VERSION') 
	
	if (dlm=='\t') dlm = char(9); end

	rv=[];
	[~,tmp] = system(['wc -l ' fn]);
	tmp = strsplit(strtrim(tmp),' '); tmp=strtrim(tmp{1});
	NLINES = str2double(tmp);
	lineno=1;
	%disp(['Reading ' num2str(NLINES) ' lines from ' fn]); 
	while true
		% Get the current line
		ln = fgetl(fid);
		
		% Stop if EOF
		if ln == -1 
			break;
		end;
		
		% Split the line string into components 
		elems = strsplit(ln, dlm);
		if isempty(rv)
			rv=cell(NLINES,length(elems)); rv(1,:)=elems;
		else
			if (length(elems) ~= size(rv,2)),
				disp(['Bad line ' num2str(lineno) ' is ' ln]);
				fclose(fid);
				error(['Line ' num2str(lineno) ' of ' fn ' contains more columns than the first line of the file. Cellread cannot handle this situation.']);
			else
				rv(lineno,:)=elems;
			end;
		end;
		lineno = lineno+1;
	end
		


else
	
	if ~exist('num','var'),num=1;end
	if num>1, grep=['^(?:.*?\n){' num2str(num-1) '}']; else grep='^'; end
	
	data=fscanf(fid,'%c');


	sz = regexp(data,[grep,'(?<regexp>.*?)(\n|$)'],'names'); 
    %DDM added on 2131024 and updated on 20140110. This should handle Mac-generated CSV files
	if isempty(sz) || (size(sz,1)==1 &&  ~isempty(strfind(data,char(13))))
        data = regexprep(data,'\r\n','\n'); % Conver windows \r\n to Unix \n
        data = regexprep(data,'\r','\n'); % Conver Mac \r\n to Unix \n
    	sz = regexp(data,[grep,'(?<regexp>.*?)(\n|$)'],'names');
    end
    if isempty(sz),
		rv = {''};
    else
		sz.size = length(regexp(sz.regexp,dlm));
		try
            % MATLAB R2015a requires the final line to end in '\n',
            % otherwise it throws a segfault
            if ~verLessThan('matlab','7.0') && strcmp(dlm,'\t') && ~strcmp(data(end),'\n'), data=sprintf('%s\n',data); end; 
			rv = rd(textscan(data,[repmat('%q ',1,sz.size+1) '%*[^\n]'], 'delimiter',dlm,'CollectOutput',1,varargin{:}),1);
%			if all(cellfun('isempty',rv(:,end))) && strcmp(dlm,',') && size(rv,2)==1,
%                dlm = ';'; % If dlm was comma and we got zero results, we can alternatively try semicolon
%                rv = rd(textscan(data,[repmat('%q ',1,sz.size+1) '%*[^\n]'],'delimiter',dlm,'CollectOutput',1,varargin{:}),1);
%            end

			if all(cellfun('isempty',rv(:,end))),rv(:,end) = [];end
		catch ME
			data = regexprep(data,'\r\n','\n'); % Conver windows \r\n to Unix \n
			data = regexprep(data,'\r','\n'); % Convert MacOS \r to Unix \n
                	rv = rd(textscan(data,[repmat('%q ',1,sz.size+1) '%*[^\n]'],'delimiter',dlm,'CollectOutput',1,varargin{:}),1);
                	if all(cellfun('isempty',rv(:,end))),rv(:,end) = [];end
		end % handle \r and \n

	end
	
end %octave or matlab?

fclose(fid);

end
