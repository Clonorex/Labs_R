install.packages('Hmisc') 
install.packages('corrplot')
install.packages('knitr')
install.packages('nortest')
library('Hmisc') # для расчёта корреляционной матрицы
library('corrplot') # визуализация корреляционных матриц
library('knitr') # для генерации отчёта
library('nortest') # тест на нормальность: ad.test()
dir()
# импорт данных из .csv
file.path<-'данные.CSV'
DF<-read.csv2(file.path,stringsAsFactors = F)
dim(DF)
# структура фрейма
str(DF)
# делаем из столбца "FO" фактор
DF$FO <- as.factor(DF$FO)
str(DF)
# оставляем только регионы и выбрасываем столбец меток,
# чтобы удобнее было считать
reg.df <- DF[DF$Reg.code<1000,c(-1,-2)]
# выбрасываем пропущенные
reg.df <- na.omit(reg.df)
# первые пять строк фрейма
head(reg.df)
# последние пять строк фрейма
tail(reg.df)
# встроенная функция расчёта описательных статистик
summary(reg.df, digits = 2)
# средние арифметические
mns <- round(apply(reg.df[, -1], 2, mean), 1)

# стандартные отклонения
sds <- round(apply(reg.df[,-1], 2, sd), 1)

# коэффициенты вариации
coef.vars <- round(sds/mns*100, 1)


smm <- rbind(mns, sds, coef.vars) # соединить как строки
# названия статистик -- заголовки строк
row.names(smm) <- c('Среднее', 'Стандартное отклонение',
                    'Коэффициент вариации, %')
kable(smm)
# тест Андерсена на нормальность
ad.test(reg.df$y)
sapply(reg.df[, 2:6], ad.test)
 p.value  <- sapply(reg.df[, 2:6], function(x){
 round(t.test(x)$p.value , 4)
 })
st<- sapply(reg.df[, 2:6], function(x){
  round(ad.test(x)$statistic, 4)
})
table<-data.frame(st, p.value )
kable(table)
# строим гистограммы на одном полотне   
par(mfrow = c(3, 2)) # разбить полотно на 5 части, 3x2
par(oma = c(0, 0, 1.5, 0)) # внешние поля общего полотна
par(mar = c(4, 4, 0.5, 0.5)) # внутренние поля каждого графика
# цикл по номерам столбцов с количественными переменными
for (i in 2:6) {
  # данные -- i-ый столбец фрейма
  x <- reg.df[, i]
  hist(x, main = " ")
  lines(density(x), col="red", lwd =2)
  curve(dnorm(x, mean = mean(x), sd = sd(x)), col = "darkblue", lwd = 2, add = T)
}
# общий заголовок для всех графиков
title(main = 'гистограммы распределения показателей',
      outer = TRUE, cex = 1.5)
par(mfrow = c(1, 1)) # вернуть настройки обратно, 1x1

# графики взаимного разброса
pairs(reg.df[, -1], # фрейм без первого столбца-фактора
      pch = 21, # тип символов для точек
      col = rgb(0.5, 1, 1, alpha = 0.9), # цвет заливки точек
      bg = rgb(0, 0.5, 0, alpha = 0.4), # цвет границы точек
      cex = 1.1) # масштаб символов для точек

# Корреляционная матрица  ======================================================

# коэффициенты Пирсона с P-значениями
rcorr(as.matrix(reg.df[, -1]))


# Визуализация корреляционной матрицы  =========================================

# сохраняем корреляционную матрицу
matrix.cor <- cor(reg.df[, -1])

# сохраняем p-значения
matrix.p <- rcorr(as.matrix(reg.df[, -1]))$P

# изображаем матрицу графически
corrplot(matrix.cor,  method = "ellipse",         # сама корреляционная матрица
         order = 'original',  # порядок отображения показателей 
         # в матрице
         diag = F,            # не отображать значения на главной 
         # диагонали
         p.mat = matrix.p,    # p-значения
         insig = 'blank',     # метод отображения незначимых
         sig.level = 0.005)    # уровень значимости

##логарифмируем данные:==============================================
lg <- reg.df
lg$y <- log(reg.df$y)
lg$x1 <- log(reg.df$x1)
lg$x2 <- log(reg.df$x2)
lg$x3 <- log(reg.df$x3)
lg$x4 <- log(reg.df$x4)
#описательна ястатистикаа
# средние арифметические
mns1 <- round(apply(lg[, -1], 2, mean), 4)
# стандартные отклонения
sds1 <- round(apply(lg[,-1], 2, sd), 4)
# коэффициенты вариации
coef.vars1 <- round(sds1/mns1*100, 4)
coef.vars1

smm1 <- rbind(mns1, sds1, coef.vars1) # соединить как строки
# названия статистик -- заголовки строк
row.names(smm1) <- c('Среднее', 'Стандартное отклонение',
                     'Коэффициент вариации, %')
kable(smm1)
# статистические тесты
ad.test(lg$y)
sapply(lg[, 2:6], ad.test)
p.value1 <- sapply(lg[, 2:6], function(x){
  round(t.test(x)$p.value, 4)
})
st1<- sapply(lg[, 2:6], function(x){
  round(ad.test(x)$statistic, 4)
})
table1<-data.frame(st1, p.value1)
kable(table1)
#строим гистограмму 
# строим гистограммы на одном полотне
par(mfrow = c(3, 2)) # разбить полотно на 5 части, 3x2
par(oma = c(0, 0, 1.5, 0)) # внешние поля общего полотна
par(mar = c(4, 4, 0.5, 0.5)) # внутренние поля каждого графика
# цикл по номерам столбцов с количественными переменными
for (i in 2:6) {
  # данные -- i-ый столбец фрейма
  x <- lg[, i]
  hist(x, main = " ")
  lines(density(x), col="red", lwd =2)
  curve(dnorm(x, mean = mean(x), sd = sd(x)), col = "darkblue", lwd = 2, add = T)
}
# общий заголовок для всех графиков
title(main = ' Гистограммы распределения логарифмов показателей',
      outer = TRUE, cex = 1.5)
par(mfrow = c(1, 1)) # вернуть настройки обратно, 1x1

# графики взаимного разброса
pairs(lg[, -1], # фрейм без первого столбца-фактора
      pch = 21, # тип символов для точек
      col = rgb(0.5, 1, 1, alpha = 0.9), # цвет заливки точек
      bg = rgb(0, 0.5, 0, alpha = 0.4), # цвет границы точек
      cex = 1.1) # масштаб символов для точек

# Корреляционная матрица  ======================================================

# коэффициенты Пирсона с P-значениями
rcorr(as.matrix(lg[, -1]))


# Визуализация корреляционной матрицы  =========================================

# сохраняем корреляционную матрицу
matrix.cor1 <- cor(lg[, -1])

# сохраняем p-значения
matrix.p1 <- rcorr(as.matrix(lg[, -1]))$P

# изображаем матрицу графически
corrplot(matrix.cor1, method = "ellipse",       # сама корреляционная матрица
         order = 'original',  # порядок отображения показателей 
         # в матрице
         diag = F,            # не отображать значения на главной 
         # диагонали
         p.mat = matrix.p1,    # p-значения
         insig = 'blank',     # метод отображения незначимых
         sig.level = 0.005)    # уровень значимости

# 5. Сохранение рабочего пространства  ------------------------------------------

# список объектов в памяти
ls()
# сохраняем нужные объекты в файл
save(list = c('DF', 'reg.df', 'lg'), file = './лаб_1.RData')

