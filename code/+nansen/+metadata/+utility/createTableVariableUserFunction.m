function createTableVariableUserFunction(initializationStruct)
%createTableVariableUserFunction Create function template for custom var

%createFunctionForCustomTableVar
    variableName = initializationStruct.VariableName;
    tableClass = initializationStruct.MetadataClass;
    dataType = initializationStruct.DataType;

    % Make sure the variable name is valid
    assert(isvarname(variableName), '%s is not a valid variable name', variableName)
    
    % Get the path for the template function
    rootPathSource = nansen.rootpath;
    fcnSourcePath = fullfile(rootPathSource, '+metadata', '+tablevar', 'TemplateFunction.m');
    
    % Modify the template function by adding the variable name
    fcnContentStr = fileread(fcnSourcePath);
    fcnContentStr = strrep(fcnContentStr, 'TemplateFunction', variableName);
    fcnContentStr = strrep(fcnContentStr, 'TEMPLATEFUNCTION', upper(variableName));
    fcnContentStr = strrep(fcnContentStr, 'metadata', lower(tableClass));

    % Add initialization of output
    defaultValue = getDefaultValueAsChar(dataType);
    valueExpr = sprintf('value = %s', defaultValue);
    fcnContentStr = strrep(fcnContentStr, 'value = []', valueExpr);
    
    % Create a target path for the function. Place it in the current
    % project folder.
    rootPathTarget = nansen.localpath('Custom Metatable Variable', 'current');
    fcnTargetPath = fullfile(rootPathTarget, ['+', lower(tableClass)] );
    fcnFilename = [variableName, '.m'];
    
    if ~exist(fcnTargetPath, 'dir'); mkdir(fcnTargetPath); end
    
    % Create a new m-file and add the function template to the file.
    fid = fopen(fullfile(fcnTargetPath, fcnFilename), 'w');
    fwrite(fid, fcnContentStr);
    fclose(fid);
    
    % Finally, open the function in the matlab editor.
    edit(fullfile(fcnTargetPath, fcnFilename))
    
end

function defaultValue = getDefaultValueAsChar(dataType)

    switch dataType
        case 'logical (true)'
            defaultValue = 'true';
        case 'logical (false)'
            defaultValue = 'false';
        case 'numeric'
            defaultValue = 'nan';
        case 'char'
            defaultValue = '{N/A}'; 
    end
            
end
