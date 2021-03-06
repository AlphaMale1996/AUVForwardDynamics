%  Forward Dynamics Model NPS AUV II (Healy and Lienhard 1993)
% * Advisor : Prof Vishwanath Nagarajan
% * Department of Ocean Engineering and Naval Architecture, *IIT Kharagpur*
% * *Autonomous Underwater Vehicle Team, IIT Kharagpur*
%
% function dX = forwarddynamics2(t, X) 
% Function containing 6DOF equations of bot, global coordinates, euler
% angles and control surface deflections in the form (A)(dX)=C;
% 
% t : time array specifying the time instants for which the equations have to
%     be solved
% X : 18X1 state vector
%     u = X(1);
%     v = X(2);
%     w = X(3);
%     p = X(4);
%     q = X(5);
%     r = X(6);
%     pos_x=X(7);  Global X coordinate 
%     pos_y=X(8);  Global Y coordinate 
%     pos_z=X(9);  Global Z coordinate 
%     phi = X(10);
%     theta =X(11);
%     psi = X(12);
%     Del_s = X(13);  %stern deflection
%     Del_bp =X(14);  %port bow deflection
%     Del_bs =X(15);  %starboard bow deflection
%     Del_r = X(16);  %rudder deflection
%     Del_delb = X(17);%change in buoyancy
%     Del_sn = X(18); %change in propeller RPM

% INPUT:time t
%       array X at t=0
%       ord_defl
%       caseNo
% ord_defl(1)=del_ordered_rudder
% ord_defl(2)=del_ordered_stern
% ord_defl(3)=del_ordered_bp
% ord_defl(4)=del_ordered_bs
% OUTPUT:dX
% function dX = forwarddynamics2(t, X)             


function dX = forwarddynamics2(t, X,ord_defl,caseNo)              


addpath('actuator dynamics');
addpath('utils');
addpath('PDcontrol');

% Files containing bot properties
geoprop;
control_surf_param;
surgederivatives;
swayderivatives;
heavederivatives;
rollderivatives;
pitchderivatives;
yawderivatives;


% (A)(dX)= C
A = [m - (0.5*rho*(L^3)*surge_deriv(5)), 0, 0, 0, m*zg, -m*yg;
    0, m-(0.5*rho*(L^3)*sway_deriv(5)),0,-m*zg-(0.5*rho*(L^4)*sway_deriv(1)), 0, (xg*m - 0.5*rho*(L^4)*sway_deriv(2));
    0,0,m - (0.5*rho*(L^3)*heave_deriv(5)), m*yg, -m*xg-(0.5*rho*(L^4)*heave_deriv(1)), 0;
    0, -m*zg - (0.5*rho*(L^4)*roll_deriv(5)), m*yg, Ix - (0.5*rho*(L^5)*roll_deriv(1)), -Ixy, -Ixz-(0.5*rho*(L^5)*roll_deriv(2));
    m*zg, 0, -m*xg-(0.5*rho*(L^4)*pitch_deriv(5)), -Ixy, Iy - 0.5*rho*(L^5)*pitch_deriv(1), -Iyx ;
    -m*yg, m*xg - (0.5*rho*(L^4)*yaw_deriv(5)), 0, -Ixz - (0.5*rho*(L^5)*yaw_deriv(1)), -Iyz, Iz - (0.5*rho*(L^5)*yaw_deriv(2))];   

% velocities and angular velocities in body frame
syms u v w p q r;
u = X(1);
v = X(2);
w = X(3);
p = X(4);
q = X(5);
r = X(6);
n=110.969;% propellor speed in RPS
X(18) = n;
% GLOBAL COORDINATES AND EULER ANGLE RATE TERMS
syms pos_x pos_y pos_z phi theta si;
pos_x = X(7);
pos_y = X(8);
pos_z = X(9);

phi = X(10);
theta = X(11);
psi = X(12);

