function [ rcodes, rnames, conames, concordance ] = regions( innames, region_type, regionmbmershipFN )
%REGIONS [ codes, names, conames, concordance ] = regions( a3s, region_type, regionmbmershipFN )
% Reads 'regionmembership.csv' (download it from worldmrio.com) and
% groups the provided cell array of a3 codes into regions.
%
% --- USAGE 1 ---
% [A,B] = regions();
% No inputs. Returns two cell arrays, A containing a list of Region Types (.e.g
% "GDP Regions", "Continents", "G20", etc., and B containing a complete list of regions names (e.g. 'High Income' ,'Upper Middle income', ...)
%
%
% --- USAGE 2 ---
% [ codes, names, conames, concordance ] = regions(a3s, [region_type; default:='Global regions']);
% [ codes, names, conames, concordance ] = regions(a3s, region_type, regionmembershipFN);
%
% The concordance matrix 'concordance' can be used for aggregation/sum
% operation like this:
%   aggregated = concordance' * disaggregated_values;
%
% --- USAGE 3 ---
% [ regions ] = regions([], region_type, [regionmembershipFN]);
% If a3s is empty, returns a list of the regions in the specified
% region_type
%
% INPUTS:
%
% a3s: an Nx1 cell array of A3 country codes
%
% region_type: Any value in the "region_type" (column C) of
% "regionmembership.csv". Current values are: 'GDP Regions', 'Global
% Regions', 'Continents', 'EU27,'G20', 'G8', 'OECD', and 'Kyoto Annex I',
% 'BRICS', 'BASIC'
%
% regionmbmershipFN [optional]: location of 'regionmembership.csv' file
%
% OUTPUT:
% codes: an Nx1 vector containing a region code (1,2,...,R) for each
% country (or -1  on lookup error)
%
% names: an Rx1 cell array containing the names for each region code (1,2,...,R)
%
% conames: an Nx1 cell array containing the full name of each country
%
% In case some countries could not be matched to a region, a warning will
% be printed. The rcodes for those unmatched countries will be -1.


%% BEGIN


% --- USAGE 2 ---
% [A,B,C] = regions(a3s, [region_type; default:='Global regions']);
if nargin<2,  region_type='Global Regions'; end


% Initialize variables
if nargin==0
	N=0;
	rcodes=cell(1,1);
	rnames=cell(1,1);
	conames=[];
    concordance = [];
else
	N=1;
	if isempty(innames)
		N=0;
	end
	if N>0 &&  ~iscell(innames), innames = {innames}; end
	if N>0
		N = length(innames);
		rcodes=zeros(N,1)-1;
		rnames= cell(1,1);
		conames= cell(N,1);
        concordance = [];
	end
end

if nargin>=1 && isa(innames, 'tree_structure'), innames=tr.countries; end;


if ~exist('regionmbmershipFN','var'), regionmbmershipFN='regionmembership.csv'; end;

if ~exist(regionmbmershipFN,'file'), disp(['FATAL: regions.m could not locate ' regionmbmershipFN']); return; end;
csv = cellread(regionmbmershipFN,',',2);
csv=csv(3:end, 3:end); 

% --- USAGE 1 ---
% [A,B] = regions();
% No inputs. Returns two cell arrays, A containing a list of Region Types (.e.g
% "GDP Regions", "Continents", "G20", etc., and B containing a complete list of regions names (e.g. 'High Income' ,'Upper Middle income', ...)
if nargin==0
	rcodes = unique(csv(:,1));
	conames = zeros(length(rcodes),1);
	rnames = cell(length(rcodes),1);
	for rti=1:length(rcodes)
		rnames{rti}= regions([], rcodes{rti})';
		conames(rti) = length(rnames{rti});
	end
	return;
end


% --- USAGE 3 ---
% [A] = regions([], region_type, [regionmembershipFN]);
% If a3s is empty, returns a list of the regions in the specified
% region_type
if isempty(innames)
	csvtmp = csv(strcmpi(csv(:,1), region_type),:);
	rcodes = unique(csvtmp(:,3));
	rnames = [];
	conames = [];
	return;
end



% --- USAGE 2 (normal case) ---

a3s = findcountrya3(innames);

csvtmp = csv(strcmpi(csv(:,1), region_type),:);


% Sometimes the user makes a mistake and region_type is not really a region
% type but is simply a region name (e.g. They should have specified
% "Continents" but actually specified "Europe")
% In this case we can impute the region type (assuming that the region name
% is only defined within one region type).
if isempty(csvtmp)
	match_rnames = strcmpi(csv(:,3), region_type); % Match against region names
	if isempty(match_rnames), error(['Found no countries in region_type ' region_type]); end
    matched_rtypes = unique(csv(match_rnames,1));
    
	if numel(matched_rtypes )>1
        error('Specify a region type instead of "%s". Did you mean %s?', region_type, strjoin(cellfun(@(x) ['"' x '"'], matched_rtypes,'UniformOutput',false),' or '));
    end
	region_type = matched_rtypes{1};
	csvtmp = csv(match_rnames,:);
end
if isempty(csvtmp), error(['Found no countries in region_type ' region_type]); end;
csv=csvtmp;

lkup_region_type_id = csv(:,2);
lkup_region_type_name = csv(:,1);
lkup_region_name = csv(:,3);
lkup_a3s = csv(:,4);
lkup_conames = csv(:,5);


for i=1:N
    match_a3 = strcmpi(lkup_a3s,a3s{i});
    match_name = strcmpi(lkup_conames,innames{i});
	if (~any(match_a3)) && (~any(match_name))
        if strcmpi(innames{i},'ROW'), conames{i}='Rest of World'; end;
        continue;
    end
	conames{i}= csv{ match_name | match_a3, 5};
end

rnames = unique(csv(:,3));
R = length(rnames);
concordance = zeros(N, R);
unmatchedcountries = []; % Countries that cannot be matched to any region. (Kept as indices into "innames")
for i=1:N
	cidx = find(strcmpi( lkup_a3s, a3s{i})); %row of this country in csv
	if isempty(cidx), cidx = find(strcmpi( lkup_conames, innames{i})); end  % If no a3 match, try for a country-name match
	if isempty(cidx)
        unmatchedcountries(end+1) = i;
        continue;
    end
    assert(length(cidx)==1, ['Country ' innames{i} ' belongs to two competing ' region_type ' regions. Please correct regionmembership.csv']);
    ridx = find(strcmpi( rnames, lkup_region_name{cidx}));
	rcodes(i) = ridx;
    concordance(i, ridx) = 1;
end

if ~isempty(unmatchedcountries)
%     warning(['regionmembership.csv does not specify a membership in "' region_type '" for: ' strjoin(innames(unmatchedcountries),', ') '. Result rcodes will be -1 for this country(s)']);
end


end %regions





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
