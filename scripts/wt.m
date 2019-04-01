function wt(fn,M,dlm,f)
%%
% 
% This function can be used to write any array
% 
%%
% fn is filename
%
% M is the array to be written
%
% dlm is the delimiter (optional)
%         if the file extension is .csv' then dlm=','
%         else if the file extension is .txt' then dlm='\t'
%         else dlm=','
%
% f is format (optional)
%        Conversion specifications, which include a % character, a
%        conversion character (such as d, i, o, u, x, f, e, g, c, or s),
%        and optional flags, width, and precision fields.  For more
%        details, type "doc fprintf" at the command prompt.


[m,n]=size(M);
[path,name,ext]=fileparts(fn);

% determine delimiter
if ~exist('delim','var'),
	if strcmp(ext,'.csv')
		delim=',';
	elseif strcmp(ext,'.txt')
		delim='\t';
	else
		delim=',';
	end
end

% generate folder (if don't exist)
if ~isempty(path)&&~exist(path,'dir'),
	mkdir(path);
end

% 1. if binary,
if strcmp(ext,'.bin')
	% save data
	fid = fopen(fn, 'wb');
	fwrite(fid, M, 'double');
	fclose(fid);
	
	% save count data
	count=[m,n];
	s=sprintf('%d\t%d\n',count);
	fid = fopen([addsep(path),'count_',name,'.txt'],'w');
	fwrite(fid,s);
	fclose(fid);

% 2. if numeric
elseif isnumeric(M)||islogical(M),
	% save data
	fmt=[repmat(['%e' dlm],1,n-1) '%e'];
	s=sprintf([fmt '\n'],M');
	fid = fopen(fn,'w');
	fwrite(fid,s);
	fclose(fid);
	
% 3. if cellarray
elseif iscell(M)
	% tf=~cellfun('isclass',M,'char');
	% M(tf)=cellfun(@(x) sprintf('%g',x),M(tf),'UniformOutput',false);
	% N=M';
	% s=sprintf([repmat(['%s' dlm],m,n-1) repmat('%s\n',m,1)]',N{:});
	% fid=fopen(fn,'w');
	% fwrite(fid,s);
	% fclose(fid);
	
	% determine fmt
	if ~exist('f','var'), f='d'; end;
	tf=cellfun('isclass',M,'char');				% get logical array (if char, true)
	[m,n]=size(M); s=size(dlm,2);					% get size
	fmt=zeros(m,n*2+size(dlm,2)*(n-1)+2);		% determine fmt size
	fmt(:,1:s+2:end-2)=uint8('%');				% percentage fmt
	fmt(:,2:s+2:end-2)=tf*double(uint8('s'))+~tf*double(uint8(f));	% char & number fmt
	fmt(:,end-1:end)=repmat(uint8('\n'),m,1);	% newline fmt
	fmt(fmt==0)=repmat(uint8(dlm),m,n-1);		% delimiter fmt
	fmt=char(fmt);
	
	% save
	fid=fopen(fn,'w');
	for i=1:m,
		fprintf(fid,fmt(i,:),M{i,:});
	end
	fclose(fid);
	
% 4. if character array
elseif ischar(M)
	% save data
	fid=fopen(fn,'wt');
	fprintf(fid,'%s\n',M);
	fclose(fid);

% 5. if empty
elseif isempty(M)
	% save data
	fid=fopen(fn,'wt');
	fprintf(fid,'%s\n','');
	fclose(fid);
	
% 6. other case
else
	error(['Function write can''t treat ' class(M) 'data structure']);
end
end