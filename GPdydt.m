function dydt = GPdydt(t,tf,y,Im,IL,Ip,Ig,kc,qc,qmb,kmb,Tout,rp,rg,k4)
  dydt = zeros(8,1);
  T=torque(t); Ff=T/rp; T=T/(5e3*t+1e-10); % Tempo inicial ligeiramente diferente de zero para não dar problema no algoritmo
  dydt(1) = y(5);
  dydt(2) = y(6);
  dydt(3) = y(7);
  dydt(4) = y(8);
  dydt(5) = (T + kc*(y(2)-y(1))  + qc*(y(6)-y(5)))/Im;
  dydt(6) = (-Ff*rp+kc*(y(1)-y(2))  + kmb*rp*(rg*y(3)-rp*y(2)) + qc*(y(5)-y(6)) + qmb*rp*(rg*y(7)-rp*y(6)))/Ip;
  dydt(7) = (Ff*rg+k4*(y(4)-y(3))   + kmb*rg*(rp*y(2)-rg*y(3)) + qc*(y(8)-y(7)) + qmb*rg*(rp*y(6)-rg*y(7)))/Ig;
  dydt(8) = (-Tout + k4*(y(3)-y(4)) + qc*(y(7)-y(8)))/IL;
end