% Actuator deflection values. These all are constantly zero in our AUV.
syms Del_s Del_bp Del_bs Del_r Del_delb Del_sn;
Del_s = X(13);  %stern deflection
Del_bp = X(14);  %port bow deflection
Del_bs = X(15); %starboard bow deflection
Del_r = X(16);   %rudder deflection
Del_delb = X(17);%change in buoyancy
Del_sn = X(18); %change in propeller RPM


% Some other quantities to describe propeller thrust in this AUV
eta = 0.012*n/u;
Cd0 = 0.00385;
C_t = (0.008*L^2)*eta*abs(eta)/2.0;
Xprop = Cd0*(eta*abs(eta) - 1);
epsilon = -1+((sign(n)/sign(u))*(sqrt(C_t + 1) - 1)/(sqrt(C_t + 1) - 1));

% DRAG TERM
% neu=1.1375*10^-3;%viscosity of water at 15deg
% Re=rho*u*L/neu; 
% Cd= -.075/[(log10(Re)-2)^2];
% Total_surface_area=12.5;%sq.m %as calculated from solidworks model
% drag=.5*rho*Total_surface_area*u*u*Cd;
drag_sim_ansys = -(30.4732*u*u+11.3196*u);


% INCLUDING THE INTEGRATION TERMS
  I = integration2(X);


