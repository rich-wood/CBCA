function rv=rd(array,n)
if iscell(array)
	rv=array{n};
elseif isstruct(array),
	rv=eval(['array.' n]);
else
	rv=array;
end
end