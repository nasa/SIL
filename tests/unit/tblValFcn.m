function retVal = tblValFcn(tbl)

    retVal = int32(0);
    
    if tbl.a > 10
        retVal = retVal - 1;
    end
    
    if tbl.b < 3
        retVal = retVal - 1;
    end

end