# Gearbox
- Os Programas com extensão ".m" e ".mat" são respectivos à aquisição de dados, processamento, simulação do modelo dinâmico e identificação dos parâmetros.
    - Os dados experimentais na íntegra estão no arquivo "data.mat". O processamento desses dados é demorado, e para facilitar a execução do algoritmo de Levemberg-Marquardt, os dados foram discretizados e salvos na forma de sinal digital no arquivo "incr1.mat" para o encoder A e "incr2" para o encoder B.
    - Para executar o algoritmo de identificação, basta executar o "programa_principal.m"
- Os programas com extensão ".ipynb" são respectivos à geração de geometria, análise de atrito e análise de contato.
