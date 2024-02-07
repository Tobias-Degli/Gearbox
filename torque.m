function T = torque(t)
    % MÉTODO 1: LER O VALOR REAL MEDIDO EXPERIMENTALMENTE (DEMORA MUITO)
    % load('Tt.mat')
    % load('t_t.mat')
    % jj=1;
    % condicao=0;
    % while condicao==0
    %     if t<t_t(jj)
    %         TT=Tt(jj-1);
    %         condicao=1;
    %     end
    %     jj=jj+1;
    % end

    % METODO2: DEGRAU DE TR PARA TL 
    %TL=5.5;TR=30 
     % T=TL;
     % if t<=tch
     %    T=TR;
     % end
     % Ff=T/rp;
     % T=T/(1000*t+1e-6);

     %MÉTODO 3 CURVE FITT FROOM EXP DATA
      a=80.62;
      b=-25.61;
      c=4.268;
      d=0.208;
      T = a*exp(b*t) + c*exp(d*t);
end
