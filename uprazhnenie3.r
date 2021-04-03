library('shiny')               # создание интерактивных приложений
library('lattice')             # графики lattice
library('data.table')          # работаем с объектами "таблица данных"
library('ggplot2')             # графики ggplot2
library('dplyr')               # трансформации данных
library('lubridate')           # работа с датами, ceiling_date()
library('zoo')                 # работа с датами, as.yearmon()

# API UN COMTRADE
source("https://raw.githubusercontent.com/aksyuk/R-data/master/API/comtrade_API.R")

# Получаем данные с UN COMTRADE за период 2010-2020 года, по следующим кодам
code = c('0801', '0802', '0803', '0804', '0805')
# Пустой дата фрейм
data = data.frame()
# Парсим данные с сайта
for (i in code){
  for (j in 2010:2020){
    Sys.sleep(5)
    s1 <- get.Comtrade(r = 'all', p = 643,
                       ps = as.character(j), freq = "M",
                       cc = i, fmt = 'csv')
    data <- rbind(data, s1$data)
  }
}

# Загружаем полученные данные в файл, чтобы не выгружать их в дальнейшем заново
file.name <- paste('./data/data_comtrade.csv', sep = '')
write.csv(data, file.name, row.names = FALSE)

write(paste('Файл', paste('data_comtrade.csv', sep = ''),
            'загружен', Sys.time()), file = './data/download.log', append=TRUE)

# Загружаем данные из файла
data <- read.csv('./data/data_comtrade.csv', header = T, sep = ',')

# Оставляем  только те столбцы, которые понядобятся в дальше
data <- data[, c(2, 8, 10, 22, 32)]

# СНГ без Белоруссии и Казахстана
country_1 = c('Armenia', 'Kyrgyzstan', 'Azerbaijan', 'Rep. of Moldova', 'Tajikistan', 'Turkmenistan', 'Uzbekistan', 'Ukraine')
# Таможенный союз России, Белоруссии и Казахстана
country_2 = c('Russian Federation', 'Belarus', 'Kazakhstan')

new.data <- data.frame(Year = numeric(), Trade.Flow = character(), Reporter = character(),
                       Trade.Value..US.. = numeric(), Group = character())

new.data <- rbind(new.data, cbind(data[data$Reporter %in% country_1, ], data.frame(Group = 'СНГ, без Казахстана и Беларуси')))
new.data <- rbind(new.data, cbind(data[data$Reporter %in% country_2, ], data.frame(Group = 'Таможенный союз, Россия, Казахстан, Беларусь')))
new.data <- rbind(new.data, cbind(data[!(data$Reporter %in% country_1) & !(data$Reporter %in% country_2), ], data.frame(Group = 'Остальные страны')))

new.data <- new.data[new.data$Trade.Value..US.. < 500000, ]

file.name <- paste('./data/data_comtrade_countries.csv', sep = '')
write.csv(new.data, file.name, row.names = FALSE)

new.data <- read.csv('./data/data_comtrade_countries.csv', header = T, sep = ',')

# Код продукта
filter.code <- as.character(unique(new.data$Commodity.Code))
names(filter.code) <- filter.code
filter.code <- as.list(filter.code)

# Торговые потоки
filter.trade.flow <- as.character(unique(new.data$Trade.Flow))
names(filter.trade.flow) <- filter.trade.flow
filter.trade.flow <- as.list(filter.trade.flow)

data.filter <- new.data[new.data$Commodity.Code == filter.code[1] & new.data$Trade.Flow == filter.trade.flow[2], ]
data.filter

ggplot(data = data.filter, aes(x = Trade.Value..US.., y = Group, group = Group, color = Group))+
  geom_boxplot() + coord_flip() + scale_color_manual(values = c('red', 'blue', 'yellow'),
                                                              name = 'Страны-поставщики') +
  labs(title = 'Коробчатые диаграммы разброса суммарной стоимости поставок по фактору\n "вхождение страны-поставщика в объединение"',
                x = 'Сумма стоимости поставок', y = 'Страны')

# Запуск приложения
runApp('./app', launch.browser = TRUE,
       display.mode = 'showcase')