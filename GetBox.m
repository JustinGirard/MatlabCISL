function boxPoints = GetBox(point,size)
   ang=0:0.01:2*pi; 
   xp=size*cos(ang);
   yp=size*sin(ang);
   boxPoints = [point(1)+xp; point(2)+yp];
end
