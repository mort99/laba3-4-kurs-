library('shiny')
library('RCurl')

data <- read.csv('./data_comtrade_countries.csv', header = T, sep = ',')

# Торговые потоки, переменная для фильтра фрейма
filter.trade.flow <- as.character(unique(data$Trade.Flow))
names(filter.trade.flow) <- filter.trade.flow
filter.trade.flow <- as.list(filter.trade.flow)

shinyUI(
  pageWithSidebar(
    headerPanel("Коробчатые диаграммы разброса суммарной стоимости поставок по фактору «вхождение страны-поставщика в объединение»"),
    sidebarPanel(
      # Выбор кода продукции
      selectInput('sp.to.plot',
                  'Выберите код продукта',
                  list('Орехи съедобные; кокосы, бразильские орехи и орехи кешью, свежие или сушеные, очищенные или неочищенные или неочищенные' = '801',
                       'Орехи (за исключением кокосов, бразильских орехов и орехов кешью); свежие или сушеные, очищенные или неочищенные' = '802',
                       'Бананы, в том числе подорожники; свежий или сушеный' = '803',
                       'Финики, инжир, ананасы, авокадо, гуава, манго и мангустины; свежий или сушеный' = '804',
                       'Цитрусовый фрукт; свежий или сушеный' = '805'),
                  selected = '801'),
      # Товарный поток
      selectInput('trade.to.plot',
                  'Выберите торговый поток:',
                  filter.trade.flow),
      # Период
      sliderInput('year.range', 'Года:',
                  min = 2010, max = 2020, value = c(2010, 2020),
                  width = '100%', sep = '')
    ),
    mainPanel(
      plotOutput('sp.ggplot')
    )
  )
)