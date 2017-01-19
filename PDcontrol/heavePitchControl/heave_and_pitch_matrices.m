%   geoprop;
%   pitchderivatives;
%   heavederivatives;
% 
%   
%   syms k1 k2 k3 k4 ;
% % k1, k2, k3, k4 : for nondimensionalising;
% % a = Kp, b = kd
% % U = x velocity, assumed 1 for now
% % TE = time lag of actuator, assumed 2.5 sec
%   
%   k1 = rho*(L^3)/2;
%   k2 = rho*(L^5)/2;
%   U  = 1;
%   TE = 2.5;
%   k3 = U/L;
%   k4 =1/k3;
%   m = W/9.81;
%   n=110.969;% propellor speed in RPS
%   eta = 0.012*n/U;
%   C_t = (0.008*L^2)*eta*abs(eta)/2.0;
%   epsilon = -1+((sign(n)/sign(U))*(sqrt(C_t + 1) - 1)/(sqrt(C_t + 1) - 1));
%   global a b;
%  
%    A = [(m/k1)-heave_deriv(5)          0              0            0 ;
%           0                 (Iy/k2)-pitch_deriv(1)     0            0 ;
%           0                         0            TE/k4         -b/k4 ;
%           0                         0              0            1 ];
%   
%    
%    B = [-(heave_deriv(9)+(heave_deriv(14)*epsilon))      (heave_deriv(6)+(heave_deriv(13)*epsilon)+(m/k1))  (heave_deriv(11)+(heave_deriv(15)*epsilon))   0 ;
%          (pitch_deriv(9)+(pitch_deriv(14)*epsilon))      (pitch_deriv(6)+(pitch_deriv(13)*epsilon))         (pitch_deriv(11)+(pitch_deriv(15)*epsilon))   -zg*W/k1 ;
%           0                                               0                                                 -1                                            a;
%           0                                               1                                                  0                                            0];
%       
% %    C = [(W-B);
% %          0;
% %          0;
% %          0]

geoprop;
  pitchderivatives;
  heavederivatives;

  
  syms k1 k2 k3 k4 ;
% k1, k2, k3, k4 : for nondimensionalising;
% a = Kp, b = kd
% U = x velocity, assumed 1 for now
% TE = time lag of actuator, assumed 2.5 sec
  
  k1 = rho*(L^3)/2;
  k2 = rho*(L^5)/2;
  U  = 1;
  TE = 2.5;
  k3 = U/L;
  k4 =1/k3;
  m = W/9.81;
  n=110.969;% propellor speed in RPS
  eta = 0.012*n/U;
  C_t = (0.008*L^2)*eta*abs(eta)/2.0;
  epsilon = -1+((sign(n)/sign(U))*(sqrt(C_t + 1) - 1)/(sqrt(C_t + 1) - 1));
  global c d;
 
   C = [(m/k1)-heave_deriv(5)          0              0            0 ;
          0                 (Iy/k2)-pitch_deriv(1)     0            0 ;
          0                         0            TE/k4         -c/k4 ;
          0                         0              0            1 ];
  
   
   D = [(heave_deriv(9)+(heave_deriv(14)*epsilon))      (heave_deriv(6)+(heave_deriv(13)*epsilon))  (heave_deriv(11)+(heave_deriv(15)*epsilon))   0 ;
         (pitch_deriv(9)+(pitch_deriv(14)*epsilon))      (pitch_deriv(6)+(pitch_deriv(13)*epsilon))         (pitch_deriv(11)+(pitch_deriv(15)*epsilon))   0 ;
          0                                               0                                                 -1                                            d;
          0                                               1                                                  0                                            0];
      
%    C = [(W-B);
%          0;
%          0;
%          0]