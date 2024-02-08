function T = torque(t)
     %CURVE FITT FROOM EXP DATA
      a=80.62;
      b=-25.61;
      c=4.268;
      d=0.208;
      T = a*exp(b*t) + c*exp(d*t);
end
