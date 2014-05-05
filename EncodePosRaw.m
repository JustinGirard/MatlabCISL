function code = EncodePosRaw(dist,orient)
    %dist = [-200 -100];

    d= floor(dist+100);
    o= round(orient+1);
    if(o <= 0)
        o = 1;
    end
    %s_encodedCodes
    %[d(1) d(2) o]
    %if(this.encodedCodes(d(1),d(2),o) ~= 0)
    %    code = this.encodedCodes(d(1),d(2),o);
    %testCode = this.s_encodedCodes.Get([d(1) d(2) o]);
    if(d(1) < 0) d(1) = 0; end
    if(d(2) < 0) d(2) = 0; end
    if(d(1) >200) d(1) = 200; end
    if(d(2) >200) d(2) = 200; end


    angle = atan2(dist(2),dist(1))*180/pi;
    angle = angle - orient*180/pi; %adjust to make angle relative
    if(angle <0)
        angle = angle + 360;
    end

    if(angle <= 180)
        positionCode=  floor(angle*3/180)+1;
    else
        positionCode = 4;
    end
    %distanceCode = floor(log((sum(dist.^2)+1)))*4;
    distanceCode = floor(log((sum((abs(dist)*4).^2)+1)))*4;

    if(distanceCode >= 16)
        distanceCode = 16;
    end

    code = positionCode +distanceCode;
    code = full(code);
    
end