%Contents of the matrix C are calculated piece by piece.
 C = [(m*(v*r - w*q + xg*(q^2 + r^2) - yg*p*q - zg*p*r) + (0.5*rho*(L^4))*(surge_deriv(1)*(p^2) + ...
     surge_deriv(2)*(q^2) + surge_deriv(3)*(r^2) + surge_deriv(4)*p*r) + (0.5*rho*(L^3))*(surge_deriv(6)*w*q ...
     + surge_deriv(7)*v*p + surge_deriv(8)*v*r + u*q*(surge_deriv(9)*Del_s + surge_deriv(10)*Del_bp + surge_deriv(11)* Del_bs) + ...
     surge_deriv(12)*u*r*Del_r) + (0.5*rho*(L^2))*(surge_deriv(12)*v*v + surge_deriv(13)*w*w + surge_deriv(14)*u*v*Del_r + ...
     u*w*(surge_deriv(15)*Del_s + surge_deriv(16)*Del_bs + surge_deriv(16)*Del_bp) + u*u*(surge_deriv(17)*Del_s^2 + surge_deriv(18)*Del_delb^2 ...
     + surge_deriv(19)*Del_r^2)) - ((W-B)*sin(theta)) + (0.5*rho*L^3)*(surge_deriv(20)*u*q*Del_s*epsilon) ...
     + (0.5*rho*L^2)*(surge_deriv(21)*u*w*Del_s + surge_deriv(22)*u*u*Del_s^2)*epsilon + (0.5*rho*L^2)*((u^2)*Xprop))+drag_sim_ansys;
    
    (m*(-u*r + w*p - xg*p*q + yg*(p^2 + r^2) - zg*q*r) + (0.5*rho*L^4)*(sway_deriv(3)*p*q + sway_deriv(4)*q*r) + (0.5*rho*L^3)* ...
    (sway_deriv(6)*u*p + sway_deriv(7)*u*r + sway_deriv(8)*v*q + sway_deriv(9)*w*p + sway_deriv(10)*w*r) + (0.5*rho*L^2)*(sway_deriv(11)*u*v ...
    + sway_deriv(12)*v*w + sway_deriv(13)*u*u*Del_r) + ((W-B)*sin(phi)*cos(theta))...
    -.5*rho*I(1));
    
    (m*(u*q - v*p - xg*p*r - yg*q*r + zg*(p^2 + q^2)) + (0.5*rho*L^4)*((heave_deriv(2)*p^2) + heave_deriv(3)*p*r + heave_deriv(4)*r*r)+ ...
    (0.5*rho*L^3)*(heave_deriv(6)*u*q + heave_deriv(7)*v*p + heave_deriv(8)*v*r) + (0.5*rho*L^2)*(heave_deriv(9)*u*w+heave_deriv(10)*v^2 ...
    +(u^2)*(heave_deriv(11)*Del_s+heave_deriv(12)*Del_bs+heave_deriv(12)*Del_bp)) + (W-B)*cos(theta)*cos(phi)+0.5*rho*L^3*heave_deriv(13)*u*q*epsilon ...
    +(rho*0.5*L^2)*(heave_deriv(14)*u*w+heave_deriv(15)*Del_s*(u^2)*epsilon)...
    +.5*rho*I(2));

    ((Iy-Iz)*q*r-Ixy*p*r+Iyz*(q^2-r^2)+Ixz*p*q-m*yg*(v*p-u*q)+m*zg*(u*r-w*p)+(0.5*rho*L^5)*(roll_deriv(3)*p*q+roll_deriv(4)*q*r)...
    +(0.5*rho*L^4)*(roll_deriv(6)*u*p+roll_deriv(7)*u*r+roll_deriv(8)*v*q+roll_deriv(9)*w*p+roll_deriv(10)*w*r)+(0.5*rho*L^3)*(roll_deriv(11)*u*v+...
    roll_deriv(12)*v*w+(u^2)*(roll_deriv(13)*Del_bp+roll_deriv(13)*Del_bs))+(yg*W-y_b*B)*cos(theta)*cos(phi)-(zg*W-z_b*B)*cos(theta)*sin(phi)...
    +(0.5*L^4)*roll_deriv(14)*u*p*epsilon+(0.5*rho*(L^3)*u^2)*roll_deriv(15));

   
    
    ((Iz-Ix)*p*r+Ixy*q*r-Iyz*p*q-Ixz*((p^2)-r^2)+m*(xg*(v*p-u*q)-zg*(w*q-v*r))+(0.5*rho*L^5)*(pitch_deriv(2)*(p^2)+pitch_deriv(3)*p*r+...
    pitch_deriv(4)*(r^2))+(0.5*rho*(L^4))*(pitch_deriv(6)*u*q+pitch_deriv(7)*v*p+pitch_deriv(8)*v*r)+(0.5*rho*(L^3))*(pitch_deriv(9)*u*w+...
    pitch_deriv(10)*(v^2)+(u^2)*(pitch_deriv(11)*Del_s+pitch_deriv(12)*Del_bp+pitch_deriv(12)*Del_bs)) - ...
    (xg*W - x_b*B)*cos(theta)*cos(phi)-(zg*W - z_b*B)*sin(theta)+0.5*rho*pitch_deriv(13)*q*u*epsilon*(L^4)+(0.5*rho*L^3)*(pitch_deriv(14)*u*w+pitch_deriv(15)...
    *Del_s*u^2)*epsilon-.5*rho*I(3));
    

    ((Ix-Iy)*p*q + Ixy*(p^2-q^2) + Iyz*p*r - Ixz*q*r - m*(xg*(-w*p+u*r)-(-v*r+w*q)*yg) + (rho*0.5*(L^5))*(yaw_deriv(3)*p*q+yaw_deriv(4)*q*r) + (0.5*rho*L^4)*...
    (yaw_deriv(6)*u*p+yaw_deriv(7)*u*r+yaw_deriv(8)*v*q+yaw_deriv(9)*w*p+yaw_deriv(10)*w*r) + (0.5*rho*L^3)*(yaw_deriv(11)*u*v+yaw_deriv(12)*v*w...
    +yaw_deriv(13)*Del_r*u^2)+(xg*W - x_b*B)*cos(theta)*sin(phi) + (yg*W - y_b*B)*sin(theta) + 0.5*rho*(L^3)*(u^2)*yaw_deriv(14)-.5*rho*I(4))];
 




dX = inv(A)*C;

% EULER ANGLE RATES AND GLOBAL POSITION TERMS
u_c0=0;
v_c0=0;
w_c0=0;

