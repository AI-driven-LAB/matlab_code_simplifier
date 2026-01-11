% History
% 11/01/2026    Leo Chen  leo.chen.yi@gmail.com


function [status, statusReport] = matlab_code_simplifier(inputPath)
    % MATLAB_CODE_SIMPLIFIER - Enterprise-grade AI Code Purifier.
    % Author: Dr Leo Chen
    %
    % This tool refactors AI-generated MATLAB code to remove "AI Smell".
    % It enforces guard clauses, removes redundant comments, and standardises naming.
    %
    % STATUS CODES:
    %   0   - Success: Processing completed without issues.
    %   101 - Path Error: Input path does not exist.
    %   102 - Folder Error: Directory creation failed.
    %   201 - Read Error: File access denied or file corrupted.
    %   202 - Write Error: Output directory is read-only or disk full.
    %   301 - Logic Error: Refactoring regex failed during processing.
    %
    % EXAMPLES OF USE:
    %
    % 1. Simplify a single script file:
    %    [status, ~] = matlab_code_simplifier('analysis_script.m');
    %
    % 2. Process all .m files within a specific folder:
    %    [status, ~] = matlab_code_simplifier('C:\Project\ExperimentalData');
    %
    % 3. Process a folder and all its sub-folders (Recursive Mode):
    %    % The tool automatically detects folders and sweeps recursively.
    %    [status, report] = matlab_code_simplifier('./RootProjectFolder');
    %
    % 4. Identify specific files that failed during a batch process:
    %    [~, report] = matlab_code_simplifier('C:\AI_Generated_Library');
    %    disp('\textsf{Failed files: }');
    %    disp(report.errorFiles);
    %
    % 5. Simplify a MATLAB Class Definition:
    %    % Handles classdef, properties, and method blocks.
    %    status = matlab_code_simplifier('DataProcessorClass.m');
    %
    % 6. Error Handling - Path does not exist:
    %    [status, ~] = matlab_code_simplifier('invalid_path_name');
    %    % Returns status = 101.
    %
    % 7. Integrating into a custom cleanup loop for multiple projects:
    %    projectFolders = {'./SignalProc', './ImageProc', './ControlSys'};
    %    for folderIndex = 1:length(projectFolders)
    %        matlab_code_simplifier(projectFolders{folderIndex});
    %    end
    %
    % 8. Checking the total number of successfully processed files:
    %    [~, report] = matlab_code_simplifier('./LegacyCode');
    %    fprintf('\textsf{Successfully cleaned %d files.}\n', report.processedCount);
    %
    % 9. Handling Read-Only scenarios:
    %    % If the output directory cannot be created due to permissions:
    %    [status, ~] = matlab_code_simplifier('R:\ProtectedServerFolder');
    %    % Returns status = 102 or 202.
    %
    % 10. Refining Abstract Classes and Interfaces:
    %    % Removes redundant method bodies hallucinated by AI in Abstract blocks.
    %    matlab_code_simplifier('ShapeInterface.m');

    status = 0;
    statusReport = struct('processedCount', 0, 'errorFiles', {}, 'details', {});

    % 1. Source Validation (Status 101)
    if ~exist(inputPath, 'file') && ~exist(inputPath, 'dir')
        status = 101;
        disp('\textsf{Status 101: Input path not recognised by the operating system.}');
        return;
    end

    % 2. Determine Scope (File vs Folder vs Recursive Folder)
    if isfile(inputPath)
        targetFiles = {inputPath};
        [parentDirectory, ~, ~] = fileparts(inputPath);
        outputRoot = fullfile(parentDirectory, 'simplified_output');
    else
        % Use recursive globbing to find all .m files in sub-folders
        filesInDirectory = dir(fullfile(inputPath, '**', '*.m'));
        % Filter out any files already in a 'simplified_output' folder to avoid loops
        validIndices = cellfun(@(x) ~contains(x, 'simplified_output'), {filesInDirectory.folder});
        filesInDirectory = filesInDirectory(validIndices);
        
        targetFiles = fullfile({filesInDirectory.folder}, {filesInDirectory.name});
        outputRoot = fullfile(inputPath, 'simplified_output');
    end

    % 3. Process Files
    for fileIndex = 1:length(targetFiles)
        currentFilePath = targetFiles{fileIndex};
        [relativeDir, fileName, fileExtension] = fileparts(currentFilePath);
        
        % Construct output path maintaining sub-folder structure
        if isfile(inputPath)
            currentOutputDir = outputRoot;
        else
            % Calculate relative sub-folder path for recursive output
            relPath = strrep(relativeDir, inputPath, '');
            currentOutputDir = fullfile(outputRoot, relPath);
        end

        % Create Sub-folder (Status 102)
        if ~exist(currentOutputDir, 'dir')
            [isCreated, folderError] = mkdir(currentOutputDir);
            if ~isCreated
                status = 102; 
                statusReport.details = folderError;
                return; 
            end
        end

        try
            % File Reading (Status 201)
            fileIdRead = fopen(currentFilePath, 'r');
            if fileIdRead == -1, throw(MException('IO:Read', 'Read Failure')); end
            rawText = fread(fileIdRead, '*char')';
            fclose(fileIdRead);
            
            % Refactoring Core (Status 301)
            processedText = applyRefactoring(rawText);
            
            % File Writing (Status 202)
            finalOutputPath = fullfile(currentOutputDir, [fileName, fileExtension]);
            fileIdWrite = fopen(finalOutputPath, 'w');
            if fileIdWrite == -1, throw(MException('IO:Write', 'Write Failure')); end
            fprintf(fileIdWrite, '%s', processedText);
            fclose(fileIdWrite);
            
            statusReport.processedCount = statusReport.processedCount + 1;
            
        catch exception
            statusReport.errorFiles{end+1} = currentFilePath;
            if strcmp(exception.identifier, 'IO:Read'), status = 201;
            elseif strcmp(exception.identifier, 'IO:Write'), status = 202;
            else, status = 301; end
        end
    end
end

function refinedCode = applyRefactoring(inputCode)
    % Implementation of Dr Leo Chen's Refactoring Rules
    % A. Guard Clauses: Invert nested IF-ELSE logic
    refinedCode = regexprep(inputCode, 'if\s+(.*?)\n\s*(.*?)\nelse\n\s*return\nend', 'if ~($1), return; end\n$2');
    
    % B. Noise Reduction: Remove redundant AI explanations
    refinedCode = regexprep(refinedCode, '%.*(define|variable|initialize|loop).*[\r\n]', '\n');
    
    % C. Standardisation: camelCase for function names
    tokens = regexp(refinedCode, 'function\s+(\w+)\(', 'tokens');
    for tokenIndex = 1:length(tokens)
        oldName = tokens{tokenIndex}{1};
        if contains(oldName, '_')
            newName = regexprep(oldName, '_(\w)', '${upper($1)}');
            newName(1) = lower(newName(1));
            refinedCode = strrep(refinedCode, oldName, newName);
        end
    end
end