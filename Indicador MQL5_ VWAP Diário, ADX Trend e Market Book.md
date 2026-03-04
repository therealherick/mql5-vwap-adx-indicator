# Indicador MQL5: VWAP Diário, ADX Trend e Market Book

## Visão Geral

Este é um indicador profissional desenvolvido em MQL5 (MetaQuotes Language 5) para a plataforma MetaTrader 5. Ele integra três ferramentas de análise técnica e de fluxo de ordens essenciais para traders: o **VWAP (Volume Weighted Average Price) Diário**, o **ADX (Average Directional Index) Trend** e a visualização do **Market Book (Livro de Ofertas)**. O objetivo é fornecer uma visão consolidada da tendência, do preço médio ponderado pelo volume e da pressão de compra/venda em tempo real.

## Funcionalidades Principais

*   **VWAP Diário:** Calcula e exibe o Volume Weighted Average Price para o período diário, reiniciando a cada novo dia. Ajuda a identificar o preço médio de negociação de um ativo, ponderado pelo volume, sendo um importante nível de suporte/resistência e de decisão para traders institucionais.
*   **ADX Trend:** Apresenta o Average Directional Index em uma subjanela separada, indicando a força da tendência (ADX) e a direção da tendência (+DI e -DI). O indicador também exibe um status textual (ALTA, BAIXA, LATERAL) para facilitar a interpretação.
*   **Market Book (Livro de Ofertas):** Exibe a pressão de compra e venda (Book Sell e Book Buy) diretamente no gráfico principal, somando os volumes das 10 melhores ofertas de cada lado. Isso oferece uma visão rápida do fluxo de ordens e do sentimento do mercado.

## Tecnologias Utilizadas

*   **MQL5 (MetaQuotes Language 5):** Linguagem de programação orientada a objetos baseada em C++, utilizada para desenvolver indicadores técnicos e Expert Advisors (EAs) para a plataforma MetaTrader 5.

## Como Instalar

1.  **Baixe o arquivo:** Faça o download do arquivo `VWAP_Daily_ADX_Book_Fixed.mq5` deste repositório.
2.  **Abra o MetaEditor:** No MetaTrader 5, vá em `Arquivo > Abrir Pasta de Dados` e navegue até `MQL5 > Indicators`.
3.  **Cole o arquivo:** Copie o arquivo `VWAP_Daily_ADX_Book_Fixed.mq5` para a pasta `Indicators`.
4.  **Compile:** No MetaEditor, localize o arquivo na árvore de navegação e compile-o (F7).
5.  **Reinicie o MetaTrader 5:** Para garantir que o indicador seja carregado corretamente.

## Como Usar

1.  **Arraste e Solte:** No MetaTrader 5, abra um gráfico e arraste o indicador `VWAP_Daily_ADX_Book_Fixed` da janela `Navegador` para o gráfico.
2.  **Configurações:** Na janela de propriedades do indicador, você pode ajustar os seguintes parâmetros:
    *   `Price_Type`: Tipo de preço para cálculo (ex: CLOSE_HIGH_LOW).
    *   `Enable_Daily`: Ativar/desativar o cálculo do VWAP Diário.
    *   `ADX_Period`: Período do cálculo do ADX (padrão: 14).
    *   `Enable_Book`: Ativar/desativar a exibição do Market Book.
3.  **Visualização:** O indicador exibirá o VWAP Diário no gráfico principal, o ADX em uma subjanela e as informações do Market Book no canto inferior esquerdo do gráfico principal.

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues para sugestões de melhoria ou pull requests com novas funcionalidades ou correções. 

## Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes. (A ser adicionado posteriormente) 

## Autor

Herick Gomes

---