dX(7)= u_c0+u*cos(psi)*cos(theta)+v*[cos(psi)*sin(theta)*sin(phi)-sin(psi)*cos(phi)]+w*[cos(psi)*sin(theta)*sin(phi)+sin(psi)*sin(phi)];
dX(8)= v_c0+u*sin(psi)*cos(theta)+v*[sin(psi)*sin(theta)*sin(phi)+cos(psi)*cos(phi)]+w*[sin(psi)*sin(theta)*sin(phi)-cos(psi)*sin(phi)];
dX(9)= w_c0-u*sin(theta)+v*cos(theta)*sin(psi)+w*cos(theta)*sin(phi);

dX(10) = p+q*sin(phi)*tan(theta)+r*cos(phi)*tan(theta);
dX(11) = q*cos(phi)-r*sin(phi);
dX(12) = (q*sin(phi)+r*cos(phi))/cos(theta);


% Actuator dynamics

dX(13)=0;
dX(14)=0;
dX(15)=0;
dX(16)=0;
dX(17)=0;
dX(18)=0;

syms del_o del_st del_bp del_bs;
del_o = ord_defl(1);
del_st = ord_defl(2);
del_bp = ord_defl(3);
del_bs = ord_defl(4);

global psi_des theta_des;
switch caseNo    

    case {'1','2','3','4','5','6'}
          dX(16) = rudderdynamics(Del_r,del_o);
    
    case {'7', '8'}
          dX(13) = sternDynamics(Del_s, del_st);
          
    case{'9'}
        dX(16) = surgePDcontrol(Del_r,psi_des-psi,r,theta_des-theta,q);
end




%STORING THE PRESENT VALUES IN Xold
%  Xold=X;
%  Xold(length(X)+1)=t;


