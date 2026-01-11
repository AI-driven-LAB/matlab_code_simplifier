================================================================================
MATLAB CODE SIMPLIFIER: ENTERPRISE EDITION
Author: Dr Leo Chen

================================================================================

OVERVIEW
--------
This tool is a "Post-run Sub-agent" designed to refactor AI-generated MATLAB 
code. It eliminates "AI Smell" by flattening logic, pruning redundant comments, 
and enforcing professional naming conventions (camelCase).

NEW IN THIS VERSION:
- Recursive Folder Support: Sweeps sub-folders automatically.
- Granular Error Reporting: Restored full status codes (0, 101, 102, 201, 202, 301).
- Sub-folder Mirroring: Maintains your project hierarchy in the output folder.

STATUS CODES
------------
0   - Success
101 - Input path not found
102 - Failed to create output directory
201 - File read access denied
202 - File write permission error
301 - Logic/Regex refactoring error

HOW TO USE
----------
Pass any path (File or Folder) to the function:
>> [status, report] = matlab_code_simplifier('C:\MyResearch\ProjectA');

The tool will process all .m files (including those in sub-folders) and 
save the results in 'ProjectA\simplified_output\', preserving your structure.

PROGRAMMING TIPS
------------------------------
1. Clarity: Use 'timeSeconds' instead of 't'.
2. Consistency: Enforce camelCase for all functions.
3. No Redundancy: Avoid names like 'dataStruct' or 'i'.
4. Descriptive: Names must reflect the engineering context.

 
