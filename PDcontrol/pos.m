function dX = pos(t,X1,X2,ansx,ansy,ansz)
u = 1;
v = X1(1,1);
w = X2(1,1);
phi = 0;
theta = X2(4,1);
psi = X1(4,1);
dX(1)= u;%*cos(atan((ansz+ansy)/ansx));%+v*[theta*sin(phi)-psi*cos(phi)]+w*[theta*sin(phi)+psi*sin(phi)];
dX(2)= v;%u*sin(psi)*cos(theta)+v*[sin(psi)*sin(theta)*sin(phi)+cos(psi)*cos(phi)]+w*[sin(psi)*sin(theta)*sin(phi)-cos(psi)*sin(phi)];
dX(3)= w;%u*sin(atan(ansz/ansx));%u*sin(theta)+v*cos(theta)*sin(psi)+w*cos(theta)*sin(phi);

end