% Fx = m*dX(1);
% Fy = m*dX(2);
% Fz = m*dX(3);
% Mx = Ix*dX(4);
% My = Iy*dX(5);
% Mz = Iz*dX(6);
% 
% %% 
% %FILE HANDLING
% 
%  
%  
%  if(t==0)
%     fid=fopen('PARAM.txt','w+');
%     fprintf(fid,'%6s       %6s       %6s       %6s       %6s       %6s','t','INERTIA(surge)','VISCOUS(surge)','CONTROL SURFACE(surge)','BUOYANCY(surge)','PROP(surge)');
%     fprintf(fid,'     %6s       %6s       %6s       %6s       %6s','INERTIA(sway)','VISCOUS(sway)','CONTROL SURFACE(sway)','BUOYANCY(sway)','PROP(sway)');
%     fprintf(fid,'     %6s       %6s       %6s       %6s       %6s','INERTIA(heave)','VISCOUS(heave)','CONTROL SURFACE(heave)','BUOYANCY(heave)','PROP(heave)');
%     fprintf(fid,'     %6s       %6s       %6s       %6s       %6s','INERTIA(roll)','VISCOUS(roll)','CONTROL SURFACE(roll)','BUOYANCY(roll)','PROP(roll)');
%     fprintf(fid,'     %6s       %6s       %6s       %6s       %6s','INERTIA(pitch)','VISCOUS(pitch)','CONTROL SURFACE(pitch)','BUOYANCY(pitch)','PROP(pitch)');
%     fprintf(fid,'     %6s       %6s       %6s       %6s       %6s\n','INERTIA(yaw)','VISCOUS(yaw)','CONTROL SURFACE(yaw)','BUOYANCY(yaw)','PROP(yaw)');
%  
% 
%  else
% fid=fopen('PARAM.txt','a+'); 
% c11=m*(dX(1)-v*r + w*q - xg*(q^2 + r^2) + yg*(p*q-dX(3)) + zg*(p*r+dX(2)));
% c12=0.5*rho*(L^4)*(surge_deriv(1)*(p^2) +surge_deriv(2)*(q^2) + surge_deriv(3)*(r^2) + surge_deriv(4)*p*r)...
%     + (0.5*rho*(L^3))*(dX(1)*surge_deriv(5)+surge_deriv(6)*w*q ...
%     + surge_deriv(7)*v*p + surge_deriv(8)*v*r)+(0.5*rho*(L^2))*(surge_deriv(12)*v*v + surge_deriv(13)*w*w) ;
% c13=.5*rho*L^3*(u*q*(surge_deriv(9)*Del_s + surge_deriv(10)*Del_bp + surge_deriv(11)* Del_bs) + surge_deriv(12)*u*r*Del_r+surge_deriv(20)*u*q*Del_s*epsilon)...
%     +.5*rho*L^2*(surge_deriv(14)*u*v*Del_r +u*w*(surge_deriv(15)*Del_s + surge_deriv(16)*Del_bs + surge_deriv(16)*Del_bp) ...
%     + u*u*(surge_deriv(17)*Del_s^2 + surge_deriv(18)*Del_delb^2 + surge_deriv(19)*Del_r^2)+(surge_deriv(21)*u*w*Del_sn + surge_deriv(22)*u*u*Del_s^2)*epsilon );
% c14=-(W-B)*sin(theta);
% c15= (0.5*rho*L^2)*((u^2)*Xprop)+drag_sim_ansys;
%  
% 
%  
% c21= m*(dX(2)+u*r - w*p + xg*(p*q+dX(3)) - yg*(p^2 + r^2) + zg*(q*r-dX(1)));
% c22=(0.5*rho*L^4)*(sway_deriv(1)*dX(4)+sway_deriv(2)*dX(6)+sway_deriv(3)*p*q + sway_deriv(4)*q*r) ...
%     +(0.5*rho*L^3)*(sway_deriv(5)*dX(4)+sway_deriv(6)*u*p + sway_deriv(7)*u*r + sway_deriv(8)*v*q + sway_deriv(9)*w*p + sway_deriv(10)*w*r)+...
%      (0.5*rho*L^2)*(sway_deriv(11)*u*v + sway_deriv(12)*v*w)...
%       -.5*rho*I(1);
% c23=(0.5*rho*L^2)*sway_deriv(13)*u*u*Del_r;
% c24=(W-B)*sin(phi)*cos(theta);
% c25=0; 
% 
% c31= m*(dX(3)-u*q + v*p +xg*(p*r-dX(5)) + yg*(q*r+dX(4))- zg*(p^2 + q^2));
% c32=(0.5*rho*L^4)*(heave_deriv(1)*dX(4)+(heave_deriv(2)*p^2) + heave_deriv(3)*p*r + heave_deriv(4)*r*r)+ ...
%     (0.5*rho*L^3)*(heave_deriv(5)*dX(3)+heave_deriv(6)*u*q + heave_deriv(7)*v*p + heave_deriv(8)*v*r +heave_deriv(13)*u*q*epsilon)+...
%     (0.5*rho*L^2)*(heave_deriv(9)*u*w+heave_deriv(10)*v^2+heave_deriv(14)*u*w*epsilon)...
%     +.5*rho*I(2);
% c33=(.5*rho*L^2)*((u^2)*(heave_deriv(11)*Del_s+heave_deriv(12)*Del_bs+heave_deriv(12)*Del_bp)+heave_deriv(15)*Del_s*(u^2)*epsilon); 
% c34=(W-B)*cos(theta)*cos(phi);
% c35=0;
% 
% c41=Ix*dX(4)+(-Iy+Iz)*q*r+Ixy*(p*r-dX(5))-Iyz*(q^2-r^2)-Ixz*(p*q+dX(6))+m*yg*(dX(3)+v*p-u*q)-m*zg*(dX(2)+u*r-w*p);
%  c42=(0.5*rho*L^5)*(roll_deriv(1)*dX(4)+roll_deriv(2)*dX(6)+roll_deriv(3)*p*q+roll_deriv(4)*q*r)...
%     +(0.5*rho*L^4)*(roll_deriv(5)*dX(2)+roll_deriv(6)*u*p+roll_deriv(7)*u*r+roll_deriv(8)*v*q+roll_deriv(9)*w*p+roll_deriv(10)*w*r+roll_deriv(14)*u*p*epsilon)+...
%     +(0.5*rho*L^3)*(roll_deriv(11)*u*v+roll_deriv(12)*v*w+(u^2)+u^2*roll_deriv(15));
% c43=(.5*rho*L^3*u^2)*(roll_deriv(13)*Del_bp+roll_deriv(13)*Del_bs);
% c44=(yg*W-y_b*B)*cos(theta)*cos(phi)-(zg*W-z_b*B)*cos(theta)*sin(phi);
% c45=0;    
%  
% c51=Iy*dX(5)+(Ix-Iz)*p*r-Ixy*(q*r+dX(4))+Iyz*(p*q-dX(6))+Ixz*((p^2)-r^2)-m*(xg*(dX(3)+v*p-u*q)-zg*(w*q-v*r+dX(1)));
% c52=(0.5*rho*(L^5))*(pitch_deriv(1)*dX(5)+pitch_deriv(2)*(p^2)+pitch_deriv(3)*p*r+pitch_deriv(4)*(r^2))+...
%     (0.5*rho*(L^4))*(pitch_deriv(5)*dX(3)+pitch_deriv(6)*u*q+pitch_deriv(7)*v*p+pitch_deriv(8)*v*r+pitch_deriv(13)*q*u*epsilon)...
%     +(0.5*rho*(L^3))*(pitch_deriv(9)*u*w+pitch_deriv(10)*(v^2)+pitch_deriv(14)*u*w)...
%      -.5*rho*I(3);
% c53=(0.5*rho*(L^3))*((u^2)*(pitch_deriv(11)*Del_s+pitch_deriv(12)*Del_bp+pitch_deriv(12)*Del_bs)+pitch_deriv(15)*Del_s*u^2*epsilon) -0;
% c54=(xg*W - x_b*B)*cos(theta)*cos(phi)-(zg*W - z_b*B)*sin(theta);
% c55=0;
% 
% 
%  c61=Iz*dX(6)+(-Ix+Iy)*p*q-Ixy*(p^2-q^2)-Iyz*(p*r+dX(5))+Ixz*(q*r-dX(5)) + m*(xg*(dX(2)-w*p+u*r)-(dX(1)-v*r+w*q)*yg);
%  c62=(rho*0.5*(L^5))*(yaw_deriv(1)*dX(4)+yaw_deriv(2)*dX(6)+yaw_deriv(3)*p*q+yaw_deriv(4)*q*r) +...
%      (0.5*rho*L^4)*(yaw_deriv(5)*dX(2)+yaw_deriv(6)*u*p+yaw_deriv(7)*u*r+yaw_deriv(8)*v*q+yaw_deriv(9)*w*p+yaw_deriv(10)*w*r) +...
%      (0.5*rho*L^3)*(yaw_deriv(11)*u*v+yaw_deriv(12)*v*w+(u^2)*yaw_deriv(14))...
%       -.5*rho*I(4);
%  c63=(0.5*rho*L^3)*yaw_deriv(13)*Del_r*u^2;
%  c64=(xg*W - x_b*B)*cos(theta)*sin(phi) + (yg*W - y_b*B)*sin(theta); 
%  c65=0;
% 
%  fprintf(fid,'%f    %f    %f    %f    %f    %f',t,c11,c12,c13,c14,c15);
%  fprintf(fid,'    %f    %f    %f    %f    %f',c21,c22,c23,c24,c25);
%  fprintf(fid,'    %f    %f    %f    %f    %f',c31,c32,c33,c34,c35);
%  fprintf(fid,'    %f    %f    %f    %f    %f',c41,c42,c43,c44,c45);
%  fprintf(fid,'    %f    %f    %f    %f    %f',c51,c52,c53,c54,c55);
%  fprintf(fid,'    %f    %f    %f    %f    %f \n',c61,c62,c63,c64,c65);
% 
%  fclose(fid);
%  end
% fclose('all'); 

disp(t);
 

end
