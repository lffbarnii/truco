program BaralhoDeTruco;

type
  TCarta = record
    nome: string;
    pontuacao_carta: integer;
    naipe: string;
    pontuacao_naipe: integer;
  end;

  TBaralho = record
    cartas: array[1..40] of TCarta;
    tamanho_maximo: integer;
    topo: integer;
  end;
  
  TMao = record
    cartas: array[1..3] of TCarta;
    tamanho_maximo: integer;
    ponteiro: integer;
  end;
  
  TMesa = record
    cartas: array[1..2] of TCarta;
    tamanho_maximo: integer;
    topo: integer;
    jogador_maior_carta: integer;
    maior_carta: TCarta;
  end;
  
  TRodada = record
    anterior_empachou : boolean;
    vitorias_jogador_1: integer;
    vitorias_jogador_2: integer;
    valor_rodada: integer;
    primeiro_jogador: integer;
  end;
  
  TPartida = record
    pontuacao_jogador_1: integer;
    pontuacao_jogador_2: integer
  end;
  
function compararCarta(carta1, carta2: TCarta; valor_manilha: integer): integer;
begin
  //Se as duas cartas são manilhas, o desempate é pelo naipe
  if (carta1.pontuacao_carta = valor_manilha) and (carta2.pontuacao_carta = valor_manilha) then
  begin
    if carta1.pontuacao_naipe > carta2.pontuacao_naipe then
      compararCarta := 1
    else
      compararCarta := 0; 
  end
  
  //Se apenas a primeira carta é manilha, retorna 1
  else if (carta1.pontuacao_carta = valor_manilha) then
  begin
    compararCarta := 1;
  end
  
  //Se apenas a segunda é manilha, retorna 0
  else if (carta2.pontuacao_carta = valor_manilha) then
  begin
    compararCarta := 0;
  end
  
  //Nenhuma é manilha: compara o valor das cartas e, em caso de empate, retorna -1
  else if carta1.pontuacao_carta = carta2.pontuacao_carta then
    compararCarta := -1
  else if carta1.pontuacao_carta > carta2.pontuacao_carta then
    compararCarta := 1
  else if carta1.pontuacao_carta < carta2.pontuacao_carta then
    compararCarta := 0;
end;

function retirarCarta(var baralho: TBaralho): TCarta;
begin
  //Não precisamos verificar se o baralho está vazio pois o baralho tem 40
  //cartas, e vamos tirar no máximo 7 (3 em cada mão mais 1 manilha)

  //retorna a carta do topo do baralho
  retirarCarta := baralho.cartas[baralho.topo];

  //atualiza o topo do baralho para ser a carta abaixo da carta retirada
  baralho.topo := baralho.topo - 1;
end;

procedure embaralhar(var baralho: TBaralho);
var
  i, posAleatoria: integer;
  cartaTemp: TCarta;
begin
  //itera do topo até a penultima carta
  for i := baralho.topo downto 2 do
  begin
  
    //gera um número entre a carta atual e 1
    posAleatoria := random(i) + 1;
    
    //armazena a carta atual temporariamente
    cartaTemp := baralho.cartas[i];
    
    //Troca a carta na posição atual com a carta da posição no número aleatório gerado
    baralho.cartas[i] := baralho.cartas[posAleatoria];
    baralho.cartas[posAleatoria] := cartaTemp;
  end;
end;

procedure cortarBaralho(var baralho: TBaralho);
var
  corte, i, indiceTemp: integer;
  cartasTemp: array[1..40] of TCarta;
begin
  corte := random(baralho.topo) + 1;

  //se o corte cair no topo a ordem não muda
  if corte < baralho.topo then
  begin
    indiceTemp := 1;

    //cartas acima do corte vão pro fundo do baralho
    for i := corte + 1 to baralho.topo do
    begin
      cartasTemp[indiceTemp] := baralho.cartas[i];
      indiceTemp := indiceTemp + 1;
    end;

    //depois é só ir adicionando cartas abaixo do corte ao baralho
    for i := 1 to corte do
    begin
      cartasTemp[indiceTemp] := baralho.cartas[i];
      indiceTemp := indiceTemp + 1;
    end;

    //passa as cartas do baralho temporário pro baralho original
    for i := 1 to baralho.topo do
    begin
      baralho.cartas[i] := cartasTemp[i];
    end;
  end;
