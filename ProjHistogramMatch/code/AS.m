#TODO verificar se deve ser usado o negocio normalizado ou n, mas provavelmente nao faz diferença.
function L = AS(s0, t0, e, k, Ha, Hb)
  i = 0; #e = 10^-5
  S = s0; #k = 100
  T = t0; #T = 256
  accepted = 0;
  while (T > e)
    if (i == k)
      T = atualizaTemperatura(T);
      i = 0;
    endif
    #Sn = vizinhoAleatorio(S); #retorna os novos 3 pontos a partir do estado S
    Sn = vizinhoAleatorio(S);
    L_S = calculaTabelaCorrecao(S); #3 pontos -> tabela 1 x 256
    L_Sn = calculaTabelaCorrecao(Sn);#retorna tabela baseado no Ha
    map_s = map(L_S, Ha);
    map_sn = map(L_Sn, Ha);
    #Ha = map_s;
    E_S = D(map_s, Hb);
    E_Sn = D(map_sn, Hb);
    delta = E_Sn - E_S;
    p = 0; #inicializa p
    if (delta < 0)
      p = 1.0;
    %else
      %p = exp(-delta / T)
    %endif
    %q = geraProbabilidade();
    %if q < p
      S = Sn;
      accepted = accepted + 1;
    endif
    i = i + 1;
  endwhile
  accepted
  L = calculaTabelaCorrecao(S);
  L = map(L, Ha);
endfunction

function mapped = map(correlacao, Ha)
  mapped = (zeros(256, 1));
  correlacao = floor(correlacao);
  for i = 1:256
      value = correlacao(i);
      #if (index > -1 && index < 256)
      mapped(i) = Ha(value+1);
      #endif
  endfor
endfunction

function prob = geraProbabilidade()
  prob = rand();
endfunction

function temp = atualizaTemperatura(t)
  alfa = 0.75;
  temp = alfa * t;
endfunction

function tabela = calculaTabelaCorrecao(Sn)#retorna novo histograma
  tabela = zeros(256, 1);
  ls = LS([Sn(1,1); Sn(1,2)], [Sn(2,1); Sn(2,2)], [Sn(3,1); Sn(3,2)]); #solução do sistema linear
  a = ls(1);
  b = ls(2);
  c = ls(3);
  for i = 1:256 #ax2 + bx + c
    #tabela(i) = (ls(1) * (Ha(i) ^ 2)) + (ls(2) * Ha(i)) + ls(3);
    resp = 0;
    if (a != 0)
      resp = resp + (a * ((i-1) ^ 2));
      #tabela(i) = (ls(1) * ((i-1) ^ 2)) + (ls(2) * (i-1)) + ls(3)
    endif
    if (b != 0)
      resp = resp + (b * (i-1));
    endif
    if (c != 0)
      resp = resp + c;
    endif
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
endfunction

# recebe uma matriz, cada linha representa um ponto
# retorna a matriz com as novas posicoes
function new_positions = randomNeighbor(position)
# pacote para usar o randint
  allPossibilities = [[1,0];[-1,0];[0,1];[0,-1];[0,0]];
  new_positions = [[[0,0]];position;[[255,255]]];
  for i = 2:rows(new_positions)-1
    # gera um numero randomico de 0 a 5
    numRand = randint(1,1, [1 5]);
    temp = new_positions(i,:) + allPossibilities(numRand,:);
    resposta = temp < new_positions(i-1,1);
    resposta2 = temp > new_positions(i+1,1);
    if(resposta(1) || resposta(2))
      temp = new_positions(i-1,:);
    endif
    if(resposta2(1) || resposta2(2))
      temp = new_positions(i+1,:);
    endif
    new_positions(i,:) = temp;
  endfor
  # retorna as novas posicoes excluindo o primeiro e ultimo ponto
  new_positions = new_positions(2:rows(new_positions)-1,:);
endfunction

function pontos = vizinhoAleatorio(s)
  #pontos = zeros(3, 2);
  pontos = s;
  row = randi([1, 3]);
  column = randi([1, 2]);
  flag = 1;
  while (flag == 1)
    op = randi([1,2]); #1 == '+'; 2 == '-'
    if (op == 1)
      if (pontos(row, column) + 1 < 255)
        pontos(row, column) = pontos(row, column) + 1;
        flag = 0;
      endif
    else #op == 2
      if (pontos(row, column) - 1 > 0)
        pontos(row, column) = pontos(row, column) - 1;
        flag = 0;
      endif
    endif
  endwhile
endfunction
