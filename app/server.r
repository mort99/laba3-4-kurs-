library('shiny')
library('dplyr')
library('data.table')
library('RCurl')
library('ggplot2')
library('lattice')
library('zoo')
library('lubridate')

data <- read.csv('./data_comtrade_countries.csv', header = T, sep = ',')

data <- data.table(data)

shinyServer(function(input, output){
  DT <- reactive({
    DT <- data[between(Year, input$year.range[1], input$year.range[2]) &
                        Commodity.Code == input$sp.to.plot &
                        Trade.Flow == input$trade.to.plot, ]
    DT <- data.table(DT)
  })
  output$sp.ggplot <- renderPlot({
    gp <- ggplot(data = DT(), aes(x = Trade.Value..US.., y = Group, group = Group, color = Group))
    gp <- gp + geom_boxplot() + coord_flip() + scale_color_manual(values = c('red', 'blue', 'yellow'),
                                                                  name = 'Страны-поставщики')
    gp <- gp + labs(title = 'Коробчатые диаграммы разброса суммарной стоимости поставок по фактору "вхождение страны-поставщика в объединение"',
                    x = 'Сумма стоимости поставок', y = 'Страны')
    gp
  })
})