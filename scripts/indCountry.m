function [iout, names, miss, conc] = indCountry(clist)
%indCountry Takes a country list and returns index for DESIRE countries, RoW regions - also checks for alternative names
%
% Input:
%   clist ...  Country list
%               This can be a cell array with names, UNcodes, ISO2 or ISO3 but no mix
%               In case of UNcodes it can also be a numerical array
%
% Output:
%   iout  ...  index for clist with
%    .sing    ...  index of the country in cc.desc.sing
%    .regi    ...  index of the country/region in cc.desc.regi
%    .DESIRE  ...  0/1  DESIRE country
%    .WA }
%    ... }    ...  0/1 for RoW region
%    .WM }
%    .unknown ...  entries in clist which couldn't be found in the DESIRE classification
%                   -> these should be put in the DESIRE classification
%
%   names  ...  various names of the official DESIRE country list in order of clist
%     .ISO2, ISO3 ... iso code for countries
%     .DESIREName       ... 'official' name for the country as defined in the DESIRE classification
%     .DESIRERegion     ... 'official' name for the country as defined in the DESIRE classification
%     .DESIRECode       ... DESIRe code of country (iso2 or RoW region)
%
%   miss.regi ... entries in the DESIRE regional DB which were not in clist (DESIRE countries + RoW regions)
%   miss.sing ... entries in the DESIRE country list which were not in clist (all countries)
%
%   conc.to_regi ... concordance matrix clist to regional classification (sparse)
%   conc.to_sing ... concordance matrix clist to countries in cc.desc.sing (sparse)
%
%Created: KST, 12.09.2013


%ifserver:
% run('getFolder.m'); 
% getCountries;    % get DESIRE country classification
%else:
load('CountryMappingDESIRE.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Check input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isnumeric(clist) & isnumeric(clist{1})
    clist = cell2mat(clist)
end

if length(unique(clist)) ~= length(clist)
    warning('KSTfunc:indCountry:MultipleNamesInInput', 'Country names are not unique in the input clist');
end

iso_type = 0;  % 0 for names, -1 for UN, 2 for ISO2, 3 for ISO3

if isnumeric(clist)
    iso_type = -1;
else
    co_length=cellfun('length', clist);
    if all(co_length==3)
        iso_type = 3;
        clist = upper(clist);
    elseif all(co_length==2)
        iso_type = 2;
        clist = upper(clist);
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find index in the DESIRE country list 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if iso_type == -1
    [iclist, iout.sing] = ismember(clist, cc.desc.sing.UNCode);
elseif iso_type == 2
    [iclist, iout.sing] = ismember(clist, cc.desc.sing.ISO2);
elseif iso_type == 3
    [iclist, iout.sing] = ismember(clist, cc.desc.sing.ISO3);

    ccVarNames = get(cc.desc.sing, 'VarNames');
    for i = 1:length(ccVarNames)     % look for alternative names
        if regexpi(ccVarNames{i}, 'AlternativeISO3')   % column with the alternative ISO3 names
            [tmp_iclist, tmp_sing] = ismember(clist, cc.desc.sing.(ccVarNames{i}));
            iclist = iclist | tmp_iclist;  
            iout.sing = iout.sing + tmp_sing;
            clear tmp*
        end
    end % for loop

else
    [iclist, iout.sing] = ismember(clist, cc.desc.sing.Name);

    ccVarNames = get(cc.desc.sing, 'VarNames');
    for i = 1:length(ccVarNames)     % look for alternative names
        if regexpi(ccVarNames{i}, 'AlternativeName\d+')   % all alter. names start with that string followed by some digits 
            [tmp_iclist, tmp_sing] = ismember(clist, cc.desc.sing.(ccVarNames{i}));
            iclist = iclist | tmp_iclist;  
            iout.sing = iout.sing + tmp_sing;
            clear tmp*
        end
    end % for loop
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iout.unknown = ~iout.sing;
iout.sing(iout.unknown) = 1;

names.ISO3         = cc.desc.sing.ISO3(iout.sing);
names.ISO2         = cc.desc.sing.ISO2(iout.sing);
names.UNCode       = cc.desc.sing.UNCode(iout.sing);
names.DESIREName   = cc.desc.sing.Name(iout.sing);
names.DESIRERegion = cc.desc.sing.DESIRERegion(iout.sing);
names.DESIRECode   = cc.desc.sing.DESIRECode(iout.sing);

names.ISO3(iout.unknown)         = {'unknown'};
names.ISO2(iout.unknown)         = {'unknown'};
names.DESIREName(iout.unknown)   = {'unknown'};
names.DESIRERegion(iout.unknown) = {'unknown'};
names.DESIRECode(iout.unknown)   = {'unknown'};

iout.sing(iout.unknown) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  index
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iout.DESIRE = ismember(names.DESIRECode, cc.desc.regi.DESIRECode(cc.DESIRE));
iout.WA = ismember(names.DESIRECode, cc.desc.regi.DESIRECode(cc.WA));
iout.WL = ismember(names.DESIRECode, cc.desc.regi.DESIRECode(cc.WL));
iout.WE = ismember(names.DESIRECode, cc.desc.regi.DESIRECode(cc.WE));
iout.WF = ismember(names.DESIRECode, cc.desc.regi.DESIRECode(cc.WF));
iout.WM = ismember(names.DESIRECode, cc.desc.regi.DESIRECode(cc.WM));

iout.regi = iout.sing * 0;
for i = 1:length(iout.regi)
    if iout.sing(i)    % avoid empty matrix in case of a country not in the DESIRE classification
        iout.regi(i) = find(ismember(cc.desc.regi.DESIRECode, names.DESIRECode(i)));
    end
end % for loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  miss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

miss.regi = cc.desc.regi.Name(~ismember(cc.desc.regi.DESIRECode, names.DESIRECode));
miss.sing = cc.desc.sing.Name(~ismember(cc.desc.sing.Name, names.DESIREName));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  build concordance matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


iout.sing(iout.unknown) = 1;
iout.regi(iout.unknown) = 1;

col_nr_conc = 1:length(iout.sing);
col_conc = length(iout.sing);
row_conc = length(cc.desc.sing);
conc.to_sing = sparse(iout.sing,col_nr_conc,1,row_conc,col_conc);

col_nr_conc = 1:length(iout.regi);
col_conc = length(iout.regi);
row_conc = length(cc.desc.regi);
conc.to_regi = sparse(iout.regi,col_nr_conc,1,row_conc,col_conc);

iout.sing(iout.unknown) = 0;
iout.regi(iout.unknown) = 0;
conc.to_sing(:,iout.unknown) = 0;
conc.to_regi(:,iout.unknown) = 0;

end   %end of function
 