end;

procedure mostrarBaralho(baralho: TBaralho);
var
  i: integer;
begin
  writeln('--- CARTAS NO BARALHO ---');
  
  //verifica se o baralho está vazio
  if baralho.topo = 0 then
  begin
    writeln('O baralho esta vazio!');
  end
  else
  begin
    //itera do topo até o fundo do baralho
    for i := baralho.topo downto 1 do
    begin
      //printa o nome da carta junto com o naipe
      writeln(baralho.cartas[i].nome, ' de ', baralho.cartas[i].naipe);
    end;
  end;
  
  writeln('-------------------------');
end;

function escolherCartaFromMao(var mao: TMao; posicao: integer): TCarta;
var
  i: integer;
begin
    //Escolhe a carta na posição informada e armazena para retornar
    escolherCartaFromMao := mao.cartas[posicao];
    
    //Para cada carta da posição escolhida até a penultima carta:
    for i := posicao to (mao.ponteiro - 1) do
    begin
      //A carta atual é igual a próxima (reorganiza o array)    
      mao.cartas[i] := mao.cartas[i + 1];
    end;
    
    //Como uma carta foi retirada da mão, diminui 1 do ponteiro
    mao.ponteiro := mao.ponteiro - 1;
end;

function definirMaoInicial(var baralho: TBaralho): TMao;
var
  mao: TMao;
  i: integer;
begin
  //Toda mão vai começar com 3 cartas
  mao.ponteiro := 3;
  
  //Para cada posição na mão
  for i := 1 to 3 do
  begin
    //Pega uma carta no baralho
    mao.cartas[i] := retirarCarta(baralho);
  end;
  
  definirMaoInicial := mao;
end;

procedure colocarCartaNaMesa(var mesa: TMesa; carta: TCarta);
begin
  //Adiciona um ao contador do topo do baralho
  mesa.topo := mesa.topo + 1;
  
  //Adiciona a carta informada ao topo do baralho
  mesa.cartas[mesa.topo] := carta;
end;

function criarBaralho(): TBaralho;
var
  baralho: TBaralho;
  nomesCartas: array[1..10] of string;
  nomesNaipes: array[1..4] of string;
  i, j: integer;
begin
  //Define os nomes das cartas
  nomesCartas[1] := '4';
  nomesCartas[2] := '5';
  nomesCartas[3] := '6';
  nomesCartas[4] := '7';
  nomesCartas[5] := 'Q';
  nomesCartas[6] := 'J';
  nomesCartas[7] := 'K';
  nomesCartas[8] := 'As';
  nomesCartas[9] := '2';
  nomesCartas[10] := '3';
  
  //Define os nomes dos naipes
  nomesNaipes[1] := 'Ouros';
  nomesNaipes[2] := 'Espadas';
  nomesNaipes[3] := 'Copas';
  nomesNaipes[4] := 'Paus';

  //O tamanho máximo sempre vai ser 40
  baralho.tamanho_maximo := 40;
  //O topo sempre começa em 0
  baralho.topo := 0;

  //Para cada naipe
  for i := 1 to 4 do
  begin
    //Para cada carta
    for j := 1 to 10 do
    begin
      //Aumenta 1 no contador do topo
      baralho.topo := baralho.topo + 1;
      
      //Define informações da carta
      baralho.cartas[baralho.topo].nome := nomesCartas[j];
      baralho.cartas[baralho.topo].pontuacao_carta := j;

      baralho.cartas[baralho.topo].naipe := nomesNaipes[i];
      baralho.cartas[baralho.topo].pontuacao_naipe := i;
    end;
  end;
  
  criarBaralho := baralho;
end;

function definirManilha(var baralho: TBaralho): integer;
var
  manilha: integer;
begin
    //Tira uma carta e salva o valor dela
    manilha := retirarCarta(baralho).pontuacao_carta;
    
    //Se for a maior carta (3) etão a manilha é a menor carta (4)
    if manilha = 10 then
      manilha := 1
    //Se não, é a carta tirada +1  
    else
      manilha := manilha + 1;
      
    definirManilha := manilha;
end;

