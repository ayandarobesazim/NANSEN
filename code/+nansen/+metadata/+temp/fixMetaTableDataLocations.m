function metaTable = fixMetaTableDataLocations(metaTable, dataLocationModel)
%fixMetaTableDataLocations Fix DataLocation of all entries to be in 
% accordance with new specification    

    entries = table2struct(metaTable.entries);
    
    if isempty(metaTable.entries); return; end
    
    if ~isfield(entries(1), 'DataLocation'); return; end
    
    numDataLocations = dataLocationModel.NumDataLocations;
    
    dataLocationCount = arrayfun(@(s) numel(s.DataLocation), entries);
    hasUuid = arrayfun(@(s) isfield(s.DataLocation, 'Uuid'), entries);
    
    if all(dataLocationCount == numDataLocations) && all(hasUuid)
        return
    end
    
    newDataLocation = cell(numel(entries), 1);
    
    for j = 1:numel(entries)
        
        if dataLocationCount(j) == numDataLocations && hasUuid(j)
            S = entries(j).DataLocation;
            
        else
            S = struct('Uuid', {}, 'RootUid', {}, 'Subfolders', {});

            for i = 1:dataLocationModel.NumDataLocations
                dataLocation = dataLocationModel.getItem(i);

                name = dataLocation.Name;
                rootPaths = {dataLocation.RootPath.Value};

                for k = 1:numel(rootPaths)
                    if isfield(entries(j).DataLocation, name)
                        tf = contains( entries(j).DataLocation.(name), rootPaths{k} );
                        if ~isempty(tf)
                            root = rootPaths{k};
                            rootIdx = k;
                            break
                        end
                    end
                end

                S(i).Uuid = dataLocation.Uuid;
                if ~isempty(rootPaths)
                    S(i).RootUid = dataLocation.RootPath(rootIdx).Key;
                    S(i).Subfolders = strrep(entries(j).DataLocation.(name), root, '');
                end
            end
            
            S = dataLocationModel.expandDataLocationInfo(S);
        end
        
        newDataLocation{j} = S;
    end

    metaTable.replaceDataColumn('DataLocation', newDataLocation );
end
        
    