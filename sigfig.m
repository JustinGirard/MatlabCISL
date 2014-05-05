function [ returnNumber  ] = sigfig( number,digits )
%SIGFIG 
    multiplier = 10^digits;
    round(number*multiplier)
    multiplier
    round(number*multiplier)/multiplier
    
    number = round(number*multiplier)/multiplier;
    returnNumber = number;

end

