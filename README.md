# artlivecustom

## Скрипт для сборки кастомного лайва на artix
##### Скачиваем стандартную систему artix
Для сборки лайва качаем систему [отсюда](https://artixlinux.org/download.php).
![Загрузка с офф сайта](https://github.com/causticheshire/artlivecustom/blob/main/download.jpg)
Подойдет любая версия, для владеющих терминалом рекомендую [base](https://eu-mirror.artixlinux.org/iso/artix-base-openrc-20210426-x86_64.iso) (самая легковесная, но требует опыта и знаний), остальным лучше [plasma](https://iso.artixlinux.org/iso/artix-plasma-openrc-20210426-x86_64.iso) (для бывших пользователей винды) или [xfce](https://eu-mirror.artixlinux.org/iso/artix-xfce-openrc-20210426-x86_64.iso) (легковесная с графическим окружением).
##### Записываем скачанный iso на флешку.
Вводим в терминале:
```
lsblk
```
Вставляем флешку и вводим команду выше еще раз.
Смотрим разницу между вводами и находим свою вставленную флешку, название флешки используем в команде для записи образа на флешку.
![Нахождение флешки](https://github.com/causticheshire/artlivecustom/blob/main/lsblk.jpg)
Теперь заходим в папку со скачанным образом и нажимаем ПКМ в файловом менеджере и выбираем пункт контекстного меню "Открыть терминал здесь"
![Открытие терминала](https://github.com/causticheshire/artlivecustom/blob/main/terminalhere.jpg)
Далее вводим команду на запись образа на флешку. Команды вводимые через `sudo` требуют ввода пароля пользователя для выполнения действий.
Пример:
`sudo dd if=artix-openrc.iso of=/dev/sda`
Стандарт команды:
```
sudo dd if=/путь/к/скачанному/iso/образу of=/dev/sdX
```
##### Устанавливаем систему на компьютер
Вставляем записанную флешку в компьютер, включаем компьютер, заходим в биос (у каждого компьютера он различается, ищется в гугле), запускаемся с флешки и устанавливаем систему следуя всем указаниям установщика ([хомячье видео](https://www.youtube.com/watch?v=J5KrJjcTY90)).
Выключаем компьютер, вытаскиваем флешку и запускаем компьютер снова.
Подключаем систему к сети, открываем терминал (CTRL+ALT+T) и запускаем команды:
```
sudo pacman -Syyu --noconfirm
sudo pacman -S git --noconfirm
cd
git clone https://github.com/causticheshire/artlivecustom.git
```
### Работа со скриптом
Для запуска сборки используем следующие команды
```
cd artlivecustom
sudo bash hacnf.sh
```
Выбираем графическую оболочку для сборки, рекомендую xfce для калькуляторов:
![Профиль](https://github.com/causticheshire/artlivecustom/blob/main/profile.jpg)
Выбираем включение/выключение автоматического входа в систему:
![Автологин](https://github.com/causticheshire/artlivecustom/blob/main/autologin.jpg)
Устанавливаем пароль для системы:
![Пароль](https://github.com/causticheshire/artlivecustom/blob/main/pass.jpg)

После того как скрипт закончит свою работу будет выдана следующая команда в последней строке вида `buildiso -p "ваш профиль"`
![Пример команды](https://github.com/causticheshire/artlivecustom/blob/main/example.jpg)
Запоминаем ее и вводим следующее:
```
sudo modprobe loop
sudo modprobe overlay
sudo reboot
```
Система перезагрузится с необходимыми модулями (возможно потребуется дополнительная перезагрузка и выполнение команды из блока выше, все зависит от системы и ее обновлений), после чего входим и вводим выданную выше команду, будет произведен процесс предварительной сборки для последующей работы.
В сборке есть возможность добавить пакеты из aur репозитория, для этого выбираем нужный пакет [тут](https://aur.archlinux.org/packages/), из столбца `name` название добавить в файл `pkgyay.conf`.
![AUR](https://github.com/causticheshire/artlivecustom/blob/main/aur.jpg)
```
cd artlivecustom
nano pkgyay.conf
```
В него в каждой отдельной строке помещаем названия необходимых пакетов из aur репозитория.
Сохраняем, выходим.
Далее вводим команду:
```
sudo bash setrot.sh
```
Лайв собран, можно записывать, для записи вводим следующую команду
```
sudo bash flash.sh
```
Выбираем каким образом записываем на флешку (используя ventoy или обычная побитовая запись)
После записи можно вытаскивать флешку и использовать