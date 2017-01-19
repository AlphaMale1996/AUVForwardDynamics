function dX = heavePitchControl(t,X)

% function containing the linearised heave and pitch equations
% Purpose: PD controller implementation for course keeping 
% assumption: p = r = v = 0 ; neglect 2nd order terms

% mat file containing A and B matrices
  heave_and_pitch_matrices;   
 % take N = .5* maximum turning moment in zig-zag maneuver
   N = -.5;
   T = 1;
   F_ext=[ 0; 
           0;
          % N*cos(2*pi*t/T);
           0;
           0];  
   
   dX = C\( D*X + F_ext);
   disp(t);


end







