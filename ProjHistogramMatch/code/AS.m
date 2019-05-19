#função responsável por retornar a tabela de correlação apropriada
function L = AS(s0, t0, e, k, Ha, Hb)
  i = 0;
  S = s0;
  T = t0;
  accepted = 0;
  L_S = calculaTabelaCorrecao(S);
  map_s = map(L_S, Ha);
  while (T > e)
    if (i == k)
      #atualiza a temperatura * 0.95
      T = atualizaTemperatura(T);
      i = 0;
    endif
    #gera novo vizinho a partir do estado anterior
    Sn = vizinhoAleatorio(S);
    #calcula a tabela a partir dos novos pontos
    L_Sn = calculaTabelaCorrecao(Sn);
    #aplica a tabela no histograma original
    map_sn = map(L_Sn, Ha);
    #calcula a distância
    E_S = D(map_s, Hb);
    E_Sn = D(map_sn, Hb);
    #diferença entre o novo estado e o anterior
    delta = E_Sn - E_S;
    p = 0;
    if (delta < 0)
      p = 1.0;
    else
      #gera probabilidade para aceitar o estado pior
      p = exp(-delta / T);
    endif
    q = geraProbabilidade();
    if q < p
      #aceita o novo estado e substitui as variáveis
      map_s = map_sn;
      S = Sn;
      accepted = accepted + 1;
    endif
    #itera o epoch
    i = i + 1;
  endwhile
  #print estados aceitos para determinado histograma
  accepted
  L = calculaTabelaCorrecao(S);
endfunction

#função responsável por aplicar a tabela de correlação no histograma original
function mapped = map(correlacao, Ha)
  mapped = zeros(256, 1);
  for i = 1:256
      #'i' se transforma em 'value + 1'
      value = correlacao(i);
      mapped(i) = Ha(value+1);
  endfor
endfunction

#função responsável por gerar um número entre 0 e 1
function prob = geraProbabilidade()
  prob = rand();
endfunction

#função responsável por atualizar a temperatura
function temp = atualizaTemperatura(t)
  alfa = 0.95;
  temp = alfa * t;
endfunction

#função responsável por gerar a tabela de correlação
function tabela = calculaTabelaCorrecao(Sn)
  tabela = zeros(256, 1);
  #função LS -> resolve o sistema linear e retorna os coeficientes
  ls = LS([Sn(1,1); Sn(1,2)], [Sn(2,1); Sn(2,2)], [Sn(3,1); Sn(3,2)]);
  for i = 1:256
    #calcula a intensidade 'resp' para determinada intensidade 'i'
    resp = (ls(1) * ((i-1) ^ 2)) + (ls(2) * (i-1)) + (ls(3));
    if (resp > 255)
      tabela(i) = 255;
    else
      if (resp < 0)
        tabela(i) = 0;
      else
        tabela(i) = resp;
      endif
    endif
  endfor
  #realiza o arredondamento da tabela de correlação
  tabela = floor(tabela);
endfunction

#tabela responsável modificar os pontos utilizados para a geração
#da tabela de correlação.
function pontos = vizinhoAleatorio(s)
  pontos = s;
  flag = 1;
  while (flag == 1) #continua até gerar pontos válidos
    #gera número referente à coluna. e.g. (x, y)
    column = randi([1, 2]);
    #gera número referente a um dos três pontos
    row = randi([1, 3]);
    #gera número referente à operação a ser realizada (- ou +)
    op = randi([1,2]);
    if (op == 1)
      if (pontos(row, column) + 1 < 256) #verifica se o ponto é válido
        pontos(row, column) = pontos(row, column) + 1;
        flag = 0;
      endif
    else
      if (pontos(row, column) - 1 > -1) #verifica se o ponto é válido
        pontos(row, column) = pontos(row, column) - 1;
        flag = 0;
      endif
    endif
  endwhile
endfunction