//Jogador Joga carta
function jogador_joga_carta(var mao: TMao): TCarta;
var
  i, escolha: integer;
begin
  writeln;
  writeln('--- SUA MAO ---');
  
  // Exibe as cartas que o jogador tem no momento
  for i := 1 to mao.ponteiro do
    writeln(i, ': ', mao.cartas[i].nome, ' de ', mao.cartas[i].naipe);
  writeln('---------------');
  
  // Solicita a escolha do usuário baseada nos índices (1, 2 ou 3)
  write('Escolha a carta (1 a ', mao.ponteiro, '): ');
  readln(escolha);
  
  //Impede que o jogador escolha um número inexistente ou uma carta que já jogou
  while (escolha < 1) or (escolha > mao.ponteiro) do
  begin
    write('Invalido! Escolha de 1 a ', mao.ponteiro, ': ');
    readln(escolha);
  end;
  
  // Chama a função que remove a carta da mão e reorganiza o array, retornando a carta escolhida
  jogador_joga_carta := escolherCartaFromMao(mao, escolha);
end;

function bot_joga_carta(var mao: TMao): TCarta;
var
  escolha: integer;
  carta: TCarta;
begin
  // O bot escolhe uma posição aleatória entre 1 e o número de cartas que ele tem
  escolha := random(mao.ponteiro) + 1;
  
  // Remove a carta da mão do bot
  carta := escolherCartaFromMao(mao, escolha);
  
  // Informa ao jogador qual foi a jogada do oponente
  writeln('-> O Bot jogou: ', carta.nome, ' de ', carta.naipe);
  bot_joga_carta := carta;
end;

procedure jogo(primeiro_jogador: integer);
var
  rodada: TRodada;
  partida: TPartida;
  baralho: TBaralho;
  manilha: integer;
  i: integer;
  mao_jogador, mao_bot: TMao;
  carta_jogador, carta_bot: TCarta;
begin
  // Inicializa o placar da partida
  partida.pontuacao_jogador_1 := 0;
  partida.pontuacao_jogador_2 := 0;
  rodada.anterior_empachou := false;
  rodada.primeiro_jogador := primeiro_jogador;
    
  // O jogo continua até que alguém atinja 12 pontos
  while (partida.pontuacao_jogador_1 < 12) and (partida.pontuacao_jogador_2 < 12) do
  begin
    // Preparação de uma nova rodada: criar, embaralhar e cortar
    baralho := criarBaralho();
    embaralhar(baralho);
    cortarBaralho(baralho);
    
    // Distribui 3 cartas para cada um e define a manilha da vez
    mao_jogador := definirMaoInicial(baralho);
    mao_bot := definirMaoInicial(baralho);
    manilha := definirManilha(baralho);
    
    writeln;
    writeln('*** NOVA RODADA | MANILHA DO VALOR: ', manilha, ' ***');
    
    // Cada rodada de Truco tem 3 "vazas" (turnos)
    for i := 1 to 3 do
    begin
      // Define a ordem de quem joga primeiro baseada em quem ganhou a anterior
      if rodada.primeiro_jogador = 1 then
      begin
        carta_jogador := jogador_joga_carta(mao_jogador);
        carta_bot := bot_joga_carta(mao_bot);
      end
      else
      begin
        carta_bot := bot_joga_carta(mao_bot);
        carta_jogador := jogador_joga_carta(mao_jogador);
      end;
      
      // Compara as duas cartas jogadas e mostra o resultado da vaza
      if compararCarta(carta_jogador, carta_bot, manilha) = 1 then
        writeln('>> Voce ganhou esta vaza!')
      else if compararCarta(carta_jogador, carta_bot, manilha) = 0 then
        writeln('>> O Bot ganhou esta vaza!')
      else
        writeln('>> Empachou!');
    end;
    
    { Exemplo de pontuação para teste }
    partida.pontuacao_jogador_1 := partida.pontuacao_jogador_1 + 1; 
    writeln('Placar: Voce ', partida.pontuacao_jogador_1, ' x ', partida.pontuacao_jogador_2, ' Bot');
  end;
end;

var
  primeiro: integer;
begin
  randomize;
  primeiro := random(2) + 1;
  jogo(primeiro);
end.
