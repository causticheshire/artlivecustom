# artlivecustom

## Скрипт для сборки кастомного лайва на artix
Для сборки лайва качаем систему [отсюда](https://artixlinux.org/download.php).
Подойдет любая версия, для владеющих терминалом рекомендую base, остальным лучше plasma или xfce.
Записываем скачанный iso на флешку и устанавливаем на железо.
```
sudo dd if=/path/to/iso/file of=/dev/sdX
```
Запускаем установленную систему, подключаем к сети и запускаем команды
```
sudo pacman -Syyu --noconfirm
sudo pacman -S git --noconfirm
cd
git clone https://github.com/causticheshire/artlivecustom.git
```
### Работа со скриптом
Скрипт основан на buildiso от artix
Для запуска сборки используем следующие команды
```
cd artlivecustom
sudo bash hacnf.sh
```
После того как скрипт закончит свою работу будет выдана следующая команда в последней строке вида `buildiso -p "ваш профиль"`
Запоминаем ее и вводим следующее
```
sudo modprobe loop
sudo modprobe overlay
sudo reboot
```
Система перезагрузится с необходимыми модулями (возможно потребуется дополнительная перезагрузка, все зависит от системы и ее обновлений), после чего входим и вводим выданную выше команду, будет произведен процесс предварительной сборки для последующей работы.
Теперь редактируем файл pkgyay.conf	
```
cd artlivecustom
nano pkgyay.conf
```
В него в каждой отдельной строке помещаем названия необходимых пакетов из aur репозитория которые можно найти [тут](https://aur.archlinux.org/)
Далее вводим команду
```
sudo bash setrot.sh
```
Лайв собран, можно записывать, для записи вводим следующую команду
```
sudo bash flash.sh
```
Выбираем каким образом записываем на флешку (используя ventoy или обычная побитовая запись)
После записи можно вытаскивать флешку и использовать