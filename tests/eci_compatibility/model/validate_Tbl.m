function retStat = validate_Tbl(TBL_obj)
% Validates that values of the Tbl parameter table are within acceptable
% bounds.
%
% Example implementation for testing purposes.

    % initalize to pass
    retStat = int32(0);
    
    if TBL_obj.Param1 == 2
        % decrement to indicate failure to validate
        retStat = retStat - int32(1); 
    end
    
    if TBL_obj.Param3 == single(12)
        % decrement to indicate failure to validate
        retStat = retStat - int32(1); 
    end
    
end % validate_Tbl()