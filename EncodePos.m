      function code = EncodePos(dist,ang)
        %dist = [-200 -100];
        d= floor(dist+100);
        o= round(orient+1);
        if(o <= 0)
            o = 1;
        end
        
            %angle = atan2(dist(2),dist(1))*180/pi;
            %angle = angle - orient*180/pi; %adjust to make angle relative
            %if(angle <0)
            %    angle = angle + 360;
            %end

            if(ang <= 180)
                positionCode=  floor(ang*3/180)+1;
            else
                positionCode = 4;
            end
            %distanceCode = floor(log((sum(dist.^2)+1)))*4;
            distanceCode = floor(log((sum((dist*4).^2)+1)))*4;

            if(distanceCode >= 16)
                distanceCode = 16;
            end

            code = positionCode +distanceCode;
